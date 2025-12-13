// camera.dart (FIXED VERSION)
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, WriteBuffer;
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:hand_landmarker/hand_landmarker.dart';
import 'dart:typed_data';

// --- IMPORT SESUAIKAN DENGAN PROJECT ANDA ---
import 'package:gestura/core/themes/app_theme.dart';
import '../main.dart';
// ---------------------------------------------

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  // --- TFLITE_FLUTTER & HAND LANDMARKER STATE ---
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isModelLoaded = false;

  HandLandmarkerPlugin? _plugin;

  final int SEQUENCE_LENGTH = 30;
  final int KEYPOINT_VECTOR_SIZE = 63;

  List<List<double>> _sequenceBuffer = [];

  // ✅ PERBAIKAN: Turunkan voting window untuk responsif lebih baik
  final List<String> _recentDetections = [];
  final int _VOTING_WINDOW = 2; // Turun dari 3 ke 2
  // ----------------------------------------------------------------------

  // --- KAMERA & LANDMARKER DATA ---
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  int selectedCameraIndex = 0;
  bool _isInitialized = false;
  bool _hasInitializationError = false;
  bool _isDetecting = false;

  // --- LANDMARK DATA UNTUK PAINTER ---
  List<Hand> _currentHands = [];
  Size _previewSize = Size.zero;
  CameraLensDirection _lensDirection = CameraLensDirection.front;
  int _sensorOrientation = 0;

  // --- LOGIC DETEKSI & TRANSLATE ---
  String _outputLabel = "Tunggu Deteksi...";
  String _confidence = "";

  bool _showGifView = false;
  String _translatedText = "";

  // --- INPUT TEXT ---
  final TextEditingController _textController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  bool _isUserTyping = false;

  @override
  void initState() {
    super.initState();

    _loadTfliteModel();

    if (isCameraAvailable && cameras.isNotEmpty) {
      final initialIndex = cameras.indexWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
      );
      selectedCameraIndex = initialIndex != -1 ? initialIndex : 0;
      _initialize();
    }

    _inputFocusNode.addListener(() {
      setState(() {
        _isUserTyping = _inputFocusNode.hasFocus;
        if (_isUserTyping) {
          _controller?.stopImageStream();
          _currentHands.clear();
          // ✅ PERBAIKAN: JANGAN clear sequence buffer, biarkan tetap ada
          // _sequenceBuffer.clear(); // DIHAPUS
        } else if (_isInitialized && _isModelLoaded && !_showGifView) {
          _startImageStream();
        }
      });
    });
  }

  // --- 1. MEMUAT MODEL (TFLITE) ---
  Future<void> _loadTfliteModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        "assets/models/sign_language_model.tflite",
      );

      final labelData = await rootBundle.loadString("assets/models/labels.txt");
      _labels = labelData
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      if (_labels.length != 28) {
        debugPrint(
          "WARNING: Labels length is ${_labels.length}. Model expects 28.",
        );
      }

      if (mounted) {
        setState(() {
          _isModelLoaded = true;
          if (_isInitialized && _plugin != null) {
            _startImageStream();
          }
        });
      }
    } catch (e) {
      print("Error loading model or labels: $e");
    }
  }

  // --- INISIALISASI CAMERA & PLUGIN ---
  Future<void> _initialize() async {
    final camera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    // INISIALISASI PLUGIN
    _plugin = HandLandmarkerPlugin.create(
      numHands: 1,
      minHandDetectionConfidence: 0.5,
      delegate: HandLandmarkerDelegate.GPU,
    );

    _initializeControllerFuture = _controller!
        .initialize()
        .then((_) async {
          if (_controller!.value.isInitialized) {
            _previewSize = _controller!.value.previewSize ?? Size.zero;
            _lensDirection = _controller!.description.lensDirection;
            _sensorOrientation = _controller!.description.sensorOrientation;

            await _controller!.startImageStream(_processCameraImage);

            if (mounted) {
              setState(() => _isInitialized = true);
            }
          }
        })
        .catchError((error) {
          print("Initialization Error: $error");
          if (mounted) {
            setState(() {
              _hasInitializationError = true;
              _isInitialized = false;
            });
          }
        });
  }

  @override
  void dispose() {
    _controller?.stopImageStream();
    _controller?.dispose();
    _interpreter?.close();
    _plugin?.dispose();
    _textController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  // --- 2. LOGIC PEMROSESAN FRAME ---
  Future<void> _processCameraImage(CameraImage image) async {
    if (_isDetecting || !_isInitialized || _plugin == null) return;
    _isDetecting = true;

    try {
      final hands = _plugin!.detect(
        image,
        _controller!.description.sensorOrientation,
      );

      if (mounted) {
        setState(() => _currentHands = hands);
      }

      // --- EKSTRAKSI KEYPOINT & INFERENSI TFLITE ---
      if (hands.isNotEmpty && _interpreter != null) {
        final keypoints = _extractKeypoints(hands);
        _sequenceBuffer.add(keypoints);

        if (_sequenceBuffer.length > SEQUENCE_LENGTH) {
          _sequenceBuffer = _sequenceBuffer.sublist(
            _sequenceBuffer.length - SEQUENCE_LENGTH,
          );
        }

        if (_sequenceBuffer.length == SEQUENCE_LENGTH) {
          _runTfliteInference();
        }
      } else {
        // ✅ PERBAIKAN: Jangan clear buffer jika tangan hilang sebentar
        // _sequenceBuffer.clear(); // DIHAPUS
      }
    } catch (e) {
      debugPrint('Error detecting landmarks or running TFLite: $e');
    } finally {
      _isDetecting = false;
    }
  }

  // --- 3. FUNGSI INFERENSI TFLITE ---
  void _runTfliteInference() {
    final List<List<double>> inputSequence = _sequenceBuffer.map((frame) {
      return frame.map((e) => e.toDouble()).toList();
    }).toList();

    final inputTensor = [inputSequence]; // shape [1,30,63]
    final output = [List.filled(_labels.length, 0.0)];

    try {
      _interpreter!.run(inputTensor, output);
    } catch (e) {
      print("Error TFLite RUN: $e");
      return;
    }

    final modelResult = output[0] as List<double>;
    double maxConfidence = 0.0;
    int maxIndex = -1;

    for (int i = 0; i < modelResult.length; i++) {
      if (modelResult[i] > maxConfidence) {
        maxConfidence = modelResult[i];
        maxIndex = i;
      }
    }

    // ✅ PERBAIKAN: Turunkan threshold dari 0.70 ke 0.50
    const THRESHOLD = 0.50;

    if (mounted) {
      setState(() {
        if (maxConfidence > THRESHOLD &&
            maxIndex != -1 &&
            maxIndex < _labels.length) {
          String detectedChar = _labels[maxIndex];
          String confStr = (maxConfidence * 100).toStringAsFixed(0) + "%";

          // ✅ DEBUGGING: Print hasil deteksi
          print("🔍 Detected: $detectedChar | Confidence: $confStr");

          // Simple voting untuk mengurangi jitter
          _recentDetections.add(detectedChar);
          if (_recentDetections.length > _VOTING_WINDOW) {
            _recentDetections.removeAt(0);
          }

          final counts = <String, int>{};
          for (var s in _recentDetections) {
            counts[s] = (counts[s] ?? 0) + 1;
          }

          // ✅ PERBAIKAN: Accept jika muncul minimal 1x (dari 2x)
          String? voted;
          counts.forEach((k, v) {
            if (v >= 1) voted = k; // Turun dari 2 ke 1
          });

          if (voted != null) {
            _outputLabel = voted!;
            _confidence = confStr;

            String currentText = _textController.text;
            String lastChar = currentText.isNotEmpty
                ? currentText.substring(currentText.length - 1)
                : "";

            if (voted != lastChar && voted != "kosong") {
              _textController.text = currentText + voted!;
              _textController.selection = TextSelection.fromPosition(
                TextPosition(offset: _textController.text.length),
              );
              _sequenceBuffer.clear();
              _recentDetections.clear();
            }
          } else {
            _outputLabel = "Menunggu stabilitas...";
            _confidence = confStr;
          }
        } else {
          _outputLabel = "Tunggu Deteksi...";
          _confidence = "";
          if (_recentDetections.isNotEmpty) _recentDetections.clear();
        }
      });
    }
  }

  // --- 4. EKSTRAKSI KEYPOINT (FIXED VERSION) ✅ ---
  List<double> _extractKeypoints(List<Hand> hands) {
    if (hands.isNotEmpty) {
      final hand = hands.first;
      List<double> keypoints = [];

      for (final landmark in hand.landmarks) {
        double x = landmark.x;
        double y = landmark.y;
        double z = landmark.z;

        // ✅ CRITICAL FIX: SELALU mirror X (konsisten dengan training)
        // Notebook menggunakan cv2.flip(frame, 1) untuk SEMUA data
        x = 1.0 - x;

        // ✅ PERBAIKAN: JANGAN clamp, biarkan nilai natural
        // Mediapipe sudah normalisasi otomatis ke [0,1]
        // Clamp bisa hilangkan informasi penting

        // Safety check untuk NaN/Inf saja
        if (x.isNaN || x.isInfinite) x = 0.0;
        if (y.isNaN || y.isInfinite) y = 0.0;
        if (z.isNaN || z.isInfinite) z = 0.0;

        keypoints.add(x);
        keypoints.add(y);
        keypoints.add(z);
      }

      if (keypoints.length >= KEYPOINT_VECTOR_SIZE) {
        return keypoints.sublist(0, KEYPOINT_VECTOR_SIZE);
      } else {
        keypoints.addAll(
          List.filled(KEYPOINT_VECTOR_SIZE - keypoints.length, 0.0),
        );
        return keypoints;
      }
    } else {
      return List.filled(KEYPOINT_VECTOR_SIZE, 0.0);
    }
  }

  // --- 5. STREAM CONTROL ---
  void _startImageStream() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (!_controller!.value.isStreamingImages) {
      _controller!.startImageStream(_processCameraImage);
    }
  }

  void _translateTextToSign() {
    String text = _textController.text.trim().toLowerCase();
    if (text.isEmpty) return;

    _inputFocusNode.unfocus();
    _controller?.stopImageStream();

    setState(() {
      _translatedText = text;
      _showGifView = true;
      _outputLabel = "Mode Terjemahan";
      _confidence = "";
    });
  }

  void _closeTranslateView() {
    setState(() {
      _showGifView = false;
      _textController.clear();
      _translatedText = "";
      _sequenceBuffer.clear();
      _currentHands.clear();
      _outputLabel = "Tunggu Deteksi...";
    });
    if (_isInitialized && _isModelLoaded) {
      _startImageStream();
    }
  }

  // --- 6. WIDGET BUILDER GIF VIEW ---
  Widget _buildGifResultView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Terjemahan: ${_translatedText.toUpperCase()}",
            style: bodyText.copyWith(fontWeight: bold, color: accentColor),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _translatedText.length,
              itemBuilder: (context, index) {
                String char = _translatedText[index];

                if (RegExp(r'[a-z]').hasMatch(char)) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Column(
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: greyColor.withOpacity(0.2),
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: secondaryBackground,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              "assets/bisindo/$char.gif",
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        color: greyColor,
                                        size: 30,
                                      ),
                                      Text(
                                        char.toUpperCase(),
                                        style: heading1.copyWith(
                                          color: greyColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          char.toUpperCase(),
                          style: smallText.copyWith(fontWeight: bold),
                        ),
                      ],
                    ),
                  );
                } else if (char == ' ') {
                  return const SizedBox(width: 40);
                }
                return const SizedBox();
              },
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Geser untuk melihat huruf selanjutnya 👉",
            style: smallText.copyWith(fontSize: 10, color: greyColor),
          ),
        ],
      ),
    );
  }

  // --- 7. WIDGET BUILDER CAMERA VIEW ---
  Widget _buildCameraView() {
    if (!isCameraAvailable) {
      return Center(
        child: Text(
          "Kamera tidak tersedia di Emulator\n(Gunakan HP Fisik)",
          textAlign: TextAlign.center,
          style: bodyText.copyWith(color: greyColor),
        ),
      );
    }
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            _isInitialized &&
            _controller!.value.isInitialized) {
          final controller = _controller!;
          final size = controller.value.previewSize!;
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: size.height,
                  height: size.width,
                  child: Stack(
                    children: [
                      CameraPreview(controller),
                      if (_currentHands.isNotEmpty && _previewSize != Size.zero)
                        CustomPaint(
                          size: Size.infinite,
                          painter: LandmarkPainter(
                            hands: _currentHands,
                            previewSize: _previewSize,
                            lensDirection: _lensDirection,
                            sensorOrientation: _sensorOrientation,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else if (_hasInitializationError) {
          return Center(
            child: Text(
              "Gagal memuat kamera. Pastikan izin sudah diberikan.",
              style: bodyText,
            ),
          );
        }
        return Center(child: CircularProgressIndicator(color: primaryColor));
      },
    );
  }

  // --- 8. BUILD METHOD UTAMA ---
  @override
  Widget build(BuildContext context) {
    final sw = screenWidth(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: responsiveHeight(context, 0.02)),
              Text(
                "Gestura",
                style: smallText.copyWith(
                  color: accentColor.withOpacity(0.6),
                  fontWeight: medium,
                ),
              ),
              SizedBox(height: responsiveHeight(context, 0.03)),

              // --- CONTAINER UTAMA (KAMERA / GIF) ---
              Expanded(
                flex: 3,
                child: Container(
                  width: sw,
                  decoration: cardDecoration.copyWith(
                    color: secondaryBackground,
                    boxShadow: cardDecoration.boxShadow,
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _showGifView
                            ? _buildGifResultView()
                            : _buildCameraView(),
                      ),

                      // Tombol Flip Camera
                      if (!_showGifView &&
                          isCameraAvailable &&
                          _isInitialized &&
                          cameras.length > 1)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: InkWell(
                            onTap: () async {
                              if (_controller != null) {
                                await _controller!.stopImageStream();
                                await _controller!.dispose();
                              }
                              setState(() {
                                selectedCameraIndex =
                                    (selectedCameraIndex + 1) % cameras.length;
                                _isInitialized = false;
                                _currentHands.clear();
                                _sequenceBuffer.clear();
                                _recentDetections.clear();
                              });
                              _initialize();
                            },
                            child: CircleAvatar(
                              backgroundColor: blackColor.withOpacity(0.5),
                              child: Icon(
                                Icons.flip_camera_ios_rounded,
                                color: backgroundColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ),

                      // Tombol Close (Mode Translate)
                      if (_showGifView)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: InkWell(
                            onTap: _closeTranslateView,
                            child: CircleAvatar(
                              backgroundColor: dangerColor.withOpacity(0.9),
                              child: Icon(
                                Icons.close,
                                color: backgroundColor,
                                size: 24,
                              ),
                            ),
                          ),
                        ),

                      // Label Deteksi di Bawah
                      if (!_showGifView &&
                          !_isUserTyping &&
                          _outputLabel.isNotEmpty)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              _confidence.isNotEmpty
                                  ? "Terdeteksi: $_outputLabel ($_confidence)"
                                  : "Status: $_outputLabel",
                              style: bodyText.copyWith(
                                color: backgroundColor,
                                fontWeight: bold,
                                fontSize: responsiveFont(context, 14),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: responsiveHeight(context, 0.02)),

              // --- CONTAINER INPUT ---
              Expanded(
                flex: 1,
                child: Container(
                  width: sw,
                  padding: EdgeInsets.all(responsiveFont(context, 15)),
                  decoration: cardDecoration.copyWith(
                    boxShadow: cardDecoration.boxShadow,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "TERJEMAHKAN:",
                            style: smallText.copyWith(
                              color: accentColor,
                              fontWeight: bold,
                            ),
                          ),
                          // Indikator Mode
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _showGifView
                                  ? primaryColor.withOpacity(0.2)
                                  : (_isUserTyping
                                        ? infoColor.withOpacity(0.15)
                                        : successColor.withOpacity(0.15)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _showGifView
                                      ? Icons.translate
                                      : (_isUserTyping
                                            ? Icons.keyboard
                                            : Icons.camera_alt),
                                  size: 14,
                                  color: _showGifView
                                      ? primaryColor
                                      : (_isUserTyping
                                            ? infoColor
                                            : successColor),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _showGifView
                                      ? "Hasil Translate"
                                      : (_isUserTyping
                                            ? "Mode Ketik"
                                            : "Mode Kamera"),
                                  style: smallText.copyWith(
                                    color: _showGifView
                                        ? primaryColor
                                        : (_isUserTyping
                                              ? infoColor
                                              : successColor),
                                    fontWeight: bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: secondaryBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: greyColor.withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _textController,
                                  focusNode: _inputFocusNode,
                                  decoration: InputDecoration(
                                    hintText: "Ketik kata di sini...",
                                    hintStyle: bodyText.copyWith(
                                      color: greyColor,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  style: bodyText.copyWith(
                                    fontSize: responsiveFont(context, 14),
                                    color: accentColor,
                                  ),
                                  onSubmitted: (value) =>
                                      _translateTextToSign(),
                                ),
                              ),
                              IconButton(
                                onPressed: _translateTextToSign,
                                icon: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.search,
                                    color: backgroundColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: responsiveHeight(context, 0.02)),
            ],
          ),
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTER UNTUK VISUALISASI LANDMARK ---
class LandmarkPainter extends CustomPainter {
  LandmarkPainter({
    required this.hands,
    required this.previewSize,
    required this.lensDirection,
    required this.sensorOrientation,
  });

  final List<Hand> hands;
  final Size previewSize;
  final CameraLensDirection lensDirection;
  final int sensorOrientation;

  static const List<List<int>> connections = [
    [0, 1],
    [1, 2],
    [2, 3],
    [3, 4],
    [0, 5],
    [5, 6],
    [6, 7],
    [7, 8],
    [5, 9],
    [9, 10],
    [10, 11],
    [11, 12],
    [9, 13],
    [13, 14],
    [14, 15],
    [15, 16],
    [13, 17],
    [0, 17],
    [17, 18],
    [18, 19],
    [19, 20],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (hands.isEmpty) return;

    final double scaleX = size.width / previewSize.height;
    final double scaleY = size.height / previewSize.width;
    final double minScale = math.min(scaleX, scaleY);

    final pointPaint = Paint()
      ..color = Colors.red.shade700
      ..strokeWidth = 10 / minScale
      ..strokeCap = StrokeCap.round;

    final linePaint = Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = 4 / minScale;

    canvas.save();

    final double radians = 90 * math.pi / 180;
    final center = Offset(size.width / 2, size.height / 2);
    canvas.translate(center.dx, center.dy);
    canvas.rotate(radians);
    if (lensDirection == CameraLensDirection.front) {
      canvas.scale(-1, 1);
    }
    canvas.translate(-center.dx, -center.dy);

    final double logicalWidth = size.width;
    final double logicalHeight = size.height;

    for (final hand in hands) {
      final landmarks = hand.landmarks;

      for (final connection in connections) {
        final start = landmarks[connection[0]];
        final end = landmarks[connection[1]];

        final startPoint = Offset(
          start.x * logicalWidth * minScale,
          start.y * logicalHeight * minScale,
        );

        final endPoint = Offset(
          end.x * logicalWidth * minScale,
          end.y * logicalHeight * minScale,
        );

        canvas.drawLine(startPoint, endPoint, linePaint);
      }

      for (final landmark in landmarks) {
        final point = Offset(
          landmark.x * logicalWidth * minScale,
          landmark.y * logicalHeight * minScale,
        );

        canvas.drawCircle(point, 5 / minScale, pointPaint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LandmarkPainter oldDelegate) {
    return oldDelegate.hands != hands;
  }
}
