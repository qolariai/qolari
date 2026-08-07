<?php
// Setup da conta de testes (fase de testes) — cria utilizador, token API,
// creditos em todas as wallets ativas e uma subscrição Chat ativa.
require '/var/www/qolari/api/vendor/autoload.php';
$app = require '/var/www/qolari/api/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Domain\Wallet\WalletService;
use App\Models\AiModel;
use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

$user = User::firstOrCreate(
    ['email' => 'teste@qolari.com'],
    [
        'name' => 'Conta Teste',
        'password' => Hash::make('TesteQolari2026'),
        'preferred_currency' => 'USD',
        'language' => 'pt',
    ]
);

$token = $user->createToken('teste-e2e')->plainTextToken;

$wallets = app(WalletService::class);
$credited = [];
foreach (AiModel::where('is_active', true)->get() as $model) {
    if ($wallets->balance($user->id, $model->id) < 1.0) {
        $wallets->adminAdjust($user->id, $model->id, 5.0, 'fase de testes: creditos NVIDIA');
        $credited[] = $model->slug;
    }
}

$plan = SubscriptionPlan::firstOrCreate(
    ['slug' => 'teste'],
    [
        'name' => 'Plano Teste',
        'token_limit' => 500000,
        'period_days' => 30,
        'throttle_percent' => 80,
        'is_active' => true,
        'sort_order' => 99,
    ]
);

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

echo "USER_ID={$user->id}\n";
echo "TOKEN={$token}\n";
echo "WALLETS_CREDITADAS=" . implode(',', $credited) . "\n";
echo "SUBSCRIPTION={$subscription->status} (plano {$plan->slug}, limite {$plan->token_limit})\n";
