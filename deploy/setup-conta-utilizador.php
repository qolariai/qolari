<?php
// Cria (ou atualiza) uma conta de utilizador para testes:
//   - creditos em todas as wallets ativas (Code)
//   - subscrição Chat ativa no plano de teste (Chatbot)
// Parametros por env: SETUP_EMAIL, SETUP_NAME, SETUP_PASSWORD, SETUP_CREDIT
require '/var/www/qolari/api/vendor/autoload.php';
$app = require '/var/www/qolari/api/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Domain\Wallet\WalletService;
use App\Models\AiModel;
use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

$email = getenv('SETUP_EMAIL') ?: 'deco@qolari.com';
$name = getenv('SETUP_NAME') ?: 'Deco';
$password = getenv('SETUP_PASSWORD') ?: 'Qolari2026Teste';
$credit = (float) (getenv('SETUP_CREDIT') ?: 10.0);

$user = User::firstOrCreate(
    ['email' => $email],
    [
        'name' => $name,
        'password' => Hash::make($password),
        'preferred_currency' => 'USD',
        'language' => 'pt',
    ]
);

$wallets = app(WalletService::class);
$credited = [];
foreach (AiModel::where('is_active', true)->get() as $model) {
    if ($wallets->balance($user->id, $model->id) < 1.0) {
        $wallets->adminAdjust($user->id, $model->id, $credit, 'fase de testes: creditos NVIDIA');
        $credited[] = $model->slug;
    }
}

$plan = SubscriptionPlan::where('slug', 'teste')->first();
if (!$plan) {
    $plan = SubscriptionPlan::create([
        'slug' => 'teste',
        'name' => 'Plano Teste',
        'token_limit' => 500000,
        'period_days' => 30,
        'throttle_percent' => 80,
        'is_active' => true,
        'sort_order' => 99,
    ]);
}

$subscription = Subscription::firstOrCreate(
    ['user_id' => $user->id, 'plan_id' => $plan->id],
    [
        'status' => 'active',
        'current_period_start' => now(),
        'current_period_end' => now()->addDays(30),
        'tokens_used' => 0,
        'cancel_at_period_end' => false,
    ]
);
if (!in_array($subscription->status, ['active', 'trialing'], true)) {
    $subscription->update([
        'status' => 'active',
        'current_period_start' => now(),
        'current_period_end' => now()->addDays(30),
    ]);
}

echo "EMAIL={$email}\n";
echo "USER_ID={$user->id}\n";
echo "WALLETS_CREDITADAS=" . implode(',', $credited) . " ({$credit} USD cada)\n";
echo "SUBSCRIPTION={$subscription->status} (plano {$plan->slug}, {$plan->token_limit} tokens, ate " . $subscription->current_period_end->toDateString() . ")\n";
