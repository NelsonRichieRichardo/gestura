import 'package:flutter/material.dart';
import 'package:gestura/core/themes/app_theme.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

import '../main.dart'; 

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  // --- KAMERA & TFLITE ---
  CameraController? _cameraController; 
  Future<void>? _initializeControllerFuture; 
  int selectedCameraIndex = 0; 
  bool _isInitialized = false; 
  bool _hasInitializationError = false; 
  bool _isDetecting = false; 

  // --- LOGIC DETEKSI & TRANSLATE ---
  String _outputLabel = ""; 
  String _confidence = "";
  
  // State untuk Mode Tampilan (Kamera vs GIF)
  bool _showGifView = false; 
  String _translatedText = ""; // Menyimpan teks yang sedang diterjemahkan

  // --- INPUT TEXT ---
  final TextEditingController _textController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  bool _isUserTyping = false;

  @override
  void initState() {
    super.initState();
    _loadTfliteModel();
    if (isCameraAvailable) {
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

  Future<void> _loadTfliteModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/models/sign_languange_model.tflite",
        labels: "assets/models/labels.txt",
        numThreads: 1, 
        isAsset: true,
      );
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  void _initializeController() {
    if (!isCameraAvailable || cameras.isEmpty) return;
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
        _startImageStream();
      }
    }).catchError((error) {
       if (mounted) setState(() { _hasInitializationError = true; _isInitialized = false; });
    });
  }

  void _startImageStream() {
    _cameraController!.startImageStream((CameraImage img) {
      // Stop deteksi jika sedang mengetik ATAU sedang melihat hasil translate GIF
      if (!_isDetecting && !_isUserTyping && !_showGifView) {
        _isDetecting = true;
        Tflite.runModelOnFrame(
          bytesList: img.planes.map((plane) {return plane.bytes;}).toList(),
          imageHeight: img.height, imageWidth: img.width,
          imageMean: 127.5, imageStd: 127.5, rotation: 90, numResults: 1, threshold: 0.5, asynch: true,
        ).then((recognitions) {
          if (recognitions != null && recognitions.isNotEmpty) {
            setState(() {
              _outputLabel = recognitions[0]['label'].toString();
              _confidence = (recognitions[0]['confidence'] * 100).toStringAsFixed(0) + "%";
            });
          }
          _isDetecting = false; 
        }).catchError((e) { _isDetecting = false; });
      }
    });
  }

  // --- LOGIC BARU: Translate Text -> Sign (Di Layar Utama) ---
  void _translateTextToSign() {
    String text = _textController.text.trim().toLowerCase();
    if (text.isEmpty) return;

    _inputFocusNode.unfocus(); // Tutup keyboard
    
    setState(() {
      _translatedText = text; // Simpan teks untuk ditampilkan
      _showGifView = true;    // UBAH MODE TAMPILAN KE GIF
      _outputLabel = "";      // Reset label kamera
    });
  }

  // Fungsi untuk kembali ke mode kamera
  void _closeTranslateView() {
    setState(() {
      _showGifView = false;
      _textController.clear();
      _translatedText = "";
    });
  }

  // Widget Tampilan GIF (Pengganti Kamera)
  Widget _buildGifResultView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
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
                            color: Colors.grey.shade50,
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
                                      Icon(Icons.broken_image, color: Colors.grey, size: 30),
                                      Text(char.toUpperCase(), style: TextStyle(fontSize: 24, fontWeight: bold, color: Colors.grey)),
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
            style: TextStyle(fontSize: 10, color: greyColor),
          )
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    if (!isCameraAvailable) {
       // Pesan error jika di Emulator
       return Center(child: Text("Kamera tidak tersedia di Emulator\n(Gunakan HP Fisik)", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)));
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
          return const Center(child: Text("Gagal memuat kamera"));
        }
        return Center(child: CircularProgressIndicator(color: accentColor));
      },
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    Tflite.close();
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
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0,4))]
                  ),
                  child: Stack(
                    children: [
                      // LOGIKA TAMPILAN:
                      // Jika _showGifView TRUE -> Tampilkan GIF
                      // Jika FALSE -> Tampilkan Kamera
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
                              backgroundColor: Colors.black54,
                              child: Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 20),
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
                              backgroundColor: Colors.red.withOpacity(0.9),
                              child: Icon(Icons.close, color: Colors.white, size: 24),
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
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              "Terdeteksi: $_outputLabel ($_confidence)",
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0,2))]
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
                              color: _showGifView ? Colors.orange.withOpacity(0.1) : (_isUserTyping ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1)),
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _showGifView ? Icons.translate : (_isUserTyping ? Icons.keyboard : Icons.camera_alt), 
                                  size: 14, 
                                  color: _showGifView ? Colors.orange : (_isUserTyping ? Colors.blue : Colors.green)
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _showGifView ? "Hasil Translate" : (_isUserTyping ? "Mode Ketik" : "Mode Kamera"),
                                  style: TextStyle(
                                    fontSize: 12, 
                                    color: _showGifView ? Colors.orange : (_isUserTyping ? Colors.blue : Colors.green), 
                                    fontWeight: FontWeight.bold
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
                             color: greyColor.withOpacity(0.1),
                             borderRadius: BorderRadius.circular(12)
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
                                  style: bodyText.copyWith(fontSize: responsiveFont(context, 16)),
                                  // Saat tekan Enter, panggil fungsi Translate
                                  onSubmitted: (value) => _translateTextToSign(),
                                ),
                              ),
                              IconButton(
                                onPressed: _translateTextToSign,
                                icon: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                                  child: const Icon(Icons.search, color: Colors.white, size: 20),
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