<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\LocationController;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/hello', function () {
    return response()->json(['message' => 'Hello, world!']);
});

// Route::post('/find-location', [LocationController::class, 'findLocation']);

