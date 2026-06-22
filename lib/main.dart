import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import file dashboard
import 'presentation/dashboard.dart';

Future<void> main() async {
  // Pastikan binding diinisialisasi sebelum memanggil plugin (dotenv/SystemChrome)
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // Jika .env tidak ikut ter-bundle, aplikasi tetap lanjut jalan.
  }

  // Konfigurasi Status Bar (Jam & Baterai) agar transparan
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Learning Geometri',
      
      // Konfigurasi Tema
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'sans-serif',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF17AEBF),
          primary: const Color(0xFF17AEBF),
        ),
      ),

      // Navigasi
      initialRoute: '/',
      routes: {
        '/': (context) => const Dashboard(),
      },
    );
  }
}