<?php

namespace App\Http\Controllers\Api;

use App\Domain\Billing\AppyPayService;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class AppyPayWebhookController extends Controller
{
    public function __construct(private AppyPayService $appypay)
    {
    }

    public function handle(Request $request): Response
    {
        try {
            $this->appypay->handleWebhook(
                $request->getContent(),
                $request->header('X-AppyPay-Signature'),
            );
        } catch (\InvalidArgumentException $e) {
            return response('Invalid webhook: ' . $e->getMessage(), 400);
        } catch (\Exception $e) {
            report($e);
            return response('Webhook error', 400);
        }

        return response('ok', 200);
    }
}
