<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Symfony\Component\Process\Process;
use Symfony\Component\Process\Exception\ProcessFailedException;

class LocationController extends Controller
{
    public function findLocation(Request $request)
    {
        \Log::info('Request received:', $request->all());

        // Validate input
        $validated = $request->validate([
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'prompt' => 'required|string',
        ]);

        $userLat = $validated['latitude'];
        $userLon = $validated['longitude'];
        $prompt = $validated['prompt'];

        \Log::info('Validated input:', compact('userLat', 'userLon', 'prompt'));

        // Sript paths
        $scriptPath = base_path('find_nearest_location.py'); 
        $pythonPath = '/usr/bin/python3'; 
        $process = new Process([$pythonPath, $scriptPath, $userLat, $userLon, $prompt]);
        $process->run();

        if (!$process->isSuccessful()) {
            \Log::error('Python script failed:', ['error' => $process->getErrorOutput()]);
            return response()->json([
                'error' => 'Failed to execute Python script.',
                'details' => $process->getErrorOutput(),
            ], 500);
        }

        $output = $process->getOutput();
        \Log::info('Python script output:', ['output' => $output]);

        try {
            $decoded = json_decode($output, true);
            if (json_last_error() !== JSON_ERROR_NONE) {
                throw new \Exception('JSON decoding error: ' . json_last_error_msg());
            }
        } catch (\Exception $e) {
            \Log::error('Failed to decode Python script output:', ['exception' => $e->getMessage()]);
            return response()->json([
                'error' => 'Failed to decode Python script output.',
                'details' => $e->getMessage(),
            ], 500);
        }

        return response()->json($decoded);
    }
}
