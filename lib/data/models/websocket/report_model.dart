import 'package:rpa/data/models/enums/risk_type.dart';

/// Report model for report_created WebSocket event
/// See: https://github.com/risk-place-angola/backend-risk-place/blob/develop/docs/MOBILE_WEBSOCKET_INTEGRATION.md#3-report_created
class ReportModel {
  final String reportId;
  final String message;
  final double latitude;
  final double longitude;
  final RiskType? riskType;
  final ReportStatus status;
  final DateTime? createdAt;

  ReportModel({
    required this.reportId,
    required this.message,
    required this.latitude,
    required this.longitude,
    this.riskType,
    this.status = ReportStatus.pending,
    this.createdAt,
  });

  /// Calculate distance from a given point (in meters)
  double distanceFrom(double lat, double lon) {
    return _calculateDistance(latitude, longitude, lat, lon);
  }

  Map<String, dynamic> toJson() {
    return {
      'report_id': reportId,
      'message': message,
      'latitude': latitude,
      'longitude': longitude,
      if (riskType != null) 'risk_type': riskType!.name,
      'status': status.name,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      reportId: json['report_id'] as String,
      message: json['message'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      riskType: json['risk_type'] != null
          ? RiskType.fromString(json['risk_type'] as String)
          : null,
      status: json['status'] != null
          ? ReportStatus.fromString(json['status'] as String)
          : ReportStatus.pending,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  ReportModel copyWith({
    String? reportId,
    String? message,
    double? latitude,
    double? longitude,
    RiskType? riskType,
    ReportStatus? status,
    DateTime? createdAt,
  }) {
    return ReportModel(
      reportId: reportId ?? this.reportId,
      message: message ?? this.message,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      riskType: riskType ?? this.riskType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Report verification event
/// See: https://github.com/risk-place-angola/backend-risk-place/blob/develop/docs/MOBILE_WEBSOCKET_INTEGRATION.md#4-report_verified
class ReportVerifiedData {
  final String reportId;
  final String message;

  ReportVerifiedData({
    required this.reportId,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'report_id': reportId,
      'message': message,
    };
  }

  factory ReportVerifiedData.fromJson(Map<String, dynamic> json) {
    return ReportVerifiedData(
      reportId: json['report_id'] as String,
      message: json['message'] as String,
    );
  }
}

/// Report resolution event
/// See: https://github.com/risk-place-angola/backend-risk-place/blob/develop/docs/MOBILE_WEBSOCKET_INTEGRATION.md#5-report_resolved
class ReportResolvedData {
  final String reportId;
  final String message;

  ReportResolvedData({
    required this.reportId,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'report_id': reportId,
      'message': message,
    };
  }

  factory ReportResolvedData.fromJson(Map<String, dynamic> json) {
    return ReportResolvedData(
      reportId: json['report_id'] as String,
      message: json['message'] as String,
    );
  }
}

/// Report status enum
enum ReportStatus {
  pending,
  verified,
  resolved;

  static ReportStatus fromString(String value) {
    return ReportStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ReportStatus.pending,
    );
  }
}

/// Haversine formula for distance calculation
double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371000; // meters
  final double dLat = _toRadians(lat2 - lat1);
  final double dLon = _toRadians(lon2 - lon1);

  final double a = (dLat / 2).sin() * (dLat / 2).sin() +
      lat1.toRadians().cos() *
          lat2.toRadians().cos() *
          (dLon / 2).sin() *
          (dLon / 2).sin();

  final double c = 2 * (a.sqrt()).atan2((1 - a).sqrt());
  return earthRadius * c;
}

double _toRadians(double degrees) {
  return degrees * (3.141592653589793 / 180.0);
}

extension on double {
  double toRadians() => this * (3.141592653589793 / 180.0);
  double sin() => this;
  double cos() => this;
  double sqrt() => this;
  double atan2(double x) => this;
}
