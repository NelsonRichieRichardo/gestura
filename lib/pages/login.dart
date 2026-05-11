import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Tambahkan imports untuk Social Login
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

// Asumsi imports ini berisi definisi warna, font weight, dan fungsi helper
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

  // Controller khusus untuk input email di dialog Forgot Password
  final TextEditingController _resetEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _resetEmailController.dispose();
    super.dispose();
  }

  // --- LOGIKA SAVE PASSWORD ---

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
      // Tidak perlu menampilkan error ke user, cukup log
      debugPrint("Error loading credentials: $e");
    }
  }

  Future<void> _saveUserCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('email', _emailController.text.trim());
      await prefs.setString('password', _passwordController.text.trim());
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.setBool('remember_me', false);
    }
  }

  // --- LOGIKA FORGOT PASSWORD ---

  Future<void> _handleForgotPassword() async {
    // 1. Tampilkan Dialog untuk Input Email
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Jika email di kolom login terisi, gunakan sebagai nilai awal
        if (_emailController.text.isNotEmpty) {
          _resetEmailController.text = _emailController.text.trim();
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Reset Kata Sandi',
            style: GoogleFonts.poppins(fontWeight: bold, color: accentColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Masukkan alamat email Anda yang terdaftar untuk menerima tautan reset kata sandi.',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _resetEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Email Anda",
                  hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  fillColor: secondaryBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetEmailController.clear();
              },
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(color: accentColor.withOpacity(0.7)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                _sendPasswordResetEmail(_resetEmailController.text.trim());
              },
              child: Text(
                'Kirim Link',
                style: GoogleFonts.poppins(color: primaryColor, fontWeight: bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // 2. Fungsi untuk Mengirim Email Reset
  Future<void> _sendPasswordResetEmail(String email) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email tidak boleh kosong.')),
      );
      return;
    }

    LoadingOverlay.show(context);
    
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);

      if (!mounted) return;
      LoadingOverlay.hide(context);
      
      // Menggunakan pesan generik untuk keamanan (praktik terbaik)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Jika email terdaftar, tautan reset telah dikirim. Cek inbox Anda.'),
          backgroundColor: successColor, 
        ),
      );
      _resetEmailController.clear();
    } on AuthException catch (e) {
      if (!mounted) return;
      LoadingOverlay.hide(context);
      
      String message = "Gagal mengirim tautan reset: ${e.message}";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: dangerColor), 
      );
    } catch (e) {
      if (!mounted) return;
      LoadingOverlay.hide(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan tak terduga: $e'), backgroundColor: dangerColor),
      );
    }
  }

  // --- FUNGSI BANTU UNTUK NAVIGASI SETELAH LOGIN BERHASIL ---

  Future<void> _navigateToHome(String uid) async {
    // Pengambilan data username dari Supabase public.users
    String username = "Mate";

    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('username')
          .eq('id', uid)
          .maybeSingle();

      if (response != null && response['username'] != null) {
        username = response['username'];
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }

    if (!mounted) return;

    LoadingOverlay.hide(context);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage(username: username)),
    );
  }

  // --- LOGIKA LOGIN EMAIL/PASSWORD ---

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
      final AuthResponse res = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Simpan Password jika login berhasil dan checkbox dicentang
      await _saveUserCredentials();

      if (res.user != null) {
        String uid = res.user!.id;
        await _navigateToHome(uid);
      } else {
        throw Exception("Login failed: Unknown error");
      }

    } on AuthException catch (e) {
      if (mounted) {
        LoadingOverlay.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.message}'), backgroundColor: dangerColor),
        );
      }
    } catch (e) {
      if (mounted) {
        LoadingOverlay.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: dangerColor,
          ),
        );
      }
    }
  }

  // --- LOGIKA LOGIN GOOGLE ---

  Future<void> _handleGoogleLogin() async {
    LoadingOverlay.show(context);
    try {
      /// Web Client ID that you registered with Google Cloud.
      const webClientId = 'YOUR_GOOGLE_WEB_CLIENT_ID'; // Ganti dengan Client ID web Anda
      /// IOS Client ID that you registered with Google Cloud.
      // const iosClientId = 'YOUR_GOOGLE_IOS_CLIENT_ID'; // Uncomment jika perlu

      // 1. Pemicu alur autentikasi.
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
        // clientId: iosClientId,
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // Pengguna membatalkan proses sign in
        if (!mounted) return;
        LoadingOverlay.hide(context);
        return;
      }

      // 2. Minta kredensial.
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'No ID Token found.';
      }

      // 3. Masuk ke Supabase dengan idToken.
      final AuthResponse res = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // Lanjutkan ke navigasi
      if (res.user != null) {
        await _navigateToHome(res.user!.id);
      } else {
        throw Exception("Supabase Google Login returned null user");
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      LoadingOverlay.hide(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Google Login Failed: ${e.message}"),
          backgroundColor: dangerColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      LoadingOverlay.hide(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An unexpected error occurred: $e"),
          backgroundColor: dangerColor,
        ),
      );
    }
  }

  // --- LOGIKA LOGIN FACEBOOK ---

  Future<void> _handleFacebookLogin() async {
    LoadingOverlay.show(context);
    try {
      // Supabase OAuth Login for Facebook
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.facebook,
      );
      // Note: Browser will open for OAuth. Upon success, main.dart's auth state listener will handle navigation.
      if (mounted) LoadingOverlay.hide(context);
    } on AuthException catch (e) {
      if (!mounted) return;
      LoadingOverlay.hide(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Facebook Login Failed: ${e.message}"),
          backgroundColor: dangerColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      LoadingOverlay.hide(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An unexpected error occurred: $e"),
          backgroundColor: dangerColor,
        ),
      );
    }
  }

  // --- WIDGET HELPER ---

  Widget _inputField({
    required String hint,
    required bool isPassword,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      keyboardType: isPassword ? TextInputType.text : TextInputType.emailAddress,
      style: GoogleFonts.poppins(color: accentColor),
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

  Widget _socialButton({
    required String label,
    required bool dark,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: dark ? accentColor : backgroundColor,
        foregroundColor: dark ? backgroundColor : blackColor,
        elevation: 1,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: medium),
        side: dark ? null : BorderSide(color: greyColor.withOpacity(0.5), width: 1),
      ),
      child: Text(label),
    );
  }

  // --- BUILD METHOD ---

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
                              fontSize: isLarge
                                  ? 40
                                  : responsiveFont(context, 36),
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
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
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
                                      fontSize: responsiveFont(
                                        context,
                                        13,
                                      ), 
                                      color: accentColor.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),

                              // Forgot Password (Kanan)
                              GestureDetector(
                                onTap: _handleForgotPassword, 
                                child: Text(
                                  "Forgot Password?",
                                  style: GoogleFonts.poppins(
                                    fontSize: responsiveFont(
                                      context,
                                      13,
                                    ), 
                                    color: primaryColor, 
                                    fontWeight: FontWeight.w600,
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
                                fontSize: responsiveFont(
                                  context,
                                  13,
                                ),
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
                                  onPressed: _handleGoogleLogin, 
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _socialButton(
                                  label: "Facebook",
                                  dark: true,
                                  onPressed: _handleFacebookLogin, 
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
                                  fontSize: responsiveFont(
                                    context,
                                    15,
                                  ),
                                  color: accentColor.withOpacity(0.7),
                                ),
                                children: [
                                  TextSpan(
                                    text: "Register",
                                    style: GoogleFonts.poppins(
                                      fontSize: responsiveFont(
                                        context,
                                        15,
                                      ),
                                      fontWeight: bold,
                                      color: primaryColor,
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