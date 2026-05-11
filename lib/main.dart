import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'core/utils/supabase_config.dart';
import 'core/themes/app_theme.dart';

// Halaman-halaman
import 'pages/onboarding.dart';
import 'pages/home.dart';
import 'pages/camera.dart'; 

// ===============================================
// DEKLARASI GLOBAL CAMERA
// ===============================================
List<CameraDescription> cameras = []; 
bool isCameraAvailable = false; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tunggu init firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // Sesi akan bertahan otomatis (Persistence)
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
      home: StreamBuilder<AuthState>(
        // Menggunakan stream dari Supabase
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          // 1. Tampilkan Loading saat koneksi belum siap
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 2. Cek apakah ada sesi user (Auth Session)
          final session = snapshot.data?.session;
          if (session != null) {
            return const HomePage(username: "User");
          }

          // 3. Jika user BELUM LOGIN -> Pindah ke Onboarding
          return const OnboardingPage();
        },
      ),
    );
  }
}

