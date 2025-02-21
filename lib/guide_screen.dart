import 'package:flutter/material.dart';
import 'conversation_screen.dart';
import 'custom_drawer.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<String> _conversationHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchConversationHistory();
  }

  void _fetchConversationHistory() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _conversationHistory = [
        'Chat with Halal AI',
        'Favorite Restaurants',
        'Travel Recommendations',
        // 'Halal Food Delivery',
        // 'Halal Food Recipes',
        // 'Halal Food Ingredients',
        // 'Halal Food Certifications',
        // 'Halal Food Preparation',
        // 'Halal Food Storage',
        // 'Halal Food Safety',
        // 'Halal Food Preservation',
        // 'Halal Food Packaging',
        // 'Hala Food Labeling',
      ];
    });
  }

  void _startNewChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ConversationScreen(title: "New Chat")),
    );
  }

  void _openConversation(String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ConversationScreen(title: title)),
    );
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halal AI', style: TextStyle(color: Colors.white, fontSize:18, fontWeight:FontWeight.bold)),
        backgroundColor: Colors.teal,
      ),
      drawer: CustomDrawer(
        openConversation: _openConversation,
        startNewChat: _startNewChat,
        conversationHistory: _conversationHistory,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/korehalal_logo.png',
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Welcome to Halal AI – Your Trusted Halal Companion',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Discover halal-friendly places with ease! Halal AI helps you find halal restaurants, mosques, and other Muslim-friendly locations near you.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Select or start a conversation from the drawer.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}