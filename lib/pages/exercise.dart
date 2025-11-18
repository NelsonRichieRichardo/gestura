import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gestura/core/themes/app_theme.dart';

class ExercisePage extends StatelessWidget {
  const ExercisePage({super.key});

  // Contoh data latihan
  final List<Map<String, dynamic>> exercises = const [
    {"title": "Exercise 1", "subtitle": "Learn the alphabet A-L", "completed": true, "icon": Icons.list_alt},
    {"title": "Exercise 2", "subtitle": "Learn the alphabet M-Z", "completed": false, "icon": Icons.lock_outline},
    {"title": "Exercise 3", "subtitle": "Learn the numbers 1-50", "completed": false, "icon": Icons.lock_outline},
    {"title": "Exercise 4", "subtitle": "Learn the numbers 51-100", "completed": false, "icon": Icons.lock_outline},
    {"title": "Exercise 5", "subtitle": "Learn basic greetings", "completed": false, "icon": Icons.lock_outline},
    {"title": "Unit 6", "subtitle": "Learn simple words", "completed": false, "icon": Icons.lock_outline},
    {"title": "Unit 7", "subtitle": "Learn simple words part 2", "completed": false, "icon": Icons.lock_outline},
    {"title": "Unit 8", "subtitle": "More advanced words", "completed": false, "icon": Icons.lock_outline},
  ];

  @override
  Widget build(BuildContext context) {
    final sw = screenWidth(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: responsiveHeight(context, 0.02)),
              
              // Header dengan Bintang dan Hati (Poin dan Nyawa)
              _buildHeader(context),
              SizedBox(height: responsiveHeight(context, 0.03)),

              // Exercise List
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(), 
                shrinkWrap: true,
                itemCount: exercises.length,
                separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, color: secondaryBackground),
                itemBuilder: (context, index) {
                  final item = exercises[index];
                  return _buildExerciseItem(context, item);
                },
              ),
              SizedBox(height: responsiveHeight(context, 0.15)), // Ruang untuk FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title
        Text(
          "Exercises", 
          style: GoogleFonts.poppins(
            fontSize: responsiveFont(context, 28),
            fontWeight: bold,
            color: accentColor,
          ),
        ),
        
        // Poin dan Nyawa
        Row(
          children: [
            // Poin Bintang
            Icon(Icons.star, color: primaryColor, size: responsiveFont(context, 20)),
            const SizedBox(width: 4),
            Text("12", style: bodyText.copyWith(fontWeight: bold)),

            const SizedBox(width: 15),

            // Nyawa Hati
            Icon(Icons.favorite, color: dangerColor, size: responsiveFont(context, 20)),
            const SizedBox(width: 4),
            Text("∞", style: bodyText.copyWith(fontWeight: bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildExerciseItem(BuildContext context, Map<String, dynamic> item) {
    final bool isCompleted = item['completed'];
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        item['title'],
        style: heading2.copyWith(fontSize: responsiveFont(context, 18)),
      ),
      subtitle: Text(
        item['subtitle'],
        style: bodyText.copyWith(color: greyColor),
      ),
      trailing: Container(
        width: responsiveWidth(context, 0.12),
        height: responsiveWidth(context, 0.12),
        decoration: BoxDecoration(
          color: isCompleted ? successColor : secondaryBackground,
          shape: BoxShape.circle,
          border: Border.all(
            color: isCompleted ? successColor : greyColor.withOpacity(0.5), 
            width: 2
          ),
        ),
        child: Center(
          child: Icon(
            isCompleted ? Icons.check : item['icon'],
            color: isCompleted ? backgroundColor : greyColor.withOpacity(0.5),
            size: responsiveFont(context, 24),
          ),
        ),
      ),
      onTap: isCompleted ? null : () {
        // Aksi untuk memulai latihan
      },
    );
  }
}