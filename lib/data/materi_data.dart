class Materi {
  final String id;
  final String judul;
  final String deskripsi;
  final String pdfPath;

  Materi({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.pdfPath,
  });
}

final List<Materi> daftarMateri = [
  Materi(
    id: "1",
    judul: "Kubus",
    deskripsi: "Mengenal sifat, luas permukaan, dan volume kubus.",
    pdfPath: "assets/pdf/Matematika_Pembelajaran-3.pdf",
  ),
  Materi(
    id: "2",
    judul: "Balok",
    deskripsi: "Mempelajari struktur balok dan rumusnya.",
    pdfPath: "assets/pdf/Matematika_Pembelajaran-3.pdf",
  ),
];