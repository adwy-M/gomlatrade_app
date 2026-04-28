import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1E1E24), // AppTheme.cardDark
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const GomlatradeApp());
}

class GomlatradeApp extends StatelessWidget {
  const GomlatradeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GomlaTrade',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
