import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

final markersProvider = StreamProvider<List<Marker>>((ref) async* {
  final saida = <Marker>[];
  final random = Random();

  for (var i = 0; i < 250; i++) {
    // Simulate delay for each marker, but yield every 10 markers
    await Future.delayed(Duration(milliseconds: 5));
    final double latOffset =
        (random.nextDouble() * 0.1) - 0.05; // -0.05 to 0.05 degrees (~5.5km)
    final double lonOffset =
        (random.nextDouble() * 0.1) - 0.05; // -0.05 to 0.05 degrees (~5.5km)

    saida.add(
      Marker(
        width: 100.0,
        height: 100.0,
        point: LatLng(-8.852845 + latOffset, 13.265561 + lonOffset),
        child: Icon(
          Icons.warning,
          size: 40.0,
          color: Colors.red,
        ),
      ),
    );

    if ((i + 1) % 10 == 0) {
      yield List.from(saida); // Yield a new list every 10 markers
    }
  }
  yield List.from(saida); // Yield any remaining markers
});
