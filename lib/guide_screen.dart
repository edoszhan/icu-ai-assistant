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
        title: const Text('Halal AI', style: TextStyle(color: Colors.white, fontSize:18, fontWeight:FontWeight.bold)),
        backgroundColor: Colors.teal,
      ),
      drawer: Container(
        width: 280, 
        decoration: const BoxDecoration(
          color: Color(0xFFF7F7F7), 
          border: Border(
            right: BorderSide(color: Colors.black26, width: 1),
          ),
        ),
        child: Drawer(
          child: Column(
            children: [
              SizedBox(
                height: 100, 
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xFF008080), 
                  ),
                  margin: EdgeInsets.zero,
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Conversation History',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.chat, color: Colors.teal),
                      title: const Text('Start New Chat', style: TextStyle(fontWeight: FontWeight.bold)),
                      onTap: _startNewChat,
                    ),
                    const Divider(thickness: 1, color: Colors.black26), 
                    for (var chat in _conversationHistory)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(10), 
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26, 
                              blurRadius: 3,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ), 
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), 
                          ),
                          title: Text(
                            chat,
                            style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white), 
                          onTap: () => _openConversation(chat),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(thickness: 1, color: Colors.black26),
              ListTile(
                leading: const Icon(Icons.arrow_back, color: Colors.red),
                title: const Text('Return to Main Screen', style: TextStyle(color: Colors.black, fontWeight : FontWeight.bold)),
                onTap: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
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