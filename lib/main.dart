import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rws_app/src/widget/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: QuakeWatchApp()));
}

class QuakeWatchApp extends StatelessWidget {
  const QuakeWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuakeWatch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1018),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF72D6C2),
          brightness: Brightness.dark,
          surface: const Color(0xFF121B27),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF121B27),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFF263342)),
          ),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
