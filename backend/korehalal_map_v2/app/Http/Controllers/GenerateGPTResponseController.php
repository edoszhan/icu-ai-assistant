<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Symfony\Component\Process\Process;
use Illuminate\Support\Facades\Log;

class GenerateGPTResponseController extends Controller
{
    public function generateResponse(Request $request)
    {
        Log::info('Request received for GPT response:', $request->all());

        // Validate input
        $validated = $request->validate([
            'prompt' => 'required|string',
        ]);

        $prompt = $validated['prompt'];

        Log::info('Validated input:', ['prompt' => $prompt]);

        $scriptPath = base_path('generate_gpt_response.py');
        // $pythonPath = '/usr/bin/python3';
        // have to use this because the my-venv is using older version of openai, in the future we will change to adapt to 1.0.0 openai version
        $pythonPath = '/mnt/c/Users/icu-e/projects/korehalal_map/backend/korehalal_map_v2/my-venv/bin/python3';
        $process = new Process([$pythonPath, $scriptPath, $prompt]);
        $process->run();

        if (!$process->isSuccessful()) {
            Log::error('Python script failed:', ['error' => $process->getErrorOutput()]);
            return response()->json([
                'error' => 'Failed to execute Python script.',
                'details' => $process->getErrorOutput(),
            ], 500);
        }

        $output = $process->getOutput();
        Log::info('Python script output:', ['output' => $output]);

        try {
            $decoded = json_decode($output, true);
            if (json_last_error() !== JSON_ERROR_NONE) {
                throw new \Exception('JSON decoding error: ' . json_last_error_msg());
            }
        } catch (\Exception $e) {
            Log::error('Failed to decode Python script output:', ['exception' => $e->getMessage()]);
            return response()->json([
                'error' => 'Failed to decode Python script output.',
                'details' => $e->getMessage(),
            ], 500);
        }

        return response()->json($decoded);
    }
}
