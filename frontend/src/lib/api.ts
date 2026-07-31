const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000/api";

export interface ApiError {
  message: string;
  errors?: Record<string, string[]>;
}

class ApiClient {
  private baseUrl: string;

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }

  private getToken(): string | null {
    if (typeof window === "undefined") return null;
    return localStorage.getItem("qolari_token");
  }

  setToken(token: string) {
    localStorage.setItem("qolari_token", token);
  }

  clearToken() {
    localStorage.removeItem("qolari_token");
  }

  isAuthenticated(): boolean {
    return !!this.getToken();
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const token = this.getToken();
    const headers: Record<string, string> = {
      "Content-Type": "application/json",
      Accept: "application/json",
      ...(options.headers as Record<string, string>),
    };

    if (token) {
      headers["Authorization"] = `Bearer ${token}`;
    }

    const response = await fetch(`${this.baseUrl}${endpoint}`, {
      ...options,
      headers,
    });

    if (response.status === 401) {
      this.clearToken();
      if (typeof window !== "undefined") {
        window.dispatchEvent(new Event("auth:logout"));
      }
      throw { message: "Unauthorized" } as ApiError;
    }

    if (!response.ok) {
      const data = await response.json().catch(() => ({}));
      throw {
        message: data.message || `Error ${response.status}`,
        errors: data.errors,
      } as ApiError;
    }

    if (response.status === 204) {
      return {} as T;
    }

    return response.json();
  }

  get<T>(endpoint: string): Promise<T> {
    return this.request<T>(endpoint, { method: "GET" });
  }

  post<T>(endpoint: string, body?: unknown): Promise<T> {
    return this.request<T>(endpoint, {
      method: "POST",
      body: body ? JSON.stringify(body) : undefined,
    });
  }

  put<T>(endpoint: string, body?: unknown): Promise<T> {
    return this.request<T>(endpoint, {
      method: "PUT",
      body: body ? JSON.stringify(body) : undefined,
    });
  }

  delete<T>(endpoint: string): Promise<T> {
    return this.request<T>(endpoint, { method: "DELETE" });
  }
}

export const api = new ApiClient(API_URL);

// Types
export interface User {
  id: number;
  name: string;
  email: string;
  is_admin: boolean;
  country: string | null;
  preferred_currency: string;
  language: string;
  promo_code_id: number | null;
  created_at: string;
}

export interface Product {
  id: number;
  type: string;
  ai_model_id: number;
  name: string;
  description: string | null;
  credits_usd: string;
  is_active: boolean;
  sort_order: number;
  prices: ProductPrice[];
  ai_model: AiModel;
}

export interface ProductPrice {
  id: number;
  product_id: number;
  currency: string;
  price: string;
}

export interface AiModel {
  id: number;
  slug: string;
  display_name: string;
  description: string | null;
  provider: string;
  is_active: boolean;
}

export interface Wallet {
  id: number;
  user_id: number;
  ai_model_id: number;
  balance: string;
  ai_model: AiModel;
}

export interface Order {
  id: number;
  user_id: number;
  product_id: number;
  currency: string;
  amount: string;
  amount_usd: string;
  status: string;
  created_at: string;
  product: Product;
}

export interface UsageLog {
  id: number;
  user_id: number;
  ai_model_id: number;
  request_id: string;
  prompt_tokens: number;
  completion_tokens: number;
  cost_usd: string;
  charged_usd: string;
  status: string;
  created_at: string;
  ai_model: AiModel;
}

export interface UsageSummary {
  date: string;
  total_usd: string;
  requests: number;
}

export interface ApiToken {
  id: number;
  name: string;
  created_at: string;
  last_used_at: string | null;
}

export interface Paginated<T> {
  data: T[];
  current_page: number;
  last_page: number;
  per_page: number;
  total: number;
}
