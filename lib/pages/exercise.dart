import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gestura/core/themes/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'exercise_play_page.dart'; 

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> with SingleTickerProviderStateMixin {
  // --- DATA STRUKTUR (10 UNIT BARU) ---
  List<Map<String, dynamic>> units = [];
  bool isLoading = true;
  
  // Stats
  int fireStreak = 0;
  int diamonds = 0;
  int hearts = 5;
  
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      final userId = session?.user.id;

      // Fetch units
      final unitsResponse = await supabase.from('exercise_units').select().order('id', ascending: true);
      // Fetch levels
      final levelsResponse = await supabase.from('exercise_levels').select().order('id', ascending: true);
      
      // Fetch user stats & progress
      List<dynamic> progressResponse = [];
      if (userId != null) {
          progressResponse = await supabase.from('user_level_progress').select().eq('user_id', userId);
          
          final userStats = await supabase.from('users').select('fire_streak, diamonds, hearts').eq('id', userId).maybeSingle();
          if (userStats != null) {
              fireStreak = userStats['fire_streak'] ?? 0;
              diamonds = userStats['diamonds'] ?? 0;
              hearts = userStats['hearts'] ?? 5;
          }
      }

      List<Map<String, dynamic>> loadedUnits = [];
      bool foundCurrent = false;
      
      for (int i = 0; i < unitsResponse.length; i++) {
        var unitData = unitsResponse[i];
        
        // Find levels for this unit
        List<Map<String, dynamic>> unitLevels = levelsResponse
            .where((level) => level['unit_id'] == unitData['id'])
            .map((level) {
                  // Find progress for this level
                  int progIndex = progressResponse.indexWhere((p) => p['level_id'] == level['id']);
                  var prog = progIndex != -1 ? progressResponse[progIndex] : null;
                  String status = prog != null ? prog['status'] : 'locked';
                  int stars = prog != null ? prog['stars'] : 0;

                  return {
                    "id": level['id'],
                    "title": level['title'],
                    "icon": Icons.star, 
                    "status": status, 
                    "stars": stars,
                  };
                })
            .toList();
            
        // Initial state logic if no progress exists at all
        if (!foundCurrent) {
           bool hasCompleted = unitLevels.any((l) => l['status'] == 'completed');
           if (!hasCompleted && unitLevels.isNotEmpty && unitLevels[0]['status'] == 'locked') {
               unitLevels[0]['status'] = 'current';
               foundCurrent = true;
           } else if (unitLevels.any((l) => l['status'] == 'current')) {
               foundCurrent = true;
           }
        }

        loadedUnits.add({
          "unitTitle": unitData['unit_title'],
          "unitDesc": unitData['unit_desc'],
          "color": Color(int.parse(unitData['color_hex'])),
          "isExpanded": i == 0, // only first is expanded
          "levels": unitLevels,
        });
      }

      if (mounted) {
        setState(() {
          units = loadedUnits;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching exercise data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  // --- HELPER: HITUNG PROGRESS UNIT ---
  double _calculateProgress(List<Map<String, dynamic>> levels) {
    int completed = levels.where((level) => level['status'] == 'completed').length;
    return completed / levels.length;
  }

  // --- HELPER: LOGIKA UPDATE BINTANG ---
  void _handleLevelCompletion(int unitIndex, int levelIndex, int stars) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final currentLevel = units[unitIndex]['levels'][levelIndex];

    try {
        // 1. Pastikan profil user ada di public.users
        final userProfile = await supabase.from('users').select().eq('id', userId).maybeSingle();
        if (userProfile == null) {
            await supabase.from('users').insert({
                'id': userId,
                'username': 'User', 
                'fire_streak': 0,
                'diamonds': 0,
                'hearts': 5
            });
        }

        // 2. Simpan level progress ke Supabase
        await supabase.from('user_level_progress').upsert({
            'user_id': userId,
            'level_id': currentLevel['id'],
            'status': 'completed',
            'stars': stars,
        });

        // 3. Update stats via RPC
        int earnedDiamonds = stars * 10;
        await supabase.rpc('increment_user_stats', params: {
            'u_id': userId,
            'd_amount': earnedDiamonds,
            's_amount': 1
        });

        // 4. Update UI Lokal (Optimistic UI)
        setState(() {
            currentLevel['status'] = 'completed';
            currentLevel['stars'] = stars;
            diamonds += earnedDiamonds;
            fireStreak += 1;

            if (levelIndex + 1 < units[unitIndex]['levels'].length) {
                units[unitIndex]['levels'][levelIndex + 1]['status'] = 'current';
            } else if (unitIndex + 1 < units.length) {
                units[unitIndex + 1]['levels'][0]['status'] = 'current';
            }
        });

        // 5. Tambah History Item
        String hexColor = units[unitIndex]['color'].value.toRadixString(16).padLeft(8, '0');
        await supabase.from('history_items').insert({
            'user_id': userId,
            'title': 'Selesai: ${currentLevel['title']}',
            'subtitle': 'Skor: $stars Bintang (+ $earnedDiamonds Diamond)',
            'time_label': 'Baru saja',
            'icon_name': 'emoji_events_rounded',
            'color_hex': '0x$hexColor',
            'item_type': 'quiz',
            'detail_payload': stars.toString()
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Progres berhasil disimpan! ✅"), backgroundColor: Colors.green)
          );
        }

    } catch (e) {
        print("Error saving progress: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal simpan progres: $e"), backgroundColor: Colors.red)
          );
        }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), 
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Stats (Floating Card Style)
            _buildHeader(context),
            
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : units.isEmpty
                      ? Center(child: Text("No units available", style: GoogleFonts.poppins(color: Colors.grey)))
                      : ListView.builder(
                          padding: EdgeInsets.only(bottom: responsiveHeight(context, 0.05)),
                          itemCount: units.length,
                          itemBuilder: (context, unitIndex) {
                            return _buildUnitSection(context, unitIndex);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET 1: HEADER & STATS (PREMIUM) ---
  Widget _buildHeader(BuildContext context) {
    final sw = screenWidth(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: responsiveHeight(context, 0.02)),
          Text(
            "Learning Path",
            style: GoogleFonts.poppins(
              fontSize: responsiveFont(context, 32),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            "Complete the units to earn new titles!",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade500),
          ),
          SizedBox(height: responsiveHeight(context, 0.03)),
          
          // Floating Stats Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatChip(Icons.local_fire_department_rounded, fireStreak.toString(), Colors.deepOrange),
                _buildStatChip(Icons.diamond_rounded, diamonds.toString(), Colors.blueAccent),
                _buildStatChip(Icons.favorite_rounded, hearts.toString(), dangerColor),
              ],
            ),
          ),
          SizedBox(height: responsiveHeight(context, 0.03)),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, Color color) {
    return Row(children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(width: 6),
      Text(
        value, 
        style: GoogleFonts.poppins(
          color: color, 
          fontWeight: FontWeight.bold, 
          fontSize: 16
        )
      )
    ]);
  }

  // --- WIDGET 2: UNIT SECTION (PROGRESS CARD + LESSON LIST) ---
  Widget _buildUnitSection(BuildContext context, int unitIndex) {
    final unitData = units[unitIndex];
    List<Map<String, dynamic>> levels = unitData['levels'];
    Color unitColor = unitData['color'];
    bool isExpanded = unitData['isExpanded'];
    double progress = _calculateProgress(levels);
    
    final sw = screenWidth(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 2A. Unit Header (Progress Card Style)
        GestureDetector(
          onTap: () {
            setState(() {
              units[unitIndex]['isExpanded'] = !units[unitIndex]['isExpanded'];
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200),
              // FIX OVERFLOW: Menggunakan Box Shadow berbasis warna unit
              boxShadow: [BoxShadow(color: unitColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // FIX OVERFLOW: Menggunakan Expanded agar Column Title/Desc tidak melebihi batas
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(unitData['unitTitle'], style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(unitData['unitDesc'], style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 14)),
                      const SizedBox(height: 15),
                      
                      // Progress Bar
                      Container(
                        width: sw * 0.4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey.shade200,
                            color: unitColor,
                            minHeight: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Progress Percentage & Arrow
                Column(
                  children: [
                    Text(
                      "${(progress * 100).toStringAsFixed(0)}%",
                      style: GoogleFonts.poppins(color: unitColor, fontWeight: FontWeight.w800, fontSize: 22),
                    ),
                    Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey, size: 28),
                  ],
                ),
              ],
            ),
          ),
        ),

        // 2B. Lesson List (Clean Indented List)
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(left: 32.0, right: 32.0, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: levels.asMap().entries.map((entry) {
                int levelIndex = entry.key;
                Map<String, dynamic> level = entry.value;
                return _buildLessonTile(
                  context, 
                  unitIndex, 
                  levelIndex, 
                  level, 
                  unitColor
                );
              }).toList(),
            ),
          ),
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 400),
        ),
      ],
    );
  }

  // --- WIDGET 3: LESSON TILE (CLEAN LIST ITEM) ---
  Widget _buildLessonTile(
    BuildContext context, 
    int unitIndex, 
    int levelIndex, 
    Map<String, dynamic> level, 
    Color unitColor
  ) {
    String status = level['status'];
    bool isLocked = status == 'locked';
    bool isCompleted = status == 'completed';
    bool isCurrent = status == 'current';
    
    Color tileColor = isLocked ? Colors.grey.shade200 : Colors.white;
    Color iconColor = isLocked ? Colors.grey.shade400 : (isCompleted ? Colors.white : unitColor);

    return InkWell(
      onTap: () async {
        if (!isLocked) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExercisePlayPage(
                levelTitle: level['title'],
                colorTheme: unitColor,
              ),
            ),
          );

          // SAFETY CHECK: Cek mount status setelah async push
          if (result != null && result is int && mounted) {
            _handleLevelCompletion(unitIndex, levelIndex, result);
          }
        } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Selesaikan level sebelumnya!")));
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(16),
          border: isCurrent ? Border.all(color: unitColor, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isCurrent ? 0.1 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Row(
          children: [
            // Icon / Status Circle
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCompleted ? unitColor : (isLocked ? Colors.grey.shade300 : unitColor.withOpacity(0.1)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check_rounded : level['icon'],
                color: isCompleted ? Colors.white : iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Title & Status Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level['title'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isLocked ? Colors.grey : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isLocked ? "Locked" : (isCurrent ? "Current Lesson" : "Completed"),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isLocked ? Colors.grey : (isCompleted ? Colors.green.shade700 : unitColor),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Stars / Progress
            if (isCompleted)
              Row(
                children: List.generate(level['stars'], (index) => Icon(Icons.star_rounded, color: Colors.amber, size: 18)),
              ),
            if (!isCompleted && !isLocked)
              Icon(Icons.arrow_forward_ios_rounded, color: unitColor, size: 18),
          ],
        ),
      ),
    );
  }
}