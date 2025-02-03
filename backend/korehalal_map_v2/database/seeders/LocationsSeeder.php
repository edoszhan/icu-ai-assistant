<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;

class LocationsSeeder extends Seeder
{
    public function run()
    {
        $filePath = $filePath = base_path('dataset/combined_dataset.csv');

        if (!File::exists($filePath)) {
            $this->command->error("CSV file not found at {$filePath}");
            return;
        }

        $csvData = array_map('str_getcsv', file($filePath));
        $headers = ['latitude', 'longitude', 'name', 'category', 'time', 'description', 'classification', 'address', 'type'];
        unset($csvData[0]); // Remove first row (headers)

        foreach ($csvData as $row) {
            $rowData = array_combine($headers, $row);

            DB::table('locations')->insert([
                'latitude' => $rowData['latitude'],
                'longitude' => $rowData['longitude'],
                'name' => $rowData['name'],
                'category' => $rowData['category'],
                'time' => $rowData['time'],
                'description' => $rowData['description'],
                'classification' => $rowData['classification'],
                'address' => $rowData['address'],
                'type' => $rowData['type'],
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        $this->command->info('Locations CSV imported successfully!');
    }
}
