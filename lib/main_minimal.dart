import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  print('🚀 Minimal app starting...');
  runApp(const MinimalApp());
}

class MinimalApp extends StatelessWidget {
  const MinimalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'XPay Debug',
      debugShowCheckedModeBanner: false,
      home: const MinimalSplashScreen(),
    );
  }
}

class MinimalSplashScreen extends StatefulWidget {
  const MinimalSplashScreen({super.key});

  @override
  State<MinimalSplashScreen> createState() => _MinimalSplashScreenState();
}

class _MinimalSplashScreenState extends State<MinimalSplashScreen> {
  @override
  void initState() {
    super.initState();
    print('🎬 Minimal splash screen loaded');
    _navigateToWelcome();
  }

  void _navigateToWelcome() async {
    await Future.delayed(const Duration(seconds: 1));
    print('🔄 Navigating to welcome screen');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payment,
              size: 80,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'XPay',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green,
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to XPay!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'App is working correctly',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}