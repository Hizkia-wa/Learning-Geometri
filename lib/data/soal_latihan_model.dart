class SoalLatihan {
  final String id;
  final String topikId;
  final String topik;
  final String pertanyaan;
  final String satuan;
  final double jawabanBenar;
  final double toleransi;
  final String rumus;
  final String pembahasan;

  // Gambar bersifat opsional.
  // Digunakan untuk soal latihan yang bergantung pada ilustrasi/gambar.
  final String? imagePath;

  const SoalLatihan({
    required this.id,
    required this.topikId,
    required this.topik,
    required this.pertanyaan,
    required this.satuan,
    required this.jawabanBenar,
    required this.toleransi,
    required this.rumus,
    required this.pembahasan,
    this.imagePath,
  });

  factory SoalLatihan.fromJson(Map<String, dynamic> json) {
    return SoalLatihan(
      id: json['id']?.toString() ?? '',
      topikId: json['topikId']?.toString() ?? '',
      topik: json['topik']?.toString() ?? '',
      pertanyaan: json['pertanyaan']?.toString() ?? '',
      satuan: json['satuan']?.toString() ?? '',
      jawabanBenar: (json['jawabanBenar'] as num).toDouble(),
      toleransi: (json['toleransi'] as num).toDouble(),
      rumus: json['rumus']?.toString() ?? '',
      pembahasan: json['pembahasan']?.toString() ?? '',
      imagePath: json['imagePath']?.toString(),
    );
  }

  bool cekJawaban(double jawabanUser) {
    return (jawabanUser - jawabanBenar).abs() <= toleransi;
  }

  bool get memilikiGambar {
    return imagePath != null && imagePath!.trim().isNotEmpty;
  }
}