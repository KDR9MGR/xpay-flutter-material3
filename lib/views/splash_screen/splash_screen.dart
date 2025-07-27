import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:xpay/routes/routes.dart';
import 'package:xpay/utils/storage_service.dart';
import 'package:xpay/utils/threading_utils.dart';
import 'package:xpay/views/auth/user_provider.dart';
import 'package:xpay/controller/subscription_controller.dart';

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(Strings.splashScreenImagePath),
            if (_isLoading) ...[
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ],
            if (_error != null) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Error: $_error',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _isLoading = true;
                  });
                  _checkSession();
                },
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _checkSession();
  }

  void _checkSession() async {
    try {
      print('Checking session status...');

      // Storage operations must run on main thread
      bool isLoggedIn = _storageService.getValue(Strings.isLoggedIn) ?? false;
      print('Is logged in: $isLoggedIn');

      if (isLoggedIn) {
        try {
          print('Fetching user details...');

          // Use background thread for Firebase operations
          await ThreadingUtils.runFirebaseOperation(
            () async => await _userProvider.fetchUserDetails(),
            operationName: 'Fetch user details',
          );

          print('User details fetched successfully');

          // Yield control to prevent main thread blocking
          await ThreadingUtils.yieldControl();

          // Initialize subscription controller after user is loaded
          try {
            final subscriptionController = Get.find<SubscriptionController>();
            print('Subscription controller found and ready');
          } catch (e) {
            print('Subscription controller not ready: $e');
            // This is okay - controller will initialize on its own
          }

          // Use UI operation for navigation
          await ThreadingUtils.runUIOperation(() async {
            Get.offAllNamed(Routes.dashboardScreen);
          });
        } catch (e) {
          print('Error fetching user details: $e');
          await ThreadingUtils.runUIOperation(() async {
            setState(() {
              _error = 'Failed to load user data. Please try again.';
              _isLoading = false;
            });
          });
        }
      } else {
        print(
          'User not logged in, navigating to welcome screen in 3 seconds...',
        );

        // Use timer with threading utils
        ThreadingUtils.createTimer(
          'splash_navigation',
          const Duration(seconds: 3),
          () {
            ThreadingUtils.runUIOperation(() async {
              Get.offAllNamed(Routes.welcomeScreen);
            });
          },
        );
      }
    } catch (e) {
      print('Error in _checkSession: $e');
      await ThreadingUtils.runUIOperation(() async {
        setState(() {
          _error = 'Something went wrong. Please try again.';
          _isLoading = false;
        });
      });
    }
  }

  @override
  void dispose() {
    // Clean up timers
    ThreadingUtils.disposeTimer('splash_navigation');
    super.dispose();
  }
}
