import 'package:flutter_dotenv/flutter_dotenv.dart';

String get BASE_URL => dotenv.env['BASE_URL'] ?? 'https://risk-place-angola-904a.onrender.com/api/v1';
String get OSM_TILE_URL => dotenv.env['OSM_TILE_URL'] ?? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
