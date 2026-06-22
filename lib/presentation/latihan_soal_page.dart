import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/soal_latihan_model.dart';
import '../services/activity_service.dart';
import 'ai_solution_page.dart';

class LatihanSoalPage extends StatefulWidget {
  final String topikId;
  final String namaTopik;

  const LatihanSoalPage({
    super.key,
    required this.topikId,
    required this.namaTopik,
  });

  @override
  State<LatihanSoalPage> createState() => _LatihanSoalPageState();
}

class _LatihanSoalPageState extends State<LatihanSoalPage> {
  static const Color primaryColor = Color(0xFF17AEBF);

  List<SoalLatihan> _soalList = [];
  int _currentIndex = 0;
  bool _sudahJawab = false;
  bool _jawabanBenar = false;
  bool _isLoading = true;
  int _skorBenar = 0;
  String? _errorMsg;
  String _jawabanUserTerakhir = '-';

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadSoal();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSoal() async {
    final jsonStr = await rootBundle.loadString('assets/data/latihan_soal.json');
    final List<dynamic> data = jsonDecode(jsonStr);
    final semua = data.map((e) => SoalLatihan.fromJson(e)).toList();
    final filtered = semua.where((s) => s.topikId == widget.topikId).toList();

    setState(() {
      if (filtered.isEmpty) {
        _errorMsg = 'Belum ada soal untuk topik ini.';
      }
      _soalList = filtered;
      _isLoading = false;
    });
  }

  void _periksa() {
    final input = _controller.text.trim().replaceAll(',', '.');
    final nilai = double.tryParse(input);

    if (nilai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan angka yang valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _focusNode.unfocus();

    final benar = _soalList[_currentIndex].cekJawaban(nilai);

    setState(() {
      _jawabanUserTerakhir = input;
      _sudahJawab = true;
      _jawabanBenar = benar;
      if (benar) _skorBenar++;
    });
  }

  void _soalBerikutnya() {
    if (_currentIndex < _soalList.length - 1) {
      setState(() {
        _currentIndex++;
        _sudahJawab = false;
        _jawabanBenar = false;
        _jawabanUserTerakhir = '-';
        _controller.clear();
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LatihanResultPage(
            skorBenar: _skorBenar,
            totalSoal: _soalList.length,
            topikId: widget.topikId,
            namaTopik: widget.namaTopik,
          ),
        ),
      );
    }
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
              Text(
                _errorMsg!,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                child: const Text(
                  'Kembali',
                  style: TextStyle(color: Colors.white),
                ),
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
          'Latihan ${widget.namaTopik}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
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
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: primaryColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.functions, size: 16, color: primaryColor),
                        const SizedBox(width: 6),
                        Text(
                          soal.rumus,
                          style: const TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Text(
                      soal.pertanyaan,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _sudahJawab
                            ? (_jawabanBenar ? Colors.green : Colors.red)
                            : Colors.grey.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            readOnly: _sudahJawab,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: 'Masukkan jawaban...',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              suffixText: soal.satuan,
                              suffixStyle: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        if (!_sudahJawab)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ElevatedButton(
                              onPressed: _periksa,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Periksa',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_sudahJawab) ...[
                    const SizedBox(height: 16),
                    _buildHasilPembahasan(soal),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
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

  Widget _buildHasilPembahasan(SoalLatihan soal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _jawabanBenar ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _jawabanBenar ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _jawabanBenar ? Icons.check_circle : Icons.cancel,
                color: _jawabanBenar ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                _jawabanBenar ? 'Jawaban Benar!' : 'Jawaban Salah',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _jawabanBenar ? Colors.green.shade700 : Colors.red.shade700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          if (!_jawabanBenar) ...[
            const SizedBox(height: 6),
            Text(
              'Jawaban benar: ${soal.jawabanBenar} ${soal.satuan}',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const Divider(height: 20),
          const Text(
            '📖 Pembahasan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            soal.pembahasan,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AiSolutionPage(
                      topik: soal.topik,
                      pertanyaan: soal.pertanyaan,
                      jawabanBenar: '${soal.jawabanBenar} ${soal.satuan}',
                      jawabanPengguna: '$_jawabanUserTerakhir ${soal.satuan}',
                      jawabanBenarFlag: _jawabanBenar,
                      pembahasanAsli: soal.pembahasan,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Lihat Pembahasan AI'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LatihanResultPage extends StatefulWidget {
  final int skorBenar;
  final int totalSoal;
  final String topikId;
  final String namaTopik;

  const LatihanResultPage({
    super.key,
    required this.skorBenar,
    required this.totalSoal,
    required this.topikId,
    required this.namaTopik,
  });

  @override
  State<LatihanResultPage> createState() => _LatihanResultPageState();
}

class _LatihanResultPageState extends State<LatihanResultPage> {
  static const Color primaryColor = Color(0xFF17AEBF);

  @override
  void initState() {
    super.initState();
    _saveActivity();
  }

  Future<void> _saveActivity() async {
    final persen = widget.totalSoal == 0
        ? 0
        : (widget.skorBenar / widget.totalSoal * 100).round();

    await ActivityService.addActivity(
      title: 'Latihan ${widget.namaTopik}',
      subtitle: 'Selesai • Skor $persen% (${widget.skorBenar}/${widget.totalSoal} benar)',
      type: 'latihan',
    );
  }

  @override
  Widget build(BuildContext context) {
    final persen = widget.totalSoal == 0
        ? 0
        : (widget.skorBenar / widget.totalSoal * 100).round();
    final lulus = persen >= 60;

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
                    color: lulus ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                  ),
                  child: Icon(
                    lulus ? Icons.emoji_events_rounded : Icons.replay_rounded,
                    size: 64,
                    color: lulus ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  lulus ? 'Hebat! 🎉' : 'Terus Berlatih!',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  lulus
                      ? 'Kemampuan hitungmu pada materi ${widget.namaTopik} sudah baik!'
                      : 'Coba pelajari lagi rumus ${widget.namaTopik} ya!',
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
                        '${widget.skorBenar} dari ${widget.totalSoal} soal benar',
                        style: const TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, ModalRoute.withName('/'));
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LatihanSoalPage(
                            topikId: widget.topikId,
                            namaTopik: widget.namaTopik,
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
                      'Ulangi Latihan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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