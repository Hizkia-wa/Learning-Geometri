class Materi {
  final String id;
  final String judul;
  final String deskripsi;
  final String isi;
  final String gambar;

  Materi({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.isi,
    required this.gambar,
  });
}

final List<Materi> daftarMateri = [
  Materi(
    id: "1",
    judul: "Kubus",
    deskripsi: "Mengenal sifat, luas permukaan, dan volume kubus.",
    isi: "Kubus adalah bangun ruang tiga dimensi yang dibatasi oleh enam bidang sisi yang kongruen berbentuk bujur sangkar...",
    gambar: "assets/images/kubus.png",
  ),
  Materi(
    id: "2",
    judul: "Balok",
    deskripsi: "Mempelajari struktur balok dan rumusnya.",
    isi: "Balok adalah bangun ruang tiga dimensi yang dibentuk oleh tiga pasang persegi atau persegi panjang...",
    gambar: "assets/images/balok.png",
  ),
  // Tambahkan materi lainnya di sini
];