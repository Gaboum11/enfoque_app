import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/home_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const EnfoqueApp());
}

class EnfoqueApp extends StatelessWidget {
  const EnfoqueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enfoque App - Productividad Estudiantil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF9F9FE),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3227C9),
          primary: const Color(0xFF3227C9),
          surface: Colors.white,
        ),
        fontFamily: 'Roboto',
      ),
      home: const HomeNavigationScreen(),
    );
  }
}
