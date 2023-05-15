import 'package:flutter/material.dart';

extension ColorHex on double {
  Color get colorFromHex => Color(this.toInt());
}
