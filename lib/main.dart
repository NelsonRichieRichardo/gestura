import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

import 'firebase_options.dart';
import 'core/themes/app_theme.dart';

// Import halaman-halaman yang dibutuhkan
import 'pages/onboarding.dart';
import 'pages/home.dart';
import 'pages/login.dart'; 

void main() async {
	WidgetsFlutterBinding.ensureInitialized();
	await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
	runApp(const MyApp());
}

class MyApp extends StatelessWidget {
	const MyApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			debugShowCheckedModeBanner: false,
			title: 'Sign Language Translator',
			theme: ThemeData(
				fontFamily: 'Poppins',
				scaffoldBackgroundColor: backgroundColor,
			),
			
			// =========================================================
			// LOGIKA PENENTUAN HALAMAN UTAMA (Sesuai Permintaan Anda)
			// =========================================================
			home: StreamBuilder<User?>(
				// Mendengarkan perubahan status otentikasi
				stream: FirebaseAuth.instance.authStateChanges(),
				builder: (context, snapshot) {
					// 1. Tampilkan Loading saat koneksi belum siap
					if (snapshot.connectionState == ConnectionState.waiting) {
						return const Scaffold(
							body: Center(child: CircularProgressIndicator()),
						);
					}

					// 2. Jika user SUDAH LOGIN (Sesi Aktif)
					if (snapshot.hasData && snapshot.data != null) {
						// Langsung ke HomePage
						// Anda harus memastikan logika pengambilan username ada sebelum Home
						return const HomePage(username: "User"); 
					}

					// 3. Jika user BELUM LOGIN (snapshot.data == null)
					// SELALU arahkan ke OnboardingPage, yang kemudian akan mengarah ke LoginPage.
					return const OnboardingPage();
				},
			),
		);
	}
}