import 'dart:convert';

import 'package:geolocator/geolocator.dart';

class Utils {
  static Future<String> hashPassword(String password) async {
    var encode = Base64Encoder().convert(utf8.encode(password));

    return encode;
  }

  static Future<double> getDistance(Position initialPosition) async {
    double distance = await Geolocator.distanceBetween(initialPosition.latitude,
        initialPosition.longitude, 38.713920, -8.972067);

    return distance;
  }
}
