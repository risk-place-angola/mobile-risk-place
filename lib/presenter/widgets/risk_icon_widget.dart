import 'package:flutter/material.dart';
import 'package:rpa/constants.dart';
import 'package:rpa/core/utils/risk_icons.dart';

class RiskIconWidget extends StatelessWidget {
  final String? iconUrl;
  final String? fallbackName;
  final double size;
  final Color? color;
  final bool isTopic;

  const RiskIconWidget({
    super.key,
    this.iconUrl,
    this.fallbackName,
    this.size = 32,
    this.color,
    this.isTopic = false,
  });

  IconData _getDefaultIcon() {
    if (isTopic) return Icons.info_outline;
    return Icons.report_problem;
  }

  @override
  Widget build(BuildContext context) {
    if (iconUrl != null && iconUrl!.isNotEmpty) {
      final fullUrl = RiskIcons.getIconUrl(iconUrl, BASE_DOMAIN);
      if (fullUrl != null) {
        return Image.network(
          fullUrl,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      }
    }
    return _buildFallback();
  }

  Widget _buildFallback() {
    if (fallbackName != null && fallbackName!.isNotEmpty) {
      final localPath = isTopic
          ? RiskIcons.getLocalIconForRiskTopic(fallbackName!)
          : RiskIcons.getLocalIconForRiskType(fallbackName!);
      return Image.asset(
        localPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Icon(
          _getDefaultIcon(),
          size: size,
          color: color ?? Colors.grey,
        ),
      );
    }
    return Icon(
      _getDefaultIcon(),
      size: size,
      color: color ?? Colors.grey,
    );
  }
}
