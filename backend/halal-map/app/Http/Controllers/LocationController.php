<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Symfony\Component\Process\Process;
use Symfony\Component\Process\Exception\ProcessFailedException;

class LocationController extends Controller
{
    public function findLocation(Request $request)
    {
        return response()->json(['message' => 'findLocation endpoint is working!']);
    }
    //     // Validate input
    //     $validated = $request->validate([
    //         'latitude' => 'required|numeric',
    //         'longitude' => 'required|numeric',
    //         'prompt' => 'required|string',
    //     ]);

    //     // Extract inputs
    //     $latitude = $validated['latitude'];
    //     $longitude = $validated['longitude'];
    //     $prompt = $validated['prompt'];

    //     // Execute Python script
    //     $scriptPath = base_path('../find_nearest_location.py');
    //     $process = new Process(['python3', $scriptPath, $latitude, $longitude, $prompt]);
    //     $process->run();

    //     // Check if the process executed successfully
    //     if (!$process->isSuccessful()) {
    //         return response()->json([
    //             'error' => 'Failed to execute Python script',
    //             'details' => $process->getErrorOutput(),
    //         ], 500);
    //     }

    //     // Get the Python script's output
    //     $output = $process->getOutput();

    //     // Return the response
    //     return response()->json([
    //         'result' => json_decode($output, true), // Parse JSON output from Python
    //     ]);
    // }
}
