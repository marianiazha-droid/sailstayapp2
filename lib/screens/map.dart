import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;

  // Initial camera position centered over Malaysia
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(4.2105, 101.9758), 
    zoom: 6.0,
  );

  // Define markers for islands
  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('langkawi'),
      position: LatLng(6.3500, 99.8000),
      infoWindow: InfoWindow(title: 'Langkawi', snippet: 'Kedah, Malaysia'),
    ),
    const Marker(
      markerId: MarkerId('tioman'),
      position: LatLng(2.8125, 104.1613),
      infoWindow: InfoWindow(title: 'Tioman Island', snippet: 'Pahang, Malaysia'),
    ),
    const Marker(
      markerId: MarkerId('redang'),
      position: LatLng(5.7844, 103.0069),
      infoWindow: InfoWindow(title: 'Redang Island', snippet: 'Terengganu, Malaysia'),
    ),
  };

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Island Explorer Map"),
        backgroundColor: const Color(0xFF2E1A78),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: _initialPosition,
        markers: _markers,
        myLocationEnabled: true, // Shows blue dot for user location
        compassEnabled: true,
        mapType: MapType.normal,
      ),
    );
  }
}