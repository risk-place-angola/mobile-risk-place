/// Risk types as defined in the WebSocket documentation
/// See: https://github.com/risk-place-angola/backend-risk-place/blob/develop/docs/MOBILE_WEBSOCKET_INTEGRATION.md#d-notification-radius
enum RiskType {
  violence('Violence', 5000),
  fire('Fire', 3000),
  traffic('Traffic', 2000),
  infrastructure('Infrastructure', 1000),
  flood('Flood', 10000);

  const RiskType(this.label, this.defaultRadius);

  final String label;
  final double defaultRadius; // in meters

  /// Get RiskType from string
  static RiskType fromString(String value) {
    return RiskType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => RiskType.infrastructure,
    );
  }
}
