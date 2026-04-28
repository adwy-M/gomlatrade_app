import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'webview_screen.dart';
import 'offline_screen.dart';
import '../config/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
       vsync: this,
       duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    _animationController.forward();
    _checkConnectivityAndNavigate();
  }

  Future<void> _checkConnectivityAndNavigate() async {
    // Wait for the minimum splash duration
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final connectivityResult = await (Connectivity().checkConnectivity());
    bool isConnected = connectivityResult.contains(ConnectivityResult.mobile) ||
                       connectivityResult.contains(ConnectivityResult.wifi) ||
                       connectivityResult.contains(ConnectivityResult.ethernet);

    if (!mounted) return;

    if (isConnected) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WebviewScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OfflineScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shopping_bag_rounded,
                size: 100,
                color: AppTheme.primaryOrange,
              ),
              const SizedBox(height: 24),
              const Text(
                'Gomlatrade App',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
