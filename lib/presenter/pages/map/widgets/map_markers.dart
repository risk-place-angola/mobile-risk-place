import 'package:flutter/material.dart';
import 'package:rpa/data/models/enums/risk_type.dart';
import 'package:rpa/core/services/icon_resolver_service.dart';

/// Custom marker widget for alerts on the map
/// High-priority markers with distinctive styling
class AlertMarkerWidget extends StatelessWidget {
  final RiskType riskType;
  final bool isPulsing;

  const AlertMarkerWidget({
    super.key,
    required this.riskType,
    this.isPulsing = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing background for critical alerts
        if (isPulsing)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getAlertColor(riskType).withOpacity(0.3),
            ),
          ),
        // Main marker
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getAlertColor(riskType),
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: IconResolverService.buildIcon(
              typeName: riskType.name,
              apiIconPath: null,
              size: 26,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Color _getAlertColor(RiskType type) {
    switch (type) {
      case RiskType.crime:
        return const Color(0xFFB71C1C);
      case RiskType.accident:
        return const Color(0xFFFF6F00);
      case RiskType.naturalDisaster:
        return const Color(0xFF0288D1);
      case RiskType.fire:
        return const Color(0xFFFF6F00);
      case RiskType.health:
        return const Color(0xFFE53935);
      case RiskType.infrastructure:
        return const Color(0xFF1976D2);
      case RiskType.environment:
        return const Color(0xFF388E3C);
      case RiskType.violence:
        return const Color(0xFFD32F2F);
      case RiskType.publicSafety:
        return const Color(0xFF1565C0);
      case RiskType.traffic:
        return const Color(0xFFFFA000);
      case RiskType.urbanIssue:
        return const Color(0xFF757575);
    }
  }
}

/// Custom marker widget for reports on the map
/// Lower priority than alerts, more subtle styling
class ReportMarkerWidget extends StatelessWidget {
  final RiskType? riskType;
  final String? topicName;
  final String? topicIconUrl;
  final bool isVerified;
  final bool isResolved;

  const ReportMarkerWidget({
    super.key,
    this.riskType,
    this.topicName,
    this.topicIconUrl,
    this.isVerified = false,
    this.isResolved = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Main marker
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isResolved
                ? Colors.grey
                : _getReportColor(riskType ?? RiskType.infrastructure),
            border: Border.all(
              color: isVerified ? Colors.green : Colors.white,
              width: isVerified ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: IconResolverService.buildIcon(
              typeName: topicName ?? (riskType ?? RiskType.infrastructure).name,
              apiIconPath: topicIconUrl,
              size: 20,
              color: Colors.white,
              isTopic: topicName != null,
            ),
          ),
        ),
        // Verified badge
        if (isVerified && !isResolved)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 8,
              ),
            ),
          ),
        // Resolved overlay
        if (isResolved)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.3),
            ),
          ),
      ],
    );
  }

  Color _getReportColor(RiskType type) {
    switch (type) {
      case RiskType.crime:
        return const Color(0xFFEF5350);
      case RiskType.accident:
        return const Color(0xFFFFB74D);
      case RiskType.naturalDisaster:
        return const Color(0xFF4FC3F7);
      case RiskType.fire:
        return const Color(0xFFFFB74D);
      case RiskType.health:
        return const Color(0xFFE57373);
      case RiskType.infrastructure:
        return const Color(0xFF64B5F6);
      case RiskType.environment:
        return const Color(0xFF81C784);
      case RiskType.violence:
        return const Color(0xFFE57373);
      case RiskType.publicSafety:
        return const Color(0xFF42A5F5);
      case RiskType.traffic:
        return const Color(0xFFFFD54F);
      case RiskType.urbanIssue:
        return const Color(0xFF9E9E9E);
    }
  }
}

/// Helper class to get radius circle color for alerts
class AlertRadiusHelper {
  static Color getRadiusColor(RiskType riskType, {double opacity = 0.2}) {
    switch (riskType) {
      case RiskType.crime:
        return const Color(0xFFB71C1C).withOpacity(opacity);
      case RiskType.accident:
        return const Color(0xFFFF6F00).withOpacity(opacity);
      case RiskType.naturalDisaster:
        return const Color(0xFF0288D1).withOpacity(opacity);
      case RiskType.fire:
        return const Color(0xFFFF6F00).withOpacity(opacity);
      case RiskType.health:
        return const Color(0xFFE53935).withOpacity(opacity);
      case RiskType.infrastructure:
        return const Color(0xFF1976D2).withOpacity(opacity);
      case RiskType.environment:
        return const Color(0xFF388E3C).withOpacity(opacity);
      case RiskType.violence:
        return const Color(0xFFD32F2F).withOpacity(opacity);
      case RiskType.publicSafety:
        return const Color(0xFF1565C0).withOpacity(opacity);
      case RiskType.traffic:
        return const Color(0xFFFFA000).withOpacity(opacity);
      case RiskType.urbanIssue:
        return const Color(0xFF757575).withOpacity(opacity);
    }
  }
}
