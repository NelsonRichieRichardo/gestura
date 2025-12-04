import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gestura/core/themes/app_theme.dart';
import 'dictionary_detail_page.dart'; 

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
  final ScrollController _scrollController = ScrollController(); 

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
    {"sign": "Makan", "description": "Kegiatan memasukkan makanan ke mulut"},
    {"sign": "Minum", "description": "Kegiatan memasukkan minuman ke mulut"},
    {"sign": "Keluarga", "description": "Sekumpulan orang yang terikat darah/perkawinan"},
    {"sign": "Ibu", "description": "Orang tua perempuan"},
    {"sign": "Ayah", "description": "Orang tua laki-laki"},
  ];

  // 3. Kumpulan Kalimat
  final List<Map<String, String>> dataKalimat = [
    {"sign": "Aku Cinta Kamu", "description": "Ungkapan kasih sayang (I Love You) 🤟"},
    {"sign": "Apa Kabar?", "description": "Bertanya tentang kondisi seseorang"},
    {"sign": "Sampai Jumpa", "description": "Salam perpisahan"},
  ];

  // Fungsi untuk mendapatkan list yang ditampilkan berdasarkan kategori & pencarian
  List<Map<String, String>> getFilteredData() {
    List<Map<String, String>> activeList;

    switch (selectedCategory) {
      case "Kata": activeList = dataKata; break;
      case "Kalimat": activeList = dataKalimat; break;
      case "Huruf":
      default: activeList = dataHuruf; break;
    }

    // Filter berdasarkan search query
    if (searchQuery.isNotEmpty) {
      return activeList.where((item) {
        final sign = item['sign']!.toLowerCase();
        final description = item['description']!.toLowerCase();
        // Menggunakan trim() untuk memastikan spasi ekstra tidak mengganggu
        final query = searchQuery.trim().toLowerCase(); 
        return sign.contains(query) || description.contains(query);
      }).toList();
    }

    return activeList;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = screenWidth(context);
    final filteredList = getFilteredData();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), 
      body: SafeArea(
        bottom: false,
        child: CustomScrollView( // Struktur utama untuk UI dinamis
          slivers: [
            // SLIVER 1: HEADER (Title, Search, Category Selector)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: responsiveHeight(context, 0.02)),
                    // Title
                    Text(
                      "Dictionary", 
                      style: GoogleFonts.poppins(
                        fontSize: responsiveFont(context, 32),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Learn new signs, words, and phrases.", 
                      style: GoogleFonts.poppins(
                        fontSize: responsiveFont(context, 14),
                        color: Colors.grey.shade500,
                      ),
                    ),
                    SizedBox(height: responsiveHeight(context, 0.03)),

                    // Search Bar (Pill Shaped)
                    _buildSearchBar(context),
                    SizedBox(height: responsiveHeight(context, 0.03)),

                    // Category Selector (Minimalist Chips)
                    _buildCategorySelector(context),
                    SizedBox(height: responsiveHeight(context, 0.03)),
                  ],
                ),
              ),
            ),
            
            // SLIVER 2: KONTEN DINAMIS (GRID atau LIST)
            if (filteredList.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Text("No items found.", style: GoogleFonts.poppins(color: Colors.grey)),
                  ),
                ),
              )
            else if (selectedCategory == "Huruf") 
              // Tampilan GRID untuk Huruf (A-Z)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // 4 kolom untuk huruf
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8, // Sedikit lebih tinggi dari kotak
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = filteredList[index];
                      return _buildLetterGridItem(context, entry['sign']!);
                    },
                    childCount: filteredList.length,
                  ),
                ),
              )
            else
              // Tampilan LIST untuk Kata dan Kalimat
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entry = filteredList[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
                      child: _buildDictionaryItem(context, entry['sign']!, entry['description']!),
                    );
                  },
                  childCount: filteredList.length,
                ),
              ),
              
            SliverToBoxAdapter(child: SizedBox(height: responsiveHeight(context, 0.05))), // Jarak bawah
          ],
        ),
      ),
    );
  }

  // Widget Search Bar (Pill Shaped)
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: "Search in $selectedCategory...",
          hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
          // FIX WARNA: Mengubah ikon pencarian menjadi hitam
          prefixIcon: Icon(Icons.search, color: Colors.black), 
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        ),
      ),
    );
  }

  // Widget Selector Kategori (Minimalist Chips)
  Widget _buildCategorySelector(BuildContext context) {
    final categories = ["Huruf", "Kata", "Kalimat"];

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = selectedCategory == category;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
                _searchController.clear();
                searchQuery = "";
                // Scroll to start on category change
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              });
            },
            child: AnimatedContainer( 
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade300),
              ),
              child: Text(
                category,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Widget Item Grid untuk kategori HURUF
  Widget _buildLetterGridItem(BuildContext context, String sign) {
    final assetPath = "assets/bisindo/${sign.toLowerCase()}.gif";
    
    return GestureDetector(
      onTap: () {
        // Navigasi ke Halaman Detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DictionaryDetailPage(
              sign: sign,
              description: "Isyarat tangan untuk huruf $sign",
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) {
                      return Center(
                        child: Text(
                          sign,
                          style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                sign,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Item List untuk kategori KATA/KALIMAT
  Widget _buildDictionaryItem(BuildContext context, String sign, String description) {
    return GestureDetector(
      onTap: () {
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
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Sign Icon/Image Placeholder
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Text(
                    "✋", // Placeholder untuk Kata/Kalimat
                    style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                ),
              )
            ),
            const SizedBox(width: 16),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sign,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Indikator panah kecil
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}