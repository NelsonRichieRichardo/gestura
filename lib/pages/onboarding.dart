import 'package:flutter/material.dart';
import 'package:gestura/pages/login.dart';
import 'package:gestura/pages/register.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gestura/core/themes/app_theme.dart';
import 'package:gestura/components/loading_overlay.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = screenWidth(context);
    final double sh = screenHeight(context);

    // --- Font scaling ---
    double titleSize = sw < 350
        ? 24
        : sw < 500
        ? 28
        : 32;
    double subtitleSize = sw < 350 ? 13 : 15;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.07),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: sh * 0.05),

              /// ---------- TITLE ----------
              Text(
                "Sign Language Translator\nTurning Gestures into Words",
                style: GoogleFonts.poppins(
                  fontSize: titleSize,
                  color: accentColor,
                  fontWeight: bold,
                  height: 1.15,
                ),
              ),

              SizedBox(height: sh * 0.015),

              /// ---------- SUBTEXT ----------
              Text(
                "Break communication barriers with real-time AI translation. "
                "Every hand gesture becomes text instantly — making conversations "
                "more inclusive and effortless.",
                style: GoogleFonts.poppins(
                  fontSize: subtitleSize,
                  height: 1.4,
                  color: accentColor.withOpacity(0.7),
                ),
              ),

              SizedBox(height: sh * 0.04),

              /// ---------- IMAGE ----------
              Expanded(
                flex: 4,
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double imgHeight = constraints.maxHeight * 0.85;
                      double imgWidth = sw * 0.8;

                      return Image.asset(
                        "assets/images/onboard.png",
                        height: imgHeight,
                        width: imgWidth,
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: sh * 0.04),

              /// ---------- LOGIN BUTTON ----------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Tampilkan Loading
                    LoadingOverlay.show(context);
                    await Future.delayed(const Duration(milliseconds: 700)); // Delay simulasi

                    // Navigasi ke halaman Login (menggunakan push agar bisa kembali)
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );

                    // Sembunyikan Loading
                    LoadingOverlay.hide(context);
                  },
                  style: primaryButton.copyWith(
                    backgroundColor: MaterialStateProperty.all(primaryColor),
                    foregroundColor: MaterialStateProperty.all(blackColor),
                    minimumSize: MaterialStateProperty.all(
                      Size(double.infinity, sh * 0.06),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  child: Text(
                    "Login",
                    style: GoogleFonts.poppins(
                      fontWeight: medium,
                      fontSize: subtitleSize + 1,
                    ),
                  ),
                ),
              ),

              SizedBox(height: sh * 0.015),

              /// ---------- REGISTER BUTTON ----------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Tampilkan Loading
                    LoadingOverlay.show(context);
                    await Future.delayed(const Duration(milliseconds: 700)); // Delay simulasi

                    // Navigasi ke halaman Register (menggunakan push agar bisa kembali)
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterPage()),
                    );

                    // Sembunyikan Loading
                    LoadingOverlay.hide(context);
                  },
                  style: primaryButton.copyWith(
                    backgroundColor: MaterialStateProperty.all(primaryColor),
                    foregroundColor: MaterialStateProperty.all(blackColor),
                    minimumSize: MaterialStateProperty.all(
                      Size(double.infinity, sh * 0.06),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  child: Text(
                    "Register",
                    style: GoogleFonts.poppins(
                      fontWeight: medium,
                      fontSize: subtitleSize + 1,
                    ),
                  ),
                ),
              ),

              SizedBox(height: sh * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}