import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/soal_kuis_model.dart';
import 'kuis_result_page.dart';

class KuisTeoriPage extends StatefulWidget {
  const KuisTeoriPage({super.key});

  @override
  State<KuisTeoriPage> createState() => _KuisTeoriPageState();
}

class _KuisTeoriPageState extends State<KuisTeoriPage> {
  static const Color primaryColor = Color(0xFF17AEBF);

  static const int durasiKuisMenit = 10;

  final List<SoalKuis> _soalList = [];
  final Map<int, int> _jawabanUser = {};

  int _currentIndex = 0;
  int _sisaDetik = durasiKuisMenit * 60;

  bool _isLoading = true;
  bool _isSubmitting = false;

  String? _errorMsg;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadSoal();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadSoal() async {
    try {
      final jsonStr = await rootBundle.loadString(
        'assets/data/kuis_teori.json',
      );

      final dynamic decoded = jsonDecode(jsonStr);

      if (decoded is! List) {
        throw const FormatException(
          'Format kuis_teori.json harus berupa List.',
        );
      }

      final semuaSoal = decoded
          .map(
            (e) => SoalKuis.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();

      if (semuaSoal.isEmpty) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _errorMsg = 'Soal kuis belum tersedia.';
        });

        return;
      }

      semuaSoal.shuffle();

      if (!mounted) return;

      setState(() {
        _soalList
          ..clear()
          ..addAll(semuaSoal);

        _isLoading = false;
      });

      _mulaiTimer();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMsg = 'Gagal memuat soal kuis.';
      });
    }
  }

  void _mulaiTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_sisaDetik <= 1) {
          timer.cancel();

          setState(() {
            _sisaDetik = 0;
          });

          _submitKuis(waktuHabis: true);
          return;
        }

        setState(() {
          _sisaDetik--;
        });
      },
    );
  }

  void _pilihJawaban(int pilihanIndex) {
    if (_isSubmitting) return;

    setState(() {
      _jawabanUser[_currentIndex] = pilihanIndex;
    });
  }

  void _soalSebelumnya() {
    if (_currentIndex <= 0 || _isSubmitting) return;

    setState(() {
      _currentIndex--;
    });
  }

  void _soalBerikutnya() {
    if (_currentIndex >= _soalList.length - 1 || _isSubmitting) {
      return;
    }

    setState(() {
      _currentIndex++;
    });
  }

  Future<void> _konfirmasiSubmit() async {
    if (_isSubmitting) return;

    final belumDijawab = _soalList.length - _jawabanUser.length;

    final submit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Kumpulkan Kuis?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            belumDijawab > 0
                ? 'Masih ada $belumDijawab soal yang belum dijawab. '
                    'Apakah kamu tetap ingin mengumpulkan kuis?'
                : 'Semua soal sudah dijawab. '
                    'Apakah kamu ingin mengumpulkan kuis sekarang?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Kumpulkan'),
            ),
          ],
        );
      },
    );

    if (submit == true) {
      _submitKuis();
    }
  }

  void _submitKuis({
    bool waktuHabis = false,
  }) {
    if (_isSubmitting || _soalList.isEmpty) return;

    _timer?.cancel();

    setState(() {
      _isSubmitting = true;
    });

    int skorBenar = 0;

    for (int i = 0; i < _soalList.length; i++) {
      final jawaban = _jawabanUser[i];

      if (jawaban != null &&
          jawaban == _soalList[i].jawabanIndex) {
        skorBenar++;
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => KuisResultPage(
          skorBenar: skorBenar,
          totalSoal: _soalList.length,
          soalList: _soalList,
          jawabanUser: _jawabanUser,
          waktuHabis: waktuHabis,
        ),
      ),
    );
  }

  Future<bool> _konfirmasiKeluar() async {
    if (_isSubmitting) {
      return true;
    }

    final keluar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Keluar dari Kuis?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Jawaban yang sudah dipilih akan hilang jika kamu keluar '
            'sebelum mengumpulkan kuis.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Tetap di Kuis',
                style: TextStyle(
                  color: primaryColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Keluar',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    return keluar ?? false;
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final keluar = await _konfirmasiKeluar();

        if (keluar && mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F8FB),
        appBar: AppBar(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Kuis Teori',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: _buildTimer(),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildProgressHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSoalCard(soal),
                    const SizedBox(height: 20),
                    _buildPilihanJawaban(soal),
                    const SizedBox(height: 24),
                    _buildNavigasiSoal(),
                    const SizedBox(height: 20),
                    _buildNomorSoal(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomSubmit(),
      ),
    );
  }

  Widget _buildErrorPage() {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Kuis Teori',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.quiz_outlined,
                size: 70,
                color: Colors.grey,
              ),
              const SizedBox(height: 18),
              Text(
                _errorMsg!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Soal kuis resmi akan ditambahkan setelah tersedia.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimer() {
    final menit = _sisaDetik ~/ 60;
    final detik = _sisaDetik % 60;

    final waktuSedikit = _sisaDetik <= 60;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: waktuSedikit
            ? Colors.red.withOpacity(0.9)
            : Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.timer_outlined,
            size: 17,
            color: Colors.white,
          ),
          const SizedBox(width: 5),
          Text(
            '${menit.toString().padLeft(2, '0')}:'
            '${detik.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    final progress = (_currentIndex + 1) / _soalList.length;

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
              Text(
                '${_jawabanUser.length}/${_soalList.length} dijawab',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.3),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoalCard(SoalKuis soal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (soal.topik.trim().isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                soal.topik,
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
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
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          color: Colors.redAccent,
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Gambar soal tidak dapat dimuat.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            soal.pertanyaan,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPilihanJawaban(SoalKuis soal) {
    return Column(
      children: List.generate(
        soal.pilihan.length,
        (index) {
          final dipilih = _jawabanUser[_currentIndex] == index;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isSubmitting
                    ? null
                    : () {
                        _pilihJawaban(index);
                      },
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: dipilih
                        ? primaryColor.withOpacity(0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: dipilih
                          ? primaryColor
                          : Colors.grey.shade200,
                      width: dipilih ? 2 : 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 180,
                        ),
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: dipilih
                              ? primaryColor
                              : primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          String.fromCharCode(65 + index),
                          style: TextStyle(
                            color: dipilih
                                ? Colors.white
                                : primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Text(
                          soal.pilihan[index],
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.black87,
                            fontWeight: dipilih
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (dipilih)
                        const Icon(
                          Icons.check_circle,
                          color: primaryColor,
                          size: 22,
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

  Widget _buildNavigasiSoal() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _currentIndex > 0 && !_isSubmitting
                ? _soalSebelumnya
                : null,
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 18,
            ),
            label: const Text('Sebelumnya'),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: const BorderSide(
                color: primaryColor,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed:
                _currentIndex < _soalList.length - 1 &&
                        !_isSubmitting
                    ? _soalBerikutnya
                    : null,
            iconAlignment: IconAlignment.end,
            icon: const Icon(
              Icons.arrow_forward_rounded,
              size: 18,
            ),
            label: const Text('Berikutnya'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade500,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNomorSoal() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daftar Soal',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              _soalList.length,
              (index) {
                final aktif = index == _currentIndex;
                final sudahDijawab =
                    _jawabanUser.containsKey(index);

                Color backgroundColor = Colors.grey.shade100;
                Color foregroundColor = Colors.grey.shade700;
                Color borderColor = Colors.grey.shade200;

                if (sudahDijawab) {
                  backgroundColor =
                      primaryColor.withOpacity(0.12);
                  foregroundColor = primaryColor;
                  borderColor =
                      primaryColor.withOpacity(0.4);
                }

                if (aktif) {
                  backgroundColor = primaryColor;
                  foregroundColor = Colors.white;
                  borderColor = primaryColor;
                }

                return InkWell(
                  onTap: _isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: borderColor,
                      ),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: foregroundColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildLegend(
                color: primaryColor,
                text: 'Aktif',
              ),
              const SizedBox(width: 16),
              _buildLegend(
                color: primaryColor.withOpacity(0.12),
                text: 'Dijawab',
                borderColor: primaryColor.withOpacity(0.4),
              ),
              const SizedBox(width: 16),
              _buildLegend(
                color: Colors.grey.shade100,
                text: 'Belum',
                borderColor: Colors.grey.shade200,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend({
    required Color color,
    required String text,
    Color? borderColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: borderColor == null
                ? null
                : Border.all(
                    color: borderColor,
                  ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSubmit() {
    if (_isLoading || _errorMsg != null) {
      return const SizedBox.shrink();
    }

    final semuaDijawab =
        _jawabanUser.length == _soalList.length;

    return SafeArea(
      top: false,
      child: Container(
        color: const Color(0xFFF4F8FB),
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          20,
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSubmitting
                ? null
                : _konfirmasiSubmit,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.task_alt_rounded,
                    size: 20,
                  ),
            label: Text(
              _isSubmitting
                  ? 'Mengumpulkan...'
                  : semuaDijawab
                      ? 'Kumpulkan Kuis'
                      : 'Kumpulkan Kuis '
                          '(${_jawabanUser.length}/${_soalList.length})',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: primaryColor.withOpacity(0.5),
              disabledForegroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}