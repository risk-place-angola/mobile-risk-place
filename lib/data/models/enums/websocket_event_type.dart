/// WebSocket event types as defined in the documentation
/// See: https://github.com/risk-place-angola/backend-risk-place/blob/develop/docs/MOBILE_WEBSOCKET_INTEGRATION.md#event-reference
enum WebSocketEventType {
  // Client → Server events
  updateLocation('update_location'),

  // Server → Client events
  locationUpdated('location_updated'),
  newAlert('new_alert'),
  reportCreated('report_created'),
  reportVerified('report_verified'),
  reportResolved('report_resolved');

  const WebSocketEventType(this.value);

  final String value;

  static WebSocketEventType fromString(String value) {
    return WebSocketEventType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw Exception('Unknown event type: $value'),
    );
  }
}
