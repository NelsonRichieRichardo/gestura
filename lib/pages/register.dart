import 'package:flutter/gestures.dart'; 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gestura/core/themes/app_theme.dart';
import 'package:gestura/core/utils/country_data.dart';
import 'package:gestura/components/loading_overlay.dart'; 
import 'package:gestura/pages/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // State untuk Country Picker
  Country selectedCountry = availableCountries.first;
  bool isAgreed = false;

  // Controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ======================================================
  //                INPUT COMPONENT (UNMODIFIED)
  // ======================================================
  Widget _inputField(String hint, TextEditingController controller,
      {bool isPassword = false, bool isMobileNumber = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isMobileNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
        
        // Custom Prefix Icon untuk Mobile Number (Pemilih Bendera)
        prefixIcon: isMobileNumber
            ? _buildCountryPicker()
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

  // Widget khusus untuk Pemilih Negara (Bendera)
  Widget _buildCountryPicker() {
    return Container(
      padding: EdgeInsets.only(left: responsiveWidth(context, 0.02)),
      constraints: BoxConstraints(maxWidth: responsiveWidth(context, 0.3)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Country>(
          value: selectedCountry,
          icon: Icon(Icons.keyboard_arrow_down_rounded, size: responsiveFont(context, 20), color: Colors.grey),
          style: GoogleFonts.poppins(
            fontSize: responsiveFont(context, 14),
            color: accentColor,
            fontWeight: medium,
          ),
          onChanged: (Country? newValue) {
            if (newValue != null) {
              setState(() {
                selectedCountry = newValue;
              });
            }
          },
          items: availableCountries.map<DropdownMenuItem<Country>>((Country country) {
            return DropdownMenuItem<Country>(
              value: country,
              child: Row(
                children: [
                  Text(country.flag, style: TextStyle(fontSize: responsiveFont(context, 18))),
                  const SizedBox(width: 4),
                  Text(country.dialCode),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
  
  // ======================================================
  //                    BUILD METHOD
  // ======================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        // Bungkus dengan ListView/SingleChildScrollView agar tidak overflow pada keyboard
        child: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              
              return Column(
                children: [
                  // Back Button 
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsiveWidth(context, 0.04), 
                      vertical: responsiveHeight(context, 0.01),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        iconSize: responsiveFont(context, 24),
                        color: accentColor,
                        onPressed: () async {
                          // Navigasi kembali dengan loading singkat (300ms)
                          LoadingOverlay.show(context);
                          await Future.delayed(const Duration(milliseconds: 300));
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),

                  /// =========================
                  ///        IMAGE TOP
                  /// =========================
                  SizedBox(
                    width: screenWidth(context),          
                    height: responsiveHeight(context, 0.20), // Dikecilkan agar muat
                    child: Image.asset(
                      "assets/images/register.png",
                      fit: BoxFit.contain,
                    ),
                  ),

                  SizedBox(height: responsiveHeight(context, 0.02)),

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
                        _inputField("Username", _usernameController),
                        SizedBox(height: responsiveHeight(context, 0.012)),
                        _inputField("Email Address", _emailController),
                        SizedBox(height: responsiveHeight(context, 0.012)),
                        // FIELD BARU DENGAN PEMILIH BENDERA
                        _inputField("Mobile Number", _mobileController, isMobileNumber: true),
                        SizedBox(height: responsiveHeight(context, 0.012)),
                        _inputField("Password", _passwordController, isPassword: true),
                        SizedBox(height: responsiveHeight(context, 0.012)),
                        _inputField("Confirm Password", _confirmPasswordController, isPassword: true),
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
                          recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                              // 1. Tampilkan Loading
                              LoadingOverlay.show(context);
                              
                              // 2. Tunggu Delay (1200ms)
                              await Future.delayed(const Duration(milliseconds: 1200)); 
                              
                              // 3. Sembunyikan Loading Overlay
                              // Ini harus dipanggil secara eksplisit untuk menghapus overlay dari stack
                              LoadingOverlay.hide(context);

                              // 4. Navigasi Pengganti ke LoginPage
                              await Navigator.pushReplacement( 
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                          },
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
                          value: isAgreed,
                          onChanged: (v) {
                            setState(() {
                              isAgreed = v ?? false;
                            });
                          },
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
                        onPressed: () async {
                          // Tampilkan Loading Overlay untuk proses registrasi
                          LoadingOverlay.show(context);
                          await Future.delayed(const Duration(milliseconds: 1200)); // KONSISTENSI: Delay 1200ms

                          // TODO: Ganti ini dengan navigasi sukses ke halaman selanjutnya
                          // Untuk saat ini, kita pop ke halaman sebelumnya (misalnya login)
                          
                          Navigator.pop(context); 
                          
                          // Hapus Loading Overlay secara eksplisit setelah pop
                          LoadingOverlay.hide(context);
                        },
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
                  SizedBox(height: responsiveHeight(context, 0.03)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}