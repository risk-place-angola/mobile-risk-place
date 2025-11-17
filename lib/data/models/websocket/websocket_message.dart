import 'package:rpa/data/models/enums/websocket_event_type.dart';

/// Base WebSocket message structure
/// All messages follow this format:
/// {
///   "event": "event_name",
///   "data": { ... }
/// }
class WebSocketMessage<T> {
  final WebSocketEventType event;
  final T data;

  WebSocketMessage({
    required this.event,
    required this.data,
  });

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) dataToJson) {
    return {
      'event': event.value,
      'data': dataToJson(data),
    };
  }

  factory WebSocketMessage.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) dataFromJson,
  ) {
    return WebSocketMessage(
      event: WebSocketEventType.fromString(json['event'] as String),
      data: dataFromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

/// Update location request payload
class LocationUpdateData {
  final double latitude;
  final double longitude;

  LocationUpdateData({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory LocationUpdateData.fromJson(Map<String, dynamic> json) {
    return LocationUpdateData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

/// Location updated confirmation payload
class LocationUpdatedData {
  final String status;

  LocationUpdatedData({required this.status});

  Map<String, dynamic> toJson() {
    return {'status': status};
  }

  factory LocationUpdatedData.fromJson(Map<String, dynamic> json) {
    return LocationUpdatedData(
      status: json['status'] as String,
    );
  }
}
