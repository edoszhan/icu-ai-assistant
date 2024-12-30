<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\LocationController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');


Route::get('/hello-api', function () {
    return response()->json(['message' => 'Hello, api!']);
});

Route::post('/find-location', [LocationController::class, 'findLocation']);
