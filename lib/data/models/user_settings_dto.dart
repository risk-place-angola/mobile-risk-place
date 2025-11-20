import 'package:rpa/domain/entities/user_settings.dart';

class UserSettingsDto {
  final String id;
  final String userId;
  final bool notificationsEnabled;
  final List<String> notificationAlertTypes;
  final int notificationAlertRadiusMeters;
  final List<String> notificationReportTypes;
  final int notificationReportRadiusMeters;
  final bool locationSharingEnabled;
  final bool locationHistoryEnabled;
  final String profileVisibility;
  final bool anonymousReports;
  final bool showOnlineStatus;
  final bool autoAlertsEnabled;
  final bool dangerZonesEnabled;
  final bool timeBasedAlertsEnabled;
  final String highRiskStartTime;
  final String highRiskEndTime;
  final bool nightModeEnabled;
  final String nightModeStartTime;
  final String nightModeEndTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSettingsDto({
    required this.id,
    required this.userId,
    required this.notificationsEnabled,
    required this.notificationAlertTypes,
    required this.notificationAlertRadiusMeters,
    required this.notificationReportTypes,
    required this.notificationReportRadiusMeters,
    required this.locationSharingEnabled,
    required this.locationHistoryEnabled,
    required this.profileVisibility,
    required this.anonymousReports,
    required this.showOnlineStatus,
    required this.autoAlertsEnabled,
    required this.dangerZonesEnabled,
    required this.timeBasedAlertsEnabled,
    required this.highRiskStartTime,
    required this.highRiskEndTime,
    required this.nightModeEnabled,
    required this.nightModeStartTime,
    required this.nightModeEndTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserSettingsDto.fromJson(Map<String, dynamic> json) {
    return UserSettingsDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      notificationsEnabled: json['notifications_enabled'] as bool,
      notificationAlertTypes:
          (json['notification_alert_types'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [],
      notificationAlertRadiusMeters:
          json['notification_alert_radius_mins'] as int,
      notificationReportTypes:
          (json['notification_report_types'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [],
      notificationReportRadiusMeters:
          json['notification_report_radius_mins'] as int,
      locationSharingEnabled: json['location_sharing_enabled'] as bool,
      locationHistoryEnabled: json['location_history_enabled'] as bool,
      profileVisibility: json['profile_visibility'] as String,
      anonymousReports: json['anonymous_reports'] as bool,
      showOnlineStatus: json['show_online_status'] as bool,
      autoAlertsEnabled: json['auto_alerts_enabled'] as bool,
      dangerZonesEnabled: json['danger_zones_enabled'] as bool,
      timeBasedAlertsEnabled: json['time_based_alerts_enabled'] as bool,
      highRiskStartTime: json['high_risk_start_time'] as String,
      highRiskEndTime: json['high_risk_end_time'] as String,
      nightModeEnabled: json['night_mode_enabled'] as bool,
      nightModeStartTime: json['night_mode_start_time'] as String,
      nightModeEndTime: json['night_mode_end_time'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications_enabled': notificationsEnabled,
      'notification_alert_types': notificationAlertTypes,
      'notification_alert_radius_mins': notificationAlertRadiusMeters,
      'notification_report_types': notificationReportTypes,
      'notification_report_radius_mins': notificationReportRadiusMeters,
      'location_sharing_enabled': locationSharingEnabled,
      'location_history_enabled': locationHistoryEnabled,
      'profile_visibility': profileVisibility,
      'anonymous_reports': anonymousReports,
      'show_online_status': showOnlineStatus,
      'auto_alerts_enabled': autoAlertsEnabled,
      'danger_zones_enabled': dangerZonesEnabled,
      'time_based_alerts_enabled': timeBasedAlertsEnabled,
      'high_risk_start_time': highRiskStartTime,
      'high_risk_end_time': highRiskEndTime,
      'night_mode_enabled': nightModeEnabled,
      'night_mode_start_time': nightModeStartTime,
      'night_mode_end_time': nightModeEndTime,
    };
  }

  UserSettings toEntity() {
    return UserSettings(
      id: id,
      userId: userId,
      notificationsEnabled: notificationsEnabled,
      notificationAlertTypes: notificationAlertTypes
          .map((type) => AlertType.fromString(type))
          .toList(),
      notificationAlertRadiusMeters: notificationAlertRadiusMeters,
      notificationReportTypes: notificationReportTypes
          .map((type) => ReportType.fromString(type))
          .toList(),
      notificationReportRadiusMeters: notificationReportRadiusMeters,
      locationSharingEnabled: locationSharingEnabled,
      locationHistoryEnabled: locationHistoryEnabled,
      profileVisibility: ProfileVisibility.fromString(profileVisibility),
      anonymousReports: anonymousReports,
      showOnlineStatus: showOnlineStatus,
      autoAlertsEnabled: autoAlertsEnabled,
      dangerZonesEnabled: dangerZonesEnabled,
      timeBasedAlertsEnabled: timeBasedAlertsEnabled,
      highRiskStartTime: highRiskStartTime,
      highRiskEndTime: highRiskEndTime,
      nightModeEnabled: nightModeEnabled,
      nightModeStartTime: nightModeStartTime,
      nightModeEndTime: nightModeEndTime,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory UserSettingsDto.fromEntity(UserSettings entity) {
    return UserSettingsDto(
      id: entity.id,
      userId: entity.userId,
      notificationsEnabled: entity.notificationsEnabled,
      notificationAlertTypes:
          entity.notificationAlertTypes.map((type) => type.name).toList(),
      notificationAlertRadiusMeters: entity.notificationAlertRadiusMeters,
      notificationReportTypes:
          entity.notificationReportTypes.map((type) => type.name).toList(),
      notificationReportRadiusMeters: entity.notificationReportRadiusMeters,
      locationSharingEnabled: entity.locationSharingEnabled,
      locationHistoryEnabled: entity.locationHistoryEnabled,
      profileVisibility: entity.profileVisibility.name,
      anonymousReports: entity.anonymousReports,
      showOnlineStatus: entity.showOnlineStatus,
      autoAlertsEnabled: entity.autoAlertsEnabled,
      dangerZonesEnabled: entity.dangerZonesEnabled,
      timeBasedAlertsEnabled: entity.timeBasedAlertsEnabled,
      highRiskStartTime: entity.highRiskStartTime,
      highRiskEndTime: entity.highRiskEndTime,
      nightModeEnabled: entity.nightModeEnabled,
      nightModeStartTime: entity.nightModeStartTime,
      nightModeEndTime: entity.nightModeEndTime,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
