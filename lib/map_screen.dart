import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'distance_map_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final List<Map<String, String>> _messages = [
    {'role': 'bot', 'content': 'Hello, I am your Halal AI, how can I help you?'}
  ];
  final TextEditingController _controller = TextEditingController();

  final double _userLat = 37.551170;
  final double _userLon = 126.988228;
  // final String _apiUrl = 'http://10.0.2.2:8000/api/find-location'; // if using android device
  // final String _apiUrl = 'http://127.0.0.1:8001/api/find-location'; // if using linux devices

  final String _apiUrl = 'http://127.0.0.1:8001/api/generate-response'; // if using linux devices

  Timer? _loadingTimer;
  String _loadingMessage = "Generating response .";
  bool _showImage = true;

  @override
  void dispose() {
    _controller.dispose();
    _loadingTimer?.cancel();
    super.dispose();
  }

  void _startLoadingAnimation() {
    int dotCount = 1;
    _loadingTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
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
      _showImage = false; // Hide the image after the first message
      _messages.add({'role': 'user', 'content': userInput});
      _messages.add({'role': 'bot', 'content': _loadingMessage});
      _controller.clear();
    });

    _startLoadingAnimation();

    final botResponse = await _sendToBackend(userInput);

    _stopLoadingAnimation();

    setState(() {
      _messages.removeLast(); // Remove the loading message
      _messages.add({'role': 'bot', 'content': botResponse});
    });
  }

//   void _handleSend(String userInput) async {
//   if (userInput.isEmpty) return;

//   setState(() {
//     _showImage = false;
//     _messages.add({'role': 'user', 'content': userInput});
//     _messages.add({'role': 'bot', 'content': _loadingMessage});
//     _controller.clear();
//   });

//   _startLoadingAnimation();

//   final botResponse = await _sendToBackend(userInput);

//   _stopLoadingAnimation();

//   setState(() {
//     _messages.removeLast();
//     _messages.add({'role': 'bot', 'content': botResponse});
//   });

//   // Simulate receiving location data from the backend
//   final List<Map<String, dynamic>> locationData = [
//     {'id': '1', 'name': 'By Tofu', 'position': LatLng(37.5460221, 126.9851827), 'description': 'A Korean vegetarian restaurant which works between 09:00 - 18:30. Closed on Tuesdays, Wednesdays.'},
//     {'id': '2', 'name': 'Kampungku', 'position': LatLng(37.5590205,126.9860206), 'description': 'A traditional Korean cafe which opens from 11:30 am to 9:30 pm'},
//   ];

//   // Navigate to GoogleMapScreen after 3 seconds
//   Future.delayed(const Duration(seconds: 3), () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => DistanceMapScreen(
//           title: 'Explore Locations',
//           currentLocation: LatLng(_userLat, _userLon),
//           locations: locationData,
//         ),
//       ),
//     );
//   });
// }

  Future<String> _sendToBackend(String userInput) async {
    final Map<String, dynamic> requestPayload = {
      "prompt": userInput,
    };

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestPayload),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.isEmpty) {
          return "No results found.";
        } else {
          return jsonResponse
              .map((item) =>
                  "${item['Name']} - ${item['Category']} - ${item['Time']} - ${item['Classification']} ")
              .join("\n");
        }
      } else {
        return "Sorry, we do not have data for this request. Try something else.";
      }
    } catch (e) {
      return "An error occurred: $e";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Halal AI'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                  height: 200,
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
                    child: Text(
                      message['content']!,
                      style: const TextStyle(fontSize: 16),
                    ),
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
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
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
           const SizedBox(height: 30), 
        ],
      ),
    );
  }
}
