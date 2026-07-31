<?php

namespace App\Http\Controllers\Api;

use App\Domain\Billing\StripeService;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class StripeWebhookController extends Controller
{
    public function __construct(private StripeService $stripeService)
    {
    }

    public function handle(Request $request): Response
    {
        $payload = $request->getContent();
        $signature = $request->header('Stripe-Signature', '');

        try {
            $this->stripeService->handleWebhook($payload, $signature);
        } catch (\Stripe\Exception\SignatureVerificationException) {
            return response('Invalid signature', 400);
        } catch (\Exception $e) {
            report($e);
            return response('Webhook error', 400);
        }

        return response('ok', 200);
    }
}
