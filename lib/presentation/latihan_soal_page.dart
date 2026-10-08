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
  int _skorBenar = 0;

  bool _sudahJawab = false;
  bool _jawabanBenar = false;
  bool _isLoading = true;

  String? _errorMsg;

  int? _pilihanTerpilih;
  String _jawabanUserTerakhir = '-';

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

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
    try {
      final jsonStr = await rootBundle.loadString(
        'assets/data/latihan_soal.json',
      );

      final List<dynamic> data = jsonDecode(jsonStr);

      final semua = data
          .map(
            (e) => SoalLatihan.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();

      final filtered = semua
          .where((soal) => soal.topikId == widget.topikId)
          .toList();

      if (!mounted) return;

      setState(() {
        _soalList = filtered;
        _isLoading = false;

        if (filtered.isEmpty) {
          _errorMsg = 'Belum ada soal untuk topik ini.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMsg = 'Gagal memuat soal latihan.';
      });
    }
  }

  void _periksaJawabanNumerik() {
    if (_sudahJawab || _soalList.isEmpty) return;

    final soal = _soalList[_currentIndex];

    if (!soal.isNumerik) return;

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

    final benar = soal.cekJawabanNumerik(nilai);

    setState(() {
      _jawabanUserTerakhir =
          '$input${soal.satuan.trim().isEmpty ? '' : ' ${soal.satuan}'}';

      _jawabanBenar = benar;
      _sudahJawab = true;

      if (benar) {
        _skorBenar++;
      }
    });
  }

  void _pilihJawaban(int index) {
    if (_sudahJawab || _soalList.isEmpty) return;

    final soal = _soalList[_currentIndex];

    if (!soal.isPilihanGanda) return;

    final benar = soal.cekJawabanPilihanGanda(index);

    setState(() {
      _pilihanTerpilih = index;
      _jawabanUserTerakhir = soal.pilihan[index];
      _jawabanBenar = benar;
      _sudahJawab = true;

      if (benar) {
        _skorBenar++;
      }
    });
  }

  void _soalBerikutnya() {
    if (_currentIndex < _soalList.length - 1) {
      setState(() {
        _currentIndex++;
        _sudahJawab = false;
        _jawabanBenar = false;
        _pilihanTerpilih = null;
        _jawabanUserTerakhir = '-';
        _controller.clear();
      });

      return;
    }

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

  String _jawabanBenarText(SoalLatihan soal) {
    if (soal.isPilihanGanda) {
      if (soal.jawabanIndex == null ||
          soal.jawabanIndex! < 0 ||
          soal.jawabanIndex! >= soal.pilihan.length) {
        return '-';
      }

      final huruf = String.fromCharCode(65 + soal.jawabanIndex!);

      return '$huruf. ${soal.pilihan[soal.jawabanIndex!]}';
    }

    if (soal.jawabanBenar == null) {
      return '-';
    }

    return '${_formatAngka(soal.jawabanBenar!)}'
        '${soal.satuan.trim().isEmpty ? '' : ' ${soal.satuan}'}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F8FB),
        body: Center(
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        ),
      );
    }

    if (_errorMsg != null) {
      return _buildErrorPage();
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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildHeader(soal, progress),
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (soal.rumus.trim().isNotEmpty) ...[
                    _buildRumusCard(soal),
                    const SizedBox(height: 14),
                  ],
                  _buildSoalCard(soal),
                  const SizedBox(height: 20),
                  if (soal.isNumerik)
                    _buildInputNumerik(soal)
                  else if (soal.isPilihanGanda)
                    _buildPilihanGanda(soal)
                  else
                    _buildTipeTidakDidukung(),
                  if (_sudahJawab) ...[
                    const SizedBox(height: 18),
                    _buildHasilPembahasan(soal),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          if (_sudahJawab) _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildErrorPage() {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Text(widget.namaTopik),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.inbox_rounded,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMsg!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(SoalLatihan soal, double progress) {
    return Container(
      width: double.infinity,
      color: primaryColor,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Soal ${_currentIndex + 1} dari ${_soalList.length}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
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
    );
  }

  Widget _buildRumusCard(SoalLatihan soal) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.functions,
            size: 17,
            color: primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              soal.rumus,
              style: const TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoalCard(SoalLatihan soal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (soal.memilikiGambar) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                soal.imagePath!,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return _buildImageError(
                    'Gambar soal tidak dapat dimuat.',
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            soal.pertanyaan,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputNumerik(SoalLatihan soal) {
    return Container(
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
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              onSubmitted: (_) {
                if (!_sudahJawab) {
                  _periksaJawabanNumerik();
                }
              },
              decoration: InputDecoration(
                hintText: 'Masukkan jawaban...',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                suffixText: soal.satuan.trim().isEmpty
                    ? null
                    : soal.satuan,
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
                onPressed: _periksaJawabanNumerik,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Periksa',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPilihanGanda(SoalLatihan soal) {
    return Column(
      children: List.generate(
        soal.pilihan.length,
        (index) {
          final dipilih = _pilihanTerpilih == index;
          final jawabanBenar = soal.jawabanIndex == index;

          Color borderColor = Colors.grey.shade200;
          Color backgroundColor = Colors.white;
          Color circleColor = primaryColor;
          Color textColor = Colors.black87;
          IconData? trailingIcon;
          Color? trailingColor;

          if (_sudahJawab) {
            if (jawabanBenar) {
              borderColor = Colors.green;
              backgroundColor = const Color(0xFFE8F5E9);
              circleColor = Colors.green;
              textColor = Colors.green.shade800;
              trailingIcon = Icons.check_circle;
              trailingColor = Colors.green;
            } else if (dipilih) {
              borderColor = Colors.red;
              backgroundColor = const Color(0xFFFFEBEE);
              circleColor = Colors.red;
              textColor = Colors.red.shade800;
              trailingIcon = Icons.cancel;
              trailingColor = Colors.red;
            }
          } else if (dipilih) {
            borderColor = primaryColor;
            backgroundColor = primaryColor.withOpacity(0.06);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _sudahJawab
                    ? null
                    : () => _pilihJawaban(index),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: borderColor,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: circleColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          String.fromCharCode(65 + index),
                          style: TextStyle(
                            color: circleColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          soal.pilihan[index],
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: dipilih || jawabanBenar
                                ? FontWeight.w600
                                : FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                      if (trailingIcon != null) ...[
                        const SizedBox(width: 10),
                        Icon(
                          trailingIcon,
                          color: trailingColor,
                          size: 22,
                        ),
                      ],
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

  Widget _buildTipeTidakDidukung() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.shade200,
        ),
      ),
      child: const Text(
        'Tipe soal ini belum didukung.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.orange,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildHasilPembahasan(SoalLatihan soal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _jawabanBenar
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _jawabanBenar
              ? Colors.green.shade200
              : Colors.red.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _jawabanBenar
                    ? Icons.check_circle
                    : Icons.cancel,
                color: _jawabanBenar
                    ? Colors.green
                    : Colors.red,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _jawabanBenar
                      ? 'Jawaban Benar!'
                      : 'Jawaban Salah',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _jawabanBenar
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          if (!_jawabanBenar) ...[
            const SizedBox(height: 8),
            Text(
              'Jawaban benar: ${_jawabanBenarText(soal)}',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ],
          const Divider(height: 24),
          const Text(
            '📖 Pembahasan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            soal.pembahasan,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
          if (soal.memilikiGambarPembahasan) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                soal.solutionImagePath!,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return _buildImageError(
                    'Gambar pembahasan tidak dapat dimuat.',
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
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
                      jawabanBenar: _jawabanBenarText(soal),
                      jawabanPengguna: _jawabanUserTerakhir,
                      jawabanBenarFlag: _jawabanBenar,
                      pembahasanAsli: soal.pembahasan,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.auto_awesome,
                size: 18,
              ),
              label: const Text(
                'Lihat Pembahasan AI',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return SafeArea(
      top: false,
      child: Container(
        color: const Color(0xFFF4F8FB),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _soalBerikutnya,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              _currentIndex < _soalList.length - 1
                  ? 'Soal Berikutnya →'
                  : 'Lihat Hasil',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageError(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.broken_image_outlined,
            color: Colors.redAccent,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAngka(double nilai) {
    if (nilai == nilai.roundToDouble()) {
      return nilai.toInt().toString();
    }

    return nilai
        .toStringAsFixed(4)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
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
  State<LatihanResultPage> createState() =>
      _LatihanResultPageState();
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
      subtitle:
          'Selesai • Skor $persen% '
          '(${widget.skorBenar}/${widget.totalSoal} benar)',
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
          child: SingleChildScrollView(
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
                    lulus
                        ? Icons.emoji_events_rounded
                        : Icons.replay_rounded,
                    size: 64,
                    color: lulus
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  lulus ? 'Hebat! 🎉' : 'Terus Berlatih!',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  lulus
                      ? 'Hasil latihan materi '
                          '${widget.namaTopik} sudah baik!'
                      : 'Coba pelajari kembali materi '
                          '${widget.namaTopik} dan kerjakan latihannya lagi.',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
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
                          color: lulus
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      const Text(
                        '%',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${widget.skorBenar} '
                        'dari ${widget.totalSoal} soal benar',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(
                        context,
                        ModalRoute.withName('/'),
                      );

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
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Ulangi Latihan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.popUntil(
                      context,
                      ModalRoute.withName('/'),
                    );
                  },
                  child: const Text(
                    'Kembali ke Beranda',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
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