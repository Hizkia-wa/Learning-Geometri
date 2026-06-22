import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/soal_kuis_model.dart';
import 'kuis_result_page.dart';

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
  List<int?> _userAnswers = [];
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _isLoading = true;
  String? _errorMsg;

  late Timer _timer;
  int _detikTersisa = 600;

  @override
  void initState() {
    super.initState();
    _loadSoal();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadSoal() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/kuis_teori.json');
      final List<dynamic> data = jsonDecode(jsonStr);
      final semua = data.map((e) => SoalKuis.fromJson(e)).toList();

      final filtered = semua.where((s) => s.topikId == widget.topikId).toList();
      filtered.shuffle();

      if (filtered.isEmpty) {
        setState(() {
          _errorMsg = 'Belum ada soal untuk topik ini.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _soalList = filtered;
        _userAnswers = List<int?>.filled(filtered.length, null);
        _isLoading = false;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_detikTersisa > 0) {
            _detikTersisa--;
          } else {
            _timer.cancel();
            _selesai();
          }
        });
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Gagal load soal.';
        _isLoading = false;
      });
    }
  }

  void _pilihJawaban(int index) {
    if (_userAnswers[_currentIndex] != null) return;
    setState(() {
      _selectedIndex = index;
      _userAnswers[_currentIndex] = index;
    });
  }

  void _soalBerikutnya() {
    if (_currentIndex < _soalList.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = _userAnswers[_currentIndex];
      });
    } else {
      _selesai();
    }
  }

  void _selesai() {
    _timer.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => KuisResultPage(
          semuaSoal: _soalList,
          userAnswers: _userAnswers,
          namaTopik: widget.namaTopik,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_errorMsg != null)
      return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          title: Text(widget.namaTopik),
          centerTitle: true,
        ),
        body: Center(child: Text(_errorMsg!, style: const TextStyle(color: Colors.grey))),
      );

    final soal = _soalList[_currentIndex];
    final progress = (_currentIndex + 1) / _soalList.length;
    final menit = _detikTersisa ~/ 60;
    final detik = _detikTersisa % 60;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Kuis ${widget.namaTopik} - $menit:$detik'),
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
                    Text('Soal ${_currentIndex + 1} dari ${_soalList.length}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        soal.topik,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      soal.pertanyaan,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(soal.pilihan.length, (i) => _buildPilihan(i, soal.pilihan[i])),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          if (_userAnswers[_currentIndex] != null)
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentIndex < _soalList.length - 1 ? 'Soal Berikutnya →' : 'Submit Kuis',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPilihan(int index, String teks) {
    final isSelected = _userAnswers[_currentIndex] == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _pilihJawaban(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade200, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: (isSelected ? Colors.blue : Colors.grey.shade200).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.blue : Colors.grey),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(teks, style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}