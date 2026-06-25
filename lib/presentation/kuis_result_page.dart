import 'package:flutter/material.dart';

import '../data/soal_kuis_model.dart';
import '../services/activity_service.dart';
import 'ai_solution_page.dart';
import 'kuis_teori_page.dart';

class KuisResultPage extends StatefulWidget {
  final List<SoalKuis> semuaSoal;
  final List<int?> userAnswers;
  final String namaTopik;

  const KuisResultPage({
    super.key,
    required this.semuaSoal,
    required this.userAnswers,
    required this.namaTopik,
  });

  @override
  State<KuisResultPage> createState() => _KuisResultPageState();
}

class _KuisResultPageState extends State<KuisResultPage> {
  static const Color primaryColor = Color(0xFF17AEBF);

  int get _skorBenar {
    int benar = 0;
    for (int i = 0; i < widget.semuaSoal.length; i++) {
      if (widget.userAnswers[i] == widget.semuaSoal[i].jawabanIndex) {
        benar++;
      }
    }
    return benar;
  }

  @override
  void initState() {
    super.initState();
    _saveActivity();
  }

  Future<void> _saveActivity() async {
    if (widget.semuaSoal.isEmpty) return;

    final persen = ((_skorBenar / widget.semuaSoal.length) * 100).round();

    await ActivityService.addActivity(
      title: 'Kuis Teori ${widget.namaTopik}',
      subtitle: 'Selesai • Skor $persen% ($_skorBenar/${widget.semuaSoal.length} benar)',
      type: 'kuis',
    );
  }

  @override
  Widget build(BuildContext context) {
    final persen = widget.semuaSoal.isEmpty
        ? 0
        : ((_skorBenar / widget.semuaSoal.length) * 100).round();
    final lulus = persen >= 70;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        title: const Text(
          'Hasil Kuis',
          style: TextStyle(fontWeight: FontWeight.bold),
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
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                children: [
                  _buildScoreCard(persen, lulus),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatCard(
                        value: '$_skorBenar',
                        label: 'Benar',
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(width: 10),
                      _buildStatCard(
                        value: '${widget.semuaSoal.length - _skorBenar}',
                        label: 'Salah',
                        color: Colors.red.shade600,
                      ),
                      const SizedBox(width: 10),
                      _buildStatCard(
                        value: '${widget.semuaSoal.length}',
                        label: 'Soal',
                        color: primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
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
                    'Tap salah satu soal untuk melihat jawaban dan pembahasan.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...List.generate(widget.semuaSoal.length, (index) {
                    final soal = widget.semuaSoal[index];
                    final jawabanUser = widget.userAnswers[index];
                    final benar = jawabanUser == soal.jawabanIndex;

                    return _buildReviewCard(
                      context: context,
                      index: index,
                      soal: soal,
                      jawabanUser: jawabanUser,
                      benar: benar,
                    );
                  }),
                ],
              ),
            ),
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(int persen, bool lulus) {
    final color = lulus ? Colors.green.shade600 : Colors.red.shade500;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              color: color.withValues(alpha: 0.1),
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
            '$_skorBenar dari ${widget.semuaSoal.length} soal benar',
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
                ? 'Pemahamanmu pada materi ${widget.namaTopik} sudah baik.'
                : 'Pelajari kembali pembahasan soal yang masih salah.',
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
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
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
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
    final statusColor =
        benar ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.22),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
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
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                benar ? Icons.check_rounded : Icons.close_rounded,
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
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
    final jawabanUserText =
        jawabanUser != null ? soal.pilihan[jawabanUser] : 'Tidak dijawab';
    final jawabanBenarText = soal.pilihan[soal.jawabanIndex];
    final statusColor =
        benar ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          benar ? Icons.check_rounded : Icons.close_rounded,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          benar ? 'Jawaban Benar' : 'Jawaban Salah',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Soal ${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
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
                    color: benar ? Colors.green : Colors.red,
                    strike: !benar,
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
                          soal.pembahasan,
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
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);

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
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: const Text('Lihat Pembahasan AI'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
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
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
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
              decoration: strike ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FB),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: widget.semuaSoal.isEmpty
                  ? null
                  : () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => KuisTeoriPage(
                            topikId: widget.semuaSoal.first.topikId,
                            namaTopik: widget.namaTopik,
                          ),
                        ),
                      );
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: const BorderSide(color: primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Ulangi Kuis',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Ke Beranda',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}