import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'core/themes/app_theme.dart';

// Halaman-halaman
import 'pages/onboarding.dart';
import 'pages/home.dart';
import 'pages/camera.dart'; 

// ===============================================
// DEKLARASI GLOBAL CAMERA
// ===============================================
late List<CameraDescription> cameras = []; 
bool isCameraAvailable = false; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tunggu init firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // =========================================================
  // ✅ SOLUSI UNTUK MENGHAPUS SESI SAAT APLIKASI DI-RESTART
  // Ini akan memaksa semua pengguna untuk melalui Onboarding/Login
  // setiap kali aplikasi dimulai ulang.
  // =========================================================
  try {
    await FirebaseAuth.instance.signOut();
    print("Sesi Firebase berhasil dihapus saat aplikasi dimulai ulang.");
  } catch (e) {
    print("Gagal menghapus sesi: $e");
  }
  // =========================================================

  // Init camera
  try {
    // 1. Coba mendapatkan kamera yang tersedia
    cameras = await availableCameras();
    // 2. Jika berhasil, set flag ke true
    if (cameras.isNotEmpty) {
      isCameraAvailable = true;
    }
  } on CameraException catch (e) {
    // Tangani error jika tidak ada kamera atau izin
    print('Error accessing cameras: $e');
  }
  
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

      // LOGIKA PENENTUAN HALAMAN UTAMA
      home: StreamBuilder<User?>(
        // Karena kita memanggil signOut() di main, stream ini akan segera mengembalikan null.
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. Tampilkan Loading saat koneksi belum siap
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 2. Karena signOut() dipanggil di main, ini akan menjadi null.
          if (snapshot.hasData && snapshot.data != null) {
            // Jika Anda ingin menguji login, hapus baris signOut() di main.
            return const HomePage(username: "User");
          }

          // 3. Jika user BELUM LOGIN (snapshot.data == null) -> Pindah ke Onboarding
          return const OnboardingPage();
        },
      ),
    );
  }
}