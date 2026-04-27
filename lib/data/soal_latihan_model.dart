class SoalLatihan {
  final String id;
  final String topikId; // TAMBAHAN
  final String topik;
  final String pertanyaan;
  final String satuan;
  final double jawabanBenar;
  final double toleransi;
  final String rumus;
  final String pembahasan;

  SoalLatihan({
    required this.id,
    required this.topikId,
    required this.topik,
    required this.pertanyaan,
    required this.satuan,
    required this.jawabanBenar,
    required this.toleransi,
    required this.rumus,
    required this.pembahasan,
  });

  factory SoalLatihan.fromJson(Map<String, dynamic> json) {
    return SoalLatihan(
      id: json['id'],
      topikId: json['topikId'], // TAMBAHAN
      topik: json['topik'],
      pertanyaan: json['pertanyaan'],
      satuan: json['satuan'],
      jawabanBenar: (json['jawabanBenar'] as num).toDouble(),
      toleransi: (json['toleransi'] as num).toDouble(),
      rumus: json['rumus'],
      pembahasan: json['pembahasan'],
    );
  }

  bool cekJawaban(double jawabanUser) {
    return (jawabanUser - jawabanBenar).abs() <= toleransi;
  }
}