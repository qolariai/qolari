<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Mailgun, Postmark, AWS and more. This file provides the de facto
    | location for this type of information, allowing packages to have
    | a conventional file to locate the various service credentials.
    |
    */

    'postmark' => [
        'key' => env('POSTMARK_API_KEY'),
    ],

    'resend' => [
        'key' => env('RESEND_API_KEY'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel' => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],

    'stripe' => [
        'key' => env('STRIPE_KEY'),
        'secret' => env('STRIPE_SECRET'),
        'webhook_secret' => env('STRIPE_WEBHOOK_SECRET'),
    ],

    'appypay' => [
        'base_url' => env('APPYPAY_BASE_URL', 'https://gwy-api.appypay.co.ao/v2.0'),
        'auth_url' => env('APPYPAY_AUTH_URL', 'https://login.microsoftonline.com/auth.appypay.co.ao/oauth2/token'),
        'client_id' => env('APPYPAY_CLIENT_ID'),
        'client_secret' => env('APPYPAY_CLIENT_SECRET'),
        'resource' => env('APPYPAY_RESOURCE'),
        'api_key' => env('APPYPAY_API_KEY'),
        'webhook_secret' => env('APPYPAY_WEBHOOK_SECRET'),
    ],

    'openrouter' => [
        'api_key' => env('OPENROUTER_API_KEY'),
        'base_url' => 'https://openrouter.ai/api/v1',
    ],

    'deepseek' => [
        'api_key' => env('DEEPSEEK_API_KEY'),
    ],

    'nvidia' => [
        'api_key' => env('NVIDIA_API_KEY'),
    ],

];
