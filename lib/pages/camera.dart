import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gestura/core/themes/app_theme.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool isFrontCamera = true;

  void _toggleCamera() {
    setState(() {
      isFrontCamera = !isFrontCamera;
    });
    // Di sini akan ada logika untuk memutar kamera
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

              // Camera View / Placeholder
              Expanded(
                child: Container(
                  width: sw,
                  margin: EdgeInsets.only(bottom: responsiveHeight(context, 0.03)),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300, // Warna abu-abu placeholder
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Placeholder Kamera
                      Center(
                        child: Icon(
                          Icons.camera_alt_outlined, 
                          size: responsiveFont(context, 80), 
                          color: greyColor,
                        ),
                      ),
                      
                      // Tombol Putar Kamera di Pojok Kanan Atas
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
                              Icons.sync, // Ikon putar kamera
                              color: backgroundColor,
                              size: responsiveFont(context, 24),
                            ),
                          ),
                        ),
                      ),
                      
                      // Teks Status Kamera (Opsional)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: responsiveFont(context, 10)),
                          child: Text(
                            isFrontCamera ? "Camera Depan" : "Camera Belakang",
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
                        maxLines: null, // Multiple lines
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
              
              SizedBox(height: responsiveHeight(context, 0.05)), // Ruang untuk FAB
            ],
          ),
        ),
      ),
    );
  }
}