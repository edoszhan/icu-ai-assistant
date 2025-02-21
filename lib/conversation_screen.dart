import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_drawer.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class ConversationScreen extends StatefulWidget {
  final String title;
  const ConversationScreen({super.key, required this.title});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _apiUrl = 'http://127.0.0.1:8000/api/generate-response'; // this needs to be changed to proper link
  bool _showImage = true;
  bool _isStreaming = false;
  StreamSubscription? _streamSubscription;
  late Timer _typingTimer = Timer(Duration.zero, () {});
  int _dotCount = 1;
  List<String> _conversationHistory = [];
  bool _isBlurred = false;
  String _selectedText = "";

  void _fetchConversationHistory() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _conversationHistory = [
        'Chat with Halal AI',
        'Favorite Restaurants',
        'Travel Recommendations',
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ConversationScreen(title: title)),
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _fetchConversationHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    _streamSubscription?.cancel();
    _scrollController.dispose();

    if (_typingTimer.isActive) {
      _typingTimer.cancel();
    }
    super.dispose();
  }

  void _initializeChat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedChat = prefs.getString(widget.title);
    if (savedChat != null) {
      setState(() {
        _messages.add({'role': 'bot', 'content': 'Hello, I am your Halal AI, how can I help you?'});
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      }
    });
  }

  void _showMessageOptions(BuildContext context, String message) {
    setState(() {
      _isBlurred = true;  // added for blurring effect
      _selectedText = message;
    });

    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),  // Dark overlay
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMessageOptions(context, message),
    ).then((_) {
      setState(() {
        _isBlurred = false;  
      });
    });
  }

  Widget _buildMessageOptions(BuildContext context, String message) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.copy, color: Colors.teal),
              title: Text("Copy"),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Copied to clipboard")),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.text_fields, color: Colors.teal),
              title: Text("Select Text"),
              onTap: () {
                Navigator.pop(context);
                _showTextSelectionDialog(message);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTextSelectionDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SelectableText(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }


  void _handleSend(String userInput) async {
    if (userInput.isEmpty) return;

    setState(() {
      _showImage = false;
      _isStreaming = true;
      _messages.add({'role': 'user', 'content': userInput});
      _messages.add({'role': 'bot', 'content': 'Generating answer...'}); // Add empty bot message for streaming updates
      _controller.clear();
    });

    _scrollToBottom();
    _startTypingAnimation();

    await _sendToBackend(userInput);
    _saveChatLocally();
  }

   void _startTypingAnimation() {
      _typingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _dotCount = (_dotCount % 5) + 1;
          _messages.last['content'] = 'Generating answer' + '.' * _dotCount;
        });
      });
    }

   void _stopStreaming() {
      _streamSubscription?.cancel(); // Stop streaming
      _typingTimer.cancel();
      setState(() {
        _isStreaming = false; // Hide stop button
      });
    }

  Future<void> _sendToBackend(String userInput) async {
    final Map<String, String> requestPayload = {"prompt": userInput};

    try {
      final request = http.Request("POST", Uri.parse(_apiUrl))
        ..headers["Content-Type"] = "application/json"
        ..body = jsonEncode(requestPayload);

      final streamedResponse = await http.Client().send(request);

      if (streamedResponse.statusCode == 200) {
        final stream = streamedResponse.stream.transform(utf8.decoder);
        String botMessage = "";
        String buffer = "";
        String lastToken = "";
        bool lastTokenHadSpace = false;

        _streamSubscription = stream.listen((chunk) {
          if (chunk.startsWith("data: ")) {
            String token = chunk.substring(6).trim();

            if (token == "[DONE]") {
              _stopStreaming(); // Stop when done
              return;
            }

            bool tokenHasLeadingSpace = token.startsWith(" ");
            token = token.trim();

            if (lastToken.isNotEmpty && !lastTokenHadSpace && !tokenHasLeadingSpace) {
              buffer += token;
            } else {
              if (buffer.isNotEmpty) botMessage += buffer + " ";
              buffer = token;
            }

            lastTokenHadSpace = RegExp(r'[.,!?;:\s]$').hasMatch(token);
            lastToken = token;

            if (mounted) {
              setState(() {
                _messages.last['content'] = botMessage + buffer;
              });
            }
             _scrollToBottom();
          }
        });

         _streamSubscription!.onDone(() {
          _stopStreaming();
          _scrollToBottom();
        });

      } else {
        _stopStreaming();
        setState(() {
          _messages.last['content'] = "Error: Unable to fetch response.";
        });
      }
      } catch (e) {
      _stopStreaming();
      setState(() {
        _messages.last['content'] = "An error occurred: ${e.toString()}";
      });
    }
  }

  void _saveChatLocally() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(widget.title, jsonEncode(_messages));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
        openConversation: _openConversation,
        startNewChat: _startNewChat,
        conversationHistory: _conversationHistory,
      ),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.teal,
        elevation: 4,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
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
                  controller: _scrollController,
                  reverse: true,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[_messages.length - 1 - index];
                    final isUser = message['role'] == 'user';
                    return GestureDetector(
                      onTap: () => _showMessageOptions(context, message['content']),
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
                        minLines: 1,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          hintText: 'Type your message...',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: _handleSend,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _isStreaming
                        ? IconButton(
                            onPressed: _stopStreaming,
                            icon: const Icon(Icons.stop, color: Colors.red),
                            iconSize: 28,
                            tooltip: "Stop Response",
                          )
                        : IconButton(
                            onPressed: () => _handleSend(_controller.text),
                            icon: const Icon(Icons.send, color: Colors.teal),
                            iconSize: 28,
                            tooltip: "Send",
                          ),
                  ],
                ),
              ),
            ],
          ),
          if (_isBlurred)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: Colors.black.withOpacity(0.1)),
              ),
            ),
        ],
      ),
    );
  }

}
