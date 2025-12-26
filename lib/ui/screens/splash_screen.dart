import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/permission_service.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Request permissions
    await PermissionService.requestAllPermissions();

    // Navigate to home screen after a delay
    Timer(
      const Duration(seconds: 3),
      () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => const HomeScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Centered content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/spm_splash_screen.png', height: 150),
                const SizedBox(height: 48),
                const CircularProgressIndicator(),
              ],
            ),
            // Bottom content
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Text(
                'Developed By Rakib Uddin Rony',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
