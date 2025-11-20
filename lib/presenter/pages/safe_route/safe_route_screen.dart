import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rpa/l10n/app_localizations.dart';
import 'package:rpa/data/models/safe_route.dart';
import 'package:rpa/data/models/enums/risk_level.dart';
import 'package:rpa/presenter/controllers/safe_route.controller.dart';
import 'package:rpa/presenter/pages/safe_route/search_destination_screen.dart';
import 'package:rpa/presenter/controllers/location.controller.dart';

class SafeRouteScreen extends ConsumerStatefulWidget {
  const SafeRouteScreen({super.key});

  @override
  ConsumerState<SafeRouteScreen> createState() => _SafeRouteScreenState();
}

class _SafeRouteScreenState extends ConsumerState<SafeRouteScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectDestination();
    });
  }

  Future<void> _selectDestination() async {
    final locationController = ref.read(locationControllerProvider);
    final position = locationController.currentPosition;

    if (position == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aguardando localização atual...'),
          ),
        );
      }
      return;
    }

    final origin = LatLng(position.latitude, position.longitude);

    if (!mounted) return;

    final destination = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => SearchDestinationScreen(origin: origin),
      ),
    );

    if (destination != null && mounted) {
      _calculateRoute(origin, destination);
    }
  }

  Future<void> _calculateRoute(LatLng origin, LatLng destination) async {
    final controller = ref.read(safeRouteControllerProvider);
    await controller.calculateSafeRoute(
      origin: origin,
      destination: destination,
    );
  }

  Color _getRiskLevelColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.veryLow:
        return Colors.green;
      case RiskLevel.low:
        return Colors.lightGreen;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.deepOrange;
      case RiskLevel.veryHigh:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(safeRouteControllerProvider);
    final locationController = ref.watch(locationControllerProvider);
    final position = locationController.currentPosition;
    final currentPosition = position != null
        ? LatLng(position.latitude, position.longitude)
        : const LatLng(-8.8383, 13.2344);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.safeRoute ?? 'Safe Route'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _selectDestination,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentPosition,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.riskplace.angola',
              ),
              if (controller.route != null) ...[
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: controller.route!.waypoints
                          .map((w) => LatLng(w.latitude, w.longitude))
                          .toList(),
                      color: _getRiskLevelColor(controller.route!.riskLevel),
                      strokeWidth: 5.0,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        controller.route!.originLat,
                        controller.route!.originLon,
                      ),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                    Marker(
                      point: LatLng(
                        controller.route!.destinationLat,
                        controller.route!.destinationLon,
                      ),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                    ...controller.route!.incidents.map(
                      (incident) => Marker(
                        point: LatLng(incident.latitude, incident.longitude),
                        width: 30,
                        height: 30,
                        child: const Icon(
                          Icons.warning,
                          color: Colors.orange,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          if (controller.status == RouteStatus.loading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          if (controller.route != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildRouteInfo(controller.route!),
            ),
          if (controller.status == RouteStatus.error)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.red,
                padding: const EdgeInsets.all(16),
                child: Text(
                  controller.errorMessage ?? 'Erro ao calcular rota',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRouteInfo(SafeRoute route) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Score de Segurança',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getRiskLevelColor(route.riskLevel),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${route.safetyScore.toStringAsFixed(1)}/100',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.straighten,
                  label: 'Distância',
                  value: '${route.distanceKm.toStringAsFixed(1)} km',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.access_time,
                  label: 'Tempo Est.',
                  value: '${route.estimatedDurationMinutes} min',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.shield,
                  label: 'Nível de Risco',
                  value: route.riskLevel.label,
                  color: _getRiskLevelColor(route.riskLevel),
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.warning_amber,
                  label: 'Incidentes',
                  value: '${route.incidentCount}',
                  color: route.incidentCount > 0 ? Colors.orange : Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.grey[600], size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
