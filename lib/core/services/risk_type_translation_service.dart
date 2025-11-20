import 'package:flutter/material.dart';
import 'package:rpa/l10n/app_localizations.dart';

class RiskTypeTranslationService {
  static String translateType(BuildContext context, String typeKey) {
    final normalized = typeKey.toLowerCase().trim().replaceAll(' ', '_');
    final l10n = AppLocalizations.of(context);

    if (l10n == null) return typeKey;

    switch (normalized) {
      case 'crime':
        return l10n.crime;
      case 'accident':
        return l10n.accident;
      case 'natural_disaster':
      case 'naturaldisaster':
        return l10n.naturalDisaster;
      case 'fire':
        return l10n.fire;
      case 'health':
        return l10n.health;
      case 'infrastructure':
        return l10n.infrastructure;
      case 'environment':
        return l10n.environment;
      case 'violence':
        return l10n.violence;
      case 'public_safety':
      case 'publicsafety':
        return l10n.publicSafety;
      case 'traffic':
        return l10n.traffic;
      case 'urban_issue':
      case 'urbanissue':
        return l10n.urbanIssue;
      default:
        return typeKey;
    }
  }
}
