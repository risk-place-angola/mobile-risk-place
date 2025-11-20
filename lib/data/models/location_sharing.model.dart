class LocationSharingSession {
  final String id;
  final String token;
  final String shareLink;
  final DateTime expiresAt;

  LocationSharingSession({
    required this.id,
    required this.token,
    required this.shareLink,
    required this.expiresAt,
  });

  factory LocationSharingSession.fromJson(Map<String, dynamic> json) {
    return LocationSharingSession(
      id: json['id'],
      token: json['token'],
      shareLink: json['share_link'],
      expiresAt: DateTime.parse(json['expires_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'token': token,
        'share_link': shareLink,
        'expires_at': expiresAt.toIso8601String(),
      };
}

class LocationSharingRequest {
  final int durationMinutes;
  final double latitude;
  final double longitude;

  LocationSharingRequest({
    required this.durationMinutes,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'duration_minutes': durationMinutes,
        'latitude': latitude,
        'longitude': longitude,
      };
}

class LocationUpdateRequest {
  final double latitude;
  final double longitude;

  LocationUpdateRequest({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}

class PublicLocationView {
  final String userName;
  final double latitude;
  final double longitude;
  final DateTime lastUpdated;
  final DateTime expiresAt;
  final bool isActive;

  PublicLocationView({
    required this.userName,
    required this.latitude,
    required this.longitude,
    required this.lastUpdated,
    required this.expiresAt,
    required this.isActive,
  });

  factory PublicLocationView.fromJson(Map<String, dynamic> json) {
    return PublicLocationView(
      userName: json['user_name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      lastUpdated: DateTime.parse(json['last_updated']),
      expiresAt: DateTime.parse(json['expires_at']),
      isActive: json['is_active'],
    );
  }
}

class LocationSharingStatus {
  final String status;

  LocationSharingStatus({required this.status});

  factory LocationSharingStatus.fromJson(Map<String, dynamic> json) {
    return LocationSharingStatus(status: json['status']);
  }
}
