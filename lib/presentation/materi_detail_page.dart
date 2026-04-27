import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../data/materi_data.dart';

class MateriDetailPage extends StatelessWidget {
  final Materi materi;

  const MateriDetailPage({super.key, required this.materi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          materi.judul,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF17AEBF),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: const Color(0xFF17AEBF).withOpacity(0.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      materi.judul,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      materi.deskripsi,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

              // PDF
              Expanded(
                child: SfPdfViewer.asset(
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
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // 🔥 Floating Menu
          _FloatingMenu(materi: materi),
        ],
      ),
    );
  }
}

//
// 🔥 FLOATING MENU EXPANDABLE
//
class _FloatingMenu extends StatefulWidget {
  final Materi materi;

  const _FloatingMenu({required this.materi});

  @override
  State<_FloatingMenu> createState() => _FloatingMenuState();
}

class _FloatingMenuState extends State<_FloatingMenu>
    with SingleTickerProviderStateMixin {
  bool isOpen = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  void toggle() {
    setState(() {
      isOpen = !isOpen;
      isOpen ? _controller.forward() : _controller.reverse();
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
      mini: true,
      onPressed: onPressed,
      child: Icon(icon),
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
                  icon: Icons.edit,
                  color: Colors.orange,
                  tag: "latihan",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlaceholderPage(
                          title: "Latihan Soal",
                          materi: widget.materi,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),

                fab(
                  icon: Icons.quiz,
                  color: Colors.purple,
                  tag: "kuis",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlaceholderPage(
                          title: "Kuis",
                          materi: widget.materi,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),

                fab(
                  icon: Icons.view_in_ar,
                  color: Colors.blue,
                  tag: "3d",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlaceholderPage(
                          title: "3D Model",
                          materi: widget.materi,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),

                fab(
                  icon: Icons.camera_alt,
                  color: Colors.green,
                  tag: "ar",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ARPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),

          // MAIN BUTTON
          FloatingActionButton(
            heroTag: "main",
            backgroundColor: const Color(0xFF17AEBF),
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

//
// 🔥 Placeholder Pages
//
class PlaceholderPage extends StatelessWidget {
  final String title;
  final Materi materi;

  const PlaceholderPage({
    super.key,
    required this.title,
    required this.materi,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$title - ${materi.judul}"),
        backgroundColor: const Color(0xFF17AEBF),
      ),
      body: Center(
        child: Text(
          "$title untuk ${materi.judul}",
          style: const TextStyle(fontSize: 18),
        ),
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
        title: const Text("AR Camera"),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text("Halaman AR Camera"),
      ),
    );
  }
}