<?php

namespace App\Domain\Wallet;

use Exception;

class InsufficientBalanceException extends Exception
{
    public function render()
    {
        return response()->json([
            'error' => 'insufficient_balance',
            'message' => $this->getMessage(),
        ], 402);
    }
}
