enum RiskLevel {
  veryLow('very_low', 'Muito Baixo'),
  low('low', 'Baixo'),
  medium('medium', 'Médio'),
  high('high', 'Alto'),
  veryHigh('very_high', 'Muito Alto');

  final String value;
  final String label;

  const RiskLevel(this.value, this.label);

  static RiskLevel fromValue(String value) {
    return RiskLevel.values.firstWhere(
      (level) => level.value == value,
      orElse: () => RiskLevel.medium,
    );
  }
}
