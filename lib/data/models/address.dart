class Address {
  final String country;
  final String municipality;
  final String neighborhood;
  final String province;
  final String zipCode;

  const Address({
    required this.country,
    required this.municipality,
    required this.neighborhood,
    required this.province,
    required this.zipCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      country: json['country'] ?? '',
      municipality: json['municipality'] ?? '',
      neighborhood: json['neighborhood'] ?? '',
      province: json['province'] ?? '',
      zipCode: json['zipCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'country': country,
        'municipality': municipality,
        'neighborhood': neighborhood,
        'province': province,
        'zipCode': zipCode,
      };
}
