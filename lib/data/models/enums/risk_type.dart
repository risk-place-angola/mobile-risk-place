enum RiskType {
  crime('Crime', 1000),
  accident('Accident', 500),
  naturalDisaster('Natural Disaster', 2000),
  fire('Fire', 1500),
  health('Health', 1000),
  infrastructure('Infrastructure', 800),
  environment('Environment', 1000),
  violence('Violence', 1200),
  publicSafety('Public Safety', 1000),
  traffic('Traffic', 600),
  urbanIssue('Urban Issue', 500);

  const RiskType(this.label, this.defaultRadius);

  final String label;
  final double defaultRadius;

  static RiskType fromString(String value) {
    return RiskType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => RiskType.infrastructure,
    );
  }
}
