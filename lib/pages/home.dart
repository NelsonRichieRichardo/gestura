import 'package:flutter/material.dart';
import 'package:gestura/components/loading_overlay.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gestura/core/themes/app_theme.dart';
import 'package:gestura/pages/login.dart'; 
import 'package:gestura/pages/dictionary.dart'; 
import 'package:gestura/pages/camera.dart'; 
import 'package:gestura/pages/exercise.dart'; 
import 'package:gestura/pages/settings.dart'; 
import 'package:gestura/pages/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
    final String username;

    const HomePage({super.key, required this.username});

    @override
    State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
    int _selectedIndex = 0;
    late String _currentUsername;
    bool _welcomeNotificationShown = false;
    
    @override
    void initState() {
        super.initState();
        _currentUsername = widget.username; 
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_currentUsername != "Mate" && _currentUsername != "User") {
                _showWelcomeNotification(context, _currentUsername);
                _welcomeNotificationShown = true; 
            }
            _fetchUsername(); 
        });
    }
    
    void _fetchUsername() async {
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) return;
        
        try {
            DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
            
            if (doc.exists && mounted) {
                String fetchedUsername = (doc.data() as Map<String, dynamic>)['username'] ?? 'User';
                
                if (fetchedUsername != _currentUsername) {
                    setState(() {
                        _currentUsername = fetchedUsername;
                    });
                }
                
                if (!_welcomeNotificationShown) {
                    _showWelcomeNotification(context, _currentUsername);
                    _welcomeNotificationShown = true;
                }
            }
        } catch (e) {
            print("Error fetching username: $e");
        }
    }

    void _showWelcomeNotification(BuildContext context, String username) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).clearSnackBars();

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

    void _handleLogout() async {
        LoadingOverlay.show(context);
        await FirebaseAuth.instance.signOut(); 
        await Future.delayed(const Duration(milliseconds: 500)); 

        if (mounted) LoadingOverlay.hide(context);

        if (mounted) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false,
            );
        }
    }
    
    void _navigateToProfilePage() async {
        final didUpdate = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        
        if (didUpdate == true && mounted) {
            _fetchUsername(); 
            _onItemTapped(0);
        }
    }
    
    void _onItemTapped(int index) {
        if (index == 2) return; 

        setState(() {
            _selectedIndex = index;
        });
        
        if (index == 0) {
            _fetchUsername();
        }
    }
    
    void _navigateToCamera() {
        setState(() {
            _selectedIndex = 2; 
        });
    }

    @override
    Widget build(BuildContext context) {
        final List<Widget> _pages = [
            HomeContent(
                username: _currentUsername, 
                onNavigate: _onItemTapped,
                onNavigateCamera: _navigateToCamera,
                onLogout: _handleLogout,
                onNavigateProfile: _navigateToProfilePage, 
            ), 
            const DictionaryPage(),
            const CameraPage(),
            const ExercisePage(),
            const SettingsPage(),
        ];

        return Scaffold( 
            backgroundColor: backgroundColor,
            appBar: null,
            body: SafeArea( 
                child: IndexedStack(
                    index: _selectedIndex,
                    children: _pages,
                ),
            ),
            bottomNavigationBar: _buildBottomNavBar(context),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: FloatingActionButton(
                onPressed: _navigateToCamera,
                backgroundColor: primaryColor,
                // Icon Floating Action Button juga dibesarkan sedikit
                child: Icon(Icons.camera_alt, color: blackColor, size: responsiveFont(context, 32)), 
                shape: const CircleBorder(),
                elevation: 4,
            ),
        );
    }

    Widget _buildBottomNavBar(BuildContext context) {
        return Container(
            height: responsiveHeight(context, 0.10), 
            decoration: BoxDecoration(
                color: blackColor, 
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
                notchMargin: 8.0, 
                shape: const CircularNotchedRectangle(),
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                            _buildNavItem(Icons.home_rounded, 0),
                            _buildNavItem(Icons.menu_book_rounded, 1),
                            SizedBox(width: responsiveWidth(context, 0.10)), 
                            _buildNavItem(Icons.fitness_center_rounded, 3), 
                            _buildNavItem(Icons.settings_rounded, 4), 
                        ],
                    ),
                ),
            ),
        );
    }

    Widget _buildNavItem(IconData icon, int index) {
        final isSelected = _selectedIndex == index;
        final color = isSelected ? primaryColor : greyColor;
        
        // UPDATE: Icon dibesarkan jadi 30 (sebelumnya 26)
        return IconButton(
            icon: Icon(icon, size: responsiveFont(context, 30)),
            color: color,
            onPressed: () => _onItemTapped(index),
            splashColor: primaryColor.withOpacity(0.2),
            highlightColor: Colors.transparent,
        );
    }
}

class HomeContent extends StatelessWidget {
    final String username;
    final Function(int) onNavigate;
    final VoidCallback onNavigateCamera;
    final VoidCallback onLogout; 
    final VoidCallback onNavigateProfile; 

    const HomeContent({
        super.key,
        required this.username,
        required this.onNavigate,
        required this.onNavigateCamera,
        required this.onLogout, 
        required this.onNavigateProfile,
    });

    @override
    Widget build(BuildContext context) {
        final usernameFirstWord = username.split(' ')[0];
        final sw = screenWidth(context);
        final sh = screenHeight(context);

        return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    SizedBox(height: sh * 0.02),
                    
                    // --- HEADER (Nama App & Profil) ---
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Text(
                                "Gestura", 
                                style: GoogleFonts.poppins(
                                    fontSize: responsiveFont(context, 16),
                                    fontWeight: bold,
                                    color: accentColor.withOpacity(0.5),
                                ),
                            ),
                            PopupMenuButton<String>(
                                child: Container(
                                    padding: EdgeInsets.all(responsiveFont(context, 8)),
                                    decoration: BoxDecoration(
                                        color: secondaryBackground,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: greyColor.withOpacity(0.3)),
                                    ),
                                    child: Icon(Icons.person, color: accentColor, size: responsiveFont(context, 22)),
                                ),
                                offset: Offset(0, responsiveHeight(context, 0.05)), 
                                color: secondaryBackground, 
                                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                    PopupMenuItem<String> (
                                        value: 'profile',
                                        child: Row(
                                            children: [
                                                Icon(Icons.account_circle, color: accentColor, size: responsiveFont(context, 18)),
                                                SizedBox(width: 8),
                                                Text('Profile', style: smallText.copyWith(color: accentColor)),
                                            ],
                                        ),
                                    ),
                                    const PopupMenuDivider(),
                                    PopupMenuItem<String> (
                                        value: 'logout',
                                        child: Row(
                                            children: [
                                                Icon(Icons.logout, color: dangerColor, size: responsiveFont(context, 18)),
                                                SizedBox(width: 8),
                                                Text('Logout', style: smallText.copyWith(color: dangerColor)),
                                            ],
                                        ),
                                    ),
                                ],
                                onSelected: (String result) {
                                    if (result == 'profile') {
                                        onNavigateProfile();
                                    } else if (result == 'logout') {
                                        onLogout(); 
                                    }
                                },
                            ),
                        ],
                    ),
                    SizedBox(height: sh * 0.02),

                    Text(
                        "Hello, $usernameFirstWord!", 
                        style: GoogleFonts.poppins(
                            fontSize: responsiveFont(context, 28),
                            fontWeight: bold,
                            color: accentColor,
                        ),
                    ),
                    SizedBox(height: sh * 0.03),

                    // --- MAIN CARD (Updated Design) ---
                    _buildMainCard(
                        context,
                        title: "Ready to try?",
                        subtitle: "Turn on camera & start signing!",
                        assetPath: "assets/images/hi.png",
                        onTap: onNavigateCamera, 
                    ),
                    
                    SizedBox(height: sh * 0.03),

                    // --- GRID CARDS (Updated Design) ---
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            _buildGridCard(
                                context,
                                title: "Let's Learn",
                                subtitle: "Basic Signs",
                                assetPath: "assets/images/wink.png",
                                bgColor: primaryColor,
                                onTap: () => onNavigate(1), // Dictionary
                            ),

                            _buildGridCard(
                                context,
                                title: "Practice",
                                subtitle: "Daily Quiz",
                                assetPath: "assets/images/question bubble.png",
                                bgColor: blackColor,
                                onTap: () => onNavigate(3), // Exercise
                            ),
                        ],
                    ),
                    
                    SizedBox(height: sh * 0.04), 

                    // --- NEW FEATURE: GAMIFICATION STATS (Ala Duolingo) ---
                    _buildGamificationStats(context),

                    SizedBox(height: sh * 0.15), 
                ],
            ),
        );
    }
    
    // UPDATE: Main Card menggunakan Stack agar gambar lebih bebas posisinya
    Widget _buildMainCard(BuildContext context, {required String title, required String subtitle, required String assetPath, required VoidCallback onTap}) {
        final sw = screenWidth(context);
        
        return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
                width: sw,
                height: responsiveHeight(context, 0.20), // Tinggi sedikit dikurangi biar compact
                decoration: BoxDecoration(
                    color: secondaryBackground, 
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                        BoxShadow(color: shadowColor.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5)),
                    ],
                ),
                child: Stack(
                    children: [
                        // Teks di Kiri
                        Padding(
                            padding: const EdgeInsets.all(24.0),
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
                                    SizedBox(height: 4),
                                    SizedBox(
                                        width: sw * 0.5,
                                        child: Text(
                                            subtitle,
                                            style: GoogleFonts.poppins(
                                                fontSize: responsiveFont(context, 12),
                                                color: accentColor.withOpacity(0.6),
                                            ),
                                        ),
                                    ),
                                    SizedBox(height: 12),
                                    Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                            color: primaryColor.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                            "Start Now ->",
                                            style: TextStyle(fontSize: 10, fontWeight: bold, color: Colors.orange[900]),
                                        ),
                                    )
                                ],
                            ),
                        ),

                        // Gambar di Kanan (Positioned agar tidak terpotong)
                        Positioned(
                            right: -10,
                            bottom: -10,
                            child: Image.asset(
                                assetPath,
                                height: responsiveHeight(context, 0.18), // Ukuran gambar proporsional
                                fit: BoxFit.contain,
                            ),
                        ),
                    ],
                ),
            ),
        );
    }

    // UPDATE: Grid Card diperbaiki agar gambar tidak gepeng
    Widget _buildGridCard(BuildContext context, {required String title, required String subtitle, required String assetPath, required Color bgColor, required VoidCallback onTap}) {
        final sw = screenWidth(context);
        final cardWidth = (sw * 0.94 - (sw * 0.06 * 2) - 10) / 2; 

        return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
                width: cardWidth,
                height: responsiveHeight(context, 0.26), 
                decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                         BoxShadow(color: bgColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                    ]
                ),
                child: Stack(
                    children: [
                        // Teks di Atas
                        Padding(
                            padding: const EdgeInsets.all(20.0),
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
                                    Text(
                                        subtitle,
                                        style: GoogleFonts.poppins(
                                            fontSize: responsiveFont(context, 12),
                                            fontWeight: medium,
                                            color: bgColor == blackColor ? backgroundColor.withOpacity(0.7) : accentColor.withOpacity(0.7),
                                        ),
                                    ),
                                ],
                            ),
                        ),

                        // Gambar di Bawah Kanan
                        Positioned(
                            right: -15,
                            bottom: -15,
                            child: Image.asset(
                                assetPath,
                                width: cardWidth * 0.8, // Lebar gambar 80% dari kartu
                                fit: BoxFit.contain,
                            ),
                        ),
                    ],
                ),
            ),
        );
    }

    // BARU: Widget Gamifikasi ala Duolingo
    Widget _buildGamificationStats(BuildContext context) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                    "Your Progress",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: bold, color: accentColor),
                ),
                SizedBox(height: 12),
                
                // Kartu Daily Streak
                Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: greyColor.withOpacity(0.1)),
                        boxShadow: [BoxShadow(color: shadowColor.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Column(
                        children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                    Row(
                                        children: [
                                            Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 24),
                                            SizedBox(width: 8),
                                            Text("2 Day Streak", style: TextStyle(fontWeight: bold, fontSize: 16)),
                                        ],
                                    ),
                                    Text("Goal: 7 days", style: TextStyle(color: greyColor, fontSize: 12)),
                                ],
                            ),
                            SizedBox(height: 16),
                            // Baris Hari
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: ["M", "T", "W", "T", "F", "S", "S"].asMap().entries.map((entry) {
                                    int idx = entry.key;
                                    String day = entry.value;
                                    bool isActive = idx < 2; // Contoh: Senin & Selasa aktif
                                    bool isToday = idx == 1; // Contoh: Selasa adalah hari ini

                                    return Column(
                                        children: [
                                            Text(day, style: TextStyle(fontSize: 12, color: isActive ? accentColor : greyColor)),
                                            SizedBox(height: 6),
                                            Container(
                                                width: 30, height: 30,
                                                decoration: BoxDecoration(
                                                    color: isActive ? (isToday ? primaryColor : primaryColor.withOpacity(0.3)) : secondaryBackground,
                                                    shape: BoxShape.circle,
                                                    border: isToday ? Border.all(color: Colors.orange, width: 2) : null,
                                                ),
                                                child: isActive 
                                                    ? Icon(Icons.check, size: 16, color: isToday ? blackColor : accentColor) 
                                                    : null,
                                            )
                                        ],
                                    );
                                }).toList(),
                            )
                        ],
                    ),
                ),
                
                SizedBox(height: 12),
                
                // Kartu XP / Target Harian
                Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: blackColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: blackColor.withOpacity(0.2), blurRadius: 10, offset: Offset(0,4))],
                    ),
                    child: Row(
                        children: [
                            Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                                child: Icon(Icons.show_chart_rounded, color: primaryColor),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Text("Daily Goal", style: TextStyle(color: Colors.white, fontWeight: bold)),
                                        SizedBox(height: 4),
                                        ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                                value: 0.7, // 70%
                                                backgroundColor: Colors.white.withOpacity(0.2),
                                                color: primaryColor,
                                                minHeight: 6,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                            SizedBox(width: 16),
                            Text("35/50 XP", style: TextStyle(color: primaryColor, fontWeight: bold)),
                        ],
                    ),
                )
            ],
        );
    }
}