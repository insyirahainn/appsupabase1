class Lokasi {
  final String id;
  final String namaLokasi;

  Lokasi({required this.id, required this.namaLokasi});

  factory Lokasi.fromJson(Map<String, dynamic> json) {
    return Lokasi(
      id: json['id'] as String,
      namaLokasi: json['nama_lokasi'] as String,
    );
  }
}