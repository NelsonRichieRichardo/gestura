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
        
        // PENTING: Notifikasi dipicu HANYA setelah nama asli diambil.
        WidgetsBinding.instance.addPostFrameCallback((_) {
            _fetchUsername(); 
        });
    }
    
    // ======================================================
    // LOGIKA USERNAME FETCH DAN NOTIFIKASI
    // ======================================================

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
                
                // Notifikasi hanya muncul SATU KALI setelah nama ASLI didapatkan.
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

    // ======================================================
    // LOGIKA NAVIGASI DAN LOGOUT
    // ======================================================

    void _handleLogout() async {
        LoadingOverlay.show(context);

        await FirebaseAuth.instance.signOut(); 
        await Future.delayed(const Duration(milliseconds: 500)); 

        if (mounted) {
            LoadingOverlay.hide(context);
        }

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
            _selectedIndex = 2; // Index Camera
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
            
            // 5. Custom Bottom Navigation Bar
            bottomNavigationBar: _buildBottomNavBar(context),

            // 6. FLOATING ACTION BUTTON (Camera)
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: FloatingActionButton(
                onPressed: _navigateToCamera,
                backgroundColor: primaryColor,
                child: Icon(Icons.camera_alt, color: blackColor, size: responsiveFont(context, 26)), 
                shape: const CircleBorder(),
            ),
        );
    }

    // ... (Fungsi _buildBottomNavBar, _buildNavItem, HomeContent, dan Card components lainnya) ...
    
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
                notchMargin: 6.0, 
                shape: const CircularNotchedRectangle(),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                        _buildNavItem(Icons.home, 0),
                        _buildNavItem(Icons.font_download_outlined, 1),
                        SizedBox(width: responsiveWidth(context, 0.10)), 
                        _buildNavItem(Icons.fitness_center_outlined, 3), 
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
        final double headlineSize = responsiveFont(context, 28);

        return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    SizedBox(height: sh * 0.02),
                    
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
                                                Icon(Icons.account_circle, color: accentColor, size: responsiveFont(context, 16)),
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
                                                Icon(Icons.logout, color: dangerColor, size: responsiveFont(context, 16)),
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
                            fontSize: headlineSize,
                            fontWeight: bold,
                            color: accentColor,
                        ),
                    ),
                    SizedBox(height: sh * 0.03),

                    _buildMainCard(
                        context,
                        title: "Ready to try?",
                        subtitle: "Turn on your camera and start signing!",
                        assetPath: "assets/images/hi.png",
                        onTap: onNavigateCamera, 
                    ),
                    
                    SizedBox(height: sh * 0.03),

                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            _buildGridCard(
                                context,
                                title: "Let's Learn",
                                subtitle: "Sign Language\nWith us",
                                assetPath: "assets/images/wink.png",
                                bgColor: primaryColor,
                                onTap: () => onNavigate(1), 
                            ),

                            _buildGridCard(
                                context,
                                title: "Time to\nPractice!",
                                subtitle: "",
                                assetPath: "assets/images/question bubble.png",
                                bgColor: blackColor,
                                onTap: () => onNavigate(3), 
                            ),
                        ],
                    ),
                    
                    SizedBox(height: sh * 0.04), 
                    SizedBox(height: sh * 0.15), 
                ],
            ),
        );
    }
    
    // ... (Card components) ...
    
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
        final cardWidth = (sw * 0.94 - (sw * 0.06 * 2) - 10) / 2; 

        return InkWell(
            onTap: onTap,
            child: Container(
                width: cardWidth,
                height: responsiveHeight(context, 0.28), 
                decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                    children: [
                        Positioned.fill(
                            child: Padding(
                                padding: const EdgeInsets.only(top: 10.0), 
                                child: Image.asset(
                                    assetPath,
                                    fit: BoxFit.cover, 
                                    alignment: Alignment.bottomRight,
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