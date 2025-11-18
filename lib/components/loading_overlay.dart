import 'package:flutter/material.dart';
import 'package:gestura/core/themes/app_theme.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    // Perbaikan: Menggunakan Stack sebagai wadah utama.
    // ModalBarrier (penutup) dan konten loading harus menjadi elemen terpisah di dalam Stack.
    return Stack(
      children: [
        // 1. ModalBarrier: Bertindak sebagai latar belakang gelap transparan
        // dan mencegah interaksi di bawahnya. (Tidak memiliki properti 'child')
        ModalBarrier(
          dismissible: false,
          color: blackColor.withOpacity(0.4), 
        ),
        
        // 2. Content Loading: Ditampilkan di tengah layar, di atas ModalBarrier.
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: shadowColor.withOpacity(0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
                const SizedBox(height: 10),
                Text(
                  "Memuat...",
                  style: bodyText.copyWith(color: accentColor),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Fungsi statis untuk menampilkan overlay
  static void show(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false, // Penting agar konten di bawahnya masih terlihat
        pageBuilder: (context, animation, secondaryAnimation) => const LoadingOverlay(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  // Fungsi statis untuk menyembunyikan overlay
  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}