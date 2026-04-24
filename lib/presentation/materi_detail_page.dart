import 'package:flutter/material.dart';
import '../data/materi_data.dart';
import '../data/data_detail_materi.dart'; // Import data detail relasional

class MateriDetailPage extends StatelessWidget {
  final Materi materi;

  const MateriDetailPage({super.key, required this.materi});

  @override
  Widget build(BuildContext context) {
    // Mencari data detail berdasarkan idMateri
    final detail = daftarDetailMateri.firstWhere(
      (element) => element.idMateri == materi.id,
      orElse: () => DetailMateri(
        id: "",
        idMateri: "",
        rumus: "Data tidak tersedia",
        luasPermukaan: "-",
        volume: "-",
        contohSoal: "-",
        sifatSifat: [],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(materi.judul, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF17AEBF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image (Bisa pakai placeholder jika asset belum ada)
            Container(
              height: 200,
              width: double.infinity,
              color: const Color(0xFF17AEBF).withValues(alpha: 0.1),
              child: const Icon(Icons.image, size: 100, color: Color(0xFF17AEBF)),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Definisi", 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF17AEBF))),
                  const SizedBox(height: 10),
                  Text(materi.isi, style: const TextStyle(fontSize: 15, height: 1.6)),
                  
                  const SizedBox(height: 25),
                  const Text("Sifat-Sifat", 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF17AEBF))),
                  const SizedBox(height: 10),
                  // Menampilkan List Sifat
                  ...detail.sifatSifat.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 10),
                        Text(s, style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                  )).toList(),

                  const SizedBox(height: 25),
                  _buildRumusBox("Rumus Volume", detail.volume, detail.rumus),
                  const SizedBox(height: 15),
                  _buildRumusBox("Luas Permukaan", "Total Luas Sisi", detail.luasPermukaan),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRumusBox(String title, String desc, String formula) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF17AEBF).withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(desc, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 10),
          Text(formula, 
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF17AEBF))),
        ],
      ),
    );
  }
}