<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;

class LocationsSeeder extends Seeder
{
    public function run()
{
        $filePath = base_path('dataset/combined_dataset.json');

        if (!File::exists($filePath)) {
            $this->command->error("JSON file not found at {$filePath}");
            return;
        }

        $jsonData = File::get($filePath);
        $locations = json_decode($jsonData, true);

        if ($locations === null) {
            $this->command->error("Invalid JSON format in file: {$filePath}");
            return;
        }

        foreach ($locations as $location) {
            DB::table('locations')->insert([
                'latitude' => $location['Latitude'],
                'longitude' => $location['Longitude'],
                'name' => $location['Name'],
                'category' => $location['Category'],
                'time' => $location['Time'],
                'description' => $location['Description'],
                'classification' => $location['Classification'],
                'address' => $location['Address'],
                'type' => $location['Type'],
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        $this->command->info('Locations JSON imported successfully!');
    }
}
