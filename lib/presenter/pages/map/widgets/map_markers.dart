import 'package:flutter/material.dart';
import 'package:rpa/data/models/enums/risk_type.dart';

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
          child: Icon(
            _getAlertIcon(riskType),
            color: Colors.white,
            size: 20,
          ),
        ),
      ],
    );
  }

  Color _getAlertColor(RiskType type) {
    switch (type) {
      case RiskType.violence:
        return const Color(0xFFD32F2F); // Red
      case RiskType.fire:
        return const Color(0xFFFF6F00); // Deep Orange
      case RiskType.traffic:
        return const Color(0xFFFFA000); // Amber
      case RiskType.infrastructure:
        return const Color(0xFF1976D2); // Blue
      case RiskType.flood:
        return const Color(0xFF0288D1); // Light Blue
    }
  }

  IconData _getAlertIcon(RiskType type) {
    switch (type) {
      case RiskType.violence:
        return Icons.warning_rounded;
      case RiskType.fire:
        return Icons.local_fire_department_rounded;
      case RiskType.traffic:
        return Icons.traffic_rounded;
      case RiskType.infrastructure:
        return Icons.construction_rounded;
      case RiskType.flood:
        return Icons.water_damage_rounded;
    }
  }
}

/// Custom marker widget for reports on the map
/// Lower priority than alerts, more subtle styling
class ReportMarkerWidget extends StatelessWidget {
  final RiskType? riskType;
  final bool isVerified;
  final bool isResolved;

  const ReportMarkerWidget({
    super.key,
    this.riskType,
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
          child: Icon(
            _getReportIcon(riskType ?? RiskType.infrastructure),
            color: Colors.white,
            size: 16,
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
      case RiskType.violence:
        return const Color(0xFFE57373); // Light Red
      case RiskType.fire:
        return const Color(0xFFFFB74D); // Light Orange
      case RiskType.traffic:
        return const Color(0xFFFFD54F); // Light Amber
      case RiskType.infrastructure:
        return const Color(0xFF64B5F6); // Light Blue
      case RiskType.flood:
        return const Color(0xFF4FC3F7); // Light Cyan
    }
  }

  IconData _getReportIcon(RiskType type) {
    switch (type) {
      case RiskType.violence:
        return Icons.report_problem_outlined;
      case RiskType.fire:
        return Icons.local_fire_department_outlined;
      case RiskType.traffic:
        return Icons.traffic_outlined;
      case RiskType.infrastructure:
        return Icons.construction_outlined;
      case RiskType.flood:
        return Icons.water_outlined;
    }
  }
}

/// Helper class to get radius circle color for alerts
class AlertRadiusHelper {
  static Color getRadiusColor(RiskType riskType, {double opacity = 0.2}) {
    final Color baseColor;
    switch (riskType) {
      case RiskType.violence:
        baseColor = const Color(0xFFD32F2F);
        break;
      case RiskType.fire:
        baseColor = const Color(0xFFFF6F00);
        break;
      case RiskType.traffic:
        baseColor = const Color(0xFFFFA000);
        break;
      case RiskType.infrastructure:
        baseColor = const Color(0xFF1976D2);
        break;
      case RiskType.flood:
        baseColor = const Color(0xFF0288D1);
        break;
    }
    return baseColor.withOpacity(opacity);
  }
}
