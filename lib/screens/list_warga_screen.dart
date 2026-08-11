import 'package:flutter/material.dart';
import '../models/warga.dart';
import '../services/warga_service.dart';
import 'form_warga_screen.dart';

class ListWargaScreen extends StatefulWidget {
  const ListWargaScreen({super.key});

  @override
  State<ListWargaScreen> createState() => _ListWargaScreenState();
}

class _ListWargaScreenState extends State<ListWargaScreen> {
  final WargaService _service = WargaService();
  late Future<List<Warga>> _futureWarga;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  void _muatData() {
    setState(() {
      _futureWarga = _service.getAllWarga();
    });
  }

  Future<void> _bukaForm({Warga? warga}) async {
    final hasilRefresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormWargaScreen(warga: warga)),
    );
    if (hasilRefresh == true) _muatData();
  }

  Future<void> _konfirmasiHapus (Warga warga) async {
    final konfirmasi = await showDialog<bool> (
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Data'),
        content: Text('Yakin ingin menghapus data ${warga.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop (ctx, true),
            child: const Text ('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      await _service.hapusWarga(warga.id!, warga.gambar);
      _muatData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Warga')),
      body: FutureBuilder<List<Warga>>(
        future: _futureWarga,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center (child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          final daftarWarga = snapshot.data ?? [];
          if (daftarWarga.isEmpty) {
            return const Center(child: Text('Belum ada data warga'));
          }

          return RefreshIndicator(
            onRefresh: () async => _muatData(),
            child: ListView.builder(
              itemCount: daftarWarga.length,
              itemBuilder: (context, index) {
                final warga = daftarWarga[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: warga.gambar != null
                        ? NetworkImage(warga.gambar!)
                        : null,
                      child: warga.gambar == null
                        ? const Icon(Icons.person)
                        : null,
                    ),
                    title: Text(warga.nama),
                    subtitle: Text(
                      '${warga.alamat}\n${warga.noTelp} . ${warga.lokasi?.namaLokasi ??  "-"}',
                    ),
                  isThreeLine: true,
                  trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue,),
                          onPressed: () => _bukaForm(warga: warga),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _konfirmasiHapus(warga),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _bukaForm(),
        child: const Icon (Icons.add),
      ),
    );
  }
}