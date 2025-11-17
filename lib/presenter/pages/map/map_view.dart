import 'dart:developer' show log;
import 'dart:math' hide log;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:rpa/presenter/pages/map/providers/markers_provider.dart';

class MapView extends ConsumerStatefulWidget {
  const MapView({super.key});

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> {
  final MapController controller = MapController();

  @override
  Widget build(BuildContext context) {
    final streamMarkers = ref.watch(markersProvider);

    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        onMapReady: () {},
        initialCenter: LatLng(-8.852845, 13.265561),
        initialZoom: 12.0,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 100.0,
              height: 100.0,
              point: LatLng(-8.852845, 13.265561),
              child: Icon(
                Icons.person_pin_circle,
                size: 50.0,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        streamMarkers.when(
          data: (markers) {
            log('Loaded ${markers.length} markers', name: 'MapView');
            return MarkerLayer(markers: markers);
          },
          loading: () {
            log('Loading markers', name: 'MapView');
            return MarkerLayer(markers: []);
          },
          error: (error, stackTrace) {
            log('Error loading markers: $error', name: 'MapView');
            return MarkerLayer(markers: []);
          },
        ),
      ],
    );
  }
}
