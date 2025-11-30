import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gestura/core/themes/app_theme.dart';
import 'exercise_play_page.dart'; 

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  // --- DATA STRUKTUR ---
  List<Map<String, dynamic>> units = [
    {
      "unitTitle": "Unit 1",
      "unitDesc": "Pengenalan Dasar",
      "color": Colors.teal,
      "isExpanded": true,
      "levels": [
        {"id": 1, "title": "Huruf Dasar", "icon": Icons.back_hand, "status": "completed", "stars": 3},
        {"id": 2, "title": "Kata Simpel", "icon": Icons.translate, "status": "completed", "stars": 2},
        {"id": 3, "title": "Kalimat", "icon": Icons.question_answer, "status": "current", "stars": 0},
        {"id": 4, "title": "Kuis Unit 1", "icon": Icons.quiz, "status": "locked", "stars": 0},
      ]
    },
    {
      "unitTitle": "Unit 2",
      "unitDesc": "Menyapa & Berkenalan",
      "color": primaryColor,
      "isExpanded": false,
      "levels": [
        {"id": 5, "title": "Sapaan", "icon": Icons.people, "status": "locked", "stars": 0},
        {"id": 6, "title": "Perkenalan", "icon": Icons.emoji_people, "status": "locked", "stars": 0},
      ]
    },
     {
      "unitTitle": "Unit 3",
      "unitDesc": "Percakapan Sehari-hari",
      "color": Colors.orange,
      "isExpanded": false,
      "levels": [
        {"id": 10, "title": "Makan", "icon": Icons.restaurant, "status": "locked", "stars": 0},
        {"id": 11, "title": "Transportasi", "icon": Icons.directions_bus, "status": "locked", "stars": 0},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopStats(context),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(bottom: responsiveHeight(context, 0.15)),
                itemCount: units.length,
                itemBuilder: (context, index) {
                  return _buildUnitSection(context, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStats(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(bottom: BorderSide(color: greyColor.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.flag_circle, color: accentColor, size: 32),
          Row(
            children: [
              _buildStatChip(Icons.local_fire_department, "2", Colors.orange),
              SizedBox(width: 12),
              _buildStatChip(Icons.diamond, "450", primaryColor),
              SizedBox(width: 12),
              _buildStatChip(Icons.favorite, "5", dangerColor),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, Color color) {
    return Row(children: [
      Icon(icon, color: color, size: 20),
      SizedBox(width: 4),
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold))
    ]);
  }

  Widget _buildUnitSection(BuildContext context, int index) {
    final unitData = units[index];
    List<Map<String, dynamic>> levels = unitData['levels'];
    Color unitColor = unitData['color'];
    bool isExpanded = unitData['isExpanded'];

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              units[index]['isExpanded'] = !units[index]['isExpanded'];
            });
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: unitColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: unitColor.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(unitData['unitTitle'], style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(unitData['unitDesc'], style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                  ],
                ),
                Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.white, size: 28),
              ],
            ),
          ),
        ),

        AnimatedCrossFade(
          firstChild: Container(),
          secondChild: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: levels.length,
            itemBuilder: (context, i) {
              double offsetX = 0;
              if (i % 4 == 1) offsetX = -40;
              if (i % 4 == 3) offsetX = 40;
              return _buildLevelNode(context, levels[i], unitColor, offsetX);
            },
          ),
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  Widget _buildLevelNode(BuildContext context, Map<String, dynamic> level, Color color, double offsetX) {
    String status = level['status'];
    bool isLocked = status == 'locked';
    bool isCompleted = status == 'completed';
    bool isCurrent = status == 'current';
    Color nodeColor = isLocked ? Colors.grey[300]! : (isCompleted ? Colors.amber : color);

    return Container(
      height: 100,
      alignment: Alignment.center,
      child: Transform.translate(
        offset: Offset(offsetX, 0),
        child: GestureDetector(
          // --- KUNCI UPDATE BINTANG ADA DI SINI ---
          onTap: () async {
            if (!isLocked) {
              // 1. Pindah halaman dan TUNGGU (await) hasilnya
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExercisePlayPage(
                    levelTitle: level['title'],
                    colorTheme: color,
                  ),
                ),
              );

              // 2. Jika ada hasil 'stars' yang dibawa pulang
              if (result != null && result is int) {
                setState(() {
                  level['status'] = 'completed'; // Ubah status jadi selesai
                  level['stars'] = result;       // Update jumlah bintang
                });
              }
            } else {
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Selesaikan level sebelumnya!")));
            }
          },
          child: Container(
            width: isCurrent ? 80 : 70,
            height: isCurrent ? 80 : 70,
            decoration: BoxDecoration(
              color: nodeColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isLocked ? Colors.grey[400]! : (isCompleted ? Colors.orange[800]! : color.withOpacity(0.6)),
                  offset: Offset(0, 6),
                  blurRadius: 0, 
                )
              ],
              border: isCurrent ? Border.all(color: Colors.white, width: 4) : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  isCompleted ? Icons.check : (isLocked ? Icons.lock : level['icon']),
                  color: isLocked ? Colors.grey : Colors.white,
                  size: 30,
                ),
                if (isCompleted)
                  Positioned(
                    bottom: 8,
                    child: Row(children: List.generate(level['stars'], (index) => Icon(Icons.star, color: Colors.yellow[100], size: 10))),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}