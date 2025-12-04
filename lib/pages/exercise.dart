import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gestura/core/themes/app_theme.dart';
import 'exercise_play_page.dart'; 

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> with SingleTickerProviderStateMixin {
  // --- DATA STRUKTUR (10 UNIT BARU) ---
  List<Map<String, dynamic>> units = [
    {
      "unitTitle": "Unit 1: The Basics",
      "unitDesc": "Core Alphabet & Numbers 1-10",
      "color": Colors.blue,
      "isExpanded": true,
      "levels": [
        {"id": 1, "title": "Core Alphabet", "icon": Icons.back_hand, "status": "completed", "stars": 3},
        {"id": 2, "title": "Numbers 1-10", "icon": Icons.translate, "status": "completed", "stars": 2},
        {"id": 3, "title": "Simple Words", "icon": Icons.question_answer, "status": "current", "stars": 0},
        {"id": 4, "title": "Unit Quiz", "icon": Icons.quiz, "status": "locked", "stars": 0},
      ]
    },
    {
      "unitTitle": "Unit 2: Introductions",
      "unitDesc": "Greetings and Basic Phrases",
      "color": Colors.green,
      "isExpanded": false,
      "levels": [
        {"id": 5, "title": "Greetings", "icon": Icons.people, "status": "locked", "stars": 0},
        {"id": 6, "title": "Self Introduction", "icon": Icons.emoji_people, "status": "locked", "stars": 0},
        {"id": 7, "title": "Practice Sentences", "icon": Icons.record_voice_over, "status": "locked", "stars": 0},
      ]
    },
    {
      "unitTitle": "Unit 3: Daily Life",
      "unitDesc": "Food, Drink, and Common Verbs",
      "color": Colors.orange,
      "isExpanded": false,
      "levels": [
        {"id": 8, "title": "Food & Drink", "icon": Icons.restaurant, "status": "locked", "stars": 0},
        {"id": 9, "title": "Time & Schedule", "icon": Icons.schedule, "status": "locked", "stars": 0},
        {"id": 10, "title": "Common Verbs", "icon": Icons.directions_run, "status": "locked", "stars": 0},
        {"id": 11, "title": "Unit Quiz", "icon": Icons.quiz, "status": "locked", "stars": 0},
      ]
    },
    {
      "unitTitle": "Unit 4: Family & Home",
      "unitDesc": "Relationships, Places, and Pronouns",
      "color": Colors.indigo,
      "isExpanded": false,
      "levels": [
        {"id": 12, "title": "Family Members", "icon": Icons.group, "status": "locked", "stars": 0},
        {"id": 13, "title": "Rooms & Objects", "icon": Icons.home, "status": "locked", "stars": 0},
        {"id": 14, "title": "Possessives", "icon": Icons.bookmark_added, "status": "locked", "stars": 0},
      ]
    },
    {
      "unitTitle": "Unit 5: Time & Date",
      "unitDesc": "Days, Months, and Seasons",
      "color": Colors.purple,
      "isExpanded": false,
      "levels": [
        {"id": 15, "title": "Days of Week", "icon": Icons.calendar_today, "status": "locked", "stars": 0},
        {"id": 16, "title": "Months & Year", "icon": Icons.calendar_month, "status": "locked", "stars": 0},
        {"id": 17, "title": "Seasons & Weather", "icon": Icons.cloud, "status": "locked", "stars": 0},
        {"id": 18, "title": "Unit Quiz", "icon": Icons.quiz, "status": "locked", "stars": 0},
      ]
    },
    {
      "unitTitle": "Unit 6: Feelings & Health",
      "unitDesc": "Emotions, Descriptions, and Illness",
      "color": Colors.pink,
      "isExpanded": false,
      "levels": [
        {"id": 19, "title": "Basic Emotions", "icon": Icons.sentiment_satisfied, "status": "locked", "stars": 0},
        {"id": 20, "title": "Describing People", "icon": Icons.face, "status": "locked", "stars": 0},
      ]
    },
    {
      "unitTitle": "Unit 7: Travel & Transport",
      "unitDesc": "Directions, Locations, and Vehicles",
      "color": Colors.brown,
      "isExpanded": false,
      "levels": [
        {"id": 21, "title": "Directions", "icon": Icons.directions, "status": "locked", "stars": 0},
        {"id": 22, "title": "Transportation Types", "icon": Icons.directions_bus, "status": "locked", "stars": 0},
        {"id": 23, "title": "Asking for Location", "icon": Icons.location_on, "status": "locked", "stars": 0},
      ]
    },
    {
      "unitTitle": "Unit 8: Education & Work",
      "unitDesc": "School Subjects and Occupations",
      "color": Colors.cyan,
      "isExpanded": false,
      "levels": [
        {"id": 24, "title": "School Subjects", "icon": Icons.book, "status": "locked", "stars": 0},
        {"id": 25, "title": "Professions", "icon": Icons.business_center, "status": "locked", "stars": 0},
        {"id": 26, "title": "Unit Quiz", "icon": Icons.quiz, "status": "locked", "stars": 0},
      ]
    },
    {
      "unitTitle": "Unit 9: Hobbies & Leisure",
      "unitDesc": "Sports, Music, and Free Time Activities",
      "color": Colors.lime[800]!,
      "isExpanded": false,
      "levels": [
        {"id": 27, "title": "Sports", "icon": Icons.sports_soccer, "status": "locked", "stars": 0},
        {"id": 28, "title": "Music & Arts", "icon": Icons.music_note, "status": "locked", "stars": 0},
        {"id": 29, "title": "Free Time Activities", "icon": Icons.videogame_asset, "status": "locked", "stars": 0},
      ]
    },
    {
      "unitTitle": "Unit 10: Abstract Concepts",
      "unitDesc": "Ideas, Opinions, and Complex Terms",
      "color": Colors.red,
      "isExpanded": false,
      "levels": [
        {"id": 30, "title": "Opinions", "icon": Icons.lightbulb, "status": "locked", "stars": 0},
        {"id": 31, "title": "Abstract Ideas", "icon": Icons.psychology, "status": "locked", "stars": 0},
        {"id": 32, "title": "Final Review", "icon": Icons.flag_rounded, "status": "locked", "stars": 0},
        {"id": 33, "title": "Final Exam", "icon": Icons.quiz, "status": "locked", "stars": 0},
      ]
    },
  ];
  
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
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
  void _handleLevelCompletion(int unitIndex, int levelIndex, int stars) {
    setState(() {
      // Update Level yang baru selesai
      units[unitIndex]['levels'][levelIndex]['status'] = 'completed';
      units[unitIndex]['levels'][levelIndex]['stars'] = stars;

      // Logika membuka level berikutnya
      if (levelIndex + 1 < units[unitIndex]['levels'].length) {
        units[unitIndex]['levels'][levelIndex + 1]['status'] = 'current';
      } else if (unitIndex + 1 < units.length) {
        // Jika unit selesai, buka level pertama unit baru
        units[unitIndex + 1]['levels'][0]['status'] = 'current';
      }
    });
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
              child: ListView.builder(
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
                _buildStatChip(Icons.local_fire_department_rounded, "2", Colors.deepOrange),
                _buildStatChip(Icons.diamond_rounded, "450", Colors.blueAccent),
                _buildStatChip(Icons.favorite_rounded, "5", dangerColor),
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