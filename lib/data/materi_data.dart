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
    pdfPath: "assets/pdf/Materi Kubus .pdf",
  ),
  Materi(
    id: "2",
    judul: "Balok",
    deskripsi: "Mempelajari struktur, luas permukaan, dan volume balok.",
    pdfPath: "assets/pdf/Materi Balok .pdf",
  ),
  Materi(
    id: "3",
    judul: "Prisma",
    deskripsi: "Mempelajari unsur, sifat, luas permukaan, dan volume prisma.",
    pdfPath: "assets/pdf/Materi Prisma .pdf",
  ),
  Materi(
    id: "4",
    judul: "Limas",
    deskripsi: "Mempelajari unsur, sifat, luas permukaan, dan volume limas.",
    pdfPath: "assets/pdf/Materi Limas.pdf",
  ),
  Materi(
    id: "5",
    judul: "Tabung",
    deskripsi: "Mempelajari unsur, luas permukaan, dan volume tabung.",
    pdfPath: "assets/pdf/Matematika_Pembelajaran-3.pdf",
  ),
  Materi(
    id: "6",
    judul: "Kerucut",
    deskripsi: "Mempelajari unsur, luas permukaan, dan volume kerucut.",
    pdfPath: "assets/pdf/Matematika_Pembelajaran-3.pdf",
  ),
  Materi(
    id: "7",
    judul: "Bola",
    deskripsi: "Mempelajari sifat, luas permukaan, dan volume bola.",
    pdfPath: "assets/pdf/Matematika_Pembelajaran-3.pdf",
  ),
];