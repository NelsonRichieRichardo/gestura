import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gestura/core/themes/app_theme.dart'; 

class DictionaryDetailPage extends StatelessWidget {
  final String sign;
  final String description;

  const DictionaryDetailPage({
    super.key,
    required this.sign,
    required this.description,
  });

  // --- HELPER 1: WIDGET TILE DENGAN PARAMETER UKURAN BARU ---
  Widget _buildSignTileForList(BuildContext context, String char, {double size = 120}) {
    // Jika karakter adalah spasi, tampilkan pemisah
    if (char == ' ') {
      return Container(
        width: 30, 
        alignment: Alignment.center,
        child: Icon(Icons.space_bar_rounded, color: Colors.grey.shade300, size: 28),
      );
    }

    final assetPath = "assets/bisindo/$char.gif";

    return Container(
      width: size, // Menggunakan ukuran dinamis
      height: size,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              assetPath,
              fit: BoxFit.cover, 
              width: size,
              height: size,
              errorBuilder: (ctx, err, stack) {
                // Fallback jika GIF tidak ditemukan
                return Center(
                  child: Text(
                    char.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: size * 0.3, // Ukuran font responsif
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                );
              },
            ),
            // Teks overlay kecil di pojok
            Positioned(
              bottom: 8,
              right: 8,
              child: Text(
                char.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- HELPER 2: KONTEN GAMBAR UTAMA (Logika A-Z dan Kata/Kalimat) ---
  Widget _buildSignContent(BuildContext context) {
    final isLetter = sign.length == 1;
    final screenWidth = MediaQuery.of(context).size.width;

    if (isLetter) {
      // 1. LOGIKA UNTUK HURUF A-Z (Satu GIF BESAR)
      
      // UKURAN BARU: 80% dari lebar layar
      final largeSize = screenWidth * 0.8; 

      return Center(
        child: Container(
          width: largeSize,
          height: largeSize,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30), // Sudut lebih besar untuk tampilan premium
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            // MEMANGGIL TILE DENGAN UKURAN BESAR BARU
            child: _buildSignTileForList(context, sign.toLowerCase(), size: largeSize), 
          ),
        ),
      );
    } else {
      // 2. LOGIKA UNTUK KATA/KALIMAT (List Horizontal GIF)
      
      final characters = sign.split('').toList();

      return Center(
        child: SizedBox(
          height: screenWidth * 0.45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            itemCount: characters.length,
            itemBuilder: (context, index) {
              String char = characters[index];
              // MEMANGGIL TILE DENGAN UKURAN KECIL (default 120)
              return _buildSignTileForList(context, char.toLowerCase()); 
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Stack(
        children: [
          // 1. BAGIAN ATAS: GAMBAR/GIF Immersive
          Column(
            children: [
              Container(
                height: screenHeight * 0.55,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  child: Container(
                    color: primaryColor.withOpacity(0.05),
                    child: _buildSignContent(context),
                  ),
                ),
              ),

              // 2. BAGIAN BAWAH: DESKRIPSI (Teks di Tengah)
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.08,
                    vertical: responsiveHeight(context, 0.04),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Judul Utama (Huruf/Kata)
                      Text(
                        sign,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: responsiveFont(context, 40),
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Garis dekorasi kecil
                      Container(
                        width: 60, height: 5,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      SizedBox(height: responsiveHeight(context, 0.03)),

                      // Label Ejaan (Hanya untuk Kata/Kalimat)
                      if (sign.length > 1) 
                        Text(
                          "Spelling: ${sign.toUpperCase().replaceAll(' ', ' ')}",
                          style: GoogleFonts.poppins(
                            fontSize: responsiveFont(context, 14),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      SizedBox(height: responsiveHeight(context, 0.02)),


                      // Deskripsi
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: bodyText.copyWith(
                          fontSize: responsiveFont(context, 15),
                          color: Colors.grey.shade700,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // TOMBOL BACK (Melayang di pojok kiri atas)
          Positioned(
            top: MediaQuery.of(context).padding.top + 20, 
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}