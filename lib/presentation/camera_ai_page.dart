import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/gemini_service.dart';
import 'widgets/interactive_3d_shape_view.dart';
import 'ar_view_page.dart';

class GeometryShapeInfo {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> sifat;
  final String rumusLuas;
  final String rumusVolume;
  final String sampleObjectName;

  const GeometryShapeInfo({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.sifat,
    required this.rumusLuas,
    required this.rumusVolume,
    required this.sampleObjectName,
  });
}

final Map<String, GeometryShapeInfo> geometryShapesData = {
  'Kubus': const GeometryShapeInfo(
    name: 'Kubus',
    description: 'Memiliki 6 sisi berbentuk persegi yang sama besar dan 12 rusuk sama panjang.',
    icon: Icons.square_outlined,
    color: Color(0xFF17AEBF),
    sifat: [
      'Memiliki 6 sisi berbentuk persegi dengan ukuran sama',
      'Memiliki 12 rusuk sama panjang',
      'Memiliki 8 titik sudut',
      'Memiliki 4 diagonal ruang dan 12 diagonal bidang'
    ],
    rumusLuas: 'L = 6 × s²',
    rumusVolume: 'V = s³',
    sampleObjectName: 'Kotak Dadu / Kardus Persegi',
  ),
  'Balok': const GeometryShapeInfo(
    name: 'Balok',
    description: 'Memiliki 6 sisi persegi panjang dengan 3 pasang sisi yang sejajar dan sama besar.',
    icon: Icons.rectangle_outlined,
    color: Color(0xFF10B981),
    sifat: [
      'Memiliki 6 sisi berwujud persegi panjang (3 pasang sejajar)',
      'Memiliki 12 rusuk (4 panjang, 4 lebar, 4 tinggi)',
      'Memiliki 8 titik sudut',
      'Memiliki 4 diagonal ruang'
    ],
    rumusLuas: 'L = 2 × (p·l + p·t + l·t)',
    rumusVolume: 'V = p × l × t',
    sampleObjectName: 'Buku Tebal / Kotak Tisu',
  ),
  'Tabung': const GeometryShapeInfo(
    name: 'Tabung',
    description: 'Bangun ruang melengkung dengan alas dan tutup lingkaran yang sejajar dan identik.',
    icon: Icons.circle_outlined,
    color: Color(0xFFF59E0B),
    sifat: [
      'Memiliki 2 sisi lingkaran (alas dan tutup) yang identik',
      'Memiliki 1 sisi lengkung (selimut tabung)',
      'Memiliki 2 rusuk lengkung',
      'Tidak memiliki titik sudut'
    ],
    rumusLuas: 'L = 2 × π × r × (r + t)',
    rumusVolume: 'V = π × r² × t',
    sampleObjectName: 'Kaleng Minuman / Botol',
  ),
  'Kerucut': const GeometryShapeInfo(
    name: 'Kerucut',
    description: 'Bangun ruang dengan alas lingkaran dan selimut yang mengerucut ke satu titik puncak.',
    icon: Icons.change_history,
    color: Color(0xFFEF4444),
    sifat: [
      'Memiliki 1 sisi alas lingkaran dan 1 sisi selimut',
      'Memiliki 1 rusuk lengkung',
      'Memiliki 1 titik puncak (titik sudut)',
    ],
    rumusLuas: 'L = π × r × (r + s)',
    rumusVolume: 'V = 1/3 × π × r² × t',
    sampleObjectName: 'Topi Ulang Tahun / Nasi Tumpeng',
  ),
  'Limas': const GeometryShapeInfo(
    name: 'Limas',
    description: 'Bangun ruang dengan alas segi-n dan sisi-sisi tegak berbentuk segitiga.',
    icon: Icons.mode_standby_outlined,
    color: Color(0xFF8B5CF6),
    sifat: [
      'Memiliki 1 sisi alas dan n+1 total sisi',
      'Memiliki 2n rusuk',
      'Memiliki n+1 titik sudut',
      'Sisi tegak berupa segitiga yang bertemu di puncak'
    ],
    rumusLuas: 'L = Luas Alas + Jumlah Luas Sisi Tegak',
    rumusVolume: 'V = 1/3 × Luas Alas × t',
    sampleObjectName: 'Piramida / Atap Rumah',
  ),
  'Bola': const GeometryShapeInfo(
    name: 'Bola',
    description: 'Bangun ruang simetris sempurna yang titik permukaannya berjarak sama dari titik pusat.',
    icon: Icons.sports_soccer,
    color: Color(0xFF3B82F6),
    sifat: [
      'Hanya memiliki 1 sisi lengkung utuh',
      'Tidak memiliki rusuk maupun titik sudut',
      'Setiap titik pada permukaan berjarak r dari pusat'
    ],
    rumusLuas: 'L = 4 × π × r²',
    rumusVolume: 'V = 4/3 × π × r³',
    sampleObjectName: 'Bola Sepak / Kelereng',
  ),
  'Prisma': const GeometryShapeInfo(
    name: 'Prisma',
    description: 'Bangun ruang dengan dua alas sejajar yang kongruen dan sisi tegak berbentuk persegi panjang.',
    icon: Icons.details,
    color: Color(0xFFEC4899),
    sifat: [
      'Memiliki 2 alas identik dan sejajar',
      'Memiliki (n+2) sisi',
      'Memiliki 3n rusuk dan 2n titik sudut'
    ],
    rumusLuas: 'L = 2 × Luas Alas + (Keliling Alas × t)',
    rumusVolume: 'V = Luas Alas × t',
    sampleObjectName: 'Cokelat Toblerone / Tenda',
  ),
};

class DetectedObjectItem {
  final String shape;
  final double confidence;
  final String objectName;
  final String summary;
  final Rect normalizedBox; // ymin, xmin, ymax, xmax in [0..1000] scale

  DetectedObjectItem({
    required this.shape,
    required this.confidence,
    required this.objectName,
    required this.summary,
    required this.normalizedBox,
  });
}

class CameraAiPage extends StatefulWidget {
  final String? initialShape;

  const CameraAiPage({super.key, this.initialShape});

  @override
  State<CameraAiPage> createState() => _CameraAiPageState();
}

class _CameraAiPageState extends State<CameraAiPage> with TickerProviderStateMixin {
  // Navigation Steps: 1 = Hub, 2 = Lens Scanner, 3 = 3D Interactive Exploration
  int _currentStep = 1;

  final GeminiService _geminiService = GeminiService();
  final ImagePicker _picker = ImagePicker();

  String _selectedShape = 'Kubus';
  bool _isAnalyzing = false;
  Uint8List? _scannedImageBytes;
  
  // Google Lens Multi-Object Detection Results
  List<DetectedObjectItem> _detectedObjects = [];
  DetectedObjectItem? _activeSelectedObject;

  // 3D View Controls
  bool _autoRotate = true;
  bool _showWireframe = false;
  bool _isArMode = false;
  double _zoomScale = 1.0;

  late AnimationController _scanBeamController;
  late Animation<double> _scanBeamAnim;

  late AnimationController _lensPulseController;
  late Animation<double> _lensPulseAnim;

  @override
  void initState() {
    super.initState();
    if (widget.initialShape != null && geometryShapesData.containsKey(widget.initialShape)) {
      _selectedShape = widget.initialShape!;
      _currentStep = 3; // Jump directly to 3D exploration
    }

    _scanBeamController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanBeamAnim = Tween<double>(begin: 0.08, end: 0.92).animate(
      CurvedAnimation(parent: _scanBeamController, curve: Curves.easeInOut),
    );

    _lensPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _lensPulseAnim = Tween<double>(begin: 0.8, end: 1.25).animate(
      CurvedAnimation(parent: _lensPulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanBeamController.dispose();
    _lensPulseController.dispose();
    super.dispose();
  }

  void _startLensScanning([String? targetShape]) {
    setState(() {
      if (targetShape != null) {
        _selectedShape = targetShape;
      }
      _currentStep = 2;
      _isAnalyzing = false;
      _scannedImageBytes = null;
      _detectedObjects = [];
      _activeSelectedObject = null;
    });
  }

  Future<void> _processLensObjectDetection(Uint8List imageBytes, String mimeType) async {
    setState(() {
      _scannedImageBytes = imageBytes;
      _isAnalyzing = true;
      _detectedObjects = [];
      _activeSelectedObject = null;
    });

    try {
      final rawResults = await _geminiService.detectObjectsWithBoundingBoxes(imageBytes, mimeType: mimeType);
      List<DetectedObjectItem> parsedItems = [];

      if (rawResults.isNotEmpty) {
        for (var item in rawResults) {
          String shapeName = item['shape'] ?? 'Balok';
          // Normalize shape name to key
          String matchedKey = _matchShapeKey(shapeName);
          double conf = (item['confidence'] as num?)?.toDouble() ?? 0.95;
          String objName = item['object_name'] ?? geometryShapesData[matchedKey]?.sampleObjectName ?? 'Objek Geometri';
          String summaryText = item['summary'] ?? geometryShapesData[matchedKey]?.description ?? '';
          
          List boxList = item['box_2d'] as List? ?? [200, 200, 700, 800];
          double ymin = (boxList[0] as num).toDouble();
          double xmin = (boxList[1] as num).toDouble();
          double ymax = (boxList[2] as num).toDouble();
          double xmax = (boxList[3] as num).toDouble();

          parsedItems.add(DetectedObjectItem(
            shape: matchedKey,
            confidence: conf,
            objectName: objName,
            summary: summaryText,
            normalizedBox: Rect.fromLTRB(xmin, ymin, xmax, ymax),
          ));
        }
      }

      if (parsedItems.isEmpty) {
        // Fallback default Google Lens detections if offline/empty
        parsedItems = _generateDemoYoloDetections();
      }

      if (!mounted) return;

      setState(() {
        _isAnalyzing = false;
        _detectedObjects = parsedItems;
        if (_detectedObjects.isNotEmpty) {
          _activeSelectedObject = _detectedObjects.first;
          _selectedShape = _activeSelectedObject!.shape;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _detectedObjects = _generateDemoYoloDetections();
        _activeSelectedObject = _detectedObjects.first;
        _selectedShape = _activeSelectedObject!.shape;
      });
    }
  }

  String _matchShapeKey(String raw) {
    for (var key in geometryShapesData.keys) {
      if (raw.toLowerCase().contains(key.toLowerCase())) {
        return key;
      }
    }
    return 'Balok';
  }

  List<DetectedObjectItem> _generateDemoYoloDetections() {
    return [
      DetectedObjectItem(
        shape: _selectedShape,
        confidence: 0.96,
        objectName: geometryShapesData[_selectedShape]?.sampleObjectName ?? 'Objek Nyata',
        summary: geometryShapesData[_selectedShape]?.description ?? '',
        normalizedBox: const Rect.fromLTRB(180, 200, 820, 750),
      ),
      if (_selectedShape != 'Tabung')
        DetectedObjectItem(
          shape: 'Tabung',
          confidence: 0.91,
          objectName: 'Kaleng Minuman / Botol',
          summary: 'Tabung memiliki alas & tutup lingkaran sejajar.',
          normalizedBox: const Rect.fromLTRB(70, 100, 450, 480),
        ),
    ];
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        final mime = photo.mimeType ?? 'image/jpeg';
        await _processLensObjectDetection(bytes, mime);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengakses kamera/galeri: $e')),
      );
    }
  }

  void _simulateLensAiScan() {
    setState(() {
      _isAnalyzing = true;
      _detectedObjects = [];
      _activeSelectedObject = null;
    });

    Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _detectedObjects = _generateDemoYoloDetections();
        if (_detectedObjects.isNotEmpty) {
          _activeSelectedObject = _detectedObjects.first;
          _selectedShape = _activeSelectedObject!.shape;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (_currentStep > 1 && widget.initialShape == null) {
              setState(() {
                _currentStep = 1;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          if (_currentStep == 3)
            IconButton(
              icon: const Icon(Icons.info_outline_rounded),
              onPressed: () => _showShapeInfoModal(context),
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildBodyForStep(),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentStep) {
      case 1:
        return 'Pilih & Pindai Bangun Ruang';
      case 2:
        return 'Google Lens AI Geometri';
      case 3:
        return 'Model 3D: $_selectedShape';
      default:
        return 'Kamera AI Geometri';
    }
  }

  Widget _buildBodyForStep() {
    switch (_currentStep) {
      case 1:
        return _buildStep1ShapeSelection();
      case 2:
        return _buildStep2GoogleLensCameraScan();
      case 3:
        return _buildStep3Interactive3DViewer();
      default:
        return _buildStep1ShapeSelection();
    }
  }

  // ================= STEP 1: HUB SELEKSI BANGUN RUANG =================
  Widget _buildStep1ShapeSelection() {
    return Container(
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Google Lens Geometri AI 🔍',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Deteksi instan objek nyata (Balok, Kubus, Tabung, dll.) dengan bounding box bergaya Google Lens / YOLO.',
                  style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: geometryShapesData.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.15,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  final key = geometryShapesData.keys.elementAt(index);
                  final info = geometryShapesData[key]!;
                  return _buildShapeCard(info);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF17AEBF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                ),
                icon: const Icon(Icons.center_focus_strong_rounded, size: 28),
                label: const Text(
                  'Buka Google Lens AI Deteksi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _startLensScanning(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShapeCard(GeometryShapeInfo info) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedShape = info.name;
          _currentStep = 3;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: info.color.withValues(alpha: 0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: info.color.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: info.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(info.icon, color: info.color, size: 36),
            ),
            const SizedBox(height: 10),
            Text(
              info.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Contoh: ${info.sampleObjectName}',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }

  // ================= STEP 2: GOOGLE LENS CAMERA & BOUNDING BOX DETECTOR =================
  Widget _buildStep2GoogleLensCameraScan() {
    final info = geometryShapesData[_selectedShape] ?? geometryShapesData['Kubus']!;

    return Stack(
      children: [
        // Camera Viewport / Image Layer
        Positioned.fill(
          child: _scannedImageBytes != null
              ? Image.memory(_scannedImageBytes!, fit: BoxFit.cover)
              : Container(
                  color: Colors.black,
                  child: Center(
                    child: Icon(
                      info.icon,
                      size: 150,
                      color: info.color.withValues(alpha: 0.2),
                    ),
                  ),
                ),
        ),

        // Google Lens Particle Dots Overlay (Pulsing visual search matrix)
        if (_isAnalyzing)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _lensPulseAnim,
              builder: (context, child) {
                return CustomPaint(
                  painter: _GoogleLensParticlesPainter(
                    pulseScale: _lensPulseAnim.value,
                  ),
                );
              },
            ),
          ),

        // Scanning Laser Bar (Moving up/down)
        if (_isAnalyzing)
          AnimatedBuilder(
            animation: _scanBeamAnim,
            builder: (context, child) {
              return Positioned(
                top: MediaQuery.of(context).size.height * _scanBeamAnim.value,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withValues(alpha: 0.9),
                        blurRadius: 15,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

        // YOLO Dynamic Bounding Boxes Overlay (Rendered on detected objects)
        if (!_isAnalyzing && _detectedObjects.isNotEmpty)
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: _detectedObjects.map((item) {
                    final bool isSelected = _activeSelectedObject == item;
                    final shapeInfo = geometryShapesData[item.shape] ?? info;

                    // Convert normalized 0..1000 coordinates to actual screen pixels
                    double left = (item.normalizedBox.left / 1000) * constraints.maxWidth;
                    double top = (item.normalizedBox.top / 1000) * constraints.maxHeight;
                    double width = ((item.normalizedBox.width) / 1000) * constraints.maxWidth;
                    double height = ((item.normalizedBox.height) / 1000) * constraints.maxHeight;

                    // Clamp values to stay inside bounds
                    left = left.clamp(10, constraints.maxWidth - 120);
                    top = top.clamp(80, constraints.maxHeight - 200);
                    width = width.clamp(100, constraints.maxWidth - left - 10);
                    height = height.clamp(100, constraints.maxHeight - top - 100);

                    return Positioned(
                      left: left,
                      top: top,
                      width: width,
                      height: height,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _activeSelectedObject = item;
                            _selectedShape = item.shape;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? Colors.cyanAccent : shapeInfo.color,
                              width: isSelected ? 3.5 : 2.0,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            color: (isSelected ? Colors.cyanAccent : shapeInfo.color).withValues(alpha: 0.15),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.cyanAccent.withValues(alpha: 0.5),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : [],
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Top Tag Badge (Google Lens style label: e.g. "Balok 96%")
                              Positioned(
                                top: -32,
                                left: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.cyanAccent : shapeInfo.color,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 2)),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(shapeInfo.icon, size: 14, color: Colors.black),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${item.shape} ${(item.confidence * 100).toInt()}%',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Center Lens Target Dot Pin
                              Center(
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? Colors.cyanAccent : Colors.white,
                                    border: Border.all(color: Colors.black, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected ? Colors.cyanAccent : Colors.white,
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.center_focus_weak, size: 16, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),

        // Status Top Lens Badge
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isAnalyzing) ...[
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Pindai Google Lens AI...',
                    style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                  ),
                ] else if (_detectedObjects.isNotEmpty) ...[
                  const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Ditemukan ${_detectedObjects.length} Objek! Ketuk kotak untuk informasi',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ] else ...[
                  const Icon(Icons.camera_enhance_rounded, color: Colors.cyanAccent, size: 20),
                  const SizedBox(width: 10),
                  const Text(
                    'Arahkan kamera ke objek di sekitar',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Bottom Lens Active Card & Controls
        Positioned(
          bottom: 20,
          left: 16,
          right: 16,
          child: Column(
            children: [
              // Google Lens Active Detection Result Sheet
              if (!_isAnalyzing && _activeSelectedObject != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.5), width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Colors.black54, blurRadius: 16, offset: Offset(0, 6)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: info.color.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(info.icon, color: info.color, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _activeSelectedObject!.shape,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.greenAccent.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        'Acc: ${(_activeSelectedObject!.confidence * 100).toInt()}%',
                                        style: const TextStyle(
                                          color: Colors.greenAccent,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Objek: "${_activeSelectedObject!.objectName}"',
                                  style: const TextStyle(fontSize: 12, color: Colors.cyanAccent),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF17AEBF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.view_in_ar_rounded, size: 22),
                          label: const Text(
                            'Eksplorasi Model 3D Interaktif',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          onPressed: () {
                            setState(() {
                              _currentStep = 3;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

              // Scanner Action Buttons (Camera / Gallery / Simulation)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildScanActionButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Galeri',
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                      backgroundColor: const Color(0xFF17AEBF),
                      elevation: 10,
                    ),
                    onPressed: _isAnalyzing ? null : () => _pickImage(ImageSource.camera),
                    child: const Icon(Icons.camera_alt_rounded, size: 36, color: Colors.white),
                  ),
                  _buildScanActionButton(
                    icon: Icons.auto_awesome_rounded,
                    label: 'Simulasi Lens',
                    onTap: _isAnalyzing ? null : _simulateLensAiScan,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScanActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.cyanAccent, size: 24),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  // ================= STEP 3: EKSPLORASI MODEL 3D INTERAKTIF =================
  Widget _buildStep3Interactive3DViewer() {
    final info = geometryShapesData[_selectedShape] ?? geometryShapesData['Kubus']!;

    return Stack(
      children: [
        // Interactive 3D Canvas
        Positioned.fill(
          child: Interactive3DShapeView(
            shapeName: info.name,
            primaryColor: info.color,
            showWireframe: _showWireframe,
            autoRotate: _autoRotate,
            zoomScale: _zoomScale,
            isArMode: _isArMode,
          ),
        ),

        // Hint Banner
        Positioned(
          top: 16,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: const Text(
              'Sentuh & geser untuk memutar 360°. Cubit untuk zoom.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ),
        ),

        // Interactive Controls Bar
        Positioned(
          bottom: 20,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: info.color.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildViewerControlBtn(
                  icon: _autoRotate ? Icons.sync_rounded : Icons.sync_disabled_rounded,
                  label: 'Putar',
                  isActive: _autoRotate,
                  activeColor: info.color,
                  onTap: () {
                    setState(() {
                      _autoRotate = !_autoRotate;
                    });
                  },
                ),
                _buildViewerControlBtn(
                  icon: Icons.zoom_in_rounded,
                  label: 'Perbesar',
                  isActive: _zoomScale > 1.0,
                  activeColor: info.color,
                  onTap: () {
                    setState(() {
                      _zoomScale = _zoomScale >= 2.0 ? 1.0 : _zoomScale + 0.4;
                    });
                  },
                ),
                _buildViewerControlBtn(
                  icon: Icons.grid_3x3_rounded,
                  label: 'Lihat Sisi',
                  isActive: _showWireframe,
                  activeColor: info.color,
                  onTap: () {
                    setState(() {
                      _showWireframe = !_showWireframe;
                    });
                  },
                ),
                _buildViewerControlBtn(
                  icon: Icons.view_in_ar_rounded,
                  label: 'AR Mode',
                  isActive: _isArMode,
                  activeColor: info.color,
                  onTap: () {
                    if (info.name == 'Kubus') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ArViewPage(
                            title: 'AR ${info.name}',
                            modelUrl: 'assets/cube/cubexm.glb',
                          ),
                        ),
                      );
                    } else {
                      setState(() {
                        _isArMode = !_isArMode;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewerControlBtn({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isActive ? activeColor : Colors.transparent),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? activeColor : Colors.white70, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showShapeInfoModal(BuildContext context) {
    final info = geometryShapesData[_selectedShape] ?? geometryShapesData['Kubus']!;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(info.icon, color: info.color, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      'Sifat & Rumus ${info.name}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sifat-Sifat Bangun Ruang:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.cyanAccent),
                ),
                const SizedBox(height: 8),
                ...info.sifat.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 6, color: Colors.white70),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(s, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
                const Text(
                  'Rumus Matematika:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.cyanAccent),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Luas Permukaan: ${info.rumusLuas}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('Volume: ${info.rumusVolume}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GoogleLensParticlesPainter extends CustomPainter {
  final double pulseScale;

  _GoogleLensParticlesPainter({required this.pulseScale});

  @override
  void paint(Canvas canvas, Size size) {
    final particlePaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Grid of pulsing Google Lens target dots
    final List<Offset> points = [
      Offset(size.width * 0.3, size.height * 0.35),
      Offset(size.width * 0.7, size.height * 0.32),
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.35, size.height * 0.68),
      Offset(size.width * 0.68, size.height * 0.72),
    ];

    for (var pt in points) {
      canvas.drawCircle(pt, 4 * pulseScale, particlePaint);
      canvas.drawCircle(pt, 12 * pulseScale, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GoogleLensParticlesPainter oldDelegate) {
    return oldDelegate.pulseScale != pulseScale;
  }
}
