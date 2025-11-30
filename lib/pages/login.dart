import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import ini untuk Save Password

import 'package:gestura/core/themes/app_theme.dart';
import 'package:gestura/pages/register.dart';
import 'package:gestura/pages/home.dart';
import 'package:gestura/components/loading_overlay.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  
  // State untuk Save Password
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadUserCredentials(); // Cek apakah ada password yang tersimpan saat aplikasi dibuka
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LOGIKA SAVE PASSWORD ---
  
  // 1. Memuat data dari penyimpanan lokal
  void _loadUserCredentials() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool remember = prefs.getBool('remember_me') ?? false;

      if (remember) {
        setState(() {
          _rememberMe = true;
          _emailController.text = prefs.getString('email') ?? '';
          _passwordController.text = prefs.getString('password') ?? '';
        });
      }
    } catch (e) {
      print("Error loading credentials: $e");
    }
  }

  // 2. Menyimpan data ke penyimpanan lokal
  Future<void> _saveUserCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('email', _emailController.text);
      await prefs.setString('password', _passwordController.text);
      await prefs.setBool('remember_me', true);
    } else {
      // Jika checkbox dimatikan, hapus data
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.setBool('remember_me', false);
    }
  }

  // --- LOGIKA LOGIN ---

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    LoadingOverlay.show(context);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Simpan Password jika login berhasil dan checkbox dicentang
      await _saveUserCredentials();

      String uid = userCredential.user!.uid;
      
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      String username = "Mate"; 

      if (userDoc.exists) {
        username = userDoc.get('username') ?? "Mate";
      }

      if (!mounted) return;

      LoadingOverlay.hide(context);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(username: username),
        ),
      );

    } on FirebaseAuthException catch (e) {
      if (mounted) {
        LoadingOverlay.hide(context);
        String message = "Login failed";
        
        if (e.code == 'user-not-found') {
          message = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          message = 'Wrong password provided.';
        } else if (e.code == 'invalid-email') {
          message = 'The email address is not valid.';
        } else if (e.code == 'invalid-credential') {
          message = 'Invalid email or password.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        LoadingOverlay.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _inputField({
    required String hint,
    required bool isPassword,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        filled: true,
        fillColor: secondaryBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _primaryButton(String text) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleLogin, 
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: blackColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: bold),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: accentColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        toolbarHeight: 50,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isLarge = constraints.maxHeight > 750;

            return Column(
              children: [
                Expanded(
                  flex: 3, 
                  child: Align(
                    alignment: Alignment.bottomCenter, 
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0), 
                      child: Image.asset(
                        "assets/images/login.png",
                        width: screenWidth(context),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    physics: isLarge
                        ? const NeverScrollableScrollPhysics()
                        : const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome back,\nMate!!",
                            style: GoogleFonts.poppins(
                              fontSize: isLarge ? 40 : responsiveFont(context, 36),
                              fontWeight: bold,
                              color: accentColor,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _inputField(
                            hint: "Email Address",
                            isPassword: false,
                            controller: _emailController,
                          ),
                          const SizedBox(height: 14),
                          _inputField(
                            hint: "Password",
                            isPassword: true,
                            controller: _passwordController,
                          ),
                          
                          // --- BARIS SAVE PASSWORD & FORGOT PASSWORD ---
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Save Password (Kiri)
                              Row(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      activeColor: primaryColor,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Save Password",
                                    style: GoogleFonts.poppins(
                                      fontSize: responsiveFont(context, 13), // Ukuran Font Save Password
                                      color: accentColor.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Forgot Password (Kanan)
                              GestureDetector(
                                onTap: () {
                                  // Logika Forgot Password di sini
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: GoogleFonts.poppins(
                                    fontSize: responsiveFont(context, 13), // EDIT: Font dibesarkan (11 -> 13)
                                    color: accentColor.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 15),
                          _primaryButton("Login"),
                          const SizedBox(height: 15),
                          
                          Center(
                            child: Text(
                              "Or login with",
                              style: GoogleFonts.poppins(
                                fontSize: responsiveFont(context, 13), // EDIT: Font dibesarkan (11 -> 13)
                                color: accentColor.withOpacity(0.6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
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
                          const SizedBox(height: 20),
                          Center(
                            child: Text.rich(
                              TextSpan(
                                text: "Don't have an account? ",
                                style: GoogleFonts.poppins(
                                  fontSize: responsiveFont(context, 15), // EDIT: Font dibesarkan (13 -> 15)
                                  color: accentColor.withOpacity(0.7),
                                ),
                                children: [
                                  TextSpan(
                                    text: "Register",
                                    style: GoogleFonts.poppins(
                                      fontSize: responsiveFont(context, 15), // EDIT: Font dibesarkan (13 -> 15)
                                      fontWeight: bold,
                                      color: primaryColor,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const RegisterPage(),
                                          ),
                                        );
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: isLarge ? 20 : 10),
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
}