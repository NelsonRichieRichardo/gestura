import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// App Colors
Color primaryColor = const Color(0xFFF8B600);
Color accentColor = const Color(0xFF2A3955);
Color backgroundColor = const Color(0xFFFFFFFF);
Color secondaryBackground = const Color(0xFFF8F8F8);

Color dangerColor = const Color(0xFFF42929);
Color successColor = const Color(0xFF28A745);
Color infoColor = const Color(0xFF4287F5);

Color greyColor = const Color(0xFFC0C0C0);
Color shadowColor = const Color(0xFF808080);
Color blackColor = const Color(0xFF000000);

// Font Weight
FontWeight light = FontWeight.w300;
FontWeight regular = FontWeight.w400;
FontWeight medium = FontWeight.w500;
FontWeight bold = FontWeight.w600;

// Text Style
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

// Button
ButtonStyle primaryButton = ElevatedButton.styleFrom(
  backgroundColor: primaryColor,
  foregroundColor: backgroundColor,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  padding: const EdgeInsets.symmetric(vertical: 14),
  textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: bold),
);

// Box
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
