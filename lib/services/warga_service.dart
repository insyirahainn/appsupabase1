import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/warga.dart';
import '../models/lokasi.dart';

class WargaService {
  final SupabaseClient _supabase = Supabase.instance.client;

  final String _tableName = 'warga';
  final String _bucketName = 'foto-warga';

  // CREATE
  Future<void> tambahWarga({
    required String nama,
    required String alamat,
    required String noTelp,
    String? lokasiId,
    Uint8List? gambarBytes,
    String? namaFileAsli,
  }) async {
    String? urlGambar;

    if (gambarBytes != null) {
      urlGambar = await _uploadGambar(
        gambarBytes,
        namaFileAsli ?? 'foto.jpg',
      );
    }

    await _supabase.from(_tableName).insert({
      'nama': nama,
      'alamat': alamat,
      'no_telp': noTelp,
      'gambar': urlGambar,
      'lokasi_id': lokasiId,
    });
  }

  // READ
  Future<List<Warga>> getAllWarga() async {
    final response = await _supabase
        .from(_tableName)
        .select('*, lokasi(*)')
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => Warga.fromJson(item))
        .toList();
  }

  // Ambil semua lokasi
  Future<List<Lokasi>> getAllLokasi() async {
    final response = await _supabase
        .from('lokasi')
        .select()
        .order('nama_lokasi');

    return (response as List)
        .map((item) => Lokasi.fromJson(item))
        .toList();
  }

  // UPDATE
  Future<void> updateWarga({
    required String id,
    required String nama,
    required String alamat,
    required String noTelp,
    String? lokasiId,
    Uint8List? gambarBytesBaru,
    String? namaFileAsli,
    String? gambarLama,
  }) async {
    String? urlGambar = gambarLama;

    if (gambarBytesBaru != null) {
      urlGambar = await _uploadGambar(
        gambarBytesBaru,
        namaFileAsli ?? 'foto.jpg',
      );

      if (gambarLama != null) {
        await _hapusGambar(gambarLama);
      }
    }

    await _supabase.from(_tableName).update({
      'nama': nama,
      'alamat': alamat,
      'no_telp': noTelp,
      'gambar': urlGambar,
      'lokasi_id': lokasiId,
    }).eq('id', id);
  }

  // DELETE
  Future<void> hapusWarga(String id, String? gambarUrl) async {
    await _supabase.from(_tableName).delete().eq('id', id);

    if (gambarUrl != null) {
      await _hapusGambar(gambarUrl);
    }
  }

  // HELPER upload gambar
  Future<String> _uploadGambar(
    Uint8List bytes,
    String namaFileAsli,
  ) async {
    final namaFile =
        '${DateTime.now().millisecondsSinceEpoch}_$namaFileAsli';

    await _supabase.storage.from(_bucketName).uploadBinary(
      namaFile,
      bytes,
      fileOptions: const FileOptions(upsert: true),
    );

    return _supabase.storage.from(_bucketName).getPublicUrl(namaFile);
  }

  // HELPER hapus gambar
  Future<void> _hapusGambar(String url) async {
    try {
      final namaFile = url.split('/$_bucketName/').last;

      await _supabase.storage.from(_bucketName).remove([namaFile]);
    } catch (e) {
      print('Gagal hapus gambar lama: $e');
    }
  }
}