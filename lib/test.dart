import 'package:flutter/material.dart';
import 'map_screen.dart';
import 'google_maps_screen.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFFF)),
        useMaterial3: true;
      ),
      home: const MyHomePage(title: 'Testing Widgets'),
    );
  }
}

class My 