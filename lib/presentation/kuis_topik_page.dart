import 'package:flutter/material.dart';
import '../data/materi_data.dart';
import 'kuis_teori_page.dart';

class KuisTopikPage extends StatelessWidget {
  const KuisTopikPage({super.key});

  static const Color primaryColor = Color(0xFF17AEBF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        title: const Text(
          'Kuis Teori',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub-header
          Container(
            width: double.infinity,
            color: primaryColor,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: const Text(
              'Pilih topik yang ingin kamu uji pemahamannya',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),

          // List topik — sama persis strukturnya dengan MateriPage
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: daftarMateri.length,
              itemBuilder: (context, index) {
                final materi = daftarMateri[index];
                return _buildTopikCard(context, materi);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopikCard(BuildContext context, Materi materi) {
    // Warna berbeda tiap topik supaya lebih menarik
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.teal,
      Colors.purple,
      Colors.redAccent,
      Colors.indigo,
      Colors.green,
    ];
    final colorIndex = (int.tryParse(materi.id) ?? 1) - 1;
    final color = colors[colorIndex % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Navigasi ke KuisTeoriPage dengan topikId dan nama topik
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => KuisTeoriPage(
                  topikId: materi.id,
                  namaTopik: materi.judul,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                // Icon topik
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.quiz_rounded, color: color, size: 30),
                ),
                const SizedBox(width: 15),

                // Judul & deskripsi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        materi.judul,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Uji pemahaman materi ${materi.judul}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),

                // Arrow
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}