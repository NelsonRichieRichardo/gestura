import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gestura/pages/onboarding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

// Core imports
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
	// =========================================================================
	// STATE MANAGEMENT
	// =========================================================================

	/// Controllers untuk input email dan password.
	final TextEditingController _emailController = TextEditingController();
	final TextEditingController _passwordController = TextEditingController();

	/// State untuk toggle visibilitas password.
	bool _isPasswordVisible = false;

	@override
	void dispose() {
		// Pastikan semua controller dibuang.
		_emailController.dispose();
		_passwordController.dispose();
		super.dispose();
	}

	// =========================================================================
	// LOGIC / FUNCTION
	// =========================================================================

	/// Fungsi utama yang dipanggil saat tombol "Login" ditekan.
	/// Mengatur validasi, proses login ke Firebase Auth, dan pengambilan data user dari Firestore.
	Future<void> _handleLogin() async {
		// A. Validasi Input Kosong
		if (_emailController.text.trim().isEmpty ||
				_passwordController.text.trim().isEmpty) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text("Please enter email and password")),
			);
			return;
		}

		// B. Tampilkan Loading Overlay
		LoadingOverlay.show(context);

		try {
			// C. Proses Login ke Firebase Auth
			UserCredential userCredential = await FirebaseAuth.instance
					.signInWithEmailAndPassword(
				email: _emailController.text.trim(),
				password: _passwordController.text.trim(),
			);

			// D. Jika Login Berhasil, Ambil Data Username dari Firestore
			String uid = userCredential.user!.uid;
			
			DocumentSnapshot userDoc = await FirebaseFirestore.instance
					.collection('users')
					.doc(uid)
					.get();

			// Default username
			String username = "Mate"; 

			if (userDoc.exists) {
				// Ambil field 'username' yang disimpan saat Register
				username = userDoc.get('username') ?? "Mate";
			}

			if (!mounted) return;

			// E. Sukses - Tutup Loading & Navigasi ke Home Page
			LoadingOverlay.hide(context);

			// Navigasi dengan pushReplacement agar tidak bisa back ke halaman login
			Navigator.pushReplacement(
				context,
				MaterialPageRoute(
					builder: (context) => HomePage(username: username),
				),
			);

		} on FirebaseAuthException catch (e) {
			// F. Error Handling Khusus Firebase Authentication
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
					// Error umum untuk kombinasi email/password yang salah
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
			// G. Error Umum Lainnya
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

	// =========================================================================
	// UI COMPONENTS
	// =========================================================================

	/// Template umum untuk input field (Email dan Password).
	Widget _inputField({
		required String hint,
		required bool isPassword,
		required TextEditingController controller,
	}) {
		return TextField(
			controller: controller,
			// Menentukan apakah teks disembunyikan
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
				// Tombol toggle visibilitas password
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

	/// Tombol utama untuk aksi Login.
	Widget _primaryButton(String text) {
		return SizedBox(
			width: double.infinity,
			child: ElevatedButton(
				// Panggil fungsi login
				onPressed: _handleLogin, 
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

	/// Template untuk tombol login pihak ketiga (Google, Facebook).
	Widget _socialButton({required String label, required bool dark}) {
		return ElevatedButton(
			onPressed: () {
				// Todo: Implement Social Login later
			},
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

	// =========================================================================
	// BUILD METHOD (Layout Utama)
	// =========================================================================
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: backgroundColor,
			// AppBar transparan dengan tombol kembali
			appBar: AppBar(
				backgroundColor: Colors.transparent,
				elevation: 0,
				leading: IconButton(
					icon: Icon(Icons.arrow_back_ios, color: accentColor),
					onPressed: () {
						Navigator.pushReplacement(
				context,
				MaterialPageRoute(
					builder: (context) => OnboardingPage(),
				),
			);
					},
				),
				toolbarHeight: 50,
			),
			body: SafeArea(
				child: LayoutBuilder(
					builder: (context, constraints) {
						// Menentukan apakah layar cukup besar (untuk optimasi layout)
						final bool isLarge = constraints.maxHeight > 750;

						return Column(
							children: [
								// Illustration Image (fleksibel berdasarkan ukuran layar)
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

								// Form Container (fleksibel untuk mengakomodasi keyboard)
								Expanded(
									flex: 3,
									child: SingleChildScrollView(
										// Mematikan scrolling jika layar besar, mengaktifkan bounce jika kecil
										physics: isLarge
												? const NeverScrollableScrollPhysics()
												: const BouncingScrollPhysics(),
										child: Padding(
											padding: const EdgeInsets.symmetric(horizontal: 28),
											child: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													SizedBox(height: isLarge ? 10 : 20),

													// Title "Welcome back, Mate!!"
													Text(
														"Welcome back,\nMate!!",
														style: GoogleFonts.poppins(
															fontSize: isLarge ? 34 : responsiveFont(context, 30),
															fontWeight: bold,
															color: accentColor,
															height: 1.2,
														),
													),

													const SizedBox(height: 14),

													// INPUT EMAIL
													_inputField(
														hint: "Email Address",
														isPassword: false,
														controller: _emailController,
													),

													const SizedBox(height: 14),

													// INPUT PASSWORD
													_inputField(
														hint: "Password",
														isPassword: true,
														controller: _passwordController,
													),

													const SizedBox(height: 8),

													// Forgot Password Text
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

													// Login Button
													_primaryButton("Login"),

													const SizedBox(height: 10),

													// Divider Text
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

													// Social Buttons (Google dan Facebook)
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

													// Register Redirect Text
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
																			color: primaryColor,
																		),
																		// GestureDetector untuk navigasi ke RegisterPage
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
													SizedBox(height: isLarge ? 20 : 10), // Padding bawah
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