import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// =====================================================
// 1. APP COLORS
// =====================================================
const Color primaryColor = Color(0xFFF8B600);
const Color accentColor = Color(0xFF2A3955);
const Color backgroundColor = Color(0xFFFFFFFF);
const Color secondaryBackground = Color(0xFFF8F8F8);

const Color dangerColor = Color(0xFFF42929);
const Color successColor = Color(0xFF28A745);
const Color infoColor = Color(0xFF4287F5);

const Color greyColor = Color(0xFFC0C0C0);
const Color shadowColor = Color(0xFF808080);
const Color blackColor = Color(0xFF000000);

// =====================================================
// 2. FONT WEIGHT (Menggunakan const di sini)
// =====================================================
const FontWeight light = FontWeight.w300;
const FontWeight regular = FontWeight.w400;
const FontWeight medium = FontWeight.w500;
const FontWeight bold = FontWeight.w600; // Catatan: Kode lama pakai w700, ini diubah ke w600

// =====================================================
// 3. TEXT STYLE
// =====================================================
TextStyle heading1 = GoogleFonts.poppins(
  fontSize: 24,
  fontWeight: bold,
  color: accentColor,
);

TextStyle heading2 = GoogleFonts.poppins(
  fontSize: 20,
  fontWeight: bold,
  color: accentColor,
);

TextStyle bodyText = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: regular,
  color: accentColor,
);

TextStyle bodyTextWhite = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: regular,
  color: backgroundColor,
);

TextStyle smallText = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: regular,
  color: accentColor,
);

// =====================================================
// 4. BUTTON STYLE
// =====================================================
ButtonStyle primaryButton = ElevatedButton.styleFrom(
  backgroundColor: primaryColor,
  foregroundColor: backgroundColor,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  padding: const EdgeInsets.symmetric(vertical: 14),
  textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: bold),
);

// =====================================================
// 5. BOX DECORATION
// =====================================================
BoxDecoration cardDecoration = BoxDecoration(
  color: backgroundColor,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [
    BoxShadow(
      color: shadowColor.withOpacity(0.2),
      blurRadius: 5,
      offset: const Offset(0, 3),
    ),
  ],
);

// =====================================================
// 6. RESPONSIVE UTILITIES (Dipertahankan agar kode lain tidak error)
// =====================================================

double screenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double screenHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double responsiveHeight(BuildContext context, double percentage) {
  return screenHeight(context) * percentage;
}

double responsiveWidth(BuildContext context, double percentage) {
  return screenWidth(context) * percentage;
}

double responsiveFont(BuildContext context, double baseSize) {
  double width = screenWidth(context);
  // Logika sederhana untuk skala font
  if (width < 600) {
    return baseSize * 0.9;
  } else if (width < 1000) {
    return baseSize * 1.0;
  } else {
    return baseSize * 1.1;
  }
}