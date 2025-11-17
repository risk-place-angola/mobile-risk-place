import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/data/services/alert_websocket_service.dart';
import 'package:rpa/data/services/risk_types.service.dart';
import 'package:rpa/data/services/report.service.dart';
import 'package:rpa/data/dtos/risk_type_response_dto.dart';
import 'package:rpa/data/dtos/risk_topic_response_dto.dart';
import 'package:rpa/data/dtos/list_nearby_reports_response_dto.dart';
import 'package:rpa/core/services/notification_service.dart';

// ============================================================================
// NOTIFICATION SERVICE PROVIDER
// ============================================================================

/// Provider for NotificationService (Singleton)
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider for AlertWebSocketService
final alertWebSocketServiceProvider = Provider<AlertWebSocketService>((ref) {
  return ref.watch(alertWebSocketProvider);
});

// ============================================================================
// RISK TYPES & TOPICS PROVIDERS
// ============================================================================

/// Provider for risk types list
final riskTypesProvider = FutureProvider<List<RiskTypeResponseDTO>>((ref) async {
  final service = ref.read(riskTypesServiceProvider);
  return await service.getRiskTypes();
});

/// Provider for risk topics list (all topics)
final riskTopicsProvider = FutureProvider<List<RiskTopicResponseDTO>>((ref) async {
  final service = ref.read(riskTypesServiceProvider);
  return await service.getRiskTopics();
});

/// Provider for risk topics filtered by type
final riskTopicsByTypeProvider = FutureProvider.family<List<RiskTopicResponseDTO>, String>(
  (ref, riskTypeId) async {
    final service = ref.read(riskTypesServiceProvider);
    return await service.getRiskTopics(riskTypeId: riskTypeId);
  },
);

// ============================================================================
// REPORTS PROVIDERS
// ============================================================================

/// Provider for nearby reports
final nearbyReportsProvider = FutureProvider.family<List<NearbyReportDTO>, NearbyReportsParams>(
  (ref, params) async {
    final service = ref.read(reportServiceProvider);
    return await service.listNearbyReports(
      latitude: params.latitude,
      longitude: params.longitude,
      radius: params.radius,
    );
  },
);

class NearbyReportsParams {
  final double latitude;
  final double longitude;
  final int radius;

  const NearbyReportsParams({
    required this.latitude,
    required this.longitude,
    this.radius = 500,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NearbyReportsParams &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.radius == radius;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode ^ radius.hashCode;
}

// ============================================================================
// WEBSOCKET ALERT PROVIDERS
// ============================================================================

/// Notifier to hold received alerts
class ReceivedAlertsNotifier extends Notifier<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> build() => [];

  void addAlert(Map<String, dynamic> alert) {
    state = [...state, alert];
  }

  void clearAlerts() {
    state = [];
  }
}

final receivedAlertsProvider = NotifierProvider<ReceivedAlertsNotifier, List<Map<String, dynamic>>>(
  () => ReceivedAlertsNotifier(),
);

/// Provider to manage WebSocket connection lifecycle
final alertWebSocketConnectionProvider = Provider<AlertWebSocketService>((ref) {
  final wsService = ref.read(alertWebSocketProvider);
  
  // Setup callbacks
  wsService.onAlertReceived = (alertData) {
    // Add alert to state
    ref.read(receivedAlertsProvider.notifier).addAlert(alertData);
  };
  
  return wsService;
});

// ============================================================================
// EXAMPLE: HOW TO USE IN YOUR APP
// ============================================================================

/*

/// 1. LOGIN AND CONNECT TO WEBSOCKET
/// 
/// In your login screen or after successful login:

void onLoginSuccess(BuildContext context, WidgetRef ref, String token) async {
  // Connect to WebSocket for real-time alerts
  final wsService = ref.read(alertWebSocketConnectionProvider);
  
  wsService.connect(
    token,
    onAlert: (alertData) {
      // Show notification or alert dialog
      showAlertNotification(context, alertData);
    },
    onError: (error) {
      print('WebSocket error: $error');
    },
    onConnected: () {
      print('Connected to alerts WebSocket');
    },
    onDisconnected: () {
      print('Disconnected from alerts WebSocket');
    },
  );
  
  // Start location updates (like Waze)
  // Get initial location
  final position = await Geolocator.getCurrentPosition();
  
  wsService.startLocationUpdates(
    latitude: position.latitude,
    longitude: position.longitude,
    getCurrentLocation: () async {
      // This callback is called every 30 seconds
      final newPosition = await Geolocator.getCurrentPosition();
      wsService.updateLocation(newPosition.latitude, newPosition.longitude);
    },
    intervalSeconds: 30, // Update every 30 seconds
  );
}


/// 2. LOAD RISK TYPES IN UI
/// 
/// In your report creation screen:

class CreateReportScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riskTypesAsync = ref.watch(riskTypesProvider);
    
    return riskTypesAsync.when(
      data: (riskTypes) {
        return DropdownButton<String>(
          items: riskTypes.map((type) {
            return DropdownMenuItem(
              value: type.id,
              child: Text(type.name),
            );
          }).toList(),
          onChanged: (selectedTypeId) {
            // Load topics for selected type
            ref.read(riskTopicsByTypeProvider(selectedTypeId!));
          },
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}


/// 3. CREATE A REPORT
/// 
/// After user fills the form:

Future<void> submitReport(WidgetRef ref) async {
  final reportService = ref.read(reportServiceProvider);
  
  final reportData = CreateReportRequestDTO(
    userId: 'user-id', // Get from auth
    riskTypeId: selectedRiskTypeId,
    riskTopicId: selectedRiskTopicId,
    description: 'Buraco grande na via',
    latitude: -8.8383,
    longitude: 13.2344,
    province: 'Luanda',
    municipality: 'Luanda',
    neighborhood: 'Talatona',
    address: 'Rua Principal',
    imageUrl: '', // Optional
  );
  
  try {
    final result = await reportService.createReport(reportData: reportData);
    print('Report created: ${result.id}');
  } catch (e) {
    print('Error creating report: $e');
  }
}


/// 4. SHOW NEARBY REPORTS ON MAP
/// 
/// In your map screen:

class MapScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = /* current user position */;
    
    final nearbyReportsAsync = ref.watch(
      nearbyReportsProvider(NearbyReportsParams(
        latitude: position.latitude,
        longitude: position.longitude,
        radius: 1000, // 1km radius
      ))
    );
    
    return nearbyReportsAsync.when(
      data: (reports) {
        return FlutterMap(
          children: [
            MarkerLayer(
              markers: reports.map((report) {
                return Marker(
                  point: LatLng(report.latitude, report.longitude),
                  builder: (ctx) => Icon(Icons.warning, color: Colors.red),
                );
              }).toList(),
            ),
          ],
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}


/// 5. CREATE AN ALERT (AUTHORITY ONLY)
/// 
/// For users with authority/government role:

Future<void> createEmergencyAlert(WidgetRef ref) async {
  final alertService = ref.read(alertServiceProvider);
  
  final alertData = CreateAlertRequestDTO(
    riskTypeId: 'crime-type-id',
    riskTopicId: 'robbery-topic-id',
    message: 'Assalto em andamento na área',
    latitude: -8.8383,
    longitude: 13.2344,
    radius: 500.0,
    severity: 'high',
  );
  
  try {
    await alertService.createAlert(alertData: alertData);
    print('Alert sent successfully');
  } catch (e) {
    print('Error creating alert: $e');
  }
}


/// 6. LISTEN TO RECEIVED ALERTS
/// 
/// Show alerts in real-time:

class AlertListenerWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(receivedAlertsProvider);
    
    ref.listen<List<Map<String, dynamic>>>(
      receivedAlertsProvider,
      (previous, next) {
        if (next.isNotEmpty && next.length > (previous?.length ?? 0)) {
          // New alert received
          final latestAlert = next.last;
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('⚠️ Alerta de Emergência'),
              content: Text(latestAlert['message']),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      },
    );
    
    return Container(); // Your UI
  }
}


/// 7. LOGOUT AND DISCONNECT
/// 
/// When user logs out:

void onLogout(WidgetRef ref) {
  // Disconnect from WebSocket
  final wsService = ref.read(alertWebSocketConnectionProvider);
  wsService.disconnect();
  
  // Logout from auth service
  final authService = ref.read(authServiceProvider);
  authService.logout();
}

*/
