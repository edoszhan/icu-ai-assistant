<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class LambdaTestController extends Controller
{
    public function checkLambdaConnection()
    {
        try {
            $response = Http::get('https://your-api-gateway-id.execute-api.your-region.amazonaws.com/dev');
            
            if ($response->successful()) {
                return response()->json([
                    'success' => true,
                    'message' => 'Successfully connected to Lambda!',
                    'data' => $response->json()
                ]);
            }

            return response()->json([
                'success' => false,
                'message' => 'Failed to connect to Lambda.',
                'status' => $response->status(),
                'error' => $response->body()
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error connecting to Lambda.',
                'error' => $e->getMessage()
            ]);
        }
    }
}
