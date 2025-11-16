import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gestura/core/themes/app_theme.dart';
import 'package:gestura/core/utils/responsive.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            
            return Column(
              children: [

                /// =========================
                ///        IMAGE TOP
                /// =========================
                SizedBox(
                  width: screenWidth(context),          // Full width
                  height: responsiveHeight(context, 0.25), // 25% tinggi layar
                  child: Image.asset(
                    "assets/images/register.png",
                    fit: BoxFit.contain,
                  ),
                ),

                SizedBox(height: responsiveHeight(context, 0.01)),

                /// =========================
                ///        TITLE
                /// =========================
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveWidth(context, 0.07),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Let’s get started, Mate!",
                      style: GoogleFonts.poppins(
                        fontSize: responsiveFont(context, 32),
                        fontWeight: bold,
                        color: accentColor,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: responsiveHeight(context, 0.01)),


                /// =========================
                ///        FORM INPUTS
                /// =========================
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveWidth(context, 0.07),
                  ),
                  child: Column(
                    children: [
                      _inputField("Username"),
                      SizedBox(height: responsiveHeight(context, 0.012)),
                      _inputField("Email Address"),
                      SizedBox(height: responsiveHeight(context, 0.012)),
                      _inputField("Mobile Number", prefixFlag: true),
                      SizedBox(height: responsiveHeight(context, 0.012)),
                      _inputField("Password", isPassword: true),
                      SizedBox(height: responsiveHeight(context, 0.012)),
                      _inputField("Confirm Password", isPassword: true),
                    ],
                  ),
                ),

                SizedBox(height: responsiveHeight(context, 0.01)),

                /// =========================
                ///      LOGIN REDIRECT
                /// =========================
                Text.rich(
                  TextSpan(
                    text: "Already have an account? ",
                    style: GoogleFonts.poppins(
                      fontSize: responsiveFont(context, 12),
                      color: accentColor.withOpacity(0.7),
                    ),
                    children: [
                      TextSpan(
                        text: "Log in",
                        style: GoogleFonts.poppins(
                          fontWeight: bold,
                          fontSize: responsiveFont(context, 12),
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 4),

                /// =========================
                ///      TERMS CHECKBOX
                /// =========================
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveWidth(context, 0.07),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: false,
                        onChanged: (v) {},
                      ),
                      Expanded(
                        child: Text(
                          "I agree with the terms and conditions",
                          style: GoogleFonts.poppins(
                            fontSize: responsiveFont(context, 12),
                            color: accentColor.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 4),

                /// =========================
                ///       NEXT BUTTON
                /// =========================
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveWidth(context, 0.07),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: blackColor,
                        padding: EdgeInsets.symmetric(
                          vertical: responsiveHeight(context, 0.018),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: GoogleFonts.poppins(
                          fontSize: responsiveFont(context, 15),
                          fontWeight: bold,
                        ),
                      ),
                      child: const Text("Next"),
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

  // ======================================================
  //                INPUT COMPONENT
  // ======================================================

  Widget _inputField(String hint,
      {bool isPassword = false, bool prefixFlag = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
        prefixIcon: prefixFlag
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(width: 10),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      size: 20, color: Colors.grey),
                ],
              )
            : null,
        filled: true,
        fillColor: secondaryBackground,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
