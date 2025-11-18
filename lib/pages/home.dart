import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gestura/core/themes/app_theme.dart';
// Note: Asumsi file responsive.dart ada
// import 'package:gestura/core/utils/responsive.dart'; 

// Mengubah menjadi StatefulWidget untuk mengelola lifecycle dan menampilkan notifikasi
class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    // Tampilkan notifikasi setelah frame pertama selesai di-render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeNotification(context, widget.username);
    });
  }

  void _showWelcomeNotification(BuildContext context, String username) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Selamat datang, $username!",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: bold),
        ),
        backgroundColor: primaryColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.symmetric(
          horizontal: responsiveWidth(context, 0.05),
          vertical: 10,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Dashboard",
          style: GoogleFonts.poppins(color: accentColor, fontWeight: bold),
        ),
        backgroundColor: secondaryBackground,
        iconTheme: const IconThemeData(color: accentColor),
        elevation: 1,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(responsiveWidth(context, 0.05)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "🎉 Selamat datang kembali, ${widget.username}! 🎉",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: responsiveFont(context, 24),
                  fontWeight: bold,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: responsiveHeight(context, 0.02)),
              Text(
                "Ini adalah halaman beranda (Home Page) Anda setelah berhasil masuk.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: responsiveFont(context, 16),
                  color: accentColor.withOpacity(0.8),
                ),
              ),
              SizedBox(height: responsiveHeight(context, 0.05)),
              ElevatedButton(
                onPressed: () {
                  // Tambahkan ini untuk memastikan SnackBar disembunyikan
                  ScaffoldMessenger.of(context).hideCurrentSnackBar(); 
                  
                  // Kembali ke halaman Login
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: secondaryBackground,
                  padding: EdgeInsets.symmetric(
                    vertical: responsiveHeight(context, 0.015),
                    horizontal: responsiveWidth(context, 0.08),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Kembali ke Login",
                  style: GoogleFonts.poppins(fontWeight: medium),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}