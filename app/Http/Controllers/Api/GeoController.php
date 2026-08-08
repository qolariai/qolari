<?php

namespace App\Http\Controllers\Api;

use App\Domain\Geo\GeoService;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GeoController extends Controller
{
    public function __construct(private GeoService $geo)
    {
    }

    public function show(Request $request): JsonResponse
    {
        $country = $this->geo->countryForIp($request->ip());

        return response()->json([
            'country' => $country,
            'suggested_currency' => $this->geo->suggestedCurrency($country),
        ]);
    }
}
