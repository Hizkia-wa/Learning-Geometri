import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/soal_kuis_model.dart';

class KuisTeoriPage extends StatefulWidget {
  final String topikId;
  final String namaTopik;

  const KuisTeoriPage({
    super.key,
    required this.topikId,
    required this.namaTopik,
  });

  @override
  State<KuisTeoriPage> createState() => _KuisTeoriPageState();
}

class _KuisTeoriPageState extends State<KuisTeoriPage> {
  static const Color primaryColor = Color(0xFF17AEBF);

  List<SoalKuis> _soalList = [];
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _sudahJawab = false;
  int _skorBenar = 0;
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadSoal();
  }

  Future<void> _loadSoal() async {
    final jsonStr = await rootBundle.loadString('assets/data/kuis_teori.json');
    final List<dynamic> data = jsonDecode(jsonStr);
    final semua = data.map((e) => SoalKuis.fromJson(e)).toList();

    // Filter hanya soal yang sesuai topikId
    final filtered = semua.where((s) => s.topikId == widget.topikId).toList();
    filtered.shuffle();

    setState(() {
      if (filtered.isEmpty) {
        _errorMsg = 'Belum ada soal untuk topik ini.';
      }
      _soalList = filtered;
      _isLoading = false;
    });
  }

  void _pilihJawaban(int index) {
    if (_sudahJawab) return;
    setState(() {
      _selectedIndex = index;
      _sudahJawab = true;
      if (index == _soalList[_currentIndex].jawabanIndex) {
        _skorBenar++;
      }
    });
  }

  void _soalBerikutnya() {
    if (_currentIndex < _soalList.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _sudahJawab = false;
      });
    } else {
      _selesai();
    }
  }

  void _selesai() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KuisResultPage(
          skorBenar: _skorBenar,
          totalSoal: _soalList.length,
          topikId: widget.topikId,
          namaTopik: widget.namaTopik,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMsg != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          title: Text(widget.namaTopik),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inbox_rounded, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(_errorMsg!, style: const TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                child: const Text('Kembali', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final soal = _soalList[_currentIndex];
    final progress = (_currentIndex + 1) / _soalList.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Kuis ${widget.namaTopik}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header progress
          Container(
            color: primaryColor,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Soal ${_currentIndex + 1} dari ${_soalList.length}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        soal.topik,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    color: Colors.white,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),

          // Body soal
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                      ],
                    ),
                    child: Text(
                      soal.pertanyaan,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ...List.generate(soal.pilihan.length, (i) {
                    return _buildPilihan(i, soal.pilihan[i], soal.jawabanIndex);
                  }),

                  if (_sudahJawab) _buildPembahasan(soal.pembahasan),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Tombol lanjut
          if (_sudahJawab)
            Container(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _soalBerikutnya,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentIndex < _soalList.length - 1
                        ? 'Soal Berikutnya →'
                        : 'Lihat Hasil',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // FIX: Ganti GestureDetector → Material + InkWell
  Widget _buildPilihan(int index, String teks, int jawabanIndex) {
    Color bgColor = Colors.white;
    Color borderColor = Colors.grey.shade200;
    Color textColor = Colors.black87;
    Widget? trailingIcon;

    if (_sudahJawab) {
      if (index == jawabanIndex) {
        bgColor = const Color(0xFFE8F5E9);
        borderColor = Colors.green;
        textColor = Colors.green.shade800;
        trailingIcon = const Icon(Icons.check_circle, color: Colors.green);
      } else if (index == _selectedIndex) {
        bgColor = const Color(0xFFFFEBEE);
        borderColor = Colors.red;
        textColor = Colors.red.shade800;
        trailingIcon = const Icon(Icons.cancel, color: Colors.red);
      }
    } else if (index == _selectedIndex) {
      borderColor = primaryColor;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _pilihJawaban(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: borderColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D
                    style: TextStyle(fontWeight: FontWeight.bold, color: borderColor),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    teks,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (trailingIcon != null) trailingIcon,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPembahasan(String pembahasan) {
    final benar = _selectedIndex == _soalList[_currentIndex].jawabanIndex;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: benar ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: benar ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                benar ? Icons.check_circle_outline : Icons.info_outline,
                color: benar ? Colors.green : Colors.orange,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                benar ? 'Jawaban Benar!' : 'Jawaban Kurang Tepat',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: benar ? Colors.green.shade700 : Colors.orange.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            pembahasan,
            style: TextStyle(
              fontSize: 13,
              color: benar ? Colors.green.shade800 : Colors.orange.shade900,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Halaman Hasil Kuis
// ─────────────────────────────────────────────
class KuisResultPage extends StatelessWidget {
  final int skorBenar;
  final int totalSoal;
  final String topikId;
  final String namaTopik;

  const KuisResultPage({
    super.key,
    required this.skorBenar,
    required this.totalSoal,
    required this.topikId,
    required this.namaTopik,
  });

  static const Color primaryColor = Color(0xFF17AEBF);

  @override
  Widget build(BuildContext context) {
    final persen = (skorBenar / totalSoal * 100).round();
    final lulus = persen >= 70;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F8FB),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: lulus
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFEBEE),
                  ),
                  child: Icon(
                    lulus ? Icons.emoji_events_rounded : Icons.replay_rounded,
                    size: 64,
                    color: lulus ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  lulus ? 'Selamat! 🎉' : 'Coba Lagi!',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  lulus
                      ? 'Kamu menguasai materi $namaTopik!'
                      : 'Pelajari lagi materi $namaTopik ya!',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$persen',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: lulus ? Colors.green : Colors.red,
                        ),
                      ),
                      const Text('%', style: TextStyle(fontSize: 20, color: Colors.grey)),
                      const SizedBox(height: 12),
                      Text(
                        '$skorBenar dari $totalSoal soal benar',
                        style: const TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Tombol Ulangi Kuis
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, ModalRoute.withName('/'));
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => KuisTeoriPage(
                            topikId: topikId,
                            namaTopik: namaTopik,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Ulangi Kuis',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Tombol Kembali ke Beranda
                TextButton(
                  onPressed: () {
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                  },
                  child: const Text(
                    'Kembali ke Beranda',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}