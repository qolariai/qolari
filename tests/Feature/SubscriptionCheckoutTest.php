<?php

namespace Tests\Feature;

use App\Models\PaymentEvent;
use App\Models\Setting;
use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Stripe\ApiRequestor;
use Stripe\HttpClient\ClientInterface;
use Tests\TestCase;

/**
 * Checkout de subscrição + webhooks Stripe (Chat).
 * A SDK stripe-php usa o seu próprio client HTTP — instala-se um fake
 * via ApiRequestor::setHttpClient (a assinatura do webhook é local/HMAC,
 * sem HTTP).
 */
class SubscriptionCheckoutTest extends TestCase
{
    use RefreshDatabase;

    private const WEBHOOK_SECRET = 'whsec_test';

    private User $user;
    private SubscriptionPlan $plan;

    protected function setUp(): void
    {
        parent::setUp();

        Setting::set('stripe_secret_key', 'sk_test_fake');
        Setting::set('stripe_webhook_secret', self::WEBHOOK_SECRET, true);
        config(['chat.throttle_sleep_ms' => 0]);

        $this->user = User::factory()->create();
        $this->plan = SubscriptionPlan::create([
            'slug' => 'chat-basic',
            'name' => 'Chat Essencial',
            'token_limit' => 1_000_000,
            'period_days' => 30,
            'throttle_percent' => 80,
            'stripe_price_id' => 'price_test_123',
            'is_active' => true,
            'sort_order' => 1,
        ]);
        $this->plan->prices()->create(['currency' => 'EUR', 'amount' => 9.99]);
    }

    protected function tearDown(): void
    {
        // Devolve o client real à SDK para não contaminar outros testes
        ApiRequestor::setHttpClient(null);

        parent::tearDown();
    }

    public function test_checkout_creates_pending_subscription_and_returns_url(): void
    {
        $fake = $this->fakeStripeClient([
            '/v1/customers' => ['id' => 'cus_test_1', 'object' => 'customer'],
            '/v1/checkout/sessions' => [
                'id' => 'cs_test_1',
                'object' => 'checkout.session',
                'url' => 'https://checkout.stripe.com/pay/cs_test_1',
            ],
        ]);

        Sanctum::actingAs($this->user);

        $response = $this->postJson('/api/v1/checkout/subscription', [
            'plan_id' => $this->plan->id,
            'currency' => 'EUR',
        ]);

        $response->assertOk()
            ->assertJsonPath('checkout_url', 'https://checkout.stripe.com/pay/cs_test_1')
            ->assertJsonStructure(['checkout_url', 'subscription_id']);

        // Subscrição pendente + cliente Stripe criado e guardado
        $this->assertDatabaseHas('subscriptions', [
            'user_id' => $this->user->id,
            'plan_id' => $this->plan->id,
            'status' => 'incomplete',
            'stripe_customer_id' => 'cus_test_1',
            'tokens_used' => 0,
        ]);

        // A sessão foi criada em mode subscription com o price do plano
        $sessionRequest = collect($fake->requests)
            ->first(fn (array $request) => str_contains($request['url'], '/v1/checkout/sessions'));
        $this->assertNotNull($sessionRequest);
        $this->assertEquals('subscription', $sessionRequest['params']['mode']);
        $this->assertEquals('price_test_123', $sessionRequest['params']['line_items'][0]['price']);
    }

    public function test_checkout_rejects_currency_without_price(): void
    {
        Sanctum::actingAs($this->user);

        $response = $this->postJson('/api/v1/checkout/subscription', [
            'plan_id' => $this->plan->id,
            'currency' => 'USD', // sem preço
        ]);

        $response->assertStatus(422);
        $this->assertDatabaseCount('subscriptions', 0);
    }

    public function test_webhook_checkout_completed_activates_subscription(): void
    {
        $subscription = Subscription::create([
            'user_id' => $this->user->id,
            'plan_id' => $this->plan->id,
            'status' => 'incomplete',
        ]);

        $periodStart = now()->subHours(1)->getTimestamp();
        $periodEnd = now()->addDays(30)->getTimestamp();

        $this->fakeStripeClient([
            '/v1/subscriptions/sub_test_123' => [
                'id' => 'sub_test_123',
                'object' => 'subscription',
                'status' => 'active',
                'current_period_start' => $periodStart,
                'current_period_end' => $periodEnd,
            ],
        ]);

        $payload = $this->eventPayload('evt_test_1', 'checkout.session.completed', [
            'id' => 'cs_test_1',
            'object' => 'checkout.session',
            'mode' => 'subscription',
            'subscription' => 'sub_test_123',
            'client_reference_id' => (string) $this->user->id,
            'payment_intent' => 'pi_test_1',
            'metadata' => ['subscription_id' => $subscription->id, 'user_id' => $this->user->id],
        ]);

        $response = $this->postWebhook($payload);
        $response->assertOk();

        $fresh = $subscription->fresh();
        $this->assertEquals('active', $fresh->status);
        $this->assertEquals('sub_test_123', $fresh->stripe_subscription_id);
        $this->assertEquals(0, $fresh->tokens_used);
        // Período real veio da Stripe
        $this->assertEquals($periodStart, $fresh->current_period_start->getTimestamp());
        $this->assertEquals($periodEnd, $fresh->current_period_end->getTimestamp());

        $this->assertEquals(1, PaymentEvent::where('gateway_event_id', 'evt_test_1')->count());
    }

    public function test_webhook_activation_derives_period_when_stripe_lookup_fails(): void
    {
        $subscription = Subscription::create([
            'user_id' => $this->user->id,
            'plan_id' => $this->plan->id,
            'status' => 'incomplete',
        ]);

        // Sem rota para /v1/subscriptions → retrieve falha → deriva do plano
        $this->fakeStripeClient([]);

        $payload = $this->eventPayload('evt_test_2', 'checkout.session.completed', [
            'id' => 'cs_test_2',
            'object' => 'checkout.session',
            'mode' => 'subscription',
            'subscription' => 'sub_test_missing',
            'client_reference_id' => (string) $this->user->id,
            'metadata' => ['subscription_id' => $subscription->id],
        ]);

        $this->postWebhook($payload)->assertOk();

        $fresh = $subscription->fresh();
        $this->assertEquals('active', $fresh->status);
        $this->assertNotNull($fresh->current_period_end);
        // Derivado do plano: ~30 dias
        $this->assertEqualsWithDelta(
            now()->addDays(30)->getTimestamp(),
            $fresh->current_period_end->getTimestamp(),
            60,
        );
    }

    public function test_webhook_is_idempotent(): void
    {
        $subscription = Subscription::create([
            'user_id' => $this->user->id,
            'plan_id' => $this->plan->id,
            'status' => 'incomplete',
        ]);

        $this->fakeStripeClient([]);

        $payload = $this->eventPayload('evt_dup', 'checkout.session.completed', [
            'id' => 'cs_dup',
            'object' => 'checkout.session',
            'mode' => 'subscription',
            'subscription' => null,
            'metadata' => ['subscription_id' => $subscription->id],
        ]);

        $this->postWebhook($payload)->assertOk();
        $this->postWebhook($payload)->assertOk();

        $this->assertEquals(1, PaymentEvent::where('gateway_event_id', 'evt_dup')->count());
        $this->assertEquals('active', $subscription->fresh()->status);
    }

    public function test_subscription_updated_webhook_syncs_status_and_cancel_flag(): void
    {
        $subscription = Subscription::create([
            'user_id' => $this->user->id,
            'plan_id' => $this->plan->id,
            'stripe_subscription_id' => 'sub_test_sync',
            'status' => 'active',
            'current_period_start' => now(),
            'current_period_end' => now()->addDays(30),
        ]);

        $payload = $this->eventPayload('evt_upd', 'customer.subscription.updated', [
            'id' => 'sub_test_sync',
            'object' => 'subscription',
            'status' => 'active',
            'cancel_at_period_end' => true,
            'current_period_start' => now()->getTimestamp(),
            'current_period_end' => now()->addDays(30)->getTimestamp(),
        ]);

        $this->postWebhook($payload)->assertOk();

        $this->assertTrue($subscription->fresh()->cancel_at_period_end);
    }

    public function test_subscription_deleted_webhook_cancels(): void
    {
        $subscription = Subscription::create([
            'user_id' => $this->user->id,
            'plan_id' => $this->plan->id,
            'stripe_subscription_id' => 'sub_test_del',
            'status' => 'active',
        ]);

        $payload = $this->eventPayload('evt_del', 'customer.subscription.deleted', [
            'id' => 'sub_test_del',
            'object' => 'subscription',
            'status' => 'canceled',
        ]);

        $this->postWebhook($payload)->assertOk();

        $this->assertEquals('canceled', $subscription->fresh()->status);
    }

    public function test_invoice_payment_failed_marks_past_due(): void
    {
        $subscription = Subscription::create([
            'user_id' => $this->user->id,
            'plan_id' => $this->plan->id,
            'stripe_subscription_id' => 'sub_test_due',
            'status' => 'active',
        ]);

        $payload = $this->eventPayload('evt_inv', 'invoice.payment_failed', [
            'id' => 'in_test_1',
            'object' => 'invoice',
            'subscription' => 'sub_test_due',
        ]);

        $this->postWebhook($payload)->assertOk();

        $this->assertEquals('past_due', $subscription->fresh()->status);
    }

    public function test_subscription_endpoint_never_exposes_stripe_ids(): void
    {
        Subscription::create([
            'user_id' => $this->user->id,
            'plan_id' => $this->plan->id,
            'stripe_subscription_id' => 'sub_test_secret',
            'stripe_customer_id' => 'cus_test_secret',
            'status' => 'active',
            'current_period_start' => now(),
            'current_period_end' => now()->addDays(30),
            'tokens_used' => 1234,
        ]);

        Sanctum::actingAs($this->user);

        $response = $this->getJson('/api/v1/subscription');

        $response->assertOk()
            ->assertJsonPath('subscription.status', 'active')
            ->assertJsonPath('subscription.plan.name', 'Chat Essencial')
            ->assertJsonPath('subscription.tokens_used', 1234)
            ->assertJsonPath('subscription.throttled', false);

        $this->assertStringNotContainsString('sub_test_secret', $response->getContent());
        $this->assertStringNotContainsString('cus_test_secret', $response->getContent());
    }

    // ------------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------------

    /**
     * Client HTTP fake para a SDK stripe-php (rotas por substring do URL).
     */
    private function fakeStripeClient(array $routes): object
    {
        $fake = new class($routes) implements ClientInterface {
            public array $requests = [];

            public function __construct(private array $routes)
            {
            }

            public function request($method, $absUrl, $headers, $params, $hasFile, $apiMode = 'v1', $maxNetworkRetries = null)
            {
                $this->requests[] = ['method' => $method, 'url' => $absUrl, 'params' => $params];

                foreach ($this->routes as $needle => $body) {
                    if (str_contains($absUrl, $needle)) {
                        return [json_encode($body), 200, []];
                    }
                }

                return [json_encode(['error' => ['message' => 'no fake route: ' . $absUrl, 'type' => 'invalid_request_error']]), 404, []];
            }
        };

        ApiRequestor::setHttpClient($fake);

        return $fake;
    }

    private function eventPayload(string $eventId, string $type, array $object): string
    {
        return json_encode([
            'id' => $eventId,
            'object' => 'event',
            'type' => $type,
            'data' => ['object' => $object],
        ]);
    }

    private function postWebhook(string $payload): \Illuminate\Testing\TestResponse
    {
        $timestamp = time();
        $signature = hash_hmac('sha256', $timestamp . '.' . $payload, self::WEBHOOK_SECRET);

        return $this->call(
            'POST',
            '/api/v1/webhooks/stripe',
            [],
            [],
            [],
            [
                'HTTP_STRIPE_SIGNATURE' => "t={$timestamp},v1={$signature}",
                'CONTENT_TYPE' => 'application/json',
            ],
            $payload,
        );
    }
}
