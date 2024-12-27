// routes/api.php

<?php
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\LocationController;

Route::post('/find-location', [LocationController::class, 'findLocation']);
