import 'dart:math';
import 'package:flutter/material.dart';

LinearGradient generatePastelGradient() {
  final random = Random();
  final hue = random.nextDouble() * 360;
  final saturation =
      0.5 + random.nextDouble() * 0.2; // Low saturation for pastels
  final lightness =
      0.85 + random.nextDouble() * 0.1; // High lightness for pastels

  final baseColor = HSLColor.fromAHSL(1.0, hue, saturation, lightness);
  final lightColor = baseColor.toColor();
  final darkColor = baseColor.withLightness(lightness - 0.1).toColor();

  return LinearGradient(
    colors: [lightColor, darkColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
