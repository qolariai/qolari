<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\JsonResponse;

class ProductController extends Controller
{
    public function index(): JsonResponse
    {
        $products = Product::active()
            ->with(['prices', 'aiModel'])
            ->orderBy('sort_order')
            ->get();

        return response()->json($products);
    }
}
