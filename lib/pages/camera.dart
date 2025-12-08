import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, WriteBuffer;
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart'; 
import 'package:google_mlkit_commons/google_mlkit_commons.dart' as ml_kit_commons; 
import 'dart:typed_data';

// --- ASUMSI IMPORT/CONFIG (Silakan sesuaikan dengan path Anda) ---
// Asumsikan AppTheme, responsiveHeight, responsiveFont, screenWidth, 
// bodyText, heading1, smallText, cardDecoration, primaryColor, 
// accentColor, backgroundColor, secondaryBackground, dangerColor, 
// infoColor, successColor, greyColor, blackColor, bold, medium ada di sini
import 'package:gestura/core/themes/app_theme.dart'; 
import '../main.dart'; // Asumsikan 'cameras' dan 'isCameraAvailable' diimpor dari main.dart
// -------------------------------------------------------------

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  // --- TFLITE_FLUTTER & POSE DETECTOR STATE ---
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isModelLoaded = false;
  late final PoseDetector _poseDetector;

  // Model Keypoint Properties 
  final int SEQUENCE_LENGTH = 30;
  // 33 landmarks * 3 (x, y, z) = 63 features
  final int KEYPOINT_VECTOR_SIZE = 63; 
  
  // Buffer untuk menyimpan urutan keypoint (30 frame)
  List<List<double>> _sequenceBuffer = [];
  // ----------------------------------------------------------------------

  // --- KAMERA & POSE LANDMARKER DATA ---
  CameraController? _cameraController; 
  Future<void>? _initializeControllerFuture; 
  int selectedCameraIndex = 0; 
  bool _isInitialized = false; 
  bool _hasInitializationError = false; 
  bool _isDetecting = false; // Flag untuk mencegah pemrosesan serentak

  // --- POSE DATA UNTUK PAINTER ---
  Pose? _currentPose; 
  Size _previewSize = Size.zero; 
  CameraLensDirection _lensDirection = CameraLensDirection.front;

  // --- LOGIC DETEKSI & TRANSLATE ---
  String _outputLabel = "Tunggu Deteksi..."; 
  String _confidence = "";
  
  // State untuk Mode Tampilan (Kamera vs GIF)
  bool _showGifView = false; 
  String _translatedText = ""; 

  // --- INPUT TEXT ---
  final TextEditingController _textController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  bool _isUserTyping = false;

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi ML Kit Pose Detector
    final options = PoseDetectorOptions(
      model: PoseDetectionModel.accurate,
      mode: PoseDetectionMode.stream,
    );
    _poseDetector = PoseDetector(options: options);

    _loadTfliteModel();
    if (isCameraAvailable && cameras.isNotEmpty) {
      final initialIndex = cameras.indexWhere((camera) => camera.lensDirection == CameraLensDirection.front);
      selectedCameraIndex = initialIndex != -1 ? initialIndex : 0; 
      _initializeController();
    }
    _inputFocusNode.addListener(() {
      setState(() {
        _isUserTyping = _inputFocusNode.hasFocus;
        // Hentikan stream jika pengguna mulai mengetik
        if (_isUserTyping) {
            _cameraController?.stopImageStream();
            _currentPose = null; // Bersihkan tampilan pose
            _sequenceBuffer.clear(); // Bersihkan buffer
        } else if (_isInitialized && _isModelLoaded && !_showGifView) {
             _startImageStream(); // Lanjutkan stream jika keyboard ditutup
        }
      });
    });
  }

  // --- 1. MEMUAT MODEL (TFLITE) ---
  Future<void> _loadTfliteModel() async {
    try {
      // Pastikan path model sudah benar
      _interpreter = await Interpreter.fromAsset("assets/models/sign_language_model.tflite");
      
      final labelData = await rootBundle.loadString("assets/models/labels.txt");
      _labels = labelData
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      if (mounted) {
        setState(() {
          _isModelLoaded = true;
          if (_isInitialized && !_isUserTyping && !_showGifView) {
            _startImageStream();
          }
        });
      }
    } catch (e) {
      print("Error loading model or labels: $e");
      // Menambahkan setState untuk menunjukkan error loading
      if (mounted) {
        setState(() {
          _outputLabel = "ERROR: Gagal memuat model.";
        });
      }
    }
  }

  // --- 2. ML KIT UTILITIES: Ekstraksi Keypoint (Normalisasi) ---
  List<double> _extractKeypoints(List<Pose> poses) {
    if (poses.isNotEmpty) {
      final pose = poses.first;
      List<double> keypoints = [];
      
      // Ambil landmark dalam urutan yang konsisten (sesuai urutan keys())
      // ML Kit Pose Landmarks harus memiliki 33 titik
      for (final landmarkType in pose.landmarks.keys) {
        final landmark = pose.landmarks[landmarkType]!;
        keypoints.add(landmark.x);
        keypoints.add(landmark.y);
        // Z juga ditambahkan
        keypoints.add(landmark.z); 
        // Optional: tambahkan visibility/likelihood jika model Anda menggunakannya
        // keypoints.add(landmark.likelihood); 
      }

      // Harus selalu 99 jika 33 landmarks terdeteksi
      if (keypoints.length >= KEYPOINT_VECTOR_SIZE) {
        return keypoints.sublist(0, KEYPOINT_VECTOR_SIZE);
      } else {
        // Pad dengan 0.0 jika kurang (seharusnya tidak terjadi jika Pose terdeteksi)
        keypoints.addAll(
          List.filled(KEYPOINT_VECTOR_SIZE - keypoints.length, 0.0),
        );
        return keypoints;
      }
    } else {
      // Jika tidak ada pose yang terdeteksi, berikan vektor nol
      return List.filled(KEYPOINT_VECTOR_SIZE, 0.0);
    }
  }

  // --- 3. ML KIT UTILITIES: Konversi CameraImage ke InputImage ---
  ml_kit_commons.InputImage? _inputImageFromCameraImage(CameraImage image) {
    // [Kode utilitas ML Kit untuk konversi InputImage tetap sama]
    if (image.format.group != ImageFormatGroup.yuv420) {
      return null;
    }

    final allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final camera = cameras[selectedCameraIndex];

    final rotationInDegrees = {
      CameraLensDirection.front: 270,
      CameraLensDirection.back: 90,
    }[camera.lensDirection] ?? 0;

    final imageRotation =
        ml_kit_commons.InputImageRotationValue.fromRawValue(rotationInDegrees) ??
            ml_kit_commons.InputImageRotation.rotation0deg;

    final inputImageFormat = ml_kit_commons.InputImageFormat.nv21;
    
    final inputImageMetadata = ml_kit_commons.InputImageMetadata(
      size: imageSize,
      rotation: imageRotation, 
      format: inputImageFormat, 
      bytesPerRow: image.planes[0].bytesPerRow, 
    );

    return ml_kit_commons.InputImage.fromBytes(
      bytes: bytes, 
      metadata: inputImageMetadata,
    );
  }
  // --- AKHIR ML KIT UTILITIES ---

  void _initializeController() {
    if (!isCameraAvailable || cameras.isEmpty) return;
    if (_cameraController != null) {
      _cameraController!.dispose();
    }
    setState(() { _hasInitializationError = false; _isInitialized = false; });
    
    _cameraController = CameraController(
      cameras[selectedCameraIndex], 
      ResolutionPreset.medium, 
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420, 
    );

    _initializeControllerFuture = _cameraController!.initialize().then((_) {
      if (mounted) {
        setState(() { 
          _isInitialized = true;
          _previewSize = _cameraController!.value.previewSize ?? Size.zero;
          _lensDirection = _cameraController!.description.lensDirection;
        });
        if (_isModelLoaded && !_isUserTyping) {
           _startImageStream();
        }
      }
    }).catchError((error) {
       print("Camera Initialization Error: $error");
       if (mounted) setState(() { _hasInitializationError = true; _isInitialized = false; });
    });
  }

  // --------------------------------------------------------------------------------------------------
  // --- 4. LOGIC INFERENSI ---
  // --------------------------------------------------------------------------------------------------
  void _startImageStream() {
    if (_cameraController == null || !_isModelLoaded || !_cameraController!.value.isInitialized) return;
    if (_cameraController!.value.isStreamingImages) return; // Sudah berjalan

    _cameraController!.startImageStream((CameraImage img) async {
      if (_interpreter == null) {
        _isDetecting = false;
        return;
      }

      // Hanya proses jika tidak sedang mendeteksi dan tidak dalam mode input/translate
      if (!_isDetecting && !_isUserTyping && !_showGifView) {
        _isDetecting = true;
        
        try {
          final inputImage = _inputImageFromCameraImage(img);

          if (inputImage != null) {
            final poses = await _poseDetector.processImage(inputImage);

            // Simpan Pose untuk Painter Overlay
            if (mounted) {
              setState(() {
                _currentPose = poses.isNotEmpty ? poses.first : null;
              });
            }

            final keypoints = _extractKeypoints(poses);
            _sequenceBuffer.add(keypoints);

            // Jaga ukuran buffer
            if (_sequenceBuffer.length > SEQUENCE_LENGTH) {
              _sequenceBuffer = _sequenceBuffer.sublist(
                _sequenceBuffer.length - SEQUENCE_LENGTH,
              );
            }

            // Jalankan inferensi hanya ketika buffer penuh (30 frame)
            if (_sequenceBuffer.length == SEQUENCE_LENGTH) {
              
              // --- PERHATIAN: Memastikan Input Shape [1, 30, 99] ---
              
              // Map ke List<List<double>> (Sequence, Features)
              final List<List<double>> inputSequence = _sequenceBuffer.map((frame) {
                  return frame.cast<double>().toList(); 
              }).toList();
              
              // Bungkus dalam List lagi untuk Batch Size 1: [1, 30, 99]
              final inputTensor = [inputSequence];

              // Output shape: [1, jumlah_kelas]
              final output = [
                List.filled(_labels.length, 0.0),
              ]; 

              _interpreter!.run(inputTensor, output); 
              // -------------------------------------------------------

              final result = output[0] as List<double>;
              double maxConfidence = 0.0;
              int maxIndex = -1;

              for (int i = 0; i < result.length; i++) {
                if (result[i] > maxConfidence) {
                  maxConfidence = result[i];
                  maxIndex = i;
                }
              }

              const THRESHOLD = 0.70; // Threshold Deteksi

              if (mounted) {
                setState(() {
                  if (maxConfidence > THRESHOLD &&
                      maxIndex != -1 &&
                      maxIndex < _labels.length) {
                    
                    String detectedChar = _labels[maxIndex];
                    _outputLabel = detectedChar;
                    _confidence = (maxConfidence * 100).toStringAsFixed(0) + "%";

                    String currentText = _textController.text;
                    String lastChar = currentText.isNotEmpty ? currentText.substring(currentText.length - 1) : "";

                    // Tambahkan hanya jika karakter yang dideteksi berbeda dari karakter terakhir
                    if (detectedChar != lastChar && detectedChar != "kosong") { // Asumsi 'kosong' adalah kelas noise
                      _textController.text = currentText + detectedChar;
                      
                      _textController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _textController.text.length)
                      );

                      // KOSONGKAN BUFFER setelah deteksi berhasil
                      _sequenceBuffer.clear();
                    }
                    
                  } else {
                    _outputLabel = "Tunggu Deteksi...";
                    _confidence = "";
                  }
                });
              }
            }
          }
        } catch (e) {
          // Log error Bad State/failed precondition ada di sini
          print("Error during ML/TFLite processing: $e"); 
          if (mounted) {
            setState(() {
              _outputLabel = "Error TFLite! Cek Log.";
            });
          }
        } finally {
          _isDetecting = false;
        }
      }
    });
  }
  // --- AKHIR LOGIC INFERENSI ---
  // --------------------------------------------------------------------------------------------------

  void _translateTextToSign() {
    String text = _textController.text.trim().toLowerCase();
    if (text.isEmpty) return;

    _inputFocusNode.unfocus(); 
    _cameraController?.stopImageStream(); 
    
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
      _currentPose = null; // Clear pose
      _outputLabel = "Tunggu Deteksi...";
    });
    // Lanjutkan stream kamera setelah mode translate ditutup
    if (_isInitialized && _isModelLoaded) {
      _startImageStream(); 
    }
  }

  Widget _buildGifResultView() {
    // [Kode _buildGifResultView tetap sama]
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
                          width: 140, height: 140,
                          decoration: BoxDecoration(
                            border: Border.all(color: greyColor.withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(12),
                            color: secondaryBackground,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              "assets/bisindo/$char.gif", // ASUMSI PATH GIF
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image, color: greyColor, size: 30),
                                      Text(char.toUpperCase(), style: heading1.copyWith(color: greyColor)),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(char.toUpperCase(), style: smallText.copyWith(fontWeight: bold)),
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
          )
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    // [Kode _buildCameraView tetap sama]
    if (!isCameraAvailable) {
        return Center(child: Text("Kamera tidak tersedia di Emulator\n(Gunakan HP Fisik)", textAlign: TextAlign.center, style: bodyText.copyWith(color: greyColor)));
    }
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && _isInitialized && _cameraController!.value.isInitialized) {
            final size = _cameraController!.value.previewSize!;
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: double.infinity, height: double.infinity,
                child: FittedBox(
                  fit: BoxFit.cover, 
                  child: SizedBox(
                    width: size.height, height: size.width, 
                    child: Stack(
                      children: [
                        CameraPreview(_cameraController!),
                        // --- OVERLAY POSE LANDMARK ---
                        if (_currentPose != null && _previewSize != Size.zero)
                          CustomPaint(
                            size: Size.infinite,
                            painter: PosePainter(
                              pose: _currentPose!,
                              previewSize: _previewSize,
                              lensDirection: _lensDirection,
                            ),
                          ),
                        // ------------------------
                      ],
                    ),
                  ),
                ),
              ),
            );
        } else if (_hasInitializationError) {
          return Center(child: Text("Gagal memuat kamera. Pastikan izin sudah diberikan.", style: bodyText));
        }
        return Center(child: CircularProgressIndicator(color: primaryColor));
      },
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _interpreter?.close();
    _poseDetector.close();
    _textController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // [Kode build UI tetap sama]
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
              Text("Gestura", style: smallText.copyWith(color: accentColor.withOpacity(0.6), fontWeight: medium)),
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

                      if (!_showGifView && isCameraAvailable && _isInitialized && cameras.length > 1) 
                        Positioned(
                          top: 10, right: 10,
                          child: InkWell(
                            onTap: () async {
                              // Logic ganti kamera
                              if (_cameraController != null) {
                                await _cameraController!.stopImageStream();
                                await _cameraController!.dispose();
                              }
                              setState(() {
                                selectedCameraIndex = (selectedCameraIndex + 1) % cameras.length;
                                _isInitialized = false;
                                _currentPose = null;
                                _sequenceBuffer.clear();
                              });
                              _initializeController(); 
                            },
                            child: CircleAvatar(
                              backgroundColor: blackColor.withOpacity(0.5),
                              child: Icon(Icons.flip_camera_ios_rounded, color: backgroundColor, size: 20),
                            ),
                          ),
                        ),
                      
                      if (_showGifView)
                        Positioned(
                          top: 10, right: 10,
                          child: InkWell(
                            onTap: _closeTranslateView, 
                            child: CircleAvatar(
                              backgroundColor: dangerColor.withOpacity(0.9),
                              child: Icon(Icons.close, color: backgroundColor, size: 24),
                            ),
                          ),
                        ),

                      if (!_showGifView && !_isUserTyping && _outputLabel.isNotEmpty)
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                          )
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
                          Text("TERJEMAHKAN:", style: smallText.copyWith(color: accentColor, fontWeight: bold)),
                          // Indikator Mode
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _showGifView ? primaryColor.withOpacity(0.2) : (_isUserTyping ? infoColor.withOpacity(0.15) : successColor.withOpacity(0.15)),
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _showGifView ? Icons.translate : (_isUserTyping ? Icons.keyboard : Icons.camera_alt), 
                                  size: 14, 
                                  color: _showGifView ? primaryColor : (_isUserTyping ? infoColor : successColor)
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _showGifView ? "Hasil Translate" : (_isUserTyping ? "Mode Ketik" : "Mode Kamera"),
                                  style: smallText.copyWith(
                                    color: _showGifView ? primaryColor : (_isUserTyping ? infoColor : successColor), 
                                    fontWeight: bold
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(
                              color: secondaryBackground,
                              borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: greyColor.withOpacity(0.5)),
                            ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _textController,
                                  focusNode: _inputFocusNode,
                                  decoration: InputDecoration(
                                    hintText: "Ketik kata di sini...",
                                    hintStyle: bodyText.copyWith(color: greyColor),
                                    border: InputBorder.none,
                                  ),
                                  style: bodyText.copyWith(fontSize: responsiveFont(context, 14), color: accentColor),
                                  onSubmitted: (value) => _translateTextToSign(),
                                ),
                              ),
                              IconButton(
                                onPressed: _translateTextToSign,
                                icon: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                                  child: Icon(Icons.search, color: backgroundColor, size: 20),
                                ),
                              )
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

// --- Custom Painter Class untuk Visualisasi Pose ---
class PosePainter extends CustomPainter {
  PosePainter({
    required this.pose, 
    required this.previewSize,
    required this.lensDirection,
  });

  final Pose pose;
  final Size previewSize;
  final CameraLensDirection lensDirection;

  // Daftar koneksi standar untuk menggambar kerangka tubuh (diambil dari ML Kit Pose)
  static final Map<PoseLandmarkType, List<PoseLandmarkType>> connections = {
    PoseLandmarkType.nose: [PoseLandmarkType.leftEyeInner, PoseLandmarkType.rightEyeInner],
    PoseLandmarkType.leftEyeInner: [PoseLandmarkType.leftEye],
    PoseLandmarkType.leftEye: [PoseLandmarkType.leftEyeOuter],
    PoseLandmarkType.leftEyeOuter: [PoseLandmarkType.leftEar],
    PoseLandmarkType.rightEyeInner: [PoseLandmarkType.rightEye],
    PoseLandmarkType.rightEye: [PoseLandmarkType.rightEyeOuter],
    PoseLandmarkType.rightEyeOuter: [PoseLandmarkType.rightEar],
    PoseLandmarkType.leftMouth: [PoseLandmarkType.rightMouth],
    PoseLandmarkType.leftShoulder: [PoseLandmarkType.leftElbow, PoseLandmarkType.rightShoulder, PoseLandmarkType.leftHip],
    PoseLandmarkType.rightShoulder: [PoseLandmarkType.rightElbow, PoseLandmarkType.rightHip],
    PoseLandmarkType.leftElbow: [PoseLandmarkType.leftWrist],
    PoseLandmarkType.rightElbow: [PoseLandmarkType.rightWrist],
    PoseLandmarkType.leftWrist: [PoseLandmarkType.leftThumb, PoseLandmarkType.leftPinky, PoseLandmarkType.leftIndex],
    PoseLandmarkType.rightWrist: [PoseLandmarkType.rightThumb, PoseLandmarkType.rightPinky, PoseLandmarkType.rightIndex],
    PoseLandmarkType.leftHip: [PoseLandmarkType.leftKnee, PoseLandmarkType.rightHip],
    PoseLandmarkType.rightHip: [PoseLandmarkType.rightKnee],
    PoseLandmarkType.leftKnee: [PoseLandmarkType.leftAnkle],
    PoseLandmarkType.rightKnee: [PoseLandmarkType.rightAnkle],
    PoseLandmarkType.leftAnkle: [PoseLandmarkType.leftHeel, PoseLandmarkType.leftFootIndex],
    PoseLandmarkType.rightAnkle: [PoseLandmarkType.rightHeel, PoseLandmarkType.rightFootIndex],
    PoseLandmarkType.leftHeel: [PoseLandmarkType.leftFootIndex],
    PoseLandmarkType.rightHeel: [PoseLandmarkType.rightFootIndex],
  };

  @override
  void paint(Canvas canvas, Size size) {
    if (pose.landmarks.isEmpty) return;

    final pointPaint = Paint()
      ..color = Colors.red.shade700
      ..strokeWidth = 10 
      ..strokeCap = StrokeCap.round;

    final linePaint = Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = 4;

    canvas.save();

    // Terapkan Mirroring Horizontal untuk kamera depan (selfie effect)
    final center = Offset(size.width / 2, size.height / 2);
    canvas.translate(center.dx, center.dy);
    if (lensDirection == CameraLensDirection.front) {
      canvas.scale(-1, 1);
    }
    canvas.translate(-center.dx, -center.dy);
    
    final double logicalWidth = size.width;
    final double logicalHeight = size.height;

    // 1. Menggambar Koneksi (Tulang)
    for (final startType in connections.keys) {
      final startLandmark = pose.landmarks[startType];
      if (startLandmark == null) continue;
      
      final startPoint = Offset(
        startLandmark.x * logicalWidth, 
        startLandmark.y * logicalHeight,
      );

      for (final endType in connections[startType]!) {
        final endLandmark = pose.landmarks[endType];
        if (endLandmark == null) continue;

        final endPoint = Offset(
          endLandmark.x * logicalWidth,
          endLandmark.y * logicalHeight,
        );
        
        // Hanya gambar garis jika kedua titik terdeteksi dengan confidence tinggi
        if (startLandmark.likelihood > 0.5 && endLandmark.likelihood > 0.5) {
          canvas.drawLine(startPoint, endPoint, linePaint);
        }
      }
    }

    // 2. Menggambar Landmark (Sendi)
    for (final landmark in pose.landmarks.values) {
      final point = Offset(
        landmark.x * logicalWidth, 
        landmark.y * logicalHeight,
      );
      
      if (landmark.likelihood > 0.5) { 
        canvas.drawCircle(point, 5, pointPaint);
      }
    }
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.pose != pose;
  }
}