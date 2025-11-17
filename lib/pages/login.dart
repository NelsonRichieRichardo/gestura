import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gestura/pages/register.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gestura/core/themes/app_theme.dart';
import 'package:gestura/core/utils/responsive.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isLarge = constraints.maxHeight > 750;

            return Column(
              children: [
                // ============================
                //        FULL WIDTH IMAGE
                // ============================
                Expanded(
                  flex: isLarge ? 3 : 2,
                  child: Center(
                    child: Image.asset(
                      "assets/images/login.png",
                      width: screenWidth(context), // stretch penuh lebar
                      fit: BoxFit.fitWidth, // tinggi menyesuaikan
                    ),
                  ),
                ),

                // ============================
                //        FORM SECTION
                // ============================
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    physics: isLarge
                        ? const NeverScrollableScrollPhysics()
                        : const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: isLarge ? 10 : 20),

                          // TITLE
                          Text(
                            "Welcome back,\nMate!!",
                            style: GoogleFonts.poppins(
                              fontSize: isLarge
                                  ? 34
                                  : responsiveFont(context, 30),
                              fontWeight: bold,
                              color: accentColor,
                              height: 1.2,
                            ),
                          ),

                          const SizedBox(height: 14),

                          // USERNAME INPUT
                          _inputField(hint: "Username", isPassword: false),

                          const SizedBox(height: 14),

                          // PASSWORD INPUT
                          _inputField(hint: "Password", isPassword: true),

                          const SizedBox(height: 8),

                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "Forgot Password?",
                              style: GoogleFonts.poppins(
                                fontSize: responsiveFont(context, 9),
                                color: accentColor.withOpacity(0.7),
                              ),
                            ),
                          ),

                          const SizedBox(height: 5),

                          // LOGIN BUTTON
                          _primaryButton("Login"),

                          const SizedBox(height: 10),

                          Center(
                            child: Text(
                              "Or login with",
                              style: GoogleFonts.poppins(
                                fontSize: responsiveFont(context, 9),
                                color: accentColor.withOpacity(0.6),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: _socialButton(
                                  label: "Google",
                                  dark: false,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _socialButton(
                                  label: "Facebook",
                                  dark: true,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          Center(
                            child: Text.rich(
                              TextSpan(
                                text: "Don't have an account? ",
                                style: GoogleFonts.poppins(
                                  fontSize: responsiveFont(context, 13),
                                  color: accentColor.withOpacity(0.7),
                                ),
                                children: [
                                  TextSpan(
                                    text: "Register",
                                    style: GoogleFonts.poppins(
                                      fontSize: responsiveFont(context, 13),
                                      fontWeight: bold,
                                      color: accentColor,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // Navigate to Register Page
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const RegisterPage(),
                                          ),
                                        );
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // =====================================================
  //                    COMPONENTS
  // =====================================================

  Widget _inputField({required String hint, required bool isPassword}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: secondaryBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _primaryButton(String text) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: blackColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: bold),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _socialButton({required String label, required bool dark}) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: dark ? accentColor : Colors.white,
        foregroundColor: dark ? Colors.white : Colors.black87,
        elevation: 1,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: medium),
      ),
      child: Text(label),
    );
  }
}
