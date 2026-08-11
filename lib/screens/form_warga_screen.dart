import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/warga.dart';
import '../models/lokasi.dart';
import '../services/warga_service.dart';

class FormWargaScreen extends StatefulWidget {
  final Warga? warga; // null = mode tambah, ada isinya = mode edit

  const FormWargaScreen({super.key, this.warga});

  @override
  State<FormWargaScreen> createState() => _FormWargaScreenState();
}

class _FormWargaScreenState extends State<FormWargaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noTelpController = TextEditingController();

  final WargaService _service = WargaService();
  final ImagePicker _picker = ImagePicker();

  Uint8List?
   _gambarBaruBytes;
   String? _namaFileAsli;
   bool _isLoading = false;
   bool _isLoadingLokasi = true;

  List<Lokasi> _daftarLokasi = [];
  String? _lokasiIdTerpilih;

  bool get _isEdit => widget.warga != null;

  @override
  void initState() {
    super.initState();
    if(_isEdit) {
      _namaController.text = widget.warga!.nama;
      _alamatController.text = widget.warga!.alamat;
      _noTelpController.text = widget.warga!.noTelp;
      _lokasiIdTerpilih = widget.warga!.lokasiId;
    }
    _muatLokasi();
  }

  Future<void> _muatLokasi() async {
    final daftar = await _service.getAllLokasi();
    setState(() {
      _daftarLokasi = daftar;
      _isLoadingLokasi = false;
    });
  }

  Future<void> _pilihGambar() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _gambarBaruBytes = bytes;
        _namaFileAsli = file.name;
      });
    }
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isEdit) {
        await _service.updateWarga(
          id: widget.warga!.id!,
          nama: _namaController.text,
          alamat: _alamatController.text,
          noTelp: _noTelpController.text,
          lokasiId: _lokasiIdTerpilih,
          gambarBytesBaru: _gambarBaruBytes,
          namaFileAsli: _namaFileAsli,
          gambarLama: widget.warga!.gambar,
        );
      } else {
        await _service.tambahWarga(
          nama: _namaController.text,
          alamat: _alamatController.text,
          noTelp: _noTelpController.text,
          lokasiId: _lokasiIdTerpilih,
          gambarBytes: _gambarBaruBytes,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e'),),);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Warga' : 'Tambah Warga')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form (
          key: _formKey,
          child: ListView (
            children: [
              // Preview gambar
              GestureDetector(
                onTap: _pilihGambar,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _gambarBaruBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        _gambarBaruBytes!,
                        fit: BoxFit.cover,
                      ),
                    )
                : (_isEdit && widget.warga!.gambar != null)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.warga!.gambar!,
                        fit: BoxFit.cover,
                      ),
                    )
                : const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_a_photo, size: 40),
                        SizedBox(height: 8),
                        Text('Ketuk untuk pilih gambar'),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => 
                  (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _noTelpController,
                decoration: const InputDecoration(
                  labelText: 'No. Telepon',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                  (v == null || v.isEmpty) ? 'No. Telepon wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              _isLoadingLokasi
              ? const Center (child: CircularProgressIndicator())
              : DropdownButtonFormField<String>(
                value: _lokasiIdTerpilih,
                // initialValue: _lokasiIdTerpilih,
                decoration: const InputDecoration(
                  labelText: 'Lokasi',
                  border: OutlineInputBorder(),
                ),
                items: _daftarLokasi.map((lokasi) {
                    return DropdownMenuItem(
                      value: lokasi.id,
                      child: Text(lokasi.namaLokasi),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _lokasiIdTerpilih = value);
                },
                validator: (v) =>
                  (v == null) ? 'Lokasi wajib dipilih' : null,
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _simpan,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text ('Simpan'),
              ),
            ],
          ),
        )
      ),
    );
  }
  

}