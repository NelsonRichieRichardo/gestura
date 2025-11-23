import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Core imports
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
	// =========================================================================
	// STATE MANAGEMENT
	// =========================================================================
	
	/// State untuk menyimpan negara yang dipilih dari Dropdown.
	Country selectedCountry = availableCountries.first;
	
	/// State untuk Checkbox Terms and Conditions.
	bool isAgreed = false;

	/// Controllers untuk input teks dari user.
	final TextEditingController _usernameController = TextEditingController();
	final TextEditingController _emailController = TextEditingController();
	final TextEditingController _mobileController = TextEditingController();
	final TextEditingController _passwordController = TextEditingController();
	final TextEditingController _confirmPasswordController = TextEditingController();

	@override
	void dispose() {
		// Pastikan semua controller dibuang untuk mencegah memory leaks.
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

	/// Fungsi utama yang dipanggil saat tombol "Next" ditekan.
	/// Mengatur validasi, proses pendaftaran ke Firebase Auth, dan penyimpanan data ke Firestore.
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

		// 4. Mulai Loading Overlay
		LoadingOverlay.show(context);

		try {
			// A. Buat Akun di Authentication (Email & Password)
			UserCredential userCredential = await FirebaseAuth.instance
					.createUserWithEmailAndPassword(
				email: _emailController.text.trim(),
				password: _passwordController.text.trim(),
			);

			String uid = userCredential.user!.uid;

			// B. Siapkan data dan simpan data lengkap ke Firestore Database
			String fullPhoneNumber = "${selectedCountry.dialCode}${_mobileController.text.trim()}";

			await FirebaseFirestore.instance.collection('users').doc(uid).set({
				'uid': uid,
				'username': _usernameController.text.trim(),
				'email': _emailController.text.trim(),
				'phoneNumber': fullPhoneNumber,
				'countryCode': selectedCountry.code,
				'createdAt': FieldValue.serverTimestamp(),
			});

			if (!mounted) return;

			// C. Sukses - Tutup Loading, Beri Notifikasi, dan Navigasi
			LoadingOverlay.hide(context);
			
			await Future.delayed(const Duration(milliseconds: 150)); 
			
			if (!mounted) return;

			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(
						content: Text("Registration Successful! Please Login."),
						backgroundColor: Colors.green),
			);

			// Arahkan ke Login Page setelah sukses
			Navigator.pushReplacement(
				context, 
				MaterialPageRoute(builder: (context) => const LoginPage())
			);

		} on FirebaseAuthException catch (e) {
			// D. Error Handling Khusus Firebase
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
			// E. Error Umum
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

	/// Template umum untuk semua TextField dalam form pendaftaran.
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
				hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
				// Menampilkan Country Picker sebagai prefix icon untuk input nomor HP
				prefixIcon: isMobileNumber ? _buildCountryPicker() : null,
				filled: true,
				fillColor: secondaryBackground,
				contentPadding: const EdgeInsets.symmetric(
					horizontal: 16,
					vertical: 14,
				),
				border: OutlineInputBorder(
					borderRadius: BorderRadius.circular(12),
					borderSide: BorderSide.none,
				),
			),
		);
	}

	/// Widget untuk memilih kode negara (bendera dan dial code).
	Widget _buildCountryPicker() {
		return Container(
			padding: EdgeInsets.only(left: responsiveWidth(context, 0.02)),
			constraints: BoxConstraints(maxWidth: responsiveWidth(context, 0.3)),
			child: DropdownButtonHideUnderline(
				child: DropdownButton<Country>(
					value: selectedCountry,
					icon: Icon(
						Icons.keyboard_arrow_down_rounded,
						size: responsiveFont(context, 20),
						color: Colors.grey,
					),
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
					items: availableCountries.map<DropdownMenuItem<Country>>((
						Country country,
					) {
						return DropdownMenuItem<Country>(
							value: country,
							child: Row(
								children: [
									// Menampilkan bendera negara
									Text(
										country.flag,
										style: TextStyle(fontSize: responsiveFont(context, 18)),
									),
									const SizedBox(width: 4),
									// Menampilkan kode dial negara (e.g., +62)
									Text(country.dialCode),
								],
							),
						);
					}).toList(),
				),
			),
		);
	}

	// =========================================================================
	// BUILD METHOD (Layout Utama)
	// =========================================================================
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
									// Back Button (Pindah ke halaman sebelumnya)
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
												onPressed: () => Navigator.pop(context),
											),
										),
									),

									// Illustration Image di bagian atas
									SizedBox(
										width: screenWidth(context),
										height: responsiveHeight(context, 0.20),
										child: Image.asset(
											"assets/images/register.png",
											fit: BoxFit.contain,
										),
									),

									SizedBox(height: responsiveHeight(context, 0.02)),

									// Title "Let’s get started, Mate!"
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

									// Form Inputs (Username, Email, Mobile, Password, Confirm Password)
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
												// Input field khusus untuk Mobile Number dengan Country Picker
												_inputField(
													"Mobile Number",
													_mobileController,
													isMobileNumber: true,
												),
												SizedBox(height: responsiveHeight(context, 0.012)),
												_inputField(
													"Password",
													_passwordController,
													isPassword: true,
												),
												SizedBox(height: responsiveHeight(context, 0.012)),
												_inputField(
													"Confirm Password",
													_confirmPasswordController,
													isPassword: true,
												),
											],
										),
									),

									SizedBox(height: responsiveHeight(context, 0.01)),

									// Text untuk redirect ke halaman Login
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
													// GestureDetector untuk navigasi ke LoginPage
													recognizer: TapGestureRecognizer()
														..onTap = () {
															Navigator.pop(context);
														},
												),
											],
										),
									),

									const SizedBox(height: 4),

									// Terms and Conditions Checkbox
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

									const SizedBox(height: 4),

									// NEXT BUTTON (Tombol untuk menjalankan _handleRegister)
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