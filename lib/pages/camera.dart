import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, WriteBuffer;
import 'package:gestura/core/themes/app_theme.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart'; 
import 'package:google_mlkit_commons/google_mlkit_commons.dart' as ml_kit_commons; 
import 'dart:typed_data';

import '../main.dart'; 

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
  final int KEYPOINT_VECTOR_SIZE = 63; 

  // Buffer untuk menyimpan urutan keypoint (30 frame)
  List<List<double>> _sequenceBuffer = [];
  // ----------------------------------------------------------------------

  // --- KAMERA & TFLITE ---
  CameraController? _cameraController; 
  Future<void>? _initializeControllerFuture; 
  int selectedCameraIndex = 0; 
  bool _isInitialized = false; 
  bool _hasInitializationError = false; 
  bool _isDetecting = false; 

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
      });
    });
  }

  // --- 1. MEMUAT MODEL (Menggunakan Interpreter dari tflite_flutter) ---
  Future<void> _loadTfliteModel() async {
    try {
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
          if (_isInitialized) {
            _startImageStream();
          }
        });
      }
    } catch (e) {
      print("Error loading model or labels: $e");
    }
  }

  // --- 2. ML KIT UTILITIES: Ekstraksi Keypoint ---
  List<double> _extractKeypoints(List<Pose> poses) {
    if (poses.isNotEmpty) {
      final pose = poses.first;
      List<double> keypoints = [];

      for (final landmarkType in pose.landmarks.keys) {
        final landmark = pose.landmarks[landmarkType]!;
        keypoints.add(landmark.x);
        keypoints.add(landmark.y);
        keypoints.add(landmark.z);
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

  // --- 3. ML KIT UTILITIES: Konversi CameraImage ke InputImage (Fix Breaking Change) ---
  ml_kit_commons.InputImage? _inputImageFromCameraImage(CameraImage image) {
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
        setState(() => _isInitialized = true);
        if (_isModelLoaded) {
           _startImageStream();
        }
      }
    }).catchError((error) {
       if (mounted) setState(() { _hasInitializationError = true; _isInitialized = false; });
    });
  }

  // --------------------------------------------------------------------------------------------------
  // --- 4. LOGIC INFERENSI ---
  // --------------------------------------------------------------------------------------------------
  void _startImageStream() {
    if (_cameraController == null || !_isModelLoaded || !_cameraController!.value.isInitialized) return;

    if (_cameraController!.value.isStreamingImages) {
      _cameraController!.stopImageStream();
    }

    _cameraController!.startImageStream((CameraImage img) async {
      if (_interpreter == null) {
        _isDetecting = false;
        return;
      }

      if (!_isDetecting && !_isUserTyping && !_showGifView) {
        _isDetecting = true;
        
        try {
          final inputImage = _inputImageFromCameraImage(img);

          if (inputImage != null) {
            final poses = await _poseDetector.processImage(inputImage);

            final keypoints = _extractKeypoints(poses);
            _sequenceBuffer.add(keypoints);

            // Jaga ukuran buffer
            if (_sequenceBuffer.length > SEQUENCE_LENGTH) {
              _sequenceBuffer = _sequenceBuffer.sublist(
                _sequenceBuffer.length - SEQUENCE_LENGTH,
              );
            }

            // Jalankan inferensi hanya ketika buffer penuh
            if (_sequenceBuffer.length == SEQUENCE_LENGTH) {
              
              // >>> INPUT (2D List untuk [1, 30, 63, 1]) <<<
              final input = _sequenceBuffer.map((frame) => frame.cast<double>()).toList();

              // >>> OUTPUT (2D List untuk [1, 28]) <<<
              final output = [
                List.filled(_labels.length, 0.0),
              ]; 

              // Pastikan output direset untuk setiap inferensi
              _interpreter!.run([input], output); 

              final result = output[0] as List<double>;
              double maxConfidence = 0.0;
              int maxIndex = -1;

              for (int i = 0; i < result.length; i++) {
                if (result[i] > maxConfidence) {
                  maxConfidence = result[i];
                  maxIndex = i;
                }
              }

              const THRESHOLD = 0.7;

              if (mounted) {
                setState(() {
                  if (maxConfidence > THRESHOLD &&
                      maxIndex != -1 &&
                      maxIndex < _labels.length) {
                    
                    String detectedChar = _labels[maxIndex];
                    _outputLabel = detectedChar;
                    _confidence = (maxConfidence * 100).toStringAsFixed(0) + "%";

                    // === START PERUBAHAN BARU: Tambahkan ke Kotak Input ===
                    String currentText = _textController.text;
                    String lastChar = currentText.isNotEmpty ? currentText.substring(currentText.length - 1) : "";

                    // Tambahkan hanya jika karakter yang dideteksi berbeda dari karakter terakhir
                    if (detectedChar != lastChar) {
                        // Tambahkan karakter baru ke kotak input
                        _textController.text = currentText + detectedChar;
                        
                        // Pindahkan kursor ke akhir
                        _textController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _textController.text.length)
                        );

                        // KOSONGKAN BUFFER agar inferensi berikutnya menunggu 30 frame baru
                        _sequenceBuffer.clear();
                    }
                    // === AKHIR PERUBAHAN BARU ===
                    
                  } else {
                    _outputLabel = "Tunggu Deteksi...";
                    _confidence = "";
                  }
                });
              }
            }
          }
        } catch (e) {
          print("Error during ML/TFLite processing: $e");
          // Tangani exception, tapi biarkan loop berlanjut
        } finally {
          _isDetecting = false;
        }
      }
    });
  }
  // --- AKHIR LOGIC INFERENSI ---
  // --------------------------------------------------------------------------------------------------

  // --- LOGIC: Translate Text -> Sign (Di Layar Utama) ---
  void _translateTextToSign() {
    String text = _textController.text.trim().toLowerCase();
    if (text.isEmpty) return;

    _inputFocusNode.unfocus(); // Tutup keyboard
    _cameraController?.stopImageStream(); // Stop stream saat mode GIF aktif
    
    setState(() {
      _translatedText = text; // Simpan teks untuk ditampilkan
      _showGifView = true;     // UBAH MODE TAMPILAN KE GIF
      _outputLabel = "";       // Reset label kamera
      _confidence = "";
    });
  }

  // Fungsi untuk kembali ke mode kamera
  void _closeTranslateView() {
    setState(() {
      _showGifView = false;
      _textController.clear();
      _translatedText = "";
      _sequenceBuffer.clear(); // Bersihkan buffer sequence saat kembali ke kamera
    });
    _startImageStream(); // Mulai stream lagi
  }

  // Widget Tampilan GIF (Pengganti Kamera)
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
          
          // List GIF Horizontal
          SizedBox(
            height: 200, // Tinggi area gambar
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              // Pusatkan item jika sedikit
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
                              "assets/bisindo/$char.gif", // Panggil GIF
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Tampilan jika gambar ERROR/TIDAK KETEMU
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
    if (!isCameraAvailable) {
        // Pesan error jika di Emulator
        return Center(child: Text("Kamera tidak tersedia di Emulator\n(Gunakan HP Fisik)", textAlign: TextAlign.center, style: bodyText.copyWith(color: greyColor)));
    }
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && _isInitialized) {
            final size = _cameraController!.value.previewSize!;
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: double.infinity, height: double.infinity,
                child: FittedBox(
                  fit: BoxFit.cover, 
                  child: SizedBox(
                    width: size.height, height: size.width, 
                    child: CameraPreview(_cameraController!),
                  ),
                ),
              ),
            );
        } else if (_hasInitializationError) {
          return Center(child: Text("Gagal memuat kamera", style: bodyText));
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
                      // LOGIKA TAMPILAN:
                      Positioned.fill(
                        child: _showGifView 
                            ? _buildGifResultView() 
                            : _buildCameraView(),
                      ),

                      // Tombol Toggle Kamera (Hanya muncul di mode Kamera)
                      if (!_showGifView && isCameraAvailable && _isInitialized && cameras.length > 1) 
                        Positioned(
                          top: 10, right: 10,
                          child: InkWell(
                            onTap: () async {
                              if (_cameraController != null) {
                                await _cameraController!.stopImageStream();
                                await _cameraController!.dispose();
                              }
                              setState(() {
                                selectedCameraIndex = (selectedCameraIndex + 1) % cameras.length;
                                _isInitialized = false;
                              });
                              _initializeController(); 
                            },
                            child: CircleAvatar(
                              backgroundColor: blackColor.withOpacity(0.5),
                              child: Icon(Icons.flip_camera_ios_rounded, color: backgroundColor, size: 20),
                            ),
                          ),
                        ),
                      
                      // Tombol CLOSE (X) - Muncul HANYA saat Mode GIF Translate Aktif
                      if (_showGifView)
                        Positioned(
                          top: 10, right: 10,
                          child: InkWell(
                            onTap: _closeTranslateView, // Kembali ke kamera
                            child: CircleAvatar(
                              backgroundColor: dangerColor.withOpacity(0.9),
                              child: Icon(Icons.close, color: backgroundColor, size: 24),
                            ),
                          ),
                        ),

                      // Label Hasil Deteksi Realtime (Hanya di Mode Kamera)
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
                                    : "Terdeteksi: $_outputLabel",
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
                              // Warna berubah tergantung mode
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
                                  // Saat tekan Enter, panggil fungsi Translate
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