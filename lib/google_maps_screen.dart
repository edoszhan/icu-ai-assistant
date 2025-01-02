import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class GoogleMapScreen extends StatefulWidget {
  final String title;

  const GoogleMapScreen({super.key, required this.title});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  late GoogleMapController _mapController;
  LatLng _initialLocation = const LatLng(37.551170, 126.988228);
  Set<Marker> _markers = {};

  // Sample data for markers
  final List<Map<String, dynamic>> _locations = [
    {
      'id': '1',
      'name': 'Namsan Tower',
      'position': LatLng(37.551170, 126.988228),
      'description': 'A popular tourist spot in Seoul.'
    },
    {
      'id': '2',
      'name': 'Gyeongbokgung Palace',
      'position': LatLng(37.579617, 126.977041),
      'description': 'A historic palace in Seoul.'
    },
    {
      'id': '3',
      'name': 'Dongdaemun Market',
      'position': LatLng(37.570485, 127.009596),
      'description': 'A bustling shopping district.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadMarkers();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _initialLocation = LatLng(position.latitude, position.longitude);
    });
  }

  void _loadMarkers() {
    for (var location in _locations) {
      _markers.add(
        Marker(
          markerId: MarkerId(location['id']),
          position: location['position'],
          infoWindow: InfoWindow(
            title: location['name'],
            snippet: location['description'],
            onTap: () {
              _showLocationDetails(location);
            },
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
    setState(() {});
  }

  void _showLocationDetails(Map<String, dynamic> location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(location['name']),
        content: Text(location['description']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialLocation,
          zoom: 14.0,
        ),
        onMapCreated: (controller) => _mapController = controller,
        markers: _markers,
        myLocationEnabled: true,
        onTap: (LatLng tappedPoint) {
          setState(() {
            _markers.add(
              Marker(
                markerId: MarkerId(tappedPoint.toString()),
                position: tappedPoint,
                infoWindow: const InfoWindow(title: 'Custom Location'),
              ),
            );
          });
        },
      ),
    );
  }
}
