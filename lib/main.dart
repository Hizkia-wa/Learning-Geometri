import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'presentation/dashboard.dart'; // Import file dashboardmu

void main() {
  // Mengatur agar status bar (jam & baterai) transparan di atas header biru
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
      theme: ThemeData(
        // Menggunakan palet warna yang kamu berikan
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF17AEBF),
          primary: const Color(0xFF17AEBF),
        ),
        useMaterial3: true,
        fontFamily: 'sans-serif', // Gunakan font bawaan yang bersih
      ),
      home: const Dashboard(),
    );
  }
}