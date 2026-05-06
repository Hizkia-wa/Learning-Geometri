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
  Materi(
    id: "3",
    judul: "Tabung",
    deskripsi: "Bangun ruang dengan dua lingkaran sebagai alas dan tutup.",
    pdfPath: "assets/pdf/Matematika_Pembelajaran-3.pdf",
  ),
  Materi(
    id: "4",
    judul: "Kerucut",
    deskripsi: "Bangun ruang dengan alas lingkaran dan puncak runcing.",
    pdfPath: "assets/pdf/Matematika_Pembelajaran-3.pdf",
  ),
  Materi(
    id: "5",
    judul: "Bola",
    deskripsi: "Bangun ruang sempurna dengan semua titik pada permukaan sama jarak dari pusat.",
    pdfPath: "assets/pdf/Matematika_Pembelajaran-3.pdf",
  ),
];