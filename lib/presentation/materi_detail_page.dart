import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../data/materi_data.dart';
import '../services/activity_service.dart';
import 'cube_3d_page.dart';
import 'kuis_teori_page.dart';
import 'latihan_soal_page.dart';

class MateriDetailPage extends StatefulWidget {
  final Materi materi;

  const MateriDetailPage({
    super.key,
    required this.materi,
  });

  @override
  State<MateriDetailPage> createState() => _MateriDetailPageState();
}

class _MateriDetailPageState extends State<MateriDetailPage> {
  static const Color primaryColor = Color(0xFF17AEBF);

  @override
  void initState() {
    super.initState();
    _saveActivity();
  }

  Future<void> _saveActivity() async {
    await ActivityService.addActivity(
      title: 'Materi ${widget.materi.judul}',
      subtitle: 'Membuka materi ${widget.materi.judul}',
      type: 'materi',
    );
  }

  @override
  Widget build(BuildContext context) {
    final materi = widget.materi;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          materi.judul,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SfPdfViewer.asset(
            materi.pdfPath,
            onDocumentLoadFailed: (details) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Gagal Memuat PDF'),
                  content: Text(
                    'Error: ${details.error}\nPath: ${materi.pdfPath}',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
          _FloatingMenu(materi: materi),
        ],
      ),
    );
  }
}

class _FloatingMenu extends StatefulWidget {
  final Materi materi;

  const _FloatingMenu({
    required this.materi,
  });

  @override
  State<_FloatingMenu> createState() => _FloatingMenuState();
}

class _FloatingMenuState extends State<_FloatingMenu>
    with SingleTickerProviderStateMixin {
  bool isOpen = false;

  late final AnimationController _controller;
  late final Animation<double> _animation;

  static const Color primaryColor = Color(0xFF17AEBF);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggle() {
    setState(() {
      isOpen = !isOpen;
      if (isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Widget fab({
    required IconData icon,
    required Color color,
    required String tag,
    required VoidCallback onPressed,
  }) {
    return FloatingActionButton(
      heroTag: tag,
      backgroundColor: color,
      foregroundColor: Colors.white,
      mini: true,
      onPressed: onPressed,
      child: Icon(icon),
    );
  }

  void _closeMenu() {
    if (!isOpen) return;

    setState(() {
      isOpen = false;
      _controller.reverse();
    });
  }

  void _openLatihan() {
    _closeMenu();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LatihanSoalPage(
          topikId: widget.materi.id,
          namaTopik: widget.materi.judul,
        ),
      ),
    );
  }

  void _openKuis() {
    _closeMenu();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KuisTeoriPage(
          topikId: widget.materi.id,
          namaTopik: widget.materi.judul,
        ),
      ),
    );
  }

  void _open3D() {
    _closeMenu();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const Cube3DPage(),
      ),
    );
  }

  void _openAR() {
    _closeMenu();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ARPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizeTransition(
            sizeFactor: _animation,
            axis: Axis.vertical,
            child: Column(
              children: [
                fab(
                  icon: Icons.edit_rounded,
                  color: Colors.orange,
                  tag: 'latihan_${widget.materi.id}',
                  onPressed: _openLatihan,
                ),
                const SizedBox(height: 10),
                fab(
                  icon: Icons.quiz_rounded,
                  color: Colors.purple,
                  tag: 'kuis_${widget.materi.id}',
                  onPressed: _openKuis,
                ),
                const SizedBox(height: 10),
                fab(
                  icon: Icons.view_in_ar_rounded,
                  color: Colors.blue,
                  tag: '3d_${widget.materi.id}',
                  onPressed: _open3D,
                ),
                const SizedBox(height: 10),
                fab(
                  icon: Icons.camera_alt_rounded,
                  color: Colors.green,
                  tag: 'ar_${widget.materi.id}',
                  onPressed: _openAR,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          FloatingActionButton(
            heroTag: 'main_${widget.materi.id}',
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            onPressed: toggle,
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _animation,
            ),
          ),
        ],
      ),
    );
  }
}

class ARPage extends StatelessWidget {
  const ARPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Camera'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Halaman AR Camera'),
      ),
    );
  }
}