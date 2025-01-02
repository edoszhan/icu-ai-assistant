import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DistanceMapScreen extends StatefulWidget {
  final String title;
  final LatLng currentLocation;
  final List<Map<String, dynamic>> locations;

  const DistanceMapScreen({
    super.key,
    required this.title,
    required this.currentLocation,
    required this.locations,
  });

  @override
  State<DistanceMapScreen> createState() => _DistanceMapScreenState();
}

class _DistanceMapScreenState extends State<DistanceMapScreen> {
  late GoogleMapController _mapController;
  late Set<Marker> _markers;
  late Set<Polyline> _polylines;

  @override
  void initState() {
    super.initState();
    _initializeMarkersAndPolylines();
  }

  void _initializeMarkersAndPolylines() {
    _markers = {
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: widget.currentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
    };

    _polylines = {};

    for (var location in widget.locations) {
      final LatLng position = location['position'];

      // Add markers for suggested locations
      _markers.add(
        Marker(
          markerId: MarkerId(location['id']),
          position: position,
          infoWindow: InfoWindow(
            title: location['name'],
            snippet: location['description'],
          ),
        ),
      );

      // Add polylines to connect current location to suggested locations
      _polylines.add(
        Polyline(
          polylineId: PolylineId('line_to_${location['id']}'),
          points: [widget.currentLocation, position],
          color: Colors.blueAccent,
          width: 4,
        ),
      );
    }
  }

  void _adjustCameraView() {
    // Calculate the bounds to include all markers
    LatLngBounds bounds;
    if (widget.locations.isNotEmpty) {
      final List<LatLng> allPoints = [
        widget.currentLocation,
        ...widget.locations.map((loc) => loc['position'] as LatLng)
      ];
      bounds = _getLatLngBounds(allPoints);
    } else {
      bounds = LatLngBounds(
        southwest: widget.currentLocation,
        northeast: widget.currentLocation,
      );
    }

    _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  LatLngBounds _getLatLngBounds(List<LatLng> points) {
    double minLat = points.first.latitude, maxLat = points.first.latitude;
    double minLng = points.first.longitude, maxLng = points.first.longitude;

    for (LatLng point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
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
          target: widget.currentLocation,
          zoom: 14.0,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
          _adjustCameraView(); // Adjust camera to fit all markers
        },
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: false,
        zoomControlsEnabled: true,
      ),
    );
  }
}
