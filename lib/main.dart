import 'package:flutter/material.dart';
import 'webview_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GomlatradeApp());
}

class GomlatradeApp extends StatelessWidget {
  const GomlatradeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gomlatrade App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF7941D), // Assuming Orange primary
          primary: const Color(0xFFF7941D),
          secondary: const Color(0xFF0A58CA), // Assuming Blue secondary
        ),
        useMaterial3: true,
      ),
      home: const WebviewScreen(),
    );
  }
}
