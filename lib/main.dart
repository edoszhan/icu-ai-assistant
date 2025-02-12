import 'package:flutter/material.dart';
import 'guide_screen.dart';
import 'google_maps_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff002113)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Korehalal Trip'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to the Halal AI Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: const Text('Open Halal AI'),
            ),
            const SizedBox(height: 10), 
            ElevatedButton(
              onPressed: () {
                // Navigate to the Google Maps Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GoogleMapScreen(title: 'Explore Locations')),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: const Text('Explore Locations'),
            ),
          ],
        ),
      ),
    );
  }
}
