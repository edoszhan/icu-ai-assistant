import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final Function(String) openConversation;
  final VoidCallback startNewChat;
  final List<String> conversationHistory;

  const CustomDrawer({
    Key? key,
    required this.openConversation,
    required this.startNewChat,
    required this.conversationHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                    title: const Text(
                      'Start New Chat',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: startNewChat,
                  ),
                  const Divider(thickness: 1, color: Colors.black26),
                  for (var chat in conversationHistory)
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
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                        onTap: () => openConversation(chat),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(thickness: 1, color: Colors.black26),
            ListTile(
              leading: const Icon(Icons.arrow_back, color: Colors.red),
              title: const Text(
                'Return to Main Screen',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}
