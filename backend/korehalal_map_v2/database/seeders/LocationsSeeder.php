<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;

class LocationsSeeder extends Seeder
{
    public function run()
    {
        $filePath = base_path('dataset/test_combined_dataset.csv');

        if (!File::exists($filePath)) {
            $this->command->error("CSV file not found at {$filePath}");
            return;
        }

        $csvData = array_map('str_getcsv', file($filePath));
        $headers = ['Latitude', 'Longitude', 'Name', 'Category', 'Time', 'Description', 'Classification', 'Address', 'Type'];
        unset($csvData[0]); // Remove first row (headers)

        foreach ($csvData as $row) {
            // Skip rows with incorrect column counts
            if (count($row) !== count($headers)) {
                $this->command->warn("Skipping row due to incorrect number of columns: " . implode(',', $row));
                continue;
            }

            $rowData = array_combine($headers, $row);

            DB::table('locations')->insert([
                'latitude' => $rowData['Latitude'],
                'longitude' => $rowData['Longitude'],
                'name' => $rowData['Name'],
                'category' => $rowData['Category'],
                'time' => $rowData['Time'],
                'description' => $rowData['Description'],
                'classification' => $rowData['Classification'],
                'address' => $rowData['Address'],
                'type' => $rowData['Type'],
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        $this->command->info('Locations CSV imported successfully!');
    }
}