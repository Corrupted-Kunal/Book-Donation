import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/location_service.dart';

class LocationPickResult {
  final double latitude;
  final double longitude;
  final String? caption;

  const LocationPickResult({
    required this.latitude,
    required this.longitude,
    this.caption,
  });
}

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final _captionController = TextEditingController();
  final _locationService = LocationService();
  LatLng? _currentLatLng;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _loadLocation() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final position = await _locationService.getCurrentPosition();
      setState(() {
        _currentLatLng = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _sendLocation() {
    final point = _currentLatLng;
    if (point == null) return;
    Navigator.of(context).pop(
      LocationPickResult(
        latitude: point.latitude,
        longitude: point.longitude,
        caption: _captionController.text.trim().isEmpty
            ? null
            : _captionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Share current location')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadLocation,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _currentLatLng!,
                          zoom: 16,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('current_location'),
                            position: _currentLatLng!,
                          ),
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Column(
                        children: [
                          TextField(
                            controller: _captionController,
                            decoration: const InputDecoration(
                              hintText: 'Add a caption (optional)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _sendLocation,
                              icon: const Icon(Icons.send),
                              label: const Text('Send location'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
