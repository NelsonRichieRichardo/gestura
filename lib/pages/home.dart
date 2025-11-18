import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gestura/core/themes/app_theme.dart';
import 'package:gestura/pages/login.dart'; // Digunakan untuk navigasi kembali (Logout)
import 'package:gestura/pages/dictionary.dart'; // Halaman baru
import 'package:gestura/pages/camera.dart'; // Halaman baru
import 'package:gestura/pages/exercise.dart'; // Halaman baru
import 'package:gestura/pages/settings.dart'; // Halaman baru

// Mengubah menjadi StatefulWidget untuk mengelola lifecycle dan menampilkan notifikasi
class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  
  // List widget untuk Bottom Navigation Bar
  late final List<Widget> _pages; // Menggunakan late untuk inisialisasi di initState

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeContent(
        username: widget.username,
        onNavigate: _onItemTapped,
        onNavigateCamera: _navigateToCamera,
      ), // Index 0: Halaman utama (Kartu)
      const DictionaryPage(), // Index 1: Dictionary
      const CameraPage(), // Index 2: Camera (FAB)
      const ExercisePage(), // Index 3: Exercise
      const SettingsPage(), // Index 4: Settings
    ];

    // Tampilkan notifikasi setelah frame pertama selesai di-render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeNotification(context, widget.username);
    });
  }

  void _showWelcomeNotification(BuildContext context, String username) {
    if (!mounted) return;
    
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
  
  void _onItemTapped(int index) {
    // Index 2 adalah FAB Camera, hanya boleh diakses dari FAB itu sendiri
    if (index == 2) return; 

    setState(() {
      _selectedIndex = index;
    });
  }
  
  // Fungsi untuk navigasi ke CameraPage (digunakan oleh FAB dan Main Card)
  void _navigateToCamera() {
    setState(() {
      _selectedIndex = 2; // Index Camera
    });
  }


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: backgroundColor,
      // Hapus AppBar
      appBar: null,
      
      // Menggunakan IndexedStack untuk menampilkan konten yang dipilih
      body: SafeArea( // Bungkus body dengan SafeArea
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      
      // 5. Custom Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavBar(context),

      // 6. FLOATING ACTION BUTTON (Camera)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCamera,
        backgroundColor: primaryColor,
        // Ukuran ikon kamera yang responsif
        child: Icon(Icons.camera_alt, color: blackColor, size: responsiveFont(context, 26)), 
        // Menggunakan CircleBorder untuk memastikan bentuk lingkaran
        shape: const CircleBorder(),
      ),
    );
  }

  // ======================================================
  //               BOTTOM NAVIGATION BAR
  // ======================================================
  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      // Tinggi disesuaikan
      height: responsiveHeight(context, 0.10), 
      decoration: BoxDecoration(
        color: blackColor, // Warna latar belakang hitam
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomAppBar(
        color: blackColor,
        elevation: 0,
        // Properti notchOnCircle: true memastikan ruang di tengah untuk FAB
        notchMargin: 6.0, 
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // Index 0: Home
            _buildNavItem(Icons.home, 0),
            // Index 1: Dictionary (Aa)
            _buildNavItem(Icons.font_download_outlined, 1),
            
            // Floating Action Button Placeholder (Camera)
            SizedBox(width: responsiveWidth(context, 0.10)), // Ruang kecil
            
            // Index 3: Exercise (Barbel)
            _buildNavItem(Icons.fitness_center_outlined, 3), 
            // Index 4: Settings (Gear)
            _buildNavItem(Icons.settings, 4), 
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final color = _selectedIndex == index ? primaryColor : greyColor;
    return IconButton(
      icon: Icon(icon, size: responsiveFont(context, 26)),
      color: color,
      onPressed: () => _onItemTapped(index),
    );
  }
}

// ======================================================
//                    HOME CONTENT (Sub Widget)
// ======================================================
// Sub-widget sekarang menerima callback navigasi
class HomeContent extends StatelessWidget {
  final String username;
  final Function(int) onNavigate;
  final VoidCallback onNavigateCamera;

  const HomeContent({
    super.key,
    required this.username,
    required this.onNavigate,
    required this.onNavigateCamera,
  });

  @override
  Widget build(BuildContext context) {
    // FIX: Gunakan username yang dilewatkan
    final usernameFirstWord = username.split(' ')[0];
    final sw = screenWidth(context);
    final sh = screenHeight(context);
    final double headlineSize = responsiveFont(context, 28);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: sh * 0.02),
          
          // 1. Header: Gestura (Kiri) dan Profile Icon (Kanan)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Gestura", 
                style: GoogleFonts.poppins(
                  fontSize: responsiveFont(context, 16),
                  fontWeight: bold,
                  color: accentColor,
                ),
              ),
              // Profile Icon
              InkWell(
                onTap: () {
                  // FIX: Langsung panggil callback ke SettingsPage (Index 4)
                  onNavigate(4);
                },
                child: Container(
                  padding: EdgeInsets.all(responsiveFont(context, 8)),
                  decoration: BoxDecoration(
                    color: secondaryBackground,
                    shape: BoxShape.circle,
                    border: Border.all(color: greyColor.withOpacity(0.3)),
                  ),
                  child: Icon(Icons.person, color: accentColor, size: responsiveFont(context, 22)),
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.02),

          // 2. Hello User!
          Text(
            "Hello, $usernameFirstWord!", 
            style: GoogleFonts.poppins(
              fontSize: headlineSize,
              fontWeight: bold,
              color: accentColor,
            ),
          ),
          SizedBox(height: sh * 0.03),

          // 3. Main Card: Ready to Try?
          _buildMainCard(
            context,
            title: "Ready to try?",
            subtitle: "Turn on your camera and start signing!",
            assetPath: "assets/images/hi.png",
            onTap: onNavigateCamera, // FIX: Langsung panggil callback Camera
          ),
          
          SizedBox(height: sh * 0.03),

          // 4. Grid Cards: Learn & Practice
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Card Kiri: Let's Learn (Dictionary Page)
              _buildGridCard(
                context,
                title: "Let's Learn",
                subtitle: "Sign Language\nWith us",
                assetPath: "assets/images/wink.png",
                bgColor: primaryColor,
                onTap: () => onNavigate(1), // FIX: Langsung panggil callback Dictionary
              ),

              // Card Kanan: Time to Practice! (Exercise Page)
              _buildGridCard(
                context,
                title: "Time to\nPractice!",
                subtitle: "",
                assetPath: "assets/images/question bubble.png",
                bgColor: blackColor,
                onTap: () => onNavigate(3), // FIX: Langsung panggil callback Exercise
              ),
            ],
          ),
          
          SizedBox(height: sh * 0.04), // Tambahan ruang di bawah

          // Tambahan ruang agar Bottom Nav tidak menutupi konten
          SizedBox(height: sh * 0.15), 
        ],
      ),
    );
  }

  // ======================================================
  //                    CARD COMPONENTS
  // ======================================================
  // ... (Card components tidak berubah dan tetap berfungsi karena menggunakan context)
  
  Widget _buildMainCard(BuildContext context, {required String title, required String subtitle, required String assetPath, required VoidCallback onTap}) {
    final sw = screenWidth(context);
    final sh = screenHeight(context);
    
    return InkWell(
      onTap: onTap,
      child: Container(
        width: sw,
        height: responsiveHeight(context, 0.22),
        padding: EdgeInsets.symmetric(
          horizontal: responsiveWidth(context, 0.05),
          vertical: responsiveHeight(context, 0.02),
        ),
        decoration: BoxDecoration(
          color: secondaryBackground, 
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: responsiveFont(context, 22),
                      fontWeight: bold,
                      color: accentColor,
                    ),
                  ),
                  SizedBox(height: responsiveHeight(context, 0.005)),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: responsiveFont(context, 12),
                      color: accentColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, {required String title, required String subtitle, required String assetPath, required Color bgColor, required VoidCallback onTap}) {
    final sw = screenWidth(context);
    
    // Lebar kartu: sedikit kurang dari setengah layar dikurangi padding
    final cardWidth = (sw * 0.94 - (sw * 0.06 * 2) - 10) / 2; // (Total width - padding horizontal - spasi tengah) / 2

    return InkWell(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: responsiveHeight(context, 0.28), // Lebih tinggi dari main card
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Gambar di Latar Depan/Tengah
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0), // Beri ruang untuk teks di atas
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.cover, 
                  alignment: Alignment.bottomRight,
                  // Jika gambar gelap, gunakan warna terang pada teks, dsb.
                ),
              ),
            ),

            // Teks Overlay
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: responsiveFont(context, 18),
                      fontWeight: bold,
                      color: bgColor == blackColor ? backgroundColor : accentColor,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: responsiveFont(context, 12),
                        fontWeight: medium,
                        color: bgColor == blackColor ? backgroundColor.withOpacity(0.8) : accentColor.withOpacity(0.8),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}