import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gestura/core/themes/app_theme.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

// Import variabel global yang dideklarasikan di main.dart
import '../main.dart'; 

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController; 
  Future<void>? _initializeControllerFuture; 
  int selectedCameraIndex = 0; 
  bool _isInitialized = false; // Status inisialisasi controller berhasil
  bool _hasInitializationError = false; // Status kegagalan inisialisasi

  @override
  void initState() {
    super.initState();
    
    // ====================================================
    // HANYA INISIALISASI CONTROLLER JIKA KAMERA TERSEDIA
    // ====================================================
    if (isCameraAvailable) {
      // Coba cari kamera depan untuk inisialisasi awal
      final initialIndex = cameras.indexWhere((camera) => camera.lensDirection == CameraLensDirection.front);
      selectedCameraIndex = initialIndex != -1 ? initialIndex : 0; 
      _initializeController();
    }
  }

  void _initializeController() {
    // Memastikan kita tidak mencoba mengakses cameras[] jika gagal di main.dart
    if (!isCameraAvailable || cameras.isEmpty) return;
    
    setState(() {
      _hasInitializationError = false; // Reset error sebelum mencoba inisialisasi lagi
      _isInitialized = false;
    });
    
    // 1. Inisialisasi controller menggunakan daftar 'cameras' global
    _cameraController = CameraController(
      cameras[selectedCameraIndex], 
      ResolutionPreset.medium, 
    );

    // 2. Simpan Future inisialisasi
    _initializeControllerFuture = _cameraController!.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true; // Sukses
        });
      }
    }).catchError((error) {
       // Tangani error inisialisasi controller
       if (error is CameraException) {
          print('Controller initialization error: ${error.code}: ${error.description}');
       } else {
          print('Controller initialization error (Non-CameraException): $error');
       }
       // Jika ada error, set status gagal
       if (mounted) {
          setState(() {
            _hasInitializationError = true; // Set status error tampilan
            _isInitialized = false; 
          });
       }
    });
  }

  void _toggleCamera() async {
    // Hanya lakukan toggle jika ada lebih dari 1 kamera DAN sudah terinisialisasi
    if (cameras.length > 1 && _cameraController != null && _isInitialized) {
      final nextIndex = (selectedCameraIndex + 1) % cameras.length;
      
      await _cameraController!.dispose();

      setState(() {
        selectedCameraIndex = nextIndex;
      });
      _initializeController(); // Panggil ulang fungsi inisialisasi
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Widget _buildCameraView(double sw) {
    // KASUS 1: availableCameras() GAGAL di awal (Izin, Ketersediaan Perangkat)
    if (!isCameraAvailable) {
      // Tampilan untuk saat dijalankan di Web/Chrome atau izin ditolak
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, size: responsiveFont(context, 48), color: Colors.orange.shade600),
            SizedBox(height: responsiveFont(context, 10)),
            Text(
              "Kamera tidak tersedia.",
              style: bodyText.copyWith(color: blackColor, fontWeight: bold),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: EdgeInsets.only(top: responsiveFont(context, 5), left: sw * 0.05, right: sw * 0.05),
              child: Text(
                "Pastikan izin sudah diberikan dan Anda menjalankan aplikasi pada perangkat fisik (bukan web).",
                style: smallText.copyWith(color: greyColor),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      );
    }

    // KASUS 2, 3, 4: Menggunakan FutureBuilder untuk menampilkan proses inisialisasi
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        // KASUS 3: Future Selesai (SUCCESS atau FAILURE)
        if (snapshot.connectionState == ConnectionState.done) {
          if (_isInitialized) {
            // KASUS 3A: SUCCESS - Controller siap
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                  aspectRatio: _cameraController!.value.aspectRatio,
                  child: CameraPreview(_cameraController!)),
            );
          } else if (_hasInitializationError) {
            // KASUS 3B: FAILURE - Controller GAGAL inisialisasi
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: responsiveFont(context, 48), color: Colors.red.shade600),
                  SizedBox(height: responsiveFont(context, 10)),
                  Text(
                    "Gagal Memuat Kamera.",
                    style: bodyText.copyWith(color: blackColor, fontWeight: bold),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: responsiveFont(context, 5), left: sw * 0.05, right: sw * 0.05),
                    child: Text(
                      "Masalah umum di Emulator: coba restart atau ganti ke perangkat fisik. Cek konsol untuk detail error (e.g., kamera sedang digunakan aplikasi lain).",
                      style: smallText.copyWith(color: greyColor),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            );
          }
        } 
        
        // KASUS 4: WAITING - Placeholder Loading (Default)
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: accentColor),
              SizedBox(height: responsiveFont(context, 10)),
              Text(
                "Memuat Kamera...",
                style: bodyText.copyWith(color: greyColor),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = screenWidth(context);
    final sh = screenHeight(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: responsiveHeight(context, 0.02)),
              
              // App Name
              Text(
                "Gestura", 
                style: smallText.copyWith(color: accentColor.withOpacity(0.6), fontWeight: medium),
              ),
              SizedBox(height: responsiveHeight(context, 0.03)),

              // Camera View / Placeholder Container
              Expanded(
                child: Container(
                  width: sw,
                  margin: EdgeInsets.only(bottom: responsiveHeight(context, 0.03)),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Camera Preview / Placeholder
                      _buildCameraView(sw),
                      
                      // Tombol Putar Kamera di Pojok Kanan Atas
                      // Hanya tampilkan jika inisialisasi berhasil DAN ada lebih dari satu kamera
                      if (isCameraAvailable && _isInitialized && cameras.length > 1) 
                        Positioned(
                          top: responsiveFont(context, 10),
                          right: responsiveFont(context, 10),
                          child: InkWell(
                            onTap: _toggleCamera,
                            child: Container(
                              padding: EdgeInsets.all(responsiveFont(context, 6)),
                              decoration: BoxDecoration(
                                color: blackColor.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.sync, 
                                color: backgroundColor,
                                size: responsiveFont(context, 24),
                              ),
                            ),
                          ),
                        ),
                      
                      // Teks Status Kamera 
                      if (isCameraAvailable && _isInitialized) // Hanya tampilkan jika sudah siap
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: responsiveFont(context, 10)),
                            child: Text(
                              cameras[selectedCameraIndex].lensDirection == CameraLensDirection.front 
                                  ? "Camera Depan" 
                                  : "Camera Belakang",
                              style: smallText.copyWith(color: blackColor.withOpacity(0.7)),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ),
              
              // Translation Output Box
              Container(
                width: sw,
                height: responsiveHeight(context, 0.15),
                padding: EdgeInsets.all(responsiveFont(context, 12)),
                margin: EdgeInsets.only(bottom: responsiveHeight(context, 0.02)),
                decoration: BoxDecoration(
                  border: Border.all(color: greyColor.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TRANSLATE:",
                      style: smallText.copyWith(color: accentColor, fontWeight: bold),
                    ),
                    Expanded(
                      child: TextField(
                        readOnly: true,
                        maxLines: null, 
                        decoration: InputDecoration(
                          hintText: "Hasil terjemahan akan muncul di sini...",
                          hintStyle: bodyText.copyWith(color: greyColor),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: bodyText.copyWith(fontSize: responsiveFont(context, 16)),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: responsiveHeight(context, 0.05)), 
            ],
          ),
        ),
      ),
    );
  }
}