import 'package:flutter/material.dart';

// Ambil width layar
double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

// Ambil height layar
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

// Cek portrait
bool isPortrait(BuildContext context) =>
    MediaQuery.of(context).orientation == Orientation.portrait;

// Cek landscape
bool isLandscape(BuildContext context) =>
    MediaQuery.of(context).orientation == Orientation.landscape;

// Skala ukuran layar
double responsiveSize(BuildContext context, double size) {
  double baseWidth = 375;
  return size * screenWidth(context) / baseWidth;
}

// Skala ukuran font
double responsiveFont(BuildContext context, double fontSize) {
  double baseWidth = 375;
  return fontSize * screenWidth(context) / baseWidth;
}

// Padding
EdgeInsets responsivePadding(
  BuildContext context, {
  double horizontal = 16,
  double vertical = 16,
}) {
  if (isLandscape(context)) {
    // Saat landscape
    return EdgeInsets.symmetric(
      horizontal: responsiveSize(context, horizontal * 1.5),
      vertical: responsiveSize(context, vertical * 0.7),
    );
  } else {
    // Default portrait
    return EdgeInsets.symmetric(
      horizontal: responsiveSize(context, horizontal),
      vertical: responsiveSize(context, vertical),
    );
  }
}
