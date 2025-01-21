import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ConversationScreen extends StatefulWidget {
  final String title;
  const ConversationScreen({super.key, required this.title});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final String _apiUrl = 'http://127.0.0.1:8000/api/lambda-connected';

  Timer? _loadingTimer;
  String _loadingMessage = "Generating response ...";
  bool _showImage = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _loadingTimer?.cancel();
    super.dispose();
  }

  void _initializeChat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedChat = prefs.getString(widget.title);
    if (savedChat != null) {
      setState(() {
        _messages.addAll(List<Map<String, String>>.from(jsonDecode(savedChat)));
      });
    } else {
      setState(() {
        _messages.add({'role': 'bot', 'content': 'Hello, I am your Halal AI, how can I help you?'});
      });
    }
  }

  void _startLoadingAnimation() {
    int dotCount = 1;
    _loadingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _loadingMessage = "Generating response ${'.' * dotCount}";
        dotCount = (dotCount % 3) + 1;
      });
    });
  }

  void _stopLoadingAnimation() {
    _loadingTimer?.cancel();
    _loadingTimer = null;
  }

  void _handleSend(String userInput) async {
    if (userInput.isEmpty) return;

    setState(() {
      _showImage = false;
      _messages.add({'role': 'user', 'content': userInput});
      _messages.add({'role': 'bot', 'content': _loadingMessage});
      _controller.clear();
    });

    _startLoadingAnimation();

    final botResponse = await _sendToBackend(userInput);

    _stopLoadingAnimation();

    setState(() {
      _messages.removeLast();
      _messages.add({'role': 'bot', 'content': botResponse});
    });

    _saveChatLocally();
  }

  Future<String> _sendToBackend(String userInput) async {
    final Map<String, dynamic> requestPayload = {"prompt": userInput};

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestPayload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse['data']?.toString() ?? "No response from server.";
      } else {
        return "Sorry, we do not have data for this request. Try something else.";
      }
    } catch (e) {
      return "An error occurred: ${e.toString()}";
    }
  }

  void _saveChatLocally() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(widget.title, jsonEncode(_messages));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Visibility(
            visible: _showImage,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  'assets/prophet_image.jpg',
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                final isUser = message['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(message['content']!, style: const TextStyle(fontSize: 16)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Type your message...', border: OutlineInputBorder()),
                    onSubmitted: _handleSend,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _handleSend(_controller.text),
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
