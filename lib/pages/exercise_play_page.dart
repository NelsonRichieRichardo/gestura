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

  // Variabel yang akan diisi saat initState()
  late List<Map<String, dynamic>> questions; 

  // --- DATABASE SOAL KOMPREHENSIF (BANK SOAL 10 UNIT) ---
  final Map<String, List<Map<String, dynamic>>> _questionBank = {
    // --- UNIT 1: THE BASICS ---
    "Core Alphabet": [
      {
        "question": "Which sign is for the letter 'A'?",
        "icon": Icons.back_hand, "icon_label": "A",
        "options": ["A", "S", "T", "O"],
        "correctIndex": 0,
      },
      {
        "question": "What letter does this sign represent?",
        "icon": Icons.back_hand, "icon_label": "B",
        "options": ["M", "B", "D", "K"],
        "correctIndex": 1,
      },
      {
        "question": "Which sign is correct for 'C'?",
        "icon": Icons.back_hand, "icon_label": "C",
        "options": ["Z", "X", "C", "Q"],
        "correctIndex": 2,
      },
    ],
    "Numbers 1-10": [
      {
        "question": "What number is shown in the sign?",
        "icon": Icons.looks_one, "icon_label": "1",
        "options": ["1", "5", "10", "2"],
        "correctIndex": 0,
      },
      {
        "question": "Which sign represents the number '7'?",
        "icon": Icons.looks_two, "icon_label": "7", // Menggunakan looks_two sebagai placeholder icon
        "options": ["9", "4", "7", "3"],
        "correctIndex": 2,
      },
    ],
    "Simple Words": [
      {
        "question": "What is the sign for 'Hello'?",
        "icon": Icons.waving_hand, "icon_label": "👋",
        "options": ["Hello", "Sleep", "Eat", "Go"],
        "correctIndex": 0,
      },
      {
        "question": "Which sign means 'Love'?",
        "icon": Icons.favorite, "icon_label": "❤️",
        "options": ["Hate", "Angry", "Love", "Fear"],
        "correctIndex": 2,
      },
    ],
    
    // --- UNIT 2: INTRODUCTIONS ---
    "Greetings": [
       {
        "question": "What is the sign for 'Good Morning'?",
        "icon": Icons.wb_sunny_rounded, "icon_label": "🌅",
        "options": ["Good Night", "Good Morning", "Welcome", "Goodbye"],
        "correctIndex": 1,
      },
    ],
    "Self Introduction": [
       {
        "question": "Which sign means 'My Name is'?",
        "icon": Icons.person, "icon_label": "👤",
        "options": ["Age", "Address", "My Name is", "Work"],
        "correctIndex": 2,
      },
    ],
    "Practice Sentences": [
       {
        "question": "What is the sign for 'How are you?'?",
        "icon": Icons.question_mark_rounded, "icon_label": "❓",
        "options": ["How are you?", "What is this?", "I feel good", "I'm sad"],
        "correctIndex": 0,
      },
    ],

    // --- UNIT 3: DAILY LIFE ---
    "Food & Drink": [
       {
        "question": "Which sign means 'Eat'?",
        "icon": Icons.restaurant, "icon_label": "🍕",
        "options": ["Drink", "Sleep", "Eat", "Drive"],
        "correctIndex": 2,
      },
    ],
    "Time & Schedule": [
       {
        "question": "What is the sign for 'Tomorrow'?",
        "icon": Icons.schedule, "icon_label": "⏳",
        "options": ["Yesterday", "Tomorrow", "Now", "Later"],
        "correctIndex": 1,
      },
    ],
    "Common Verbs": [
       {
        "question": "Which sign means 'Walk'?",
        "icon": Icons.directions_run, "icon_label": "🚶",
        "options": ["Run", "Walk", "Jump", "Stop"],
        "correctIndex": 1,
      },
    ],

    // --- UNIT 4: FAMILY & HOME ---
    "Family Members": [
       {
        "question": "Which sign means 'Mother'?",
        "icon": Icons.group, "icon_label": "👩",
        "options": ["Father", "Sister", "Mother", "Brother"],
        "correctIndex": 2,
      },
    ],

    // --- UNIT 5: TIME & DATE ---
    "Days of Week": [
       {
        "question": "What is the sign for 'Monday'?",
        "icon": Icons.calendar_today, "icon_label": "📅",
        "options": ["Sunday", "Tuesday", "Monday", "Friday"],
        "correctIndex": 2,
      },
    ],

    // --- UNIT 6: FEELINGS & HEALTH ---
    "Basic Emotions": [
       {
        "question": "Which sign means 'Happy'?",
        "icon": Icons.sentiment_satisfied, "icon_label": "😄",
        "options": ["Sad", "Happy", "Angry", "Tired"],
        "correctIndex": 1,
      },
    ],

    // --- UNIT 7: TRAVEL & TRANSPORT ---
    "Directions": [
       {
        "question": "What is the sign for 'Up'?",
        "icon": Icons.directions, "icon_label": "⬆️",
        "options": ["Down", "Left", "Up", "Right"],
        "correctIndex": 2,
      },
    ],

    // --- UNIT 9: HOBBIES & LEISURE ---
    "Sports": [
       {
        "question": "Which sign means 'Soccer'?",
        "icon": Icons.sports_soccer, "icon_label": "⚽",
        "options": ["Soccer", "Tennis", "Basketball", "Golf"],
        "correctIndex": 0,
      },
    ],


    // --- QUIZ AND REVIEW LEVELS (Generic/Fallback for the rest) ---
    "Unit Quiz": [
      {
        "question": "Review: What is the sign for 'C'?",
        "icon": Icons.quiz, "icon_label": "🏆",
        "options": ["A", "B", "C", "D"],
        "correctIndex": 2,
      },
    ],
    "Final Exam": [
      {
        "question": "Final Question: What is the sign for 'Love'?",
        "icon": Icons.flag, "icon_label": "🚩",
        "options": ["Hate", "Angry", "Love", "Fear"],
        "correctIndex": 2,
      },
    ],
    
    // Default Fallback
    "Default": [
       {
        "question": "What is the sign for 'Go'?",
        "icon": Icons.directions_run,
        "icon_label": "🏃",
        "options": ["Stop", "Go", "Wait", "Start"],
        "correctIndex": 1,
      },
    ]
  };

  @override
  void initState() {
    super.initState();
    // Inisialisasi daftar pertanyaan berdasarkan levelTitle
    questions = _questionBank[widget.levelTitle] ?? _questionBank["Default"]!;
  }


  double get progressValue => (currentQuestionIndex + 1) / questions.length;

  void _checkAnswer() {
    final currentQuestion = questions[currentQuestionIndex];
    bool isCorrect = selectedAnswerIndex == currentQuestion['correctIndex'];

    userAnswersLog.add({
      // Log semua data yang dibutuhkan, termasuk label icon
      "question": currentQuestion['question'],
      "icon": currentQuestion['icon'],
      "icon_label": currentQuestion['icon_label'], 
      "options": currentQuestion['options'],
      "correctIndex": currentQuestion['correctIndex'],
      "selectedAnswerIndex": selectedAnswerIndex,
      "isCorrect": isCorrect,
    });

    _showResultSheet(isCorrect);
  }

  // --- LOGIKA UTAMA PERPINDAHAN PAGE ---
  void _nextQuestion() async {
    // Safety check: Pastikan sheet tertutup
    if (Navigator.canPop(context)) {
        Navigator.pop(context); 
    }

    if (currentQuestionIndex < questions.length - 1) {
      // Pindah ke soal berikutnya
      if (mounted) {
        setState(() {
          currentQuestionIndex++;
          selectedAnswerIndex = -1;
        });
      }
    } else {
      // SOAL HABIS -> PINDAH KE HALAMAN RESULT
      final resultStars = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            userAnswersLog: userAnswersLog,
            totalQuestions: questions.length,
            colorTheme: widget.colorTheme,
            levelTitle: widget.levelTitle,
          ),
        ),
      );

      // Kirim data bintang ini KEMBALI ke ExercisePage (Peta)
      if (resultStars != null && mounted) {
        Navigator.pop(context, resultStars); 
      } else if (mounted) {
        Navigator.pop(context); 
      }
    }
  }

  // --- MODAL RESULT SHEET (PREMIUM STYLE) ---
  void _showResultSheet(bool correct) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(
            top: BorderSide(
              color: correct ? successColor : dangerColor, 
              width: 5 
            )
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              correct ? "Excellent!" : "Oops, Incorrect!",
              style: GoogleFonts.poppins(
                color: correct ? successColor : dangerColor, 
                fontWeight: FontWeight.w900, 
                fontSize: 32
              ),
            ),
            const SizedBox(height: 10),
            Text(
              correct 
                ? "Your answer is perfectly correct. Keep up the great work!" 
                : "The correct answer was: ${questions[currentQuestionIndex]['options'][questions[currentQuestionIndex]['correctIndex']]}",
              style: GoogleFonts.poppins(color: Colors.grey.shade700, fontSize: 16),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: correct ? successColor : dangerColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  currentQuestionIndex == questions.length - 1 ? "VIEW RESULTS" : "NEXT QUESTION", 
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- WIDGET PENGGANTI IKON UNTUK ALPHABET/NUMBER ---
  Widget _buildQuestionIcon(Map<String, dynamic> question) {
    // Cek apakah question memiliki label (untuk huruf/angka/emoji)
    final hasLabel = question.containsKey('icon_label') && question['icon_label'] != null && question['icon_label'].isNotEmpty;

    return Container(
      height: 160, width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: widget.colorTheme.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Center(
        child: hasLabel
          ? Text(
              question['icon_label'],
              style: GoogleFonts.poppins(
                fontSize: 80, 
                fontWeight: FontWeight.bold, 
                color: widget.colorTheme // Warna ikon disesuaikan dengan tema
              ),
            )
          : Icon(question['icon'], size: 90, color: widget.colorTheme),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeQuestion = questions[currentQuestionIndex];
    final sw = screenWidth(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.grey.shade600, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: EdgeInsets.only(right: sw * 0.1), 
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 12,
              backgroundColor: Colors.grey.shade300,
              color: widget.colorTheme,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Question ${currentQuestionIndex + 1} of ${questions.length}", 
                style: GoogleFonts.poppins(color: Colors.grey.shade600, fontWeight: FontWeight.w500)
              ),
              const SizedBox(height: 10),
              Text(
                activeQuestion['question'], 
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)
              ),
              const SizedBox(height: 30),
              
              // Sign Icon/Image Placeholder (Dynamic based on level)
              Center(
                child: _buildQuestionIcon(activeQuestion),
              ),
              
              const SizedBox(height: 40),
              
              // Answer Options Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, 
                    childAspectRatio: 1.5, 
                    crossAxisSpacing: 16, 
                    mainAxisSpacing: 16,
                  ),
                  itemCount: activeQuestion['options'].length,
                  itemBuilder: (context, index) {
                    final bool isSelected = selectedAnswerIndex == index;
                    final optionText = activeQuestion['options'][index];

                    return GestureDetector(
                      onTap: () => setState(() => selectedAnswerIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: isSelected ? widget.colorTheme.withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? widget.colorTheme : Colors.grey.shade300, 
                            width: isSelected ? 3 : 1
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                        ),
                        child: Center(
                          child: Text(
                            optionText, 
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: isSelected ? widget.colorTheme : Colors.black87, 
                              fontSize: 16,
                              fontWeight: FontWeight.w600
                            )
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Check Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: selectedAnswerIndex == -1 ? null : _checkAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.colorTheme,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    "CHECK ANSWER", 
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
  final String levelTitle;

  const ResultPage({
    super.key, 
    required this.userAnswersLog, 
    required this.totalQuestions, 
    required this.colorTheme,
    required this.levelTitle
  });

  @override
  Widget build(BuildContext context) {
    int correctCount = userAnswersLog.where((log) => log['isCorrect']).length;
    
    // Hitung Bintang
    int stars = 0;
    double score = correctCount / totalQuestions;
    if (score == 1.0) {
      stars = 3;
    } else if (score >= 0.75) stars = 3; 
    else if (score >= 0.5) stars = 2;
    else if (score > 0) stars = 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: Column(
          children: [
            // Top Section: Score & Stars
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              decoration: BoxDecoration(
                color: colorTheme.withOpacity(0.1),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Level Completed!", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
                  Text(levelTitle, style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade700)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) => Icon(Icons.star_rounded, size: 55, color: index < stars ? Colors.amber : Colors.grey.withOpacity(0.3))),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "$correctCount / $totalQuestions Correct", 
                    style: GoogleFonts.poppins(color: colorTheme, fontWeight: FontWeight.bold, fontSize: 22)
                  ),
                ],
              ),
            ),
            
            // Bottom Section: Summary List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                children: [
                  Align(alignment: Alignment.centerLeft, child: Text("Answer Summary", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black))),
                  const SizedBox(height: 16),
                  
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: userAnswersLog.length,
                    itemBuilder: (context, index) {
                      final log = userAnswersLog[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: log['isCorrect'] ? successColor.withOpacity(0.5) : dangerColor.withOpacity(0.5)),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
                        ),
                        child: Row(
                          children: [
                            Icon(log['isCorrect'] ? Icons.check_circle_rounded : Icons.cancel_rounded, color: log['isCorrect'] ? successColor : dangerColor),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(log['question'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black)),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Your Answer: ${log['options'][log['selectedAnswerIndex']]}", 
                                    style: GoogleFonts.poppins(color: log['isCorrect'] ? successColor : dangerColor, fontSize: 12)
                                  ),
                                  if (!log['isCorrect'])
                                    Text(
                                      "Correct: ${log['options'][log['correctIndex']]}", 
                                      style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  
                  // Finish Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, stars); 
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: colorTheme, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: Text("FINISH & RETURN", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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