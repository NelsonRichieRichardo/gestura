import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart'; // Import Package Country Picker

// Core imports
import 'package:gestura/core/themes/app_theme.dart';
// Hapus import country_data.dart karena sudah pakai library otomatis
// import 'package:gestura/core/utils/country_data.dart'; 
import 'package:gestura/components/loading_overlay.dart';
import 'package:gestura/pages/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // =========================================================================
  // STATE MANAGEMENT
  // =========================================================================
  
  // Menggunakan Object Country dari library. Default ke Indonesia (ID)
  Country selectedCountry = Country.parse('ID');
  
  bool isAgreed = false;

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

  // =========================================================================
  // LOGIC / FUNCTION
  // =========================================================================

  Future<void> _handleRegister() async {
    // 1. Validasi Input Kosong
    if (_usernameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _mobileController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    // 2. Validasi Password Match
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    // 3. Validasi Terms Checked
    if (!isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must agree to the terms")),
      );
      return;
    }

    LoadingOverlay.show(context);

    try {
      // A. Buat Akun di Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // B. Siapkan data (Gabungkan kode negara + nomor HP)
      // selectedCountry.phoneCode mengambil kode otomatis (misal 62)
      String fullPhoneNumber = "+${selectedCountry.phoneCode}${_mobileController.text.trim()}";

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': fullPhoneNumber,
        'countryCode': selectedCountry.countryCode, // Misal: ID, US, MY
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      LoadingOverlay.hide(context);
      
      await Future.delayed(const Duration(milliseconds: 150)); 
      
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Registration Successful! Please Login."),
            backgroundColor: Colors.green),
      );

      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const LoginPage())
      );

    } on FirebaseAuthException catch (e) {
      if (mounted) {
        LoadingOverlay.hide(context);
        String message = "Registration failed";
        if (e.code == 'weak-password') {
          message = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          message = 'The account already exists for that email.';
        } else if (e.code == 'invalid-email') {
          message = 'The email address is not valid.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        LoadingOverlay.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // =========================================================================
  // UI COMPONENTS
  // =========================================================================

  Widget _inputField(
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
    bool isMobileNumber = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isMobileNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        // Font hint diperbesar sedikit (16)
        hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
        prefixIcon: isMobileNumber ? _buildCountryPicker() : null,
        filled: true,
        fillColor: secondaryBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16, // Padding diperbesar agar input field lebih tinggi
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Widget Picker Negara Otomatis (Menggunakan Library)
  Widget _buildCountryPicker() {
    return GestureDetector(
      onTap: () {
        // Memunculkan Bottom Sheet bawaan library
        showCountryPicker(
          context: context,
          showPhoneCode: true, // Tampilkan kode telepon di list
          countryListTheme: CountryListThemeData(
            bottomSheetHeight: 500,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            inputDecoration: InputDecoration(
              hintText: 'Search country',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
            ),
          ),
          onSelect: (Country country) {
            setState(() {
              selectedCountry = country;
            });
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        margin: const EdgeInsets.only(right: 8), // Jarak ke teks input
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bendera (Emoji)
            Text(
              selectedCountry.flagEmoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 4),
            // Kode Telepon (+62)
            Text(
              "+${selectedCountry.phoneCode}",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  // Header: Back Button
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsiveWidth(context, 0.04),
                      vertical: responsiveHeight(context, 0.01),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        iconSize: 24,
                        color: accentColor,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),

                  // Illustration Image
                  SizedBox(
                    width: screenWidth(context),
                    height: responsiveHeight(context, 0.20),
                    child: Image.asset(
                      "assets/images/register.png",
                      fit: BoxFit.contain,
                    ),
                  ),

                  SizedBox(height: responsiveHeight(context, 0.02)),

                  // Title: Font diperbesar (36)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsiveWidth(context, 0.07),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Let’s get started,\nMate!", // Pakai \n biar rapi 2 baris
                        style: GoogleFonts.poppins(
                          fontSize: responsiveFont(context, 36),
                          fontWeight: bold,
                          color: accentColor,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: responsiveHeight(context, 0.02)),

                  // Form Inputs
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsiveWidth(context, 0.07),
                    ),
                    child: Column(
                      children: [
                        _inputField("Username", _usernameController),
                        const SizedBox(height: 16),
                        _inputField("Email Address", _emailController),
                        const SizedBox(height: 16),
                        _inputField(
                          "Mobile Number",
                          _mobileController,
                          isMobileNumber: true,
                        ),
                        const SizedBox(height: 16),
                        _inputField(
                          "Password",
                          _passwordController,
                          isPassword: true,
                        ),
                        const SizedBox(height: 16),
                        _inputField(
                          "Confirm Password",
                          _confirmPasswordController,
                          isPassword: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Login Redirect
                  Text.rich(
                    TextSpan(
                      text: "Already have an account? ",
                      style: GoogleFonts.poppins(
                        fontSize: responsiveFont(context, 14), // Font dibesarkan
                        color: accentColor.withOpacity(0.7),
                      ),
                      children: [
                        TextSpan(
                          text: "Log in",
                          style: GoogleFonts.poppins(
                            fontWeight: bold,
                            fontSize: responsiveFont(context, 14), // Font dibesarkan
                            color: accentColor,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pop(context);
                            },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Terms & Conditions
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        Expanded(
                          child: Text(
                            "I agree with the terms and conditions",
                            style: GoogleFonts.poppins(
                              fontSize: responsiveFont(context, 13), // Font dibesarkan dikit
                              color: accentColor.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tombol Next
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsiveWidth(context, 0.07),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleRegister, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: blackColor,
                          padding: const EdgeInsets.symmetric(vertical: 16), // Padding tombol diperbesar
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: GoogleFonts.poppins(
                            fontSize: 18, // Font tombol diperbesar
                            fontWeight: bold,
                          ),
                        ),
                        child: const Text("Next"),
                      ),
                    ),
                  ),
                  SizedBox(height: responsiveHeight(context, 0.05)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}