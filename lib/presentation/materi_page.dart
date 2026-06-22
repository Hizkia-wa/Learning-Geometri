import 'package:flutter/material.dart';

import '../data/materi_data.dart';
import 'materi_detail_page.dart';

class MateriPage extends StatelessWidget {
  const MateriPage({super.key});

  Color _getTopicColor(String id) {
    switch (id) {
      case '1':
        return const Color(0xFF3B82F6); // Kubus
      case '2':
        return const Color(0xFFF59E0B); // Balok
      case '3':
        return const Color(0xFF10B981); // Tabung
      case '4':
        return const Color(0xFFA855F7); // Kerucut
      case '5':
        return const Color(0xFFEF4444); // Bola
      default:
        return const Color(0xFF17AEBF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        title: const Text(
          'Materi Pembelajaran',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: daftarMateri.length,
        itemBuilder: (context, index) {
          final materi = daftarMateri[index];
          final color = _getTopicColor(materi.id);

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MateriDetailPage(materi: materi),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: color,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 15),
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
                              materi.deskripsi,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: color.withValues(alpha: 0.75),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}