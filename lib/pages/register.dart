import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gestura/core/themes/app_theme.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Definisi warna dan bold asumsikan berasal dari AppTheme/responsive.dart,
    // Jika tidak didefinisikan secara global, perlu diimpor atau didefinisikan.
    // Untuk tujuan modifikasi, saya asumsikan mereka tersedia di scope ini.
    // Misalnya: final Color backgroundColor = Colors.white;
    // final Color accentColor = Colors.black;
    // final Color primaryColor = Colors.blue;
    // final Color blackColor = Colors.black;
    // final Color secondaryBackground = Colors.grey.shade100;
    // final FontWeight bold = FontWeight.bold;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            
            return Column(
              children: [
                
                /// =========================
                ///       BACK BUTTON
                /// =========================
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveWidth(context, 0.04), // Padding responsif
                    vertical: responsiveHeight(context, 0.01),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded), // Ikon '<' modern
                      iconSize: responsiveFont(context, 24), // Ukuran ikon responsif
                      color: accentColor,
                      onPressed: () {
                        // Logika untuk kembali ke halaman sebelumnya
                        Navigator.pop(context); 
                      },
                    ),
                  ),
                ),

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
                        // Tambahkan styling pada Checkbox agar lebih sesuai dengan tema,
                        // misalnya menggunakan primaryColor.
                        activeColor: primaryColor,
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
    // ... (Fungsi _inputField tidak berubah)
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