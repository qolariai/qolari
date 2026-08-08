<?php

namespace Tests\Feature;

use App\Models\AiModel;
use App\Models\ExchangeRate;
use App\Models\Order;
use App\Models\PaymentEvent;
use App\Models\Product;
use App\Models\Setting;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

/**
 * Checkout AOA via AppyPay (Multicaixa Express / GPO) + webhook assinado.
 * A API AppyPay é faked via Http::fake — nenhuma chamada real é feita.
 */
class AppyPayCheckoutTest extends TestCase
{
    use RefreshDatabase;

    private const WEBHOOK_SECRET = 'appypay_webhook_test';

    private User $user;
    private Product $product;

    protected function setUp(): void
    {
        parent::setUp();

        config([
            'services.appypay.base_url' => 'https://appypay.test/v2.0',
            'services.appypay.auth_url' => 'https://appypay.test/oauth2/token',
        ]);
        Setting::set('appypay_client_id', 'client-test');
        Setting::set('appypay_client_secret', 'secret-test');
        Setting::set('appypay_resource', 'resource-test');
        Setting::set('appypay_api_key', 'POS123');
        Setting::set('appypay_webhook_secret', self::WEBHOOK_SECRET);

        ExchangeRate::create(['currency' => 'AOA', 'rate_to_usd' => 0.0011]);

        $this->user = User::factory()->create();

        $model = AiModel::create([
            'slug' => 'nexus-high',
            'display_name' => 'Nexus High',
            'provider' => 'openrouter',
            'provider_model_id' => 'test/high',
            'margin_multiplier' => 3.00,
            'is_active' => true,
            'sort_order' => 1,
        ]);

        $this->product = Product::create([
            'type' => 'package',
            'ai_model_id' => $model->id,
            'name' => 'Pacote Pro AO',
            'credits_usd' => 20.00,
            'is_active' => true,
            'sort_order' => 1,
        ]);
        $this->product->prices()->create(['currency' => 'AOA', 'price' => 18000]);
    }

    private function fakeAppyPay(string $chargeStatus = 'Pending'): void
    {
        Http::fake([
            'appypay.test/oauth2/token' => Http::response([
                'access_token' => 'token-test',
                'expires_in' => 3600,
            ]),
            'appypay.test/v2.0/charges' => Http::response([
                'id' => 'charge-abc-123',
                'responseStatus' => ['status' => $chargeStatus],
            ]),
        ]);
    }

    private function postWebhook(array $payload, ?string $secret = self::WEBHOOK_SECRET): \Illuminate\Testing\TestResponse
    {
        $body = json_encode($payload);
        $signature = $secret ? hash_hmac('sha256', $body, $secret) : 'invalid';

        return $this->call('POST', '/api/v1/webhooks/appypay', [], [], [], [
            'CONTENT_TYPE' => 'application/json',
            'HTTP_X_APPYPAY_SIGNATURE' => $signature,
        ], $body);
    }

    public function test_aoa_checkout_requires_valid_angolan_phone(): void
    {
        Sanctum::actingAs($this->user);

        $this->postJson('/api/v1/checkout', [
            'product_id' => $this->product->id,
            'currency' => 'AOA',
        ])->assertStatus(422);

        $this->postJson('/api/v1/checkout', [
            'product_id' => $this->product->id,
            'currency' => 'AOA',
            'phone' => '12345',
        ])->assertStatus(422);

        $this->assertDatabaseCount('orders', 0);
    }

    public function test_aoa_checkout_creates_pending_order_and_dispatches_charge(): void
    {
        $this->fakeAppyPay();
        Sanctum::actingAs($this->user);

        $response = $this->postJson('/api/v1/checkout', [
            'product_id' => $this->product->id,
            'currency' => 'AOA',
            'phone' => '+244 923 456 789',
        ]);

        $response->assertOk()
            ->assertJsonPath('gateway', 'appypay')
            ->assertJsonPath('payment_method', 'multicaixa_express')
            ->assertJsonPath('status', 'Pending');

        $order = Order::first();
        $this->assertSame('appypay', $order->gateway);
        $this->assertSame('pending', $order->status);
        $this->assertSame('AOA', $order->currency);
        $this->assertSame('charge-abc-123', $order->gateway_reference);
        // 18000 AOA * 0.0011 = 19.80 USD
        $this->assertSame('19.80', (string) $order->amount_usd);

        Http::assertSent(fn ($request) => str_ends_with($request->url(), '/charges')
            && $request['paymentMethod'] === 'GPO_POS123'
            && $request['paymentInfo']['phoneNumber'] === '923456789'
            && $request['currency'] === 'AOA'
            && str_starts_with($request['merchantTransactionId'], 'Q' . $order->id));
    }

    public function test_immediate_failed_charge_marks_order_failed(): void
    {
        $this->fakeAppyPay('Failed');
        Sanctum::actingAs($this->user);

        $this->postJson('/api/v1/checkout', [
            'product_id' => $this->product->id,
            'currency' => 'AOA',
            'phone' => '923456789',
        ])->assertOk()->assertJsonPath('status', 'Failed');

        $this->assertSame('failed', Order::first()->status);
    }

    public function test_webhook_success_fulfills_order_and_credits_wallet(): void
    {
        $this->fakeAppyPay();
        Sanctum::actingAs($this->user);

        $this->postJson('/api/v1/checkout', [
            'product_id' => $this->product->id,
            'currency' => 'AOA',
            'phone' => '923456789',
        ])->assertOk();

        $order = Order::first();

        $this->postWebhook([
            'id' => 'charge-abc-123',
            'merchantTransactionId' => 'Q' . $order->id . 'XYZ',
            'responseStatus' => ['status' => 'Success'],
        ])->assertOk();

        $order->refresh();
        $this->assertSame('paid', $order->status);
        $this->assertSame('delivered', $order->fulfillment_status);

        $wallet = Wallet::where('user_id', $this->user->id)->first();
        $this->assertSame(20.0, (float) $wallet->balance);

        $this->assertDatabaseHas('payment_events', [
            'gateway' => 'appypay',
            'gateway_event_id' => 'appypay-charge-abc-123-Success',
            'order_id' => $order->id,
        ]);
    }

    public function test_webhook_is_idempotent(): void
    {
        $this->fakeAppyPay();
        Sanctum::actingAs($this->user);

        $this->postJson('/api/v1/checkout', [
            'product_id' => $this->product->id,
            'currency' => 'AOA',
            'phone' => '923456789',
        ])->assertOk();

        $order = Order::first();
        $payload = [
            'id' => 'charge-abc-123',
            'merchantTransactionId' => 'Q' . $order->id . 'XYZ',
            'responseStatus' => ['status' => 'Success'],
        ];

        $this->postWebhook($payload)->assertOk();
        $this->postWebhook($payload)->assertOk();

        $this->assertSame(1, PaymentEvent::where('gateway', 'appypay')->count());
        $this->assertSame(20.0, (float) Wallet::where('user_id', $this->user->id)->first()->balance);
    }

    public function test_webhook_rejects_invalid_signature(): void
    {
        $this->postWebhook(['id' => 'charge-x', 'responseStatus' => ['status' => 'Success']], secret: null)
            ->assertStatus(400);

        $this->assertDatabaseCount('payment_events', 0);
    }

    public function test_webhook_failed_marks_pending_order_failed(): void
    {
        $this->fakeAppyPay();
        Sanctum::actingAs($this->user);

        $this->postJson('/api/v1/checkout', [
            'product_id' => $this->product->id,
            'currency' => 'AOA',
            'phone' => '923456789',
        ])->assertOk();

        $this->postWebhook([
            'id' => 'charge-abc-123',
            'responseStatus' => ['status' => 'Failed'],
        ])->assertOk();

        $this->assertSame('failed', Order::first()->status);
        $this->assertDatabaseMissing('wallets', ['user_id' => $this->user->id]);
    }
}
