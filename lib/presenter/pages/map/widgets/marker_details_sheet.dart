import 'package:flutter/material.dart';
import 'package:rpa/data/models/enums/risk_type.dart';
import 'package:rpa/data/models/websocket/alert_model.dart';
import 'package:rpa/data/models/websocket/report_model.dart';
import 'package:rpa/l10n/app_localizations.dart';

/// Bottom sheet to show alert details
class AlertDetailsSheet extends StatelessWidget {
  final AlertModel alert;

  const AlertDetailsSheet({
    super.key,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final riskType = alert.riskType ?? RiskType.infrastructure;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Header with icon and type
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getAlertColor(riskType).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getAlertIcon(riskType),
                  color: _getAlertColor(riskType),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.emergencyAlert,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getAlertColor(riskType),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getRiskTypeLabel(context, riskType),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              alert.message,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Details
          _buildDetailRow(
            Icons.location_on_rounded,
            l10n.reachRadius,
            '${(alert.radius / 1000).toStringAsFixed(1)} km',
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.access_time_rounded,
            l10n.timeLabel,
            alert.createdAt != null 
                ? _formatDateTime(context, alert.createdAt!)
                : l10n.now,
          ),
          const SizedBox(height: 24),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  label: Text(l10n.close),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    // TODO: Navigate to alert details page
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.info_rounded),
                  label: Text(l10n.moreDetails),
                  style: FilledButton.styleFrom(
                    backgroundColor: _getAlertColor(riskType),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getAlertColor(RiskType type) {
    switch (type) {
      case RiskType.crime: return const Color(0xFFB71C1C);
      case RiskType.accident: return const Color(0xFFFF6F00);
      case RiskType.naturalDisaster: return const Color(0xFF0288D1);
      case RiskType.fire: return const Color(0xFFFF6F00);
      case RiskType.health: return const Color(0xFFE53935);
      case RiskType.infrastructure: return const Color(0xFF1976D2);
      case RiskType.environment: return const Color(0xFF388E3C);
      case RiskType.violence: return const Color(0xFFD32F2F);
      case RiskType.publicSafety: return const Color(0xFF1565C0);
      case RiskType.traffic: return const Color(0xFFFFA000);
      case RiskType.urbanIssue: return const Color(0xFF757575);
    }
  }

  IconData _getAlertIcon(RiskType type) {
    switch (type) {
      case RiskType.crime: return Icons.gavel_rounded;
      case RiskType.accident: return Icons.car_crash_rounded;
      case RiskType.naturalDisaster: return Icons.water_damage_rounded;
      case RiskType.fire: return Icons.local_fire_department_rounded;
      case RiskType.health: return Icons.medical_services_rounded;
      case RiskType.infrastructure: return Icons.construction_rounded;
      case RiskType.environment: return Icons.eco_rounded;
      case RiskType.violence: return Icons.warning_rounded;
      case RiskType.publicSafety: return Icons.shield_rounded;
      case RiskType.traffic: return Icons.traffic_rounded;
      case RiskType.urbanIssue: return Icons.location_city_rounded;
    }
  }

  String _getRiskTypeLabel(BuildContext context, RiskType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case RiskType.crime: return l10n.crime;
      case RiskType.accident: return l10n.accident;
      case RiskType.naturalDisaster: return l10n.naturalDisaster;
      case RiskType.fire: return l10n.fire;
      case RiskType.health: return l10n.health;
      case RiskType.infrastructure: return l10n.infrastructure;
      case RiskType.environment: return l10n.environment;
      case RiskType.violence: return l10n.violence;
      case RiskType.publicSafety: return l10n.publicSafety;
      case RiskType.traffic: return l10n.traffic;
      case RiskType.urbanIssue: return l10n.urbanIssue;
    }
  }

  String _formatDateTime(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return l10n.now;
    } else if (diff.inHours < 1) {
      return l10n.minutesAgo(diff.inMinutes);
    } else if (diff.inDays < 1) {
      return l10n.hoursAgo(diff.inHours);
    } else {
      return '${dateTime.day}/${dateTime.month} às ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// Bottom sheet to show report details
class ReportDetailsSheet extends StatelessWidget {
  final ReportModel report;
  final Function(ReportModel)? onEditLocation;

  const ReportDetailsSheet({
    super.key,
    required this.report,
    this.onEditLocation,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final riskType = report.riskType ?? RiskType.infrastructure;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Header with icon and type
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getReportColor(riskType).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getReportIcon(riskType),
                  color: _getReportColor(riskType),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.communityReport,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getReportColor(riskType),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getRiskTypeLabel(context, riskType),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (report.status == ReportStatus.verified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        l10n.verified,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              if (report.status == ReportStatus.resolved)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        l10n.resolved,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              report.message,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Details
          _buildDetailRow(
            Icons.access_time_rounded,
            l10n.reported,
            report.createdAt != null 
                ? _formatDateTime(context, report.createdAt!)
                : l10n.now,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.info_outline_rounded,
            l10n.status,
            _getStatusLabel(context, report.status),
          ),
          const SizedBox(height: 24),
          
          // Actions
          if (onEditLocation != null && report.status == ReportStatus.pending)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onEditLocation?.call(report);
                  },
                  icon: const Icon(Icons.edit_location_outlined),
                  label: Text(l10n.editLocation),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  label: Text(l10n.close),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    // TODO: Navigate to report details page
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.visibility_rounded),
                  label: Text(l10n.viewDetails),
                  style: FilledButton.styleFrom(
                    backgroundColor: _getReportColor(riskType),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getReportColor(RiskType type) {
    switch (type) {
      case RiskType.crime: return const Color(0xFFEF5350);
      case RiskType.accident: return const Color(0xFFFFB74D);
      case RiskType.naturalDisaster: return const Color(0xFF4FC3F7);
      case RiskType.fire: return const Color(0xFFFFB74D);
      case RiskType.health: return const Color(0xFFE57373);
      case RiskType.infrastructure: return const Color(0xFF64B5F6);
      case RiskType.environment: return const Color(0xFF81C784);
      case RiskType.violence: return const Color(0xFFE57373);
      case RiskType.publicSafety: return const Color(0xFF42A5F5);
      case RiskType.traffic: return const Color(0xFFFFD54F);
      case RiskType.urbanIssue: return const Color(0xFF9E9E9E);
    }
  }

  IconData _getReportIcon(RiskType type) {
    switch (type) {
      case RiskType.crime: return Icons.gavel_outlined;
      case RiskType.accident: return Icons.car_crash_outlined;
      case RiskType.naturalDisaster: return Icons.water_outlined;
      case RiskType.fire: return Icons.local_fire_department_outlined;
      case RiskType.health: return Icons.medical_services_outlined;
      case RiskType.infrastructure: return Icons.construction_outlined;
      case RiskType.environment: return Icons.eco_outlined;
      case RiskType.violence: return Icons.report_problem_outlined;
      case RiskType.publicSafety: return Icons.shield_outlined;
      case RiskType.traffic: return Icons.traffic_outlined;
      case RiskType.urbanIssue: return Icons.location_city_outlined;
    }
  }

  String _getRiskTypeLabel(BuildContext context, RiskType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case RiskType.crime: return l10n.crime;
      case RiskType.accident: return l10n.accident;
      case RiskType.naturalDisaster: return l10n.naturalDisaster;
      case RiskType.fire: return l10n.fire;
      case RiskType.health: return l10n.health;
      case RiskType.infrastructure: return l10n.infrastructure;
      case RiskType.environment: return l10n.environment;
      case RiskType.violence: return l10n.violence;
      case RiskType.publicSafety: return l10n.publicSafety;
      case RiskType.traffic: return l10n.traffic;
      case RiskType.urbanIssue: return l10n.urbanIssue;
    }
  }

  String _getStatusLabel(BuildContext context, ReportStatus status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case ReportStatus.pending:
        return l10n.pending;
      case ReportStatus.verified:
        return l10n.verified;
      case ReportStatus.resolved:
        return l10n.resolved;
    }
  }

  String _formatDateTime(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return l10n.now;
    } else if (diff.inHours < 1) {
      return l10n.minutesAgo(diff.inMinutes);
    } else if (diff.inDays < 1) {
      return l10n.hoursAgo(diff.inHours);
    } else {
      return '${dateTime.day}/${dateTime.month} às ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
