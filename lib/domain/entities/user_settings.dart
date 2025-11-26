import 'package:rpa/l10n/app_localizations.dart';

enum ProfileVisibility {
  public,
  friends,
  private;

  String get displayName {
    switch (this) {
      case ProfileVisibility.public:
        return 'Público';
      case ProfileVisibility.friends:
        return 'Amigos';
      case ProfileVisibility.private:
        return 'Privado';
    }
  }

  String getLocalizedName(AppLocalizations l10n) {
    switch (this) {
      case ProfileVisibility.public:
        return l10n.visibilityPublic;
      case ProfileVisibility.friends:
        return l10n.visibilityFriends;
      case ProfileVisibility.private:
        return l10n.visibilityPrivate;
    }
  }

  static ProfileVisibility fromString(String value) {
    switch (value.toLowerCase()) {
      case 'public':
        return ProfileVisibility.public;
      case 'friends':
        return ProfileVisibility.friends;
      case 'private':
        return ProfileVisibility.private;
      default:
        return ProfileVisibility.public;
    }
  }
}

enum AlertType {
  low,
  medium,
  high,
  critical;

  String getLocalizedName(AppLocalizations l10n) {
    switch (this) {
      case AlertType.low:
        return l10n.alertTypeLow;
      case AlertType.medium:
        return l10n.alertTypeMedium;
      case AlertType.high:
        return l10n.alertTypeHigh;
      case AlertType.critical:
        return l10n.alertTypeCritical;
    }
  }

  static AlertType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return AlertType.low;
      case 'medium':
        return AlertType.medium;
      case 'high':
        return AlertType.high;
      case 'critical':
        return AlertType.critical;
      default:
        return AlertType.low;
    }
  }
}

enum ReportType {
  pending,
  verified,
  resolved,
  rejected;

  String getLocalizedName(AppLocalizations l10n) {
    switch (this) {
      case ReportType.pending:
        return l10n.pending;
      case ReportType.verified:
        return l10n.verified;
      case ReportType.resolved:
        return l10n.resolved;
      case ReportType.rejected:
        return l10n.reportTypeRejected;
    }
  }

  static ReportType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return ReportType.pending;
      case 'verified':
        return ReportType.verified;
      case 'resolved':
        return ReportType.resolved;
      case 'rejected':
        return ReportType.rejected;
      default:
        return ReportType.pending;
    }
  }
}

class UserSettings {
  final String id;
  final String userId;
  final bool notificationsEnabled;
  final List<AlertType> notificationAlertTypes;
  final int notificationAlertRadiusMeters;
  final List<ReportType> notificationReportTypes;
  final int notificationReportRadiusMeters;
  final bool locationSharingEnabled;
  final bool locationHistoryEnabled;
  final ProfileVisibility profileVisibility;
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

  UserSettings({
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

  UserSettings copyWith({
    String? id,
    String? userId,
    bool? notificationsEnabled,
    List<AlertType>? notificationAlertTypes,
    int? notificationAlertRadiusMeters,
    List<ReportType>? notificationReportTypes,
    int? notificationReportRadiusMeters,
    bool? locationSharingEnabled,
    bool? locationHistoryEnabled,
    ProfileVisibility? profileVisibility,
    bool? anonymousReports,
    bool? showOnlineStatus,
    bool? autoAlertsEnabled,
    bool? dangerZonesEnabled,
    bool? timeBasedAlertsEnabled,
    String? highRiskStartTime,
    String? highRiskEndTime,
    bool? nightModeEnabled,
    String? nightModeStartTime,
    String? nightModeEndTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationAlertTypes:
          notificationAlertTypes ?? this.notificationAlertTypes,
      notificationAlertRadiusMeters:
          notificationAlertRadiusMeters ?? this.notificationAlertRadiusMeters,
      notificationReportTypes:
          notificationReportTypes ?? this.notificationReportTypes,
      notificationReportRadiusMeters:
          notificationReportRadiusMeters ?? this.notificationReportRadiusMeters,
      locationSharingEnabled:
          locationSharingEnabled ?? this.locationSharingEnabled,
      locationHistoryEnabled:
          locationHistoryEnabled ?? this.locationHistoryEnabled,
      profileVisibility: profileVisibility ?? this.profileVisibility,
      anonymousReports: anonymousReports ?? this.anonymousReports,
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      autoAlertsEnabled: autoAlertsEnabled ?? this.autoAlertsEnabled,
      dangerZonesEnabled: dangerZonesEnabled ?? this.dangerZonesEnabled,
      timeBasedAlertsEnabled:
          timeBasedAlertsEnabled ?? this.timeBasedAlertsEnabled,
      highRiskStartTime: highRiskStartTime ?? this.highRiskStartTime,
      highRiskEndTime: highRiskEndTime ?? this.highRiskEndTime,
      nightModeEnabled: nightModeEnabled ?? this.nightModeEnabled,
      nightModeStartTime: nightModeStartTime ?? this.nightModeStartTime,
      nightModeEndTime: nightModeEndTime ?? this.nightModeEndTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
