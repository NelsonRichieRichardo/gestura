import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gestura/core/themes/app_theme.dart';

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  String selectedCategory = "Huruf";
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // --- DATA SUMBER ---
  final List<Map<String, String>> dataHuruf = List.generate(26, (index) {
    String letter = String.fromCharCode(65 + index);
    return {
      "sign": letter,
      "description": "Isyarat tangan untuk huruf $letter",
      "image": "assets/images/signs/$letter.png" // Contoh path gambar (dummy)
    };
  });

  final List<Map<String, String>> dataKata = [
    {"sign": "Halo", "description": "Sapaan umum", "image": "assets/images/signs/halo.png"},
    {"sign": "Teman", "description": "Seseorang yang dikenal", "image": "assets/images/signs/teman.png"},
    {"sign": "Saya", "description": "Menunjuk diri sendiri", "image": "assets/images/signs/saya.png"},
  ];

  final List<Map<String, String>> dataKalimat = [
    {"sign": "Aku Cinta Kamu", "description": "Ungkapan kasih sayang", "image": "assets/images/signs/iloveyou.png"},
  ];

  List<Map<String, String>> getFilteredData() {
    List<Map<String, String>> activeList;
    switch (selectedCategory) {
      case "Kata": activeList = dataKata; break;
      case "Kalimat": activeList = dataKalimat; break;
      case "Huruf": default: activeList = dataHuruf; break;
    }

    if (searchQuery.isNotEmpty) {
      return activeList.where((item) {
        final sign = item['sign']!.toLowerCase();
        final desc = item['description']!.toLowerCase();
        final query = searchQuery.toLowerCase();
        return sign.contains(query) || desc.contains(query);
      }).toList();
    }
    return activeList;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = screenWidth(context);
    final filteredList = getFilteredData();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: responsiveHeight(context, 0.02)),
            
            // Header Area (Fixed)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Gestura", style: smallText.copyWith(color: accentColor.withOpacity(0.6), fontWeight: medium)),
                  SizedBox(height: responsiveHeight(context, 0.01)),
                  Text("Dictionary", style: GoogleFonts.poppins(fontSize: responsiveFont(context, 28), fontWeight: bold, color: accentColor)),
                  SizedBox(height: responsiveHeight(context, 0.03)),
                  _buildSearchBar(context),
                  SizedBox(height: responsiveHeight(context, 0.03)),
                  _buildCategorySelector(context),
                  SizedBox(height: responsiveHeight(context, 0.03)),
                ],
              ),
            ),

            // Scrollable List Area
            Expanded(
              child: filteredList.isEmpty 
              ? Center(child: Text("Tidak ditemukan", style: bodyText.copyWith(color: greyColor)))
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final entry = filteredList[index];
                    return _buildDictionaryItem(context, entry);
                  },
                ),
            ),
          ],
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
        controller: _searchController,
        onChanged: (value) => setState(() => searchQuery = value),
        decoration: InputDecoration(
          hintText: "Cari di $selectedCategory...",
          hintStyle: bodyText.copyWith(color: greyColor),
          suffixIcon: Icon(Icons.search, color: accentColor),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: responsiveFont(context, 14)),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    final categories = ["Huruf", "Kata", "Kalimat"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = selectedCategory == category;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = category),
            child: Container(
              margin: EdgeInsets.only(right: responsiveWidth(context, 0.03)),
              padding: EdgeInsets.symmetric(horizontal: responsiveWidth(context, 0.05), vertical: responsiveHeight(context, 0.012)),
              decoration: BoxDecoration(
                color: isSelected ? accentColor : secondaryBackground,
                borderRadius: BorderRadius.circular(20),
                border: isSelected ? null : Border.all(color: greyColor.withOpacity(0.2)),
                boxShadow: isSelected ? [BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4))] : [],
              ),
              child: Text(category, style: bodyText.copyWith(color: isSelected ? Colors.white : accentColor, fontWeight: isSelected ? bold : medium)),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- WIDGET ITEM (DENGAN KLIK) ---
  Widget _buildDictionaryItem(BuildContext context, Map<String, String> entry) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke Halaman Detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DictionaryDetailPage(
              sign: entry['sign']!,
              description: entry['description']!,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: responsiveHeight(context, 0.02)),
        padding: EdgeInsets.all(responsiveFont(context, 16)),
        decoration: BoxDecoration(
          color: secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: shadowColor.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: responsiveWidth(context, 0.15),
              height: responsiveWidth(context, 0.15),
              decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Center(
                child: Text(
                  entry['sign']!.length == 1 ? entry['sign']! : "👋", 
                  style: TextStyle(fontSize: responsiveFont(context, 24), fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(width: responsiveWidth(context, 0.04)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry['sign']!, style: heading2.copyWith(fontWeight: bold, fontSize: responsiveFont(context, 18))),
                  SizedBox(height: 4),
                  Text(entry['description']!, style: bodyText.copyWith(color: greyColor, fontSize: responsiveFont(context, 12)), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: greyColor.withOpacity(0.5)) // Indikator panah
          ],
        ),
      ),
    );
  }
}

// --- HALAMAN DETAIL BARU ---
class DictionaryDetailPage extends StatelessWidget {
  final String sign;
  final String description;

  const DictionaryDetailPage({
    super.key,
    required this.sign,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    // Mengambil tinggi layar penuh
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      // Menggunakan Stack agar tombol Back bisa melayang di atas gambar
      body: Stack(
        children: [
          Column(
            children: [
              // 1. BAGIAN ATAS: GAMBAR (50% Layar)
              Container(
                height: screenHeight * 0.5,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1), // Placeholder warna background gambar
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Center(
                  // Nanti ganti Icon ini dengan Image.asset atau Image.network
                  // Contoh: Image.asset('assets/images/$sign.png', fit: BoxFit.cover)
                  child: Icon(
                    Icons.sign_language, 
                    size: screenWidth * 0.4, 
                    color: accentColor.withOpacity(0.5),
                  ),
                ),
              ),

              // 2. BAGIAN BAWAH: DESKRIPSI (Sisa Layar)
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveWidth(context, 0.08),
                    vertical: responsiveHeight(context, 0.04),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Judul Utama (Huruf/Kata)
                      Text(
                        sign,
                        style: GoogleFonts.poppins(
                          fontSize: responsiveFont(context, 48),
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: responsiveHeight(context, 0.02)),
                      
                      // Garis dekorasi kecil
                      Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      SizedBox(height: responsiveHeight(context, 0.03)),

                      // Deskripsi
                      Text(
                        description,
                        style: bodyText.copyWith(
                          fontSize: responsiveFont(context, 16),
                          color: greyColor,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // TOMBOL BACK (Melayang di pojok kiri atas)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10, // Menyesuaikan dengan status bar
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    )
                  ],
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}