class DetailMateri {
  final String id;
  final String idMateri; // Referensi ke ID di materi_data.dart
  final String rumus;
  final String luasPermukaan;
  final String volume;
  final String contohSoal;
  final List<String> sifatSifat;

  DetailMateri({
    required this.id,
    required this.idMateri,
    required this.rumus,
    required this.luasPermukaan,
    required this.volume,
    required this.contohSoal,
    required this.sifatSifat,
  });
}

final List<DetailMateri> daftarDetailMateri = [
  DetailMateri(
    id: "101",
    idMateri: "1", // Merujuk ke Kubus
    rumus: "V = s x s x s",
    luasPermukaan: "L = 6 x s²",
    volume: "Sisi pangkat tiga",
    contohSoal: "Jika s = 2, maka V = 2³ = 8",
    sifatSifat: ["6 Sisi", "12 Rusuk", "8 Titik Sudut"],
  ),
  DetailMateri(
    id: "102",
    idMateri: "2", // Merujuk ke Balok
    rumus: "V = p x l x t",
    luasPermukaan: "L = 2 x (pl + pt + lt)",
    volume: "Panjang x Lebar x Tinggi",
    contohSoal: "Jika p=2, l=3, t=4, maka V = 24",
    sifatSifat: ["Sisi berhadapan sama", "12 Rusuk", "8 Titik Sudut"],
  ),
];
