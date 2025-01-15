<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class LambdaTestController extends Controller
{
    public function checkLambdaConnection(Request $request)
    {
        try {
            $request->validate([
                'prompt' => 'required|string'
            ]);

            $prompt = $request->input('prompt');
            $lambdaUrl = env('AWS_LAMBDA_URL');


            $response = Http::withHeaders([
                'Content-Type' => 'application/json',
            ])->post($lambdaUrl, [
                'prompt' => $prompt
            ]);

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
