import 'package:flutter/material.dart';
import 'conversation_screen.dart';

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
        title: const Text('Halal AI'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            SizedBox(
              height: 80,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                margin: EdgeInsets.zero,
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Conversation History',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.chat),
                    title: const Text('Start New Chat'),
                    onTap: _startNewChat,
                  ),
                  const Divider(),
                  for (var chat in _conversationHistory)
                    ListTile(
                      title: Text(chat),
                      onTap: () => _openConversation(chat),
                    ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.arrow_back),
              title: const Text('Return to Main Screen'),
              onTap: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column (
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/korehalal_logo.png',
              height: 150,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Welcome to Halal AI – Your Trusted Halal Companion',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Discover halal-friendly places with ease! Halal AI helps you find halal restaurants, mosques, and other Muslim-friendly locations near you.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Select or start conversation from the drawer.',
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
