import 'package:flutter_dotenv/flutter_dotenv.dart';

String get BASE_URL =>
    dotenv.env['BASE_URL'] ??
    'https://risk-place-angola-904a.onrender.com/api/v1';
String get BASE_DOMAIN =>
    dotenv.env['BASE_DOMAIN'] ?? 'https://risk-place-angola-904a.onrender.com';
String get WS_URL =>
    dotenv.env['WS_URL'] ??
    'wss://risk-place-angola-904a.onrender.com/api/ws/alerts';
String get OSM_TILE_URL =>
    dotenv.env['OSM_TILE_URL'] ??
    'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
