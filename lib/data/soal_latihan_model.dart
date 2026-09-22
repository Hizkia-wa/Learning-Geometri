class SoalLatihan {
  final String id;
  final String topikId;
  final String topik;
  final String tipe;
  final String pertanyaan;
  final String satuan;
  final double? jawabanBenar;
  final double toleransi;
  final List<String> pilihan;
  final int? jawabanIndex;
  final String rumus;
  final String pembahasan;
  final String? imagePath;
  final String? solutionImagePath;

  const SoalLatihan({
    required this.id,
    required this.topikId,
    required this.topik,
    required this.tipe,
    required this.pertanyaan,
    required this.satuan,
    required this.jawabanBenar,
    required this.toleransi,
    required this.pilihan,
    required this.jawabanIndex,
    required this.rumus,
    required this.pembahasan,
    this.imagePath,
    this.solutionImagePath,
  });

  factory SoalLatihan.fromJson(Map<String, dynamic> json) {
    return SoalLatihan(
      id: json['id']?.toString() ?? '',
      topikId: json['topikId']?.toString() ?? '',
      topik: json['topik']?.toString() ?? '',
      tipe: json['tipe']?.toString() ?? 'numerik',
      pertanyaan: json['pertanyaan']?.toString() ?? '',
      satuan: json['satuan']?.toString() ?? '',
      jawabanBenar: json['jawabanBenar'] == null
          ? null
          : (json['jawabanBenar'] as num).toDouble(),
      toleransi: json['toleransi'] == null
          ? 0.1
          : (json['toleransi'] as num).toDouble(),
      pilihan: json['pilihan'] == null
          ? []
          : List<String>.from(
              (json['pilihan'] as List).map(
                (item) => item.toString(),
              ),
            ),
      jawabanIndex: json['jawabanIndex'] == null
          ? null
          : (json['jawabanIndex'] as num).toInt(),
      rumus: json['rumus']?.toString() ?? '',
      pembahasan: json['pembahasan']?.toString() ?? '',
      imagePath: json['imagePath']?.toString(),
      solutionImagePath: json['solutionImagePath']?.toString(),
    );
  }

  bool cekJawabanNumerik(double jawabanUser) {
    if (!isNumerik || jawabanBenar == null) {
      return false;
    }

    return (jawabanUser - jawabanBenar!).abs() <= toleransi;
  }

  bool cekJawabanPilihanGanda(int pilihanIndex) {
    if (!isPilihanGanda || jawabanIndex == null) {
      return false;
    }

    return pilihanIndex == jawabanIndex;
  }

  bool get isNumerik => tipe == 'numerik';

  bool get isPilihanGanda => tipe == 'pilihan_ganda';

  bool get memilikiGambar =>
      imagePath != null && imagePath!.trim().isNotEmpty;

  bool get memilikiGambarPembahasan =>
      solutionImagePath != null &&
      solutionImagePath!.trim().isNotEmpty;
}