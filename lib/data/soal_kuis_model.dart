class SoalKuis {
  final String id;
  final String topikId; // TAMBAHAN — untuk filter per topik
  final String topik;
  final String pertanyaan;
  final List<String> pilihan;
  final int jawabanIndex;
  final String pembahasan;

  SoalKuis({
    required this.id,
    required this.topikId,
    required this.topik,
    required this.pertanyaan,
    required this.pilihan,
    required this.jawabanIndex,
    required this.pembahasan,
  });

  factory SoalKuis.fromJson(Map<String, dynamic> json) {
    return SoalKuis(
      id: json['id'],
      topikId: json['topikId'], // TAMBAHAN
      topik: json['topik'],
      pertanyaan: json['pertanyaan'],
      pilihan: List<String>.from(json['pilihan']),
      jawabanIndex: json['jawabanIndex'],
      pembahasan: json['pembahasan'],
    );
  }
}