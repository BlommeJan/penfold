import 'package:flutter/material.dart';

import 'screens/app_home.dart';
import 'services/spen_button_service.dart';
import 'services/stroke_smoothing_service.dart';
import 'services/toolbar_order_service.dart';

const _kPenfoldBlue = Color(0xFF2455C3);
const _kPenfoldBlueLight = Color(0xFF3D6FD4);
const _kPenfoldAccent = Color(0xFFE8A317);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ToolbarOrderService.instance.load();
  StrokeSmoothingService.instance.load();
  SpenButtonService.instance.load();
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
          seedColor: _kPenfoldBlue,
          brightness: Brightness.light,
          primary: _kPenfoldBlue,
          secondary: _kPenfoldBlueLight,
          tertiary: _kPenfoldAccent,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F7F9),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0.5,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1A1A1A),
        ),
        chipTheme: ChipThemeData(
          selectedColor: _kPenfoldBlue.withOpacity(0.14),
          checkmarkColor: _kPenfoldBlue,
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          side: const BorderSide(color: Color(0xFFE0E4EA)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _kPenfoldBlue,
            foregroundColor: Colors.white,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _kPenfoldBlue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const AppHome(),
    );
  }
}
