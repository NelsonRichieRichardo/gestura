import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gestura/core/themes/app_theme.dart';

class DictionaryPage extends StatelessWidget {
  const DictionaryPage({super.key});

  // Contoh data kamus (menggunakan ikon tangan sebagai placeholder)
  final List<Map<String, String>> dictionaryEntries = const [
    {"sign": "Y", "description": "Letter Y handshape – thumb and pinky out"},
    {"sign": "A", "description": "Letter A handshape – closed fist"},
    {"sign": "B", "description": "Letter B handshape – flat hand, thumb crossed"},
    {"sign": "C", "description": "Letter C handshape – curved hand"},
    {"sign": "D", "description": "Letter D handshape – index finger up"},
  ];

  @override
  Widget build(BuildContext context) {
    final sw = screenWidth(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
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
              SizedBox(height: responsiveHeight(context, 0.01)),

              // Title
              Text(
                "Dictionary", 
                style: GoogleFonts.poppins(
                  fontSize: responsiveFont(context, 28),
                  fontWeight: bold,
                  color: accentColor,
                ),
              ),
              SizedBox(height: responsiveHeight(context, 0.03)),

              // Search Bar
              _buildSearchBar(context),
              SizedBox(height: responsiveHeight(context, 0.03)),

              // Dictionary List
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(), // Disable inner scroll
                shrinkWrap: true,
                itemCount: dictionaryEntries.length,
                itemBuilder: (context, index) {
                  final entry = dictionaryEntries[index];
                  return _buildDictionaryItem(context, entry['sign']!, entry['description']!);
                },
              ),
              SizedBox(height: responsiveHeight(context, 0.15)), // Ruang untuk FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: responsiveWidth(context, 0.04)),
      decoration: BoxDecoration(
        color: secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: greyColor.withOpacity(0.3)),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "search",
          hintStyle: bodyText.copyWith(color: greyColor),
          suffixIcon: Icon(Icons.search, color: accentColor),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: responsiveFont(context, 14)),
        ),
      ),
    );
  }

  Widget _buildDictionaryItem(BuildContext context, String sign, String description) {
    return Container(
      margin: EdgeInsets.only(bottom: responsiveHeight(context, 0.02)),
      padding: EdgeInsets.all(responsiveFont(context, 16)),
      decoration: BoxDecoration(
        color: secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sign Icon/Image Placeholder
          Container(
            width: responsiveWidth(context, 0.15),
            height: responsiveWidth(context, 0.15),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            // Placeholder tangan (Bisa diganti dengan Image.asset)
            child: Center(
              child: Text(
                "🤘", // Emoji tangan yang sedikit mirip ASL 'Y'
                style: TextStyle(fontSize: responsiveFont(context, 30)),
              ),
            ),
          ),
          SizedBox(width: responsiveWidth(context, 0.04)),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sign,
                  style: heading2.copyWith(fontWeight: bold, fontSize: responsiveFont(context, 18)),
                ),
                Text(
                  description,
                  style: bodyText.copyWith(color: greyColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}