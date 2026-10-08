class SoalKuis {
  final String id;
  final String topikId;
  final String topik;
  final String pertanyaan;
  final List<String> pilihan;
  final int jawabanIndex;
  final String pembahasan;
  final String? imagePath;

  const SoalKuis({
    required this.id,
    required this.topikId,
    required this.topik,
    required this.pertanyaan,
    required this.pilihan,
    required this.jawabanIndex,
    required this.pembahasan,
    this.imagePath,
  });

  factory SoalKuis.fromJson(Map<String, dynamic> json) {
    return SoalKuis(
      id: json['id']?.toString() ?? '',
      topikId: json['topikId']?.toString() ?? '',
      topik: json['topik']?.toString() ?? '',
      pertanyaan: json['pertanyaan']?.toString() ?? '',
      pilihan: List<String>.from(
        (json['pilihan'] ?? []).map(
          (item) => item.toString(),
        ),
      ),
      jawabanIndex: json['jawabanIndex'] is int
          ? json['jawabanIndex']
          : int.tryParse(
                json['jawabanIndex']?.toString() ?? '',
              ) ??
              0,
      pembahasan: json['pembahasan']?.toString() ?? '',
      imagePath: json['imagePath']?.toString(),
    );
  }

  bool get memilikiGambar =>
      imagePath != null && imagePath!.trim().isNotEmpty;
}