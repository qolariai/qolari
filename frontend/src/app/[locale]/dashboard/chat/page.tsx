"use client";

import { useTranslations } from "next-intl";
import {
  useQuery,
  useQueryClient,
  useInfiniteQuery,
} from "@tanstack/react-query";
import {
  api,
  API_URL,
  type ChatConversation,
  type ChatMessage,
  type Paginated,
  type SubscriptionState,
} from "@/lib/api";
import { Link } from "@/i18n/navigation";
import { buttonVariants } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";
import { cn } from "@/lib/utils";
import { useCallback, useEffect, useRef, useState } from "react";
import { MessageSquare, Plus, Send, Square, Trash2, Zap, Menu, X } from "lucide-react";

export default function ChatPage() {
  const t = useTranslations();

  const { data: subData, isLoading } = useQuery({
    queryKey: ["subscription"],
    queryFn: () =>
      api.get<{ subscription: SubscriptionState | null }>("/v1/subscription"),
  });

  if (isLoading) {
    return (
      <div className="flex h-[calc(100dvh-7rem)] lg:h-[calc(100dvh-4rem)] items-center justify-center">
        <p className="text-muted-foreground">{t("common.loading")}</p>
      </div>
    );
  }

  // Sem subscrição ativa → paywall (mesmo estado de um 402)
  if (!subData?.subscription) {
    return (
      <div className="flex h-[calc(100dvh-7rem)] lg:h-[calc(100dvh-4rem)] items-center justify-center">
        <Card className="max-w-md w-full">
          <CardContent className="pt-6 text-center space-y-4">
            <div className="flex justify-center">
              <div className="rounded-full bg-primary/10 p-3">
                <MessageSquare className="h-6 w-6 text-primary" />
              </div>
            </div>
            <h2 className="text-xl font-semibold">{t("chat.paywallTitle")}</h2>
            <p className="text-sm text-muted-foreground">
              {t("chat.paywallDesc")}
            </p>
            <Link
              href="/pricing#chat-plans"
              className={cn(buttonVariants(), "w-full")}
            >
              {t("chat.viewPlans")}
            </Link>
          </CardContent>
        </Card>
      </div>
    );
  }

  return <ChatApp subscription={subData.subscription} />;
}

// ---------------------------------------------------------------------
// App de chat (só com subscrição ativa)
// ---------------------------------------------------------------------

function ChatApp({ subscription }: { subscription: SubscriptionState }) {
  const t = useTranslations();
  const queryClient = useQueryClient();

  const [selectedId, setSelectedId] = useState<number | null>(null);
  const [mobileListOpen, setMobileListOpen] = useState(false);
  const [input, setInput] = useState("");
  const [localMessages, setLocalMessages] = useState<ChatMessage[]>([]);
  const [streamText, setStreamText] = useState<string | null>(null);
  const [streamError, setStreamError] = useState<string | null>(null);
  const [isStreaming, setIsStreaming] = useState(false);
  const [ceiling, setCeiling] = useState(false);
  const [throttledLive, setThrottledLive] = useState(false);
  const abortRef = useRef<AbortController | null>(null);
  const scrollRef = useRef<HTMLDivElement | null>(null);
  const textareaRef = useRef<HTMLTextAreaElement | null>(null);
  // Conversa selecionada + conversas criadas nesta sessão (o histórico
  // dessas vive só em localMessages até recarregar a página)
  const selectedIdRef = useRef<number | null>(null);
  const sessionCreatedRef = useRef<Set<number>>(new Set());

  // O estado da subscrição acaba de ser revalidado → o flag live do header
  // X-Qolari-Throttled volta a ser decidido pelo servidor
  useEffect(() => {
    setThrottledLive(false);
  }, [subscription.throttled, subscription.tokens_used]);

  const resetThreadState = () => {
    setLocalMessages([]);
    setStreamText(null);
    setStreamError(null);
    setCeiling(false);
    setInput("");
  };

  const selectConversation = (id: number | null) => {
    abortRef.current?.abort();
    resetThreadState();
    selectedIdRef.current = id;
    setSelectedId(id);
  };

  const conversationsQuery = useInfiniteQuery({
    queryKey: ["chat-conversations"],
    queryFn: ({ pageParam }) =>
      api.get<Paginated<ChatConversation>>(
        `/v1/chat/conversations?page=${pageParam}`
      ),
    initialPageParam: 1,
    getNextPageParam: (last) =>
      last.current_page < last.last_page ? last.current_page + 1 : undefined,
  });
  const conversations =
    conversationsQuery.data?.pages.flatMap((page) => page.data) ?? [];

  const historyEnabled =
    selectedId !== null && !sessionCreatedRef.current.has(selectedId);
  const { data: historyMessages, isLoading: historyLoading } = useQuery({
    queryKey: ["chat-messages", selectedId],
    enabled: historyEnabled,
    refetchOnWindowFocus: false,
    refetchOnReconnect: false,
    queryFn: async () => {
      // Histórico paginado (50/página) — carrega tudo para o thread
      const all: ChatMessage[] = [];
      let page = 1;
      for (;;) {
        const res = await api.get<Paginated<ChatMessage>>(
          `/v1/chat/conversations/${selectedId}/messages?page=${page}`
        );
        all.push(...res.data);
        if (page >= res.last_page) break;
        page++;
      }
      return all;
    },
  });

  const messages = [...(historyMessages ?? []), ...localMessages];

  // Auto-scroll com novas mensagens / tokens em streaming
  useEffect(() => {
    const el = scrollRef.current;
    if (el) el.scrollTop = el.scrollHeight;
  }, [messages.length, streamText]);

  const handleNewConversation = () => {
    selectConversation(null);
    setMobileListOpen(false);
  };

  const handleDeleteConversation = async (id: number) => {
    try {
      await api.delete(`/v1/chat/conversations/${id}`);
      if (selectedId === id) selectConversation(null);
      queryClient.invalidateQueries({ queryKey: ["chat-conversations"] });
    } catch {
      // ignorar — lista volta a sincronizar
    }
  };

  const handleSend = useCallback(
    async (raw: string) => {
      const content = raw.trim();
      if (!content || isStreaming || ceiling) return;
      setInput("");
      if (textareaRef.current) textareaRef.current.style.height = "auto";

      // Garante que existe conversa (cria sem título — o servidor define)
      let convId = selectedId;
      if (!convId) {
        try {
          const data = await api.post<{ conversation: ChatConversation }>(
            "/v1/chat/conversations",
            {}
          );
          convId = data.conversation.id;
          sessionCreatedRef.current.add(convId);
          selectedIdRef.current = convId;
          setSelectedId(convId);
          queryClient.invalidateQueries({ queryKey: ["chat-conversations"] });
        } catch {
          setStreamError(t("chat.errorGeneric"));
          setInput(content);
          return;
        }
      }

      // Mensagem do utilizador (otimista — o servidor persiste antes da resposta)
      setLocalMessages((prev) => [
        ...prev,
        {
          id: -Date.now(),
          role: "user",
          content,
          tokens: null,
          created_at: new Date().toISOString(),
        },
      ]);
      setIsStreaming(true);
      setStreamText("");
      setStreamError(null);

      const controller = new AbortController();
      abortRef.current = controller;
      const targetId = convId;

      let acc = "";
      let sawErrorFrame = false;

      try {
        const token = api.getToken();
        const res = await fetch(
          `${API_URL}/v1/chat/conversations/${convId}/messages`,
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              Accept: "text/event-stream",
              ...(token ? { Authorization: `Bearer ${token}` } : {}),
            },
            body: JSON.stringify({ content, stream: true }),
            signal: controller.signal,
          }
        );

        if (!res.ok) {
          let code = "";
          try {
            const data = await res.json();
            code = data?.error?.code ?? "";
          } catch {
            // corpo não-JSON
          }
          if (res.status === 402 || code === "subscription_required") {
            // Paywall: o estado da subscrição é revalidado e a página muda
            queryClient.invalidateQueries({ queryKey: ["subscription"] });
            return;
          }
          if (res.status === 429 || code === "token_ceiling_exceeded") {
            setCeiling(true);
            return;
          }
          setStreamError(t("chat.errorGeneric"));
          return;
        }

        // Acima do soft limit do plano → modo mais lento (header do backend)
        if (res.headers.get("X-Qolari-Throttled") === "1") {
          setThrottledLive(true);
        }

        const reader = res.body?.getReader();
        if (!reader) throw new Error("stream unavailable");
        const decoder = new TextDecoder();
        let buffer = "";

        for (;;) {
          const { done, value } = await reader.read();
          if (done) break;
          buffer += decoder.decode(value, { stream: true });

          let sep: number;
          while ((sep = buffer.indexOf("\n\n")) !== -1) {
            const frame = buffer.slice(0, sep);
            buffer = buffer.slice(sep + 2);

            for (const line of frame.split("\n")) {
              if (!line.startsWith("data:")) continue; // ignora "event:" etc.
              const payload = line.slice(5).trim();
              if (payload === "" || payload === "[DONE]") continue;
              try {
                const parsed = JSON.parse(payload);
                if (parsed?.error) {
                  sawErrorFrame = true;
                  continue;
                }
                const delta = parsed?.choices?.[0]?.delta?.content;
                if (typeof delta === "string") {
                  acc += delta;
                  setStreamText(acc);
                }
              } catch {
                // frame malformado — ignorar
              }
            }
          }
        }

        if (sawErrorFrame || acc === "") {
          setStreamError(t("chat.errorUpstream"));
        } else if (selectedIdRef.current === targetId) {
          setLocalMessages((prev) => [
            ...prev,
            {
              id: -Date.now() - 1,
              role: "assistant",
              content: acc,
              tokens: null,
              created_at: new Date().toISOString(),
            },
          ]);
        }
      } catch (err) {
        if ((err as Error)?.name === "AbortError") {
          // Parado pelo utilizador: mantém o texto parcial já recebido
          if (acc !== "" && selectedIdRef.current === targetId) {
            setLocalMessages((prev) => [
              ...prev,
              {
                id: -Date.now() - 1,
                role: "assistant",
                content: acc,
                tokens: null,
                created_at: new Date().toISOString(),
              },
            ]);
          }
        } else {
          setStreamError(t("chat.errorGeneric"));
        }
      } finally {
        setStreamText(null);
        setIsStreaming(false);
        abortRef.current = null;
        queryClient.invalidateQueries({ queryKey: ["chat-conversations"] });
        queryClient.invalidateQueries({ queryKey: ["subscription"] });
      }
    },
    [selectedId, isStreaming, ceiling, queryClient, t]
  );

  const handleStop = () => {
    abortRef.current?.abort();
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      handleSend(input);
    }
  };

  const autoResize = () => {
    const el = textareaRef.current;
    if (!el) return;
    el.style.height = "auto";
    el.style.height = Math.min(el.scrollHeight, 160) + "px";
  };

  const conversationList = (
    <>
      <div className="p-3 border-b">
        <button
          onClick={handleNewConversation}
          className={cn(buttonVariants(), "w-full")}
        >
          <Plus className="h-4 w-4 mr-1" />
          {t("chat.newConversation")}
        </button>
      </div>
      <div className="flex-1 overflow-y-auto p-2 space-y-1">
        {conversations.length === 0 && (
          <p className="text-center text-sm text-muted-foreground py-6 px-2">
            {t("chat.conversationsEmpty")}
          </p>
        )}
        {conversations.map((conversation) => (
          <div
            key={conversation.id}
            className={cn(
              "group flex items-center gap-2 rounded-lg px-3 py-2 cursor-pointer text-sm transition-colors",
              selectedId === conversation.id
                ? "bg-primary text-primary-foreground"
                : "hover:bg-muted"
            )}
            onClick={() => {
              selectConversation(conversation.id);
              setMobileListOpen(false);
            }}
          >
            <div className="flex-1 min-w-0">
              <p className="truncate font-medium">
                {conversation.title || t("chat.untitled")}
              </p>
              <p
                className={cn(
                  "text-xs",
                  selectedId === conversation.id
                    ? "text-primary-foreground/70"
                    : "text-muted-foreground"
                )}
              >
                {new Date(conversation.updated_at).toLocaleDateString()}
              </p>
            </div>
            <AlertDialog>
              <AlertDialogTrigger
                className={cn(
                  "opacity-0 group-hover:opacity-100 transition-opacity shrink-0",
                  buttonVariants({ variant: "destructive", size: "icon-xs" }),
                  selectedId === conversation.id && "opacity-100"
                )}
                onClick={(e) => e.stopPropagation()}
              >
                <Trash2 className="h-3 w-3" />
              </AlertDialogTrigger>
              <AlertDialogContent>
                <AlertDialogHeader>
                  <AlertDialogTitle>{t("chat.deleteTitle")}</AlertDialogTitle>
                  <AlertDialogDescription>
                    {t("chat.deleteConfirm")}
                  </AlertDialogDescription>
                </AlertDialogHeader>
                <AlertDialogFooter>
                  <AlertDialogCancel>{t("common.cancel")}</AlertDialogCancel>
                  <AlertDialogAction
                    onClick={() => handleDeleteConversation(conversation.id)}
                  >
                    {t("common.confirm")}
                  </AlertDialogAction>
                </AlertDialogFooter>
              </AlertDialogContent>
            </AlertDialog>
          </div>
        ))}
        {conversationsQuery.hasNextPage && (
          <button
            onClick={() => conversationsQuery.fetchNextPage()}
            disabled={conversationsQuery.isFetchingNextPage}
            className="w-full text-center text-xs text-muted-foreground hover:text-foreground py-2"
          >
            {conversationsQuery.isFetchingNextPage
              ? t("common.loading")
              : t("chat.loadMore")}
          </button>
        )}
      </div>
    </>
  );

  return (
    <div className="flex h-[calc(100dvh-7rem)] lg:h-[calc(100dvh-4rem)] overflow-hidden rounded-lg border bg-background">
      {/* Sidebar de conversas — desktop */}
      <aside className="hidden md:flex w-64 shrink-0 flex-col border-r">
        {conversationList}
      </aside>

      {/* Sidebar de conversas — mobile (overlay) */}
      {mobileListOpen && (
        <div className="fixed inset-0 z-50 md:hidden">
          <div
            className="fixed inset-0 bg-black/50"
            onClick={() => setMobileListOpen(false)}
          />
          <aside className="fixed left-0 top-0 h-full w-64 bg-background border-r flex flex-col">
            <div className="flex items-center justify-between p-3 border-b">
              <span className="font-bold text-sm">{t("chat.title")}</span>
              <button onClick={() => setMobileListOpen(false)}>
                <X className="h-5 w-5" />
              </button>
            </div>
            {conversationList}
          </aside>
        </div>
      )}

      {/* Thread */}
      <div className="flex flex-1 flex-col min-w-0">
        <SubscriptionStrip subscription={subscription} throttledLive={throttledLive} />

        <div ref={scrollRef} className="flex-1 overflow-y-auto p-4 space-y-4">
          {selectedId === null && !isStreaming && localMessages.length === 0 ? (
            <div className="flex h-full flex-col items-center justify-center text-center gap-3">
              <div className="rounded-full bg-primary/10 p-3">
                <MessageSquare className="h-6 w-6 text-primary" />
              </div>
              <p className="text-muted-foreground text-sm max-w-xs">
                {t("chat.selectOrStart")}
              </p>
            </div>
          ) : historyLoading ? (
            <p className="text-center text-muted-foreground py-8">
              {t("common.loading")}
            </p>
          ) : (
            <>
              {messages.map((message) => (
                <MessageBubble
                  key={message.id}
                  message={message}
                  assistantLabel={t("common.appName")}
                  userLabel={t("chat.you")}
                />
              ))}

              {streamText !== null && (
                <MessageBubble
                  message={{
                    id: -1,
                    role: "assistant",
                    content: streamText,
                    tokens: null,
                    created_at: new Date().toISOString(),
                  }}
                  streaming
                  assistantLabel={t("common.appName")}
                  userLabel={t("chat.you")}
                />
              )}

              {streamError && (
                <p className="text-sm text-destructive text-center">
                  {streamError}
                </p>
              )}

              {ceiling && (
                <div className="rounded-lg border border-amber-500/40 bg-amber-500/10 px-4 py-3 text-sm text-amber-700 dark:text-amber-400">
                  {t("chat.ceiling")}
                </div>
              )}
            </>
          )}
        </div>

        {/* Composer */}
        <div className="border-t p-3">
          <div className="flex items-end gap-2">
            <button
              onClick={() => setMobileListOpen(true)}
              className={cn(
                buttonVariants({ variant: "outline", size: "icon" }),
                "md:hidden shrink-0"
              )}
              aria-label={t("chat.title")}
            >
              <Menu className="h-4 w-4" />
            </button>
            <textarea
              ref={textareaRef}
              value={input}
              onChange={(e) => {
                setInput(e.target.value);
                autoResize();
              }}
              onKeyDown={handleKeyDown}
              placeholder={t("chat.placeholder")}
              rows={1}
              disabled={ceiling}
              className="flex-1 resize-none rounded-lg border border-input bg-transparent px-3 py-2 text-sm outline-none placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50 disabled:opacity-50 max-h-40"
            />
            {isStreaming ? (
              <button
                onClick={handleStop}
                className={cn(
                  buttonVariants({ variant: "outline", size: "icon" }),
                  "shrink-0"
                )}
                aria-label={t("chat.stop")}
              >
                <Square className="h-4 w-4" />
              </button>
            ) : (
              <button
                onClick={() => handleSend(input)}
                disabled={!input.trim() || ceiling}
                className={cn(buttonVariants({ size: "icon" }), "shrink-0")}
                aria-label={t("chat.send")}
              >
                <Send className="h-4 w-4" />
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

// ---------------------------------------------------------------------
// Faixa de estado da subscrição
// ---------------------------------------------------------------------

function SubscriptionStrip({
  subscription,
  throttledLive,
}: {
  subscription: SubscriptionState;
  throttledLive: boolean;
}) {
  const t = useTranslations();
  const limit = subscription.plan?.token_limit ?? 0;
  const used = subscription.tokens_used;
  const percent = limit > 0 ? Math.min(100, (used / limit) * 100) : 0;
  const throttled = subscription.throttled || throttledLive;

  return (
    <div className="border-b px-4 py-2 space-y-1.5">
      <div className="flex flex-wrap items-center gap-x-4 gap-y-1 text-xs">
        <span className="flex items-center gap-1.5 font-medium">
          <Zap className="h-3.5 w-3.5 text-primary" />
          {t("common.appName")} Chat
          {subscription.plan?.name && (
            <span className="text-muted-foreground">
              · {subscription.plan.name}
            </span>
          )}
        </span>
        <span className="text-muted-foreground">
          {t("chat.usage")}: {new Intl.NumberFormat().format(used)}
          {limit > 0 && (
            <> / {new Intl.NumberFormat().format(limit)} {t("pricing.tokens")}</>
          )}
        </span>
        {subscription.current_period_end && (
          <span className="text-muted-foreground">
            {t("chat.periodEnd")}:{" "}
            {new Date(subscription.current_period_end).toLocaleDateString()}
          </span>
        )}
      </div>
      {limit > 0 && (
        <div className="h-1.5 w-full rounded-full bg-muted overflow-hidden">
          <div
            className={cn(
              "h-full rounded-full transition-all",
              throttled ? "bg-amber-500" : "bg-primary"
            )}
            style={{ width: `${percent}%` }}
          />
        </div>
      )}
      {throttled && (
        <p className="text-xs text-amber-600 dark:text-amber-400">
          {t("chat.throttledNotice")}
        </p>
      )}
    </div>
  );
}

// ---------------------------------------------------------------------
// Bolha de mensagem (sem markdown — texto com whitespace preservado)
// ---------------------------------------------------------------------

function MessageBubble({
  message,
  streaming,
  assistantLabel,
  userLabel,
}: {
  message: ChatMessage;
  streaming?: boolean;
  assistantLabel: string;
  userLabel: string;
}) {
  const isUser = message.role === "user";
  return (
    <div className={cn("flex", isUser ? "justify-end" : "justify-start")}>
      <div
        className={cn(
          "max-w-[85%] sm:max-w-[75%] rounded-lg px-3 py-2 text-sm",
          isUser ? "bg-primary text-primary-foreground" : "bg-muted"
        )}
      >
        <p
          className={cn(
            "mb-0.5 text-[10px] font-medium uppercase tracking-wide",
            isUser ? "text-primary-foreground/70" : "text-muted-foreground"
          )}
        >
          {isUser ? userLabel : assistantLabel}
        </p>
        <div className="whitespace-pre-wrap break-words">
          {message.content}
          {streaming && (
            <span className="ml-0.5 inline-block h-3 w-1.5 animate-pulse bg-current align-middle" />
          )}
        </div>
      </div>
    </div>
  );
}
