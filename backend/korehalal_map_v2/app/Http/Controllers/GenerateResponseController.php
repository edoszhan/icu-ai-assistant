<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Symfony\Component\Process\Process;
use Illuminate\Support\Facades\Log;

class GenerateResponseController extends Controller
{
    public function generateGeneralResponse(Request $request)
    {
        Log::info('Request received:', $request->all());

        // validation
        $validated = $request->validate([
            'prompt' => 'required|string',
        ]);

        $prompt = $validated['prompt'];

        $scriptPath = base_path('generate_gpt_response.py');
        $lambdaPath = base_path('lambda_package/lambda_function.py');
        $pythonPath = '/usr/bin/python3';
 
        // start python script as a streaming process
        $process = new Process([$pythonPath, $lambdaPath]);
        $process->setTimeout(3600);
        $process->setInput(json_encode(['prompt' => $prompt]));
        $process->start();

        return response()->stream(function () use ($process) {
            while ($process->isRunning()) {
                $output = $process->getIncrementalOutput();
                $errorOutput = $process->getIncrementalErrorOutput();

                if (!empty($output)) {
                    echo "data: " . trim($output) . "\n\n";
                    ob_flush();
                    flush();
                }

                if (!empty($errorOutput)) {
                    Log::error('Python script error:', ['error' => $errorOutput]);
                    echo "data: Error: " . trim($errorOutput) . "\n\n";
                    ob_flush();
                    flush();
                }

                usleep(50000); // 50ms delay to mimic real-time streaming
            }

            if (!$process->isSuccessful()) {
                Log::error('Python script failed:', ['error' => $process->getErrorOutput()]);
                echo "data: Error processing request.\n\n";
            }

            echo "data: [DONE]\n\n"; // indicate stream completion
            ob_flush();
            flush();
        }, 200, [
            'Content-Type' => 'text/event-stream',
            'Cache-Control' => 'no-cache',
            'Connection' => 'keep-alive',
        ]);
    }
}
