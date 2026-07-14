import 'package:flutter/material.dart';

import 'screens/library_screen.dart';

void main() {
  runApp(const PenfoldApp());
}

class PenfoldApp extends StatelessWidget {
  const PenfoldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Penfold',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2455C3),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F7F9),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0.5,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1A1A1A),
        ),
      ),
      home: const LibraryScreen(),
    );
  }
}
