import 'package:flutter/material.dart';
import 'package:gestura/core/themes/app_theme.dart'; // Import file tema

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, // Warna latar belakang dari app_theme
      appBar: AppBar(
        // Penataan AppBar agar sesuai dengan desain
        backgroundColor: backgroundColor, 
        elevation: 0, 
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: accentColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Terms & Conditions',
          style: heading2, // Menggunakan heading2 dari tema untuk judul
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Judul utama halaman
            Text(
              "Our App Terms & Conditions",
              style: heading2,
            ),
            const SizedBox(height: 16),

            // Paragraf 1: Penggunaan dan Fungsi
            Text(
              "By using Gestura, you agree to these Terms and Conditions. The app allows users to translate sign language into text through their device’s camera. Please use the app responsibly and only for personal and lawful purposes.",
              style: bodyText,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),

            // Paragraf 2: Hak Kekayaan Intelektual
            Text(
              "All content and technology within the app belong to [App Name] and are protected by intellectual property laws.",
              style: bodyText,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),

            // Paragraf 3: Pemrosesan Data (Konfirmasi Privasi)
            Text(
              "The app processes video input in real time and does not store or share any images or personal data.",
              style: bodyText,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),
            
            // Paragraf 4: Disclaimer (As Is) dan Perubahan
            Text(
              "The app is provided “as is,” and we are not responsible for any loss or damage caused by its use. We may update or modify the app and these terms at any time, and continued use means you accept those changes.",
              style: bodyText,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// Catatan: Pastikan file app_theme.dart tersedia dan sudah diimpor.