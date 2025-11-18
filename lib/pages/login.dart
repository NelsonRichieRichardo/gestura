import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gestura/pages/register.dart'; 
import 'package:gestura/pages/home.dart'; // Import halaman Home yang baru
import 'package:google_fonts/google_fonts.dart';
import 'package:gestura/core/themes/app_theme.dart';
// =================================================================
// Ubah dari StatelessWidget ke StatefulWidget untuk mengelola state form
// =================================================================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 1. Controller untuk menangkap input teks
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 2. State untuk toggle visibilitas password
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // =====================================================
  //                INPUT COMPONENT (MODIFIED)
  // =====================================================
  Widget _inputField({
    required String hint,
    required bool isPassword,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      // Tentukan apakah teks harus disembunyikan
      obscureText: isPassword && !_isPasswordVisible,
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
        // Tambahkan tombol toggle mata hanya jika itu adalah field password
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  // Menggunakan setState untuk mengubah state visibilitas
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }

  // =====================================================
  //               PRIMARY BUTTON (MODIFIED)
  // =====================================================
  Widget _primaryButton(String text) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Tangkap nilai username
          final username = _usernameController.text.isNotEmpty
              ? _usernameController.text
              : "Pengguna";

          // Bersihkan controller SEBELUM navigasi
          _usernameController.clear();
          _passwordController.clear();
            
          // Navigasi ke HomePage (Notifikasi akan ditampilkan di HomePage)
          // Tidak ada blok .then() atau pemanggilan notifikasi di sini.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(username: username),
            ),
          );
        },
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

  // =====================================================
  //               SOCIAL BUTTON (UNMODIFIED)
  // =====================================================
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
        title: const Text(''),
        toolbarHeight: 50,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isLarge = constraints.maxHeight > 750;

            return Column(
              children: [
                // ============================
                //      FULL WIDTH IMAGE
                // ============================
                Expanded(
                  flex: isLarge ? 3 : 2,
                  child: Center(
                    child: Image.asset(
                      "assets/images/login.png",
                      width: screenWidth(context),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),

                // ============================
                //      FORM SECTION
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
                          _inputField(
                            hint: "Username",
                            isPassword: false,
                            controller: _usernameController, // Gunakan controller
                          ),

                          const SizedBox(height: 14),

                          // PASSWORD INPUT (dengan logo mata)
                          _inputField(
                            hint: "Password",
                            isPassword: true,
                            controller: _passwordController, // Gunakan controller
                          ),

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

                          // LOGIN BUTTON (menuju Home)
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
}