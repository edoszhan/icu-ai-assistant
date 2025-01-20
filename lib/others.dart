//   [IMPORTANT!] this part of the code refers to navigation to GoogleMaps Screen, which is not included right now

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


// <?php

// namespace App\Http\Controllers;

// use Illuminate\Http\Request;
// use Illuminate\Support\Facades\Http;

// class LambdaTestController extends Controller
// {
//     public function checkLambdaConnection(Request $request)
//     {
//         $validated = $request->validate([
//             'prompt' => 'required|string',
//             'latitude' => 'required|numeric',
//             'longitude' => 'required|numeric',
//         ]);

//         $lambdaUrl = env('AWS_LAMBDA_URL');

//         try {
//             $response = Http::post($lambdaUrl, [
//                 'prompt' => $validated['prompt'],
//                 'latitude' => $validated['latitude'],
//                 'longitude' => $validated['longitude'],
//             ]);

//             if ($response->successful()) {
//                 return response()->json([
//                     'success' => true,
//                     'message' => 'Successfully connected to Lambda!',
//                     'data' => $response->json(),
//                 ]);
//             }

//             return response()->json([
//                 'success' => false,
//                 'message' => 'Failed to connect to Lambda.',
//                 'status' => $response->status(),
//                 'error' => $response->body(),
//             ]);

//         } catch (\Exception $e) {
//             return response()->json([
//                 'success' => false,
//                 'message' => 'Error connecting to Lambda.',
//                 'error' => $e->getMessage(),
//             ]);
//         }
//     }
// }

