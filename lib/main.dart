import 'package:appsupabase1/screens/list_warga_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ayjvzsvgmwmqxhoszjiw.supabase.co',
    anonKey: 'sb_publishable_4zFqCFfSfUdndfX-X2hx2Q_A-j_l3by',
    // anonKey: 'API KEY',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD Warga - Supabase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ListWargaScreen(),
    );
  }
}
