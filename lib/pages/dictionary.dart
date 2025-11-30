import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gestura/core/themes/app_theme.dart';
import 'dictionary_detail_page.dart'; // Pastikan file ini ada di folder yang sama

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  // State untuk melacak kategori yang dipilih
  String selectedCategory = "Huruf";
  // State untuk pencarian
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // --- DATA SUMBER ---
  
  // 1. Generate Huruf A-Z secara otomatis
  final List<Map<String, String>> dataHuruf = List.generate(26, (index) {
    String letter = String.fromCharCode(65 + index); // 65 adalah kode ASCII 'A'
    return {
      "sign": letter,
      "description": "Isyarat tangan untuk huruf $letter"
    };
  });

  // 2. Kumpulan Kata
  final List<Map<String, String>> dataKata = [
    {"sign": "Halo", "description": "Sapaan umum untuk menyapa seseorang"},
    {"sign": "Teman", "description": "Seseorang yang dikenal dan dipercaya"},
    {"sign": "Saya", "description": "Menunjuk pada diri sendiri"},
  ];

  // 3. Kumpulan Kalimat
  final List<Map<String, String>> dataKalimat = [
    {"sign": "Aku Cinta Kamu", "description": "Ungkapan kasih sayang (I Love You) 🤟"},
  ];

  // Fungsi untuk mendapatkan list yang ditampilkan berdasarkan kategori & pencarian
  List<Map<String, String>> getFilteredData() {
    List<Map<String, String>> activeList;

    // Pilih list berdasarkan kategori
    switch (selectedCategory) {
      case "Kata":
        activeList = dataKata;
        break;
      case "Kalimat":
        activeList = dataKalimat;
        break;
      case "Huruf":
      default:
        activeList = dataHuruf;
        break;
    }

    // Filter berdasarkan search query jika ada
    if (searchQuery.isNotEmpty) {
      return activeList.where((item) {
        final sign = item['sign']!.toLowerCase();
        final description = item['description']!.toLowerCase();
        final query = searchQuery.toLowerCase();
        return sign.contains(query) || description.contains(query);
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
          children: [
            // Bagian Header dan Search (Tidak ikut scroll agar tetap di atas)
            Padding(
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

                  // Category Selector (Huruf, Kata, Kalimat)
                  _buildCategorySelector(context),
                  SizedBox(height: responsiveHeight(context, 0.03)),
                ],
              ),
            ),

            // Dictionary List (Expanded agar bisa scroll terpisah)
            Expanded(
              child: filteredList.isEmpty 
              ? Center(
                  child: Text("Tidak ditemukan", style: bodyText.copyWith(color: greyColor)),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final entry = filteredList[index];
                    return _buildDictionaryItem(context, entry['sign']!, entry['description']!);
                  },
                ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Search Bar yang Aktif
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
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
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

  // Widget Selector Kategori
  Widget _buildCategorySelector(BuildContext context) {
    final categories = ["Huruf", "Kata", "Kalimat"];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = selectedCategory == category;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: responsiveWidth(context, 0.03)),
              padding: EdgeInsets.symmetric(
                horizontal: responsiveWidth(context, 0.05),
                vertical: responsiveHeight(context, 0.012),
              ),
              decoration: BoxDecoration(
                color: isSelected ? accentColor : secondaryBackground,
                borderRadius: BorderRadius.circular(20),
                border: isSelected ? null : Border.all(color: greyColor.withOpacity(0.2)),
                boxShadow: isSelected 
                  ? [BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4))] 
                  : [],
              ),
              child: Text(
                category,
                style: bodyText.copyWith(
                  color: isSelected ? Colors.white : accentColor,
                  fontWeight: isSelected ? bold : medium,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- PERBAIKAN UTAMA ADA DI SINI ---
  Widget _buildDictionaryItem(BuildContext context, String sign, String description) {
    // 1. Kita bungkus Container dengan GestureDetector
    return GestureDetector(
      onTap: () {
        // 2. Kita tambahkan logika navigasi (pindah halaman)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DictionaryDetailPage(
              sign: sign,
              description: description,
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
              child: Center(
                child: Text(
                  sign.length == 1 ? sign : "👋", 
                  style: TextStyle(fontSize: responsiveFont(context, 24), fontWeight: FontWeight.bold),
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
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: bodyText.copyWith(color: greyColor, fontSize: responsiveFont(context, 12)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Indikator panah kecil agar user tahu bisa diklik
            Icon(Icons.arrow_forward_ios, size: 14, color: greyColor.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}