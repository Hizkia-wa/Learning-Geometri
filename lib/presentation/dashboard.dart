import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'materi_page.dart'; // <--- Pastikan file ini sudah ada
import 'kuis_topik_page.dart';
import 'latihan_topik_page.dart';
import 'ai_solution_page.dart';
import 'peta_konsep_page.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  static const Color primaryColor = Color(0xFF17AEBF);
  static const Color secondaryColor = Color(0xFFDCFCE7);

  @override
  Widget build(BuildContext context) {
    // AnnotatedRegion digunakan agar status bar (jam & baterai) berwarna putih
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F8FB),
        body: Stack(
          children: [
            _buildHeaderBackground(context),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 15),
                    _buildGreeting(),
                    const SizedBox(height: 25),
                    
                    // Kita oper 'context' ke sini agar bisa melakukan navigasi
                    _buildMainQuickActions(context), 
                    
                    _buildGamifikasiSection(),
                    _buildRecentActivity(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBackground(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, Color(0xFF128A99)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.notes, color: Colors.white, size: 28),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: secondaryColor,
              child: Icon(Icons.person, color: primaryColor, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Selamat Belajar,", style: TextStyle(color: Colors.white70, fontSize: 16)),
          Text("Hizkia Cristian", 
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Menambahkan parameter BuildContext agar bisa Navigator.push
  Widget _buildMainQuickActions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionItem(
                Icons.menu_book_rounded, 
                "Materi", 
                Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MateriPage()),
                  );
                },
              ),
              _buildActionItem(Icons.account_tree_outlined, "Peta Konsep", Colors.teal, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PetaKonsepPage()))),
              _buildActionItem(
                Icons.quiz_outlined, 
                "Kuis Teori", 
                Colors.orange,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const KuisTopikPage()),
                  ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionItem(
                Icons.edit_note_rounded, 
                "Latihan", 
                Colors.redAccent,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LatihanTopikPage()),
                  ),
                ),
              _buildActionItem(
                Icons.auto_awesome,
                "AI Solver",
                Colors.purple,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AiSolutionPage()),
                ),
              ),
              _buildActionItem(Icons.view_in_ar_rounded, "AR View", Colors.indigo),
            ],
          ),
        ],
      ),
    );
  }

  // Menambahkan parameter optional {VoidCallback? onTap}
  Widget _buildActionItem(IconData icon, String label, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: SizedBox(
        width: 85,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              label, 
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamifikasiSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [secondaryColor, Colors.white],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.layers_outlined, color: primaryColor, size: 40),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Eksplorasi Bangun Ruang", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Bongkar pasang struktur geometri secara interaktif", 
                  style: TextStyle(fontSize: 12, color: Colors.grey[700])),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Lanjutkan Belajar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _buildActivityCard("Volume Kerucut", "Terakhir dipelajari kemarin", 0.4),
        ],
      ),
    );
  }

  Widget _buildActivityCard(String title, String desc, double progress) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            color: primaryColor,
            minHeight: 4,
          )
        ],
      ),
    );
  }
}