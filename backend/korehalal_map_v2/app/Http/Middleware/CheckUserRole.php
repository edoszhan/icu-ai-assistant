<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class CheckUserRole
{
    public function handle($request, Closure $next, $role)
    {
        if (auth()->check()) {
            $user = auth()->user();
            Log::info('User authentication check', ['user' => $user]);

            if ($user && $user->role === $role) {
                return $next($request);
            }
            
            Log::warning('Unauthorized access attempt', [
                'user_id' => $user->id,
                'required_role' => $role,
                'actual_role' => $user->role
            ]);
        } else {
            Log::warning('No authenticated user found');
        }

        return response()->json(['error' => 'Unauthorized'], 403);
    }
}
