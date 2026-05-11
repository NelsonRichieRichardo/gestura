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
import 'package:supabase_flutter/supabase_flutter.dart';

// --- DATA MODEL UNTUK HISTORY (GLOBAL) ---
enum HistoryType { translation, learning, quiz }

class HistoryItem {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;
  final HistoryType type;
  final String? detailPayload; 

  HistoryItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
    required this.type,
    this.detailPayload,
  });
}

// Data Global History (akan diisi dari Supabase)
List<HistoryItem> globalHistory = [];

// --- WIDGET HELPER GLOBAL: History List Tile ---
// Digunakan di HomeContent dan HistoryPage
Widget buildHistoryTile({required HistoryItem item, required VoidCallback onTap}) {
    return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))]
            ),
            child: Row(
                children: [
                    Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: item.color.withOpacity(0.1), shape: BoxShape.circle),
                        child: Icon(item.icon, color: item.color, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text(item.title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
                                Text("${item.time} • ${item.subtitle}", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                            ],
                        ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300)
                ],
            ),
        ),
    );
}


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
            _fetchHistory();
        });
    }

    void _fetchHistory() async {
        try {
            final supabase = Supabase.instance.client;
            final session = supabase.auth.currentSession;
            if (session == null) return;
            
            final response = await supabase
                .from('history_items')
                .select()
                .eq('user_id', session.user.id)
                .order('created_at', ascending: false);
            
            List<HistoryItem> loaded = [];
            for (var item in response) {
                HistoryType hType = HistoryType.translation;
                if (item['item_type'] == 'learning') hType = HistoryType.learning;
                if (item['item_type'] == 'quiz') hType = HistoryType.quiz;
                
                loaded.add(HistoryItem(
                    title: item['title'],
                    subtitle: item['subtitle'],
                    time: item['time_label'],
                    icon: Icons.history, // placeholder
                    color: Color(int.parse(item['color_hex'])),
                    type: hType,
                    detailPayload: item['detail_payload']
                ));
            }
            if (mounted) {
                setState(() {
                    globalHistory = loaded;
                });
            }
        } catch (e) {
            print("Error fetching history: $e");
        }
    }
    
    void _fetchUsername() async {
        final session = Supabase.instance.client.auth.currentSession;
        if (session == null) return;
        
        try {
            final response = await Supabase.instance.client
                .from('users')
                .select('username')
                .eq('id', session.user.id)
                .maybeSingle();
            
            if (mounted) {
                String fetchedUsername = 'User';
                if (response != null && response['username'] != null) {
                    fetchedUsername = response['username'];
                } else if (session.user.userMetadata != null && session.user.userMetadata!['username'] != null) {
                    fetchedUsername = session.user.userMetadata!['username'];
                } else if (session.user.email != null) {
                    fetchedUsername = session.user.email!.split('@')[0];
                }

                setState(() {
                    _currentUsername = fetchedUsername;
                });
                
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
                content: Row(
                    children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text("Welcome back, $username!", style: GoogleFonts.poppins(color: Colors.white)),
                    ],
                ),
                backgroundColor: blackColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: EdgeInsets.all(20),
            ),
        );
    }

    void _handleLogout() async {
        LoadingOverlay.show(context);
        await Supabase.instance.client.auth.signOut(); 
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
            _fetchHistory();
        }
    }
    
    void _navigateToCamera() {
        setState(() {
            _selectedIndex = 2; 
        });
    }

    @override
    Widget build(BuildContext context) {
        final List<Widget> pages = [
            HomeContent(
                username: _currentUsername, 
                onNavigate: _onItemTapped,
                onNavigateCamera: _navigateToCamera,
                onLogout: _handleLogout,
                onNavigateProfile: _navigateToProfilePage, 
            ), 
            const DictionaryPage(),
            CameraPage(isActive: _selectedIndex == 2),
            const ExercisePage(),
            const SettingsPage(),
        ];

        return Scaffold( 
            backgroundColor: const Color(0xFFF8F9FD), 
            body: SafeArea( 
                bottom: false,
                child: IndexedStack(
                    index: _selectedIndex,
                    children: pages,
                ),
            ),
            bottomNavigationBar: _buildPremiumBottomNavBar(context),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Container(
                margin: const EdgeInsets.only(top: 10),
                height: 70, width: 70,
                child: FloatingActionButton(
                    onPressed: _navigateToCamera,
                    backgroundColor: primaryColor, 
                    elevation: 8,
                    shape: const CircleBorder(),
                    child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 32),
                ),
            ),
        );
    }

    Widget _buildPremiumBottomNavBar(BuildContext context) {
        return Container(
            height: 85,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -5)),
                ],
            ),
            child: BottomAppBar(
                color: Colors.transparent,
                elevation: 0,
                notchMargin: 12.0, 
                shape: const CircularNotchedRectangle(),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                        _buildNavItem(Icons.grid_view_rounded, 0),
                        _buildNavItem(Icons.book_rounded, 1),
                        const SizedBox(width: 40), 
                        _buildNavItem(Icons.bar_chart_rounded, 3), 
                        _buildNavItem(Icons.settings_rounded, 4), 
                    ],
                ),
            ),
        );
    }

    Widget _buildNavItem(IconData icon, int index) {
        final isSelected = _selectedIndex == index;
        return InkWell(
            onTap: () => _onItemTapped(index),
            borderRadius: BorderRadius.circular(16),
            child: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(
                    icon, 
                    size: 28, 
                    color: isSelected ? blackColor : Colors.grey.shade400
                ),
            ),
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

    // --- FUNGSI NAVIGASI KE HALAMAN SEE ALL ---
    void _navigateToHistoryPage(BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HistoryPage()),
      );
    }

    // --- FUNGSI MENAMPILKAN MODAL DETAIL ---
    void _showDetailModal(BuildContext context, HistoryItem item) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildDetailModalContent(context, item),
      );
    }

    // --- MODAL CONTENT BUILDER ---
    Widget _buildDetailModalContent(BuildContext context, HistoryItem item) {
        String mainText = "";
        String subText = "";
        String btnText = "";
        VoidCallback btnAction = () => Navigator.pop(context);

        // LOGIKA KONTEN MODAL BERDASARKAN TIPE
        if (item.type == HistoryType.translation) {
            mainText = "Translation Complete";
            subText = "You have done translated \"${item.detailPayload}\"";
            btnText = "Done";
        } else if (item.type == HistoryType.learning) {
            mainText = "Alphabet Learned";
            subText = "Good job! You learned \"${item.detailPayload}\"";
            btnText = "Continue Learning";
            btnAction = () {
                Navigator.pop(context);
                onNavigate(1); // Pindah ke Dictionary
            };
        } else if (item.type == HistoryType.quiz) {
            mainText = "Quiz Result";
            subText = "You scored ${item.detailPayload} in Daily Quiz";
            btnText = "Retake Quiz";
            btnAction = () {
                Navigator.pop(context);
                onNavigate(3); // Pindah ke Exercise/Quiz
            };
        }

        return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Container(
                        width: 50, height: 5,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(height: 30),
                    Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: item.color.withOpacity(0.1), shape: BoxShape.circle),
                        child: Icon(item.icon, color: item.color, size: 40),
                    ),
                    const SizedBox(height: 20),
                    Text(mainText, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 10),
                    Text(subText, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 30),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: btnAction,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: item.color,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0
                            ),
                            child: Text(btnText, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                    ),
                    const SizedBox(height: 10),
                ],
            ),
        );
    }
    
    @override
    Widget build(BuildContext context) {
        final sw = screenWidth(context);

        return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const SizedBox(height: 20),
                    
                    // --- HEADER ---
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text("Hello, Mate!", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade500)),
                                    Text(
                                        username.length > 15 ? "${username.substring(0, 15)}..." : username, 
                                        style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)
                                    ),
                                ],
                            ),
                            InkWell(
                                onTap: onNavigateProfile,
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                    height: 50, width: 50,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.grey.shade200, width: 2),
                                    ),
                                    child: const Icon(Icons.person, color: Colors.grey),
                                ),
                            ),
                        ],
                    ),
                    const SizedBox(height: 30),

                    // --- HERO CARD ---
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                            color: blackColor,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                                BoxShadow(color: blackColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                            ]
                        ),
                        child: Row(
                            children: [
                                Expanded(
                                    flex: 6,
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Text(
                                                "Start Learning\nSign Language",
                                                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                                "Use camera to translate gestures instantly.",
                                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400),
                                            ),
                                            const SizedBox(height: 20),
                                            InkWell(
                                                onTap: onNavigateCamera,
                                                child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                    decoration: BoxDecoration(
                                                        color: primaryColor,
                                                        borderRadius: BorderRadius.circular(12)
                                                    ),
                                                    child: Text("Try Now", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                                Expanded(
                                    flex: 4,
                                    child: Image.asset("assets/images/hi.png", fit: BoxFit.contain, errorBuilder: (c,e,s)=>SizedBox()), 
                                )
                            ],
                        ),
                    ),
                    
                    const SizedBox(height: 30),

                    // --- MAIN MENU GRID ---
                    Row(
                        children: [
                            Expanded(
                                child: _buildMenuCard(
                                    title: "Dictionary",
                                    icon: Icons.menu_book_rounded,
                                    color: Colors.blueAccent,
                                    onTap: () => onNavigate(1),
                                ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                                child: _buildMenuCard(
                                    title: "Practice",
                                    icon: Icons.gamepad_rounded,
                                    color: Colors.orangeAccent,
                                    onTap: () => onNavigate(3),
                                ),
                            ),
                        ],
                    ),

                    const SizedBox(height: 30),

                    // --- RECENT HISTORY ---
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Text("Recent History", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                            // TOMBOL SEE ALL YANG BISA DIKLIK
                            InkWell(
                                onTap: () => _navigateToHistoryPage(context),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text("See All", style: GoogleFonts.poppins(fontSize: 14, color: primaryColor, fontWeight: FontWeight.w600)),
                                ),
                            ),
                        ],
                    ),
                    const SizedBox(height: 16),

                    // LIST HISTORY (3 ITEM PERTAMA)
                    Column(
                        children: globalHistory.take(3).map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: buildHistoryTile(
                                item: item,
                                onTap: () => _showDetailModal(context, item),
                            ),
                          );
                        }).toList(),
                    ),
                    
                    const SizedBox(height: 100), 
                ],
            ),
        );
    }

    // HELPER: Menu Card
    Widget _buildMenuCard({required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
        return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: Icon(icon, color: color, size: 24),
                        ),
                        const SizedBox(height: 12),
                        Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                        Text("Start learning", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                    ],
                ),
            ),
        );
    }
}


// --- HALAMAN BARU: SEE ALL HISTORY (FUNGSIONAL) ---
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final List<String> _filters = ['All', 'Translation', 'Learning', 'Quiz'];
  String _selectedFilter = 'All';

  // LOGIKA FILTERING HISTORY
  List<HistoryItem> get _filteredHistory {
    if (_selectedFilter == 'All') {
      return globalHistory;
    }
    return globalHistory.where((item) {
      if (_selectedFilter == 'Translation') return item.type == HistoryType.translation;
      if (_selectedFilter == 'Learning') return item.type == HistoryType.learning;
      if (_selectedFilter == 'Quiz') return item.type == HistoryType.quiz;
      return false;
    }).toList();
  }

  // FUNGSI UNTUK MENAMPILKAN MODAL DETAIL (sama seperti di HomeContent)
  void _showDetailModal(BuildContext context, HistoryItem item) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildDetailModalContent(context, item),
      );
    }
    
    Widget _buildDetailModalContent(BuildContext context, HistoryItem item) {
        String mainText = "";
        String subText = "";
        String btnText = "";
        VoidCallback btnAction = () => Navigator.pop(context);

        // LOGIKA KONTEN MODAL BERDASARKAN TIPE
        if (item.type == HistoryType.translation) {
            mainText = "Translation Complete";
            subText = "You have done translated \"${item.detailPayload}\"";
            btnText = "Done";
        } else if (item.type == HistoryType.learning) {
            mainText = "Alphabet Learned";
            subText = "Good job! You learned \"${item.detailPayload}\"";
            btnText = "Continue Learning";
            btnAction = () {
                // Karena di halaman terpisah, kita pop, lalu kirim sinyal untuk ganti tab
                Navigator.pop(context); 
            };
        } else if (item.type == HistoryType.quiz) {
            mainText = "Quiz Result";
            subText = "You scored ${item.detailPayload} in Daily Quiz";
            btnText = "Retake Quiz";
            btnAction = () {
                Navigator.pop(context);
            };
        }

        return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Container(
                        width: 50, height: 5,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(height: 30),
                    Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: item.color.withOpacity(0.1), shape: BoxShape.circle),
                        child: Icon(item.icon, color: item.color, size: 40),
                    ),
                    const SizedBox(height: 20),
                    Text(mainText, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 10),
                    Text(subText, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 30),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: btnAction,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: item.color,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0
                            ),
                            child: Text(btnText, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                    ),
                    const SizedBox(height: 10),
                ],
            ),
        );
    }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Activity History", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Filter Chips (Sudah Fungsional)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: _filters.map((filter) {
                return _buildFilterChip(filter, filter == _selectedFilter);
              }).toList(),
            ),
          ),
          
          // List View yang sudah di filter
          Expanded(
            child: _filteredHistory.isEmpty 
            ? Center(child: Text("No history found for $_selectedFilter", style: TextStyle(color: Colors.grey)))
            : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _filteredHistory.length,
              itemBuilder: (context, index) {
                final item = _filteredHistory[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: buildHistoryTile(
                    item: item,
                    onTap: () => _showDetailModal(context, item),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? Colors.black : Colors.grey.shade200),
        ),
        child: Text(
          label, 
          style: GoogleFonts.poppins(
            color: isActive ? Colors.white : Colors.grey, 
            fontWeight: FontWeight.w500
          )
        ),
      ),
    );
  }
}