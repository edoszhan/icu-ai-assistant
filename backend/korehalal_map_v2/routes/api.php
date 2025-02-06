<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\LocationController;
use App\Http\Controllers\GenerateGPTResponseController;
use App\Http\Controllers\LambdaTestController;
use App\Http\Middleware\CheckUserRole;

use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

Route::get('/hello-api', function () {
    return response()->json(['message' => 'Hello, api!']);
});

Route::post('/find-location', [LocationController::class, 'findLocation']);

Route::post('/generate-response', [GenerateGPTResponseController::class, 'generateGeneralResponse']);

Route::get('/lambda-connected', [LambdaTestController::class, 'checkLambdaConnection']);
Route::post('/lambda-connected', [LambdaTestController::class, 'checkLambdaConnection']);

# auth sanctum verifies if the user is authenticated first before checking the role
Route::middleware(['auth:sanctum', CheckUserRole::class . ':admin'])->get('/dashboard', function () {
    return response()->json(['message' => 'Welcome, Admin!']);
});

Route::post('/register', function (Request $request) {
    $validator = Validator::make($request->all(), [
        'name' => 'required|string|max:255',
        'email' => 'required|string|email|max:255|unique:users',
        'password' => 'required|string|min:8|confirmed',
        'role' => 'required|string|in:admin,regular_user,premium_user'
    ]);

    if ($validator->fails()) {
        return response()->json(['errors' => $validator->errors()], 400);
    }

    $user = User::create([
        'name' => $request->name,
        'email' => $request->email,
        'password' => Hash::make($request->password),
        'role' => $request->role
    ]);

    return response()->json(['message' => 'User registered successfully'], 201);
});

Route::post('/login-user', function (Request $request) {
    $credentials = $request->only('email', 'password');

    if (auth()->attempt($credentials)) {
        $user = auth()->user();
        $token = $user->createToken('auth_token')->plainTextToken;
        return response()->json(['token' => $token], 200);
    }

    return response()->json(['error' => 'Unauthorized'], 401);
});

