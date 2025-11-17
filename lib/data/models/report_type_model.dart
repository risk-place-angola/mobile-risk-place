import 'package:flutter/material.dart';

/// Report types that users can submit, similar to Waze
class ReportTypeModel {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  const ReportTypeModel({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}

/// Predefined report types for RiskPlace
class ReportTypes {
  static const traffic = ReportTypeModel(
    id: 'traffic',
    label: 'Traffic',
    icon: Icons.local_shipping,
    color: Color(0xFFE74C3C),
  );

  static const police = ReportTypeModel(
    id: 'police',
    label: 'Police',
    icon: Icons.local_police,
    color: Color(0xFF3498DB),
  );

  static const crash = ReportTypeModel(
    id: 'crash',
    label: 'Crash',
    icon: Icons.car_crash,
    color: Color(0xFFE67E22),
  );

  static const hazard = ReportTypeModel(
    id: 'hazard',
    label: 'Hazard',
    icon: Icons.warning,
    color: Color(0xFFF39C12),
  );

  static const closure = ReportTypeModel(
    id: 'closure',
    label: 'Closure',
    icon: Icons.block,
    color: Color(0xFF95A5A6),
  );

  static const blockedLane = ReportTypeModel(
    id: 'blocked_lane',
    label: 'Blocked lane',
    icon: Icons.traffic,
    color: Color(0xFFE67E22),
  );

  static const mapIssue = ReportTypeModel(
    id: 'map_issue',
    label: 'Map issue',
    icon: Icons.map,
    color: Color(0xFF9B59B6),
  );

  static const badWeather = ReportTypeModel(
    id: 'bad_weather',
    label: 'Bad weather',
    icon: Icons.cloud,
    color: Color(0xFF34495E),
  );

  static const gasPrices = ReportTypeModel(
    id: 'gas_prices',
    label: 'Gas prices',
    icon: Icons.local_gas_station,
    color: Color(0xFF16A085),
  );

  static const roadsideHelp = ReportTypeModel(
    id: 'roadside_help',
    label: 'Roadside help',
    icon: Icons.help_outline,
    color: Color(0xFFE74C3C),
  );

  static const mapChat = ReportTypeModel(
    id: 'map_chat',
    label: 'Map chat',
    icon: Icons.chat_bubble_outline,
    color: Color(0xFF27AE60),
  );

  static const place = ReportTypeModel(
    id: 'place',
    label: 'Place',
    icon: Icons.add_location,
    color: Color(0xFF8E44AD),
  );

  /// All available report types
  static List<ReportTypeModel> get all => [
        traffic,
        police,
        crash,
        hazard,
        closure,
        blockedLane,
        mapIssue,
        badWeather,
        gasPrices,
        roadsideHelp,
        mapChat,
        place,
      ];
}
