import 'package:flutter/material.dart';

// Ambil width layar
double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

// Ambil height layar
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

/// responsive width: ambil persen dari layar
double responsiveWidth(BuildContext context, double percentage) {
  return screenWidth(context) * percentage;
}

/// responsive height: ambil persen dari layar
double responsiveHeight(BuildContext context, double percentage) {
  return screenHeight(context) * percentage;
}

/// responsive font: skala mengikuti lebar layar
double responsiveFont(BuildContext context, double fontSize) {
  double scale = screenWidth(context) / 390; // normalizing factor
  return fontSize * scale;
}
// Orientation
bool isPortrait(BuildContext context) =>
    MediaQuery.of(context).orientation == Orientation.portrait;
bool isLandscape(BuildContext context) =>
    MediaQuery.of(context).orientation == Orientation.landscape;

// Scale ukuran berdasarkan width
double responsiveSize(BuildContext context, double size) {
  double baseWidth = 375; // iPhone 11 width
  return size * screenWidth(context) / baseWidth;
}

// Padding responsif
EdgeInsets responsivePadding(
  BuildContext context, {
  double horizontal = 16,
  double vertical = 16,
}) {
  if (isLandscape(context)) {
    return EdgeInsets.symmetric(
      horizontal: responsiveSize(context, horizontal * 1.3),
      vertical: responsiveHeight(context, vertical * 0.7),
    );
  } else {
    return EdgeInsets.symmetric(
      horizontal: responsiveSize(context, horizontal),
      vertical: responsiveHeight(context, vertical),
    );
  }
}
