import 'package:flutter/material.dart';
import 'package:sudoku/features/menu/screens/main_menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule navigation after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainMenuScreen()),
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache the Main Menu icon so it appears instantly
    precacheImage(const AssetImage('assets/icon/app_icon.png'), context);
    precacheImage(
      const AssetImage('assets/splash/splash_branding.png'),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use the App Icon which we know works
            // Use ClipOval to match Android 12's circular native splash mask
            ClipOval(
              child: Image.asset(
                'assets/icon/app_icon.png',
                width: 120,
                height: 120,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Sudoku: Always Free',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
