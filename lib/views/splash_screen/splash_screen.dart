import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../routes/routes.dart';
import '../../utils/storage_service.dart';
import '../auth/user_provider.dart';
import '../../controller/subscription_controller.dart';
import '../../data/user_model.dart';

import '../../utils/custom_color.dart';
import '../../utils/strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final UserProvider _userProvider;
  final _storageService = StorageService();
  bool _isLoading = true;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.splashScreenColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CustomColor.gradientStart,
              CustomColor.gradientMiddle,
              CustomColor.gradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with error handling
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    Strings.splashScreenImagePath,
                    width: 120,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) {
                      if (kDebugMode) {
                        debugPrint('❌ Image loading error: $error');
                      }
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: CustomColor.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.payment,
                          size: 60,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // App name
                Text(
                  Strings.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Digital Payment Solution',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 40),

                if (_isLoading) ...[
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],

                if (_error != null) ...[
                  Container(
                    margin: const EdgeInsets.all(20.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error: $_error',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _error = null;
                              _isLoading = true;
                            });
                            _checkSession();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      debugPrint('🎬 SplashScreen: initState called');
    }
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _checkSession();
  }

  void _checkSession() async {
    try {
      if (kDebugMode) {
        debugPrint('🚀 Splash Screen: Starting immediate navigation...');
      }

      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Immediate navigation for testing
      await Future.delayed(const Duration(milliseconds: 500));

      if (kDebugMode) {
        debugPrint('🔄 Navigating to welcome screen immediately...');
      }
      
      // Use pushReplacement instead of offAllNamed for testing
      Navigator.of(context).pushReplacementNamed(Routes.welcomeScreen);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('💥 Critical error in _checkSession: $e');
      }
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
