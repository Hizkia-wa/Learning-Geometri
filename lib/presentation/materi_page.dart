import 'package:flutter/material.dart';
import '../data/materi_data.dart';
import 'materi_detail_page.dart'; // Pastikan import ke file detail materi sudah benar

class MateriPage extends StatelessWidget {
  const MateriPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        title: const Text(
          "Materi Pembelajaran", 
          style: TextStyle(fontWeight: FontWeight.bold)
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
                )
              ],
            ),
            child: Material( // Menambahkan Material agar efek InkWell (klik) muncul
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  // LOGIKA NAVIGASI: Mengirim objek 'materi' ke halaman detail
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
                      // Leading Icon/Image
                      Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          color: const Color(0xFF17AEBF).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded, 
                          color: Color(0xFF17AEBF),
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 15),
                      // Title & Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              materi.judul, 
                              style: const TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 18
                              )
                            ),
                            const SizedBox(height: 5),
                            Text(
                              materi.deskripsi, 
                              maxLines: 2, 
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Trailing Icon
                      const Icon(
                        Icons.arrow_forward_ios_rounded, 
                        size: 16, 
                        color: Colors.black26
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