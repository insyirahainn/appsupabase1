import 'lokasi.dart';

class Warga {
  final String? id;
  final String nama;
  final String alamat;
  final String noTelp;
  final String? gambar;
  final String? lokasiId;
  final Lokasi? lokasi;

  Warga({
    this.id,
    required this.nama,
    required this.alamat,
    required this.noTelp,
    this.gambar,
    this.lokasiId,
    this.lokasi,
  });

  factory Warga.fromJson(Map<String, dynamic> json) {
    return Warga(
      id: json['id'] as String?,
      nama: json['nama'] as String,
      alamat: json['alamat'] as String,
      noTelp: json['no_telp'] as String,
      gambar: json['gambar'] as String?,
      lokasiId: json['lokasi_id'] as String?,
      lokasi: json['lokasi'] != null 
        ? Lokasi.fromJson(json['lokasi'] as Map<String, dynamic>) : null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'alamat': alamat,
      'no_telp': noTelp,
      'gambar': gambar,
      'lokasi_id': lokasiId,
    };
  }
}