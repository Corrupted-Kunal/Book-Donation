import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationAttachmentMapView extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double height;

  const LocationAttachmentMapView({
    super.key,
    required this.latitude,
    required this.longitude,
    this.height = 160,
  });

  Future<void> _openExternalMaps() async {
    final lat = latitude.toStringAsFixed(6);
    final lng = longitude.toStringAsFixed(6);

    final webUrl =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    final androidGeo = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    final iosUrl = Uri.parse('comgooglemaps://?q=$lat,$lng');

    if (kIsWeb) {
      await launchUrl(webUrl, mode: LaunchMode.platformDefault);
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final ok = await launchUrl(androidGeo, mode: LaunchMode.externalApplication);
      if (!ok) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ok = await launchUrl(iosUrl, mode: LaunchMode.externalApplication);
      if (!ok) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
      return;
    }

    await launchUrl(webUrl, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: point, zoom: 15),
                markers: {
                  Marker(
                    markerId: const MarkerId('location_attachment'),
                    position: point,
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                compassEnabled: false,
              ),
            ),
            // Platform views can still consume taps in some builds; this
            // overlay guarantees the entire preview is tappable.
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _openExternalMaps,
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Material(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: _openExternalMaps,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      'Open map',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
