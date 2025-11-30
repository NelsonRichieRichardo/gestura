import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gestura/core/themes/app_theme.dart';

class ExercisePlayPage extends StatefulWidget {
  final String levelTitle;
  final Color colorTheme;

  const ExercisePlayPage({
    super.key,
    required this.levelTitle,
    required this.colorTheme,
  });

  @override
  State<ExercisePlayPage> createState() => _ExercisePlayPageState();
}

class _ExercisePlayPageState extends State<ExercisePlayPage> {
  int currentQuestionIndex = 0;
  int selectedAnswerIndex = -1;
  
  // Log jawaban user
  List<Map<String, dynamic>> userAnswersLog = [];

  // Database Soal (Dummy)
  final List<Map<String, dynamic>> questions = [
    {
      "question": "Apa arti isyarat tangan ini?",
      "icon": Icons.waving_hand,
      "options": ["Halo", "Makan", "Tidur", "Pergi"],
      "correctIndex": 0,
    },
    {
      "question": "Manakah isyarat untuk 'Cinta'?",
      "icon": Icons.favorite,
      "options": ["Benci", "Marah", "Cinta", "Takut"],
      "correctIndex": 2,
    },
    {
      "question": "Simbol ini biasanya berarti?",
      "icon": Icons.thumb_up,
      "options": ["Jelek", "Bagus", "Kiri", "Bawah"],
      "correctIndex": 1, 
    },
  ];

  double get progressValue => (currentQuestionIndex + 1) / questions.length;

  void _checkAnswer() {
    final currentQuestion = questions[currentQuestionIndex];
    bool isCorrect = selectedAnswerIndex == currentQuestion['correctIndex'];

    userAnswersLog.add({
      "question": currentQuestion['question'],
      "icon": currentQuestion['icon'],
      "options": currentQuestion['options'],
      "correctIndex": currentQuestion['correctIndex'],
      "selectedAnswerIndex": selectedAnswerIndex,
      "isCorrect": isCorrect,
    });

    _showResultSheet(isCorrect);
  }

  // --- LOGIKA UTAMA PERPINDAHAN PAGE ---
  void _nextQuestion() async {
    Navigator.pop(context); // Tutup Bottom Sheet dulu

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswerIndex = -1;
      });
    } else {
      // SOAL HABIS -> PINDAH KE HALAMAN RESULT
      // Kita pakai 'await' untuk menunggu hasil dari ResultPage
      final resultStars = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            userAnswersLog: userAnswersLog,
            totalQuestions: questions.length,
            colorTheme: widget.colorTheme,
          ),
        ),
      );

      // Jika user menekan tombol SELESAI dan membawa data bintang
      if (resultStars != null) {
        // Kirim data bintang ini KEMBALI ke ExercisePage (Peta)
        Navigator.pop(context, resultStars); 
      } else {
        // Jika user back biasa
        Navigator.pop(context); 
      }
    }
  }

  void _showResultSheet(bool correct) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            top: BorderSide(
              color: correct ? successColor : dangerColor, 
              width: 3
            )
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              correct ? "Hebat!" : "Yah, salah...",
              style: heading2.copyWith(color: correct ? successColor : dangerColor, fontWeight: bold),
            ),
            SizedBox(height: 8),
            Text(
              correct 
                ? "Jawaban kamu tepat sekali." 
                : "Jawaban yang benar adalah: ${questions[currentQuestionIndex]['options'][questions[currentQuestionIndex]['correctIndex']]}",
              style: bodyText.copyWith(color: greyColor),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: correct ? successColor : dangerColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  currentQuestionIndex == questions.length - 1 ? "LIHAT HASIL" : "LANJUTKAN", 
                  style: TextStyle(color: Colors.white, fontWeight: bold)
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeQuestion = questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: greyColor, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progressValue,
            minHeight: 12,
            backgroundColor: greyColor.withOpacity(0.2),
            color: widget.colorTheme,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text("Pilih jawaban yang benar", style: bodyText.copyWith(color: greyColor, fontWeight: medium)),
              SizedBox(height: 10),
              Text(activeQuestion['question'], style: heading2.copyWith(fontSize: 24, fontWeight: bold)),
              SizedBox(height: 30),
              Center(
                child: Container(
                  height: 140,
                  width: 140,
                  decoration: BoxDecoration(
                    color: widget.colorTheme.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(activeQuestion['icon'], size: 80, color: widget.colorTheme),
                ),
              ),
              SizedBox(height: 30),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 1.5, crossAxisSpacing: 16, mainAxisSpacing: 16,
                  ),
                  itemCount: activeQuestion['options'].length,
                  itemBuilder: (context, index) {
                    final bool isSelected = selectedAnswerIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => selectedAnswerIndex = index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? widget.colorTheme.withOpacity(0.1) : secondaryBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isSelected ? widget.colorTheme : greyColor.withOpacity(0.2), width: 2),
                        ),
                        child: Center(
                          child: Text(activeQuestion['options'][index], style: heading2.copyWith(color: isSelected ? widget.colorTheme : accentColor, fontSize: 16)),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: selectedAnswerIndex == -1 ? null : _checkAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.colorTheme,
                    disabledBackgroundColor: greyColor.withOpacity(0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text("PERIKSA", style: TextStyle(fontSize: 18, fontWeight: bold, color: Colors.white)),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// --- HALAMAN RESULT ---
class ResultPage extends StatelessWidget {
  final List<Map<String, dynamic>> userAnswersLog;
  final int totalQuestions;
  final Color colorTheme;

  const ResultPage({super.key, required this.userAnswersLog, required this.totalQuestions, required this.colorTheme});

  @override
  Widget build(BuildContext context) {
    int correctCount = userAnswersLog.where((log) => log['isCorrect']).length;
    
    // Hitung Bintang
    int stars = 0;
    double score = correctCount / totalQuestions;
    if (score == 1.0) stars = 3;
    else if (score >= 0.5) stars = 2;
    else if (score > 0) stars = 1;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Text("Latihan Selesai!", style: heading2.copyWith(fontSize: 28, fontWeight: bold)),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(color: secondaryBackground, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) => Icon(Icons.star_rounded, size: 48, color: index < stars ? Colors.amber : greyColor.withOpacity(0.3))),
                    ),
                    SizedBox(height: 16),
                    Text("$correctCount / $totalQuestions Benar", style: heading2.copyWith(color: colorTheme, fontWeight: bold, fontSize: 24)),
                    SizedBox(height: 8),
                    Text("Kamu mendapatkan $stars bintang!", style: bodyText.copyWith(color: greyColor)),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Align(alignment: Alignment.centerLeft, child: Text("Ringkasan Jawaban", style: heading2.copyWith(fontSize: 18, fontWeight: bold))),
              SizedBox(height: 16),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: userAnswersLog.length,
                itemBuilder: (context, index) {
                  final log = userAnswersLog[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: secondaryBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: log['isCorrect'] ? successColor.withOpacity(0.5) : dangerColor.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Icon(log['isCorrect'] ? Icons.check : Icons.close, color: log['isCorrect'] ? successColor : dangerColor),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(log['question'], style: bodyText.copyWith(fontWeight: bold)),
                              Text("Jawaban: ${log['options'][log['selectedAnswerIndex']]}", style: TextStyle(color: log['isCorrect'] ? successColor : dangerColor)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // PENTING: Kirim 'stars' kembali ke PlayPage
                    Navigator.pop(context, stars); 
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: colorTheme, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: Text("SELESAI", style: TextStyle(fontSize: 18, fontWeight: bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}