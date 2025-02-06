<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log; 
class LambdaTestController extends Controller
{
    public function checkLambdaConnection(Request $request)
    {
        $prompt = $request->input('prompt', 'What is best halal restaurant nearby?');

        Log::info('LambdaTestController: Received prompt from user', ['prompt' => $prompt]);

        $lambdaUrl = env('AWS_LAMBDA_URL');

        try {
            $response = Http::post($lambdaUrl, [
                'prompt' => $prompt,
            ]);

            Log::info('LambdaTestController: Lambda response received', [
                'status' => $response->status(),
                'body' => $response->body()
            ]);

            if ($response->successful()) {
                $data = $response->json();

                Log::info('LambdaTestController: Parsed response from Lambda', ['data' => $data]);

                return response()->json([
                    'success' => true,
                    'message' => 'Successfully connected to Lambda!',
                    'data' => $data['response'] ?? 'No response from Lambda'
                ]);
            }

            Log::warning('LambdaTestController: Failed to connect to Lambda', [
                'status' => $response->status(),
                'error' => $response->body()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to connect to Lambda.',
                'status' => $response->status(),
                'error' => $response->body(),
            ]);

        } catch (\Exception $e) {
            Log::error('LambdaTestController: Error connecting to Lambda', [
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Error connecting to Lambda.',
                'error' => $e->getMessage(),
            ]);
        }
    }
}

// class LambdaTestController extends Controller
// {
//     public function checkLambdaConnection(Request $request)
//     {
//         $prompt = $request->input('prompt', 'What is the best halal restaurant nearby?');

//         Log::info('LambdaTestController: Received prompt', ['prompt' => $prompt]);

//         $lambdaUrl = env('AWS_LAMBDA_URL');  // Ensure this is set in .env file

//         try {
//             $response = Http::withOptions([
//                 'stream' => true, // Enable streaming
//             ])->post($lambdaUrl, [
//                 'prompt' => $prompt,
//             ]);

//             if (!$response->successful()) {
//                 return response()->json([
//                     'success' => false,
//                     'message' => 'Failed to connect to Lambda.',
//                     'status' => $response->status(),
//                     'error' => $response->body(),
//                 ]);
//             }

//             return response()->stream(function () use ($response) {
//                 foreach ($response->getBody() as $chunk) {
//                     echo $chunk;
//                     flush();
//                 }
//             }, 200, [
//                 'Content-Type' => 'text/event-stream',
//                 'Cache-Control' => 'no-cache',
//                 'Connection' => 'keep-alive',
//             ]);

//         } catch (\Exception $e) {
//             Log::error('LambdaTestController: Error connecting to Lambda', [
//                 'error' => $e->getMessage()
//             ]);

//             return response()->json([
//                 'success' => false,
//                 'message' => 'Error connecting to Lambda.',
//                 'error' => $e->getMessage(),
//             ]);
//         }
//     }
// }
