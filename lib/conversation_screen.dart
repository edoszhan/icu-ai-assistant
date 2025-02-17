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
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final String _apiUrl = 'http://127.0.0.1:8000/api/generate-response';
  bool _showImage = true;
  bool _isStreaming = false;
  StreamSubscription? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _streamSubscription?.cancel();
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

  void _handleSend(String userInput) async {
    if (userInput.isEmpty) return;

    setState(() {
      _showImage = false;
      _isStreaming = true;
      _messages.add({'role': 'user', 'content': userInput});
      _messages.add({'role': 'bot', 'content': 'Generating answer...'}); // Add empty bot message for streaming updates
      _controller.clear();
    });

    await _sendToBackend(userInput);
    _saveChatLocally();
  }

   void _stopStreaming() {
    _streamSubscription?.cancel(); // Stop streaming
    setState(() {
      _isStreaming = false; // Hide stop button
    });
  }

  // Future<void> _sendToBackend(String userInput) async {
  //   final Map<String, String> requestPayload = {"prompt": userInput};

  //   try {
  //     final request = http.Request("POST", Uri.parse(_apiUrl))
  //       ..headers["Content-Type"] = "application/json"
  //       ..body = jsonEncode(requestPayload);

  //     final streamedResponse = await http.Client().send(request);

  //     if (streamedResponse.statusCode == 200) {
  //       final stream = streamedResponse.stream.transform(utf8.decoder);
  //       String botMessage = "";
  //       String buffer = "";

  //       await for (var chunk in stream) {
  //         if (chunk.startsWith("data: ")) {
  //           String token = chunk.substring(6).trim(); // Remove 'data: ' prefix

  //           if (token == "[DONE]") break; // Stop streaming when done

  //           // Ensure spacing before words, but not inside a word split across tokens
  //           if (buffer.isNotEmpty && !buffer.endsWith(" ") && !token.startsWith(" ")) {
  //             buffer += " ";
  //           }
  //           buffer += token;

  //           // If token ends in a space or punctuation, append to final output
  //           if (RegExp(r'[.,!?;:\s]').hasMatch(token)) {
  //             botMessage += buffer;
  //             buffer = ""; // Reset buffer
  //           }

  //           setState(() {
  //             _messages.last['content'] = botMessage + buffer; // Update UI progressively
  //           });
  //         }
  //       }

  //       // Append any remaining text in buffer after streaming ends
  //       if (buffer.isNotEmpty) {
  //         botMessage += buffer;
  //         setState(() {
  //           _messages.last['content'] = botMessage;
  //         });
  //       }
  //     } else {
  //       setState(() {
  //         _messages.last['content'] = "Error: Unable to fetch response.";
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _messages.last['content'] = "An error occurred: ${e.toString()}";
  //     });
  //   }
  // }

  // Future<void> _sendToBackend(String userInput) async {
  //   final Map<String, String> requestPayload = {"prompt": userInput};

  //   try {
  //     final request = http.Request("POST", Uri.parse(_apiUrl))
  //       ..headers["Content-Type"] = "application/json"
  //       ..body = jsonEncode(requestPayload);

  //     final streamedResponse = await http.Client().send(request);

  //     if (streamedResponse.statusCode == 200) {
  //       final stream = streamedResponse.stream.transform(utf8.decoder);
  //       String botMessage = "";
  //       String buffer = "";
  //       String lastToken = "";
  //       bool lastTokenHadSpace = false;

  //       await for (var chunk in stream) {
  //         if (chunk.startsWith("data: ")) {
  //           String token = chunk.substring(6).trim(); // Remove 'data: ' prefix

  //           if (token == "[DONE]") break; // Stop streaming when done

  //           bool tokenHasLeadingSpace = token.startsWith(" ");
  //           token = token.trim(); // Remove any leading space for processing

  //           // Merge words properly if split across multiple tokens
  //           if (lastToken.isNotEmpty && !lastTokenHadSpace && !tokenHasLeadingSpace) {
  //             buffer += token; // Merge with previous token
  //           } else {
  //             if (buffer.isNotEmpty) botMessage += buffer + " ";
  //             buffer = token;
  //           }

  //           // Check if this token ends with punctuation or a space
  //           lastTokenHadSpace = RegExp(r'[.,!?;:\s]$').hasMatch(token);
  //           lastToken = token;

  //           setState(() {
  //             _messages.last['content'] = botMessage + buffer; // Update UI progressively
  //           });
  //         }
  //       }

  //       // Append any remaining text in buffer after streaming ends
  //       if (buffer.isNotEmpty) {
  //         botMessage += buffer;
  //         setState(() {
  //           _messages.last['content'] = botMessage;
  //         });
  //       }
  //     } else {
  //       setState(() {
  //         _messages.last['content'] = "Error: Unable to fetch response.";
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _messages.last['content'] = "An error occurred: ${e.toString()}";
  //     });
  //   }
  // }

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
          }
        });

        _streamSubscription!.onDone(() {
          if (mounted) {
            setState(() {
              _isStreaming = false;
            });
          }
        });

      } else {
        setState(() {
          _isStreaming = false;
          _messages.last['content'] = "Error: Unable to fetch response.";
        });
      }
    } catch (e) {
      setState(() {
        _isStreaming = false;
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
      ),
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
                    minLines: 1, 
                    maxLines: null, 
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(hintText: 'Type your message...', border: OutlineInputBorder()),
                    onSubmitted: _handleSend,
                  ),
                ),
                const SizedBox(width: 8),
                _isStreaming
                  ? IconButton(
                      onPressed: _stopStreaming,
                      icon: const Icon(Icons.stop, color: Colors.red), // Square stop icon
                      iconSize: 28, // Adjust size if needed
                      tooltip: "Stop Response",
                    )
                  : IconButton(
                      onPressed: () => _handleSend(_controller.text),
                      icon: const Icon(Icons.send, color: Colors.teal), // Arrow up send icon
                      iconSize: 28, // Adjust size if needed
                      tooltip: "Send",
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
