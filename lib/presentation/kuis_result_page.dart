import 'package:flutter/material.dart';

import '../data/soal_kuis_model.dart';
import '../services/activity_service.dart';
import 'ai_solution_page.dart';
import 'kuis_teori_page.dart';

class KuisResultPage extends StatefulWidget {
  final int skorBenar;
  final int totalSoal;
  final List<SoalKuis> soalList;
  final Map<int, int> jawabanUser;
  final bool waktuHabis;

  const KuisResultPage({
    super.key,
    required this.skorBenar,
    required this.totalSoal,
    required this.soalList,
    required this.jawabanUser,
    this.waktuHabis = false,
  });

  @override
  State<KuisResultPage> createState() => _KuisResultPageState();
}

class _KuisResultPageState extends State<KuisResultPage> {
  static const Color primaryColor = Color(0xFF17AEBF);

  @override
  void initState() {
    super.initState();
    _saveActivity();
  }

  Future<void> _saveActivity() async {
    if (widget.totalSoal == 0) return;

    final persen =
        (widget.skorBenar / widget.totalSoal * 100).round();

    await ActivityService.addActivity(
      title: 'Kuis Teori',
      subtitle:
          'Selesai • Skor $persen% '
          '(${widget.skorBenar}/${widget.totalSoal} benar)',
      type: 'kuis',
    );
  }

  int get _jumlahTidakDijawab {
    return widget.totalSoal - widget.jawabanUser.length;
  }

  int get _jumlahSalah {
    return widget.totalSoal -
        widget.skorBenar -
        _jumlahTidakDijawab;
  }

  @override
  Widget build(BuildContext context) {
    final persen = widget.totalSoal == 0
        ? 0
        : (widget.skorBenar / widget.totalSoal * 100).round();

    final lulus = persen >= 70;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        title: const Text(
          'Hasil Kuis',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF4F8FB),
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  20,
                ),
                children: [
                  if (widget.waktuHabis) ...[
                    _buildWaktuHabisCard(),
                    const SizedBox(height: 16),
                  ],
                  _buildScoreCard(
                    persen,
                    lulus,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatCard(
                        value: '${widget.skorBenar}',
                        label: 'Benar',
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(width: 8),
                      _buildStatCard(
                        value: '$_jumlahSalah',
                        label: 'Salah',
                        color: Colors.red.shade600,
                      ),
                      const SizedBox(width: 8),
                      _buildStatCard(
                        value: '$_jumlahTidakDijawab',
                        label: 'Kosong',
                        color: Colors.orange.shade600,
                      ),
                      const SizedBox(width: 8),
                      _buildStatCard(
                        value: '${widget.totalSoal}',
                        label: 'Soal',
                        color: primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Review Jawaban',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pilih salah satu soal untuk melihat '
                    'jawaban dan pembahasannya.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...List.generate(
                    widget.soalList.length,
                    (index) {
                      final soal = widget.soalList[index];
                      final jawabanUser =
                          widget.jawabanUser[index];

                      final benar = jawabanUser != null &&
                          jawabanUser == soal.jawabanIndex;

                      return _buildReviewCard(
                        context: context,
                        index: index,
                        soal: soal,
                        jawabanUser: jawabanUser,
                        benar: benar,
                      );
                    },
                  ),
                ],
              ),
            ),
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWaktuHabisCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer_off_outlined,
            color: Colors.orange.shade700,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Waktu kuis telah habis. Jawaban yang sudah '
              'dipilih dikumpulkan secara otomatis.',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(
    int persen,
    bool lulus,
  ) {
    final color = lulus
        ? Colors.green.shade600
        : Colors.red.shade500;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 28,
        horizontal: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
            ),
            child: Center(
              child: Text(
                '$persen%',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${widget.skorBenar} dari '
            '${widget.totalSoal} soal benar',
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lulus ? 'Selamat! 🎉' : 'Coba Lagi!',
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            lulus
                ? 'Hasil Kuis Teorimu sudah baik.'
                : 'Pelajari kembali pembahasan '
                    'pada soal yang masih salah.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard({
    required BuildContext context,
    required int index,
    required SoalKuis soal,
    required int? jawabanUser,
    required bool benar,
  }) {
    final tidakDijawab = jawabanUser == null;

    final statusColor = tidakDijawab
        ? Colors.orange.shade700
        : benar
            ? const Color(0xFF16A34A)
            : const Color(0xFFDC2626);

    final statusIcon = tidakDijawab
        ? Icons.remove_rounded
        : benar
            ? Icons.check_rounded
            : Icons.close_rounded;

    return GestureDetector(
      onTap: () {
        _showPembahasanModal(
          context: context,
          index: index,
          soal: soal,
          jawabanUser: jawabanUser,
          benar: benar,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 12,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: statusColor.withOpacity(0.22),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                statusIcon,
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (soal.topik.trim().isNotEmpty) ...[
                    Text(
                      soal.topik,
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                  ],
                  Text(
                    'Soal ${index + 1}: ${soal.pertanyaan}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_right_rounded,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _showPembahasanModal({
    required BuildContext context,
    required int index,
    required SoalKuis soal,
    required int? jawabanUser,
    required bool benar,
  }) {
    final tidakDijawab = jawabanUser == null;

    final jawabanUserText = tidakDijawab
        ? 'Tidak dijawab'
        : _formatPilihan(
            jawabanUser,
            soal.pilihan[jawabanUser],
          );

    final jawabanBenarText = _formatPilihan(
      soal.jawabanIndex,
      soal.pilihan[soal.jawabanIndex],
    );

    final statusColor = tidakDijawab
        ? Colors.orange.shade700
        : benar
            ? const Color(0xFF16A34A)
            : const Color(0xFFDC2626);

    final statusText = tidakDijawab
        ? 'Tidak Dijawab'
        : benar
            ? 'Jawaban Benar'
            : 'Jawaban Salah';

    final statusIcon = tidakDijawab
        ? Icons.remove_rounded
        : benar
            ? Icons.check_rounded
            : Icons.close_rounded;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.45,
          maxChildSize: 0.94,
          builder: (
            context,
            scrollController,
          ) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  24,
                ),
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          statusIcon,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
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
                    const SizedBox(height: 12),
                  ],
                  Text(
                    'Soal ${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
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
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.redAccent,
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Gambar soal tidak dapat dimuat.',
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
                    const SizedBox(height: 14),
                  ],
                  Text(
                    soal.pertanyaan,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildAnswerBox(
                    title: 'Jawabanmu',
                    value: jawabanUserText,
                    color: tidakDijawab
                        ? Colors.orange
                        : benar
                            ? Colors.green
                            : Colors.red,
                    strike: !benar && !tidakDijawab,
                  ),
                  if (!benar) ...[
                    const SizedBox(height: 10),
                    _buildAnswerBox(
                      title: 'Jawaban benar',
                      value: jawabanBenarText,
                      color: Colors.green,
                      strike: false,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: const Border(
                        left: BorderSide(
                          color: primaryColor,
                          width: 4,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pembahasan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          soal.pembahasan.trim().isEmpty
                              ? 'Pembahasan belum tersedia.'
                              : soal.pembahasan,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4B5563),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AiSolutionPage(
                              topik: soal.topik,
                              pertanyaan: soal.pertanyaan,
                              jawabanBenar: jawabanBenarText,
                              jawabanPengguna: jawabanUserText,
                              jawabanBenarFlag: benar,
                              pembahasanAsli: soal.pembahasan,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.auto_awesome_rounded,
                      ),
                      label: const Text(
                        'Lihat Pembahasan AI',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnswerBox({
    required String title,
    required String value,
    required Color color,
    required bool strike,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: color.withOpacity(0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
              decoration:
                  strike ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FB),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const KuisTeoriPage(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: const BorderSide(
                  color: primaryColor,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Ulangi Kuis',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.popUntil(
                  context,
                  ModalRoute.withName('/'),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Ke Beranda',
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

  String _formatPilihan(
    int index,
    String jawaban,
  ) {
    final huruf = String.fromCharCode(65 + index);
    return '$huruf. $jawaban';
  }
}