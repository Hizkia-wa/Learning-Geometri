import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ArViewPage extends StatefulWidget {
  final String title;
  final String modelUrl; // Bisa berupa URL online atau path asset lokal (misal: 'assets/cube/cube.glb')

  const ArViewPage({
    super.key,
    required this.title,
    required this.modelUrl,
  });

  @override
  State<ArViewPage> createState() => _ArViewPageState();
}

class _ArViewPageState extends State<ArViewPage> {
  static const Color primaryColor = Color(0xFF17AEBF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: primaryColor.withValues(alpha: 0.1),
            child: const Text(
              'Sentuh & geser untuk memutar. Cubit untuk zoom.\nTekan ikon [AR] di pojok kanan bawah untuk menampilkannya di dunia nyata!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          Expanded(
            child: ModelViewer(
              backgroundColor: Colors.white,
              src: widget.modelUrl,
              alt: 'A 3D model of \${widget.title}',
              ar: true, // Mengaktifkan tombol AR
              arModes: const ['scene-viewer', 'quick-look'], // Standard mode untuk Android & iOS
              autoRotate: true,
              cameraControls: true, // Memungkinkan user interaksi (putar & zoom)
              disableZoom: false,
            ),
          ),
        ],
      ),
    );
  }
}
