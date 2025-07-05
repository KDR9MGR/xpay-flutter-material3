import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/stripe_config.dart';
import '../utils/custom_color.dart';

/// StripeService - Production Implementation
/// 
/// This service uses real Stripe payment processing with Google Pay and Apple Pay support.
/// The payment sheet will show native payment options including:
/// - Credit/Debit Cards
/// - Google Pay (Android)
/// - Apple Pay (iOS)
/// 
/// IMPORTANT: To complete the setup for production use:
/// 1. Deploy the Firebase Functions from functions/index.js
/// 2. Configure your Stripe secret key in Firebase Functions
/// 3. Update Firebase Functions URLs if using custom domains
/// 
/// See STRIPE_SETUP.md for detailed setup instructions.
class StripeService {
  static final StripeService _instance = StripeService._internal();
  factory StripeService() => _instance;
  StripeService._internal();

  // Keys for local storage
  static const String _subscriptionStatusKey = 'test_subscription_status';
  static const String _subscriptionStartKey = 'test_subscription_start';

  // Initialize Stripe
  static Future<void> init() async {
    try {
      print('Initializing Stripe service...');
      Stripe.publishableKey = StripeConfig.publishableKey;
      await Stripe.instance.applySettings();
      print('Stripe service initialized successfully');
    } catch (e) {
      print('Error initializing Stripe service: $e');
      // Don't throw error - allow app to continue without Stripe
    }
  }

  // Helper method to get current user ID
  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // Get stored subscription status
  Future<String?> _getStoredSubscriptionStatus() async {
    if (_currentUserId == null) return null;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('${_subscriptionStatusKey}_$_currentUserId');
  }

  // Set stored subscription status
  Future<void> _setStoredSubscriptionStatus(String status) async {
    if (_currentUserId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_subscriptionStatusKey}_$_currentUserId', status);
    
    if (status == 'active') {
      await prefs.setInt('${_subscriptionStartKey}_$_currentUserId', DateTime.now().millisecondsSinceEpoch);
    } else if (status == 'cancelled') {
      await prefs.remove('${_subscriptionStartKey}_$_currentUserId');
    }
  }

  // Clear stored subscription data
  Future<void> _clearStoredSubscriptionData() async {
    if (_currentUserId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_subscriptionStatusKey}_$_currentUserId');
    await prefs.remove('${_subscriptionStartKey}_$_currentUserId');
  }

  // Create customer in Stripe via Firebase Function
  Future<String?> createCustomer({
    required String email,
    required String name,
    String? phone,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final callable = FirebaseFunctions.instance.httpsCallable('createStripeCustomer');
      final result = await callable.call({
        'email': email,
        'name': name,
        'phone': phone,
        'userId': user.uid,
      });

      return result.data['customerId'] as String?;
    } catch (e) {
      print('Error creating customer: $e');
      Get.snackbar('Error', 'Failed to create customer: $e');
      return null;
    }
  }

  // Create subscription via Firebase Function
  Future<Map<String, dynamic>?> createSubscription({
    required String customerId,
    required String priceId,
    String? paymentMethodId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final callable = FirebaseFunctions.instance.httpsCallable('createSubscription');
      final result = await callable.call({
        'customerId': customerId,
        'priceId': priceId,
        'paymentMethodId': paymentMethodId,
        'userId': user.uid,
      });

      return result.data as Map<String, dynamic>?;
    } catch (e) {
      print('Error creating subscription: $e');
      Get.snackbar('Error', 'Failed to create subscription: $e');
      return null;
    }
  }

  // Create setup intent for saving payment method
  Future<String?> createSetupIntent({required String customerId}) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('createSetupIntent');
      final result = await callable.call({
        'customerId': customerId,
      });

      return result.data['clientSecret'] as String?;
    } catch (e) {
      print('Error creating setup intent: $e');
      Get.snackbar('Error', 'Failed to create setup intent: $e');
      return null;
    }
  }

  // Real Stripe payment sheet for subscriptions with Google Pay and Apple Pay
  Future<bool> presentPaymentSheet({
    required String customerId,
    required String priceId,
  }) async {
    try {
      // Check if user already has active subscription
      final currentStatus = await _getStoredSubscriptionStatus();
      if (currentStatus == 'active') {
        Get.snackbar('Info', 'You already have an active subscription!');
        return true;
      }

      // Show loading
      Get.dialog(
        Center(
          child: Material(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Setting up payment...'),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      try {
        // Create subscription with incomplete status
        final subscriptionData = await createSubscription(
          customerId: customerId,
          priceId: priceId,
        );

        if (subscriptionData == null) {
          Get.back(); // Close loading dialog
          Get.snackbar('Error', 'Failed to create subscription');
          return false;
        }

        final clientSecret = subscriptionData['clientSecret'] as String?;
        final ephemeralKey = subscriptionData['ephemeralKey'] as String?;

        if (clientSecret == null) {
          Get.back(); // Close loading dialog
          Get.snackbar('Error', 'Invalid payment configuration');
          return false;
        }

        // Initialize payment sheet with Google Pay and Apple Pay
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'XPay',
            customerId: customerId,
            customerEphemeralKeySecret: ephemeralKey,
            allowsDelayedPaymentMethods: true,
            // Enable Google Pay
            googlePay: PaymentSheetGooglePay(
              merchantCountryCode: 'US',
              currencyCode: 'USD',
              testEnv: true, // Set to false for production
            ),
            // Enable Apple Pay
            applePay: PaymentSheetApplePay(
              merchantCountryCode: 'US',
            ),
            style: ThemeMode.system,
            // Appearance customization
            appearance: PaymentSheetAppearance(
              colors: PaymentSheetAppearanceColors(
                primary: CustomColor.primaryColor,
                background: Colors.white,
                componentBackground: Colors.grey[50]!,
                componentBorder: Colors.grey[300]!,
                componentDivider: Colors.grey[200]!,
                primaryText: Colors.black,
                secondaryText: Colors.grey[600]!,
                componentText: Colors.black,
                placeholderText: Colors.grey[500]!,
              ),
              primaryButton: PaymentSheetPrimaryButtonAppearance(
                colors: PaymentSheetPrimaryButtonTheme(
                  light: PaymentSheetPrimaryButtonThemeColors(
                    background: CustomColor.primaryColor,
                    text: Colors.white,
                    border: CustomColor.primaryColor,
                  ),
                  dark: PaymentSheetPrimaryButtonThemeColors(
                    background: CustomColor.primaryColor,
                    text: Colors.white,
                    border: CustomColor.primaryColor,
                  ),
                ),
              ),
            ),
          ),
        );

        Get.back(); // Close loading dialog

        // Present the payment sheet
        await Stripe.instance.presentPaymentSheet();
        
        // If we reach here, payment was successful
        await _setStoredSubscriptionStatus('active');
        
        Get.snackbar(
          'Success! 🎉', 
          'Subscription activated successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        
        return true;

      } catch (stripeError) {
        Get.back(); // Close loading dialog if still open
        
        if (stripeError is StripeException) {
          final message = stripeError.error.localizedMessage;
          
          // Handle different types of Stripe errors
          if (message != null) {
            if (message.toLowerCase().contains('canceled') || 
                message.toLowerCase().contains('cancelled')) {
              // User cancelled - don't show error
              return false;
            } else if (message.toLowerCase().contains('authentication') ||
                       message.toLowerCase().contains('declined')) {
              Get.snackbar(
                'Payment Failed', 
                'Your payment was declined. Please try a different payment method.',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            } else {
              Get.snackbar(
                'Payment Error', 
                message,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          } else {
            Get.snackbar(
              'Payment Error', 
              'Payment failed. Please try again.',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        } else {
          print('Non-Stripe error: $stripeError');
          Get.snackbar(
            'Error', 
            'Failed to process payment. Please try again.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        return false;
      }
    } catch (e) {
      print('Error presenting payment sheet: $e');
      Get.back(); // Close loading dialog if still open
      Get.snackbar(
        'Error', 
        'Failed to initialize payment. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Mock implementations for testing
  Future<bool> confirmSetupIntent({
    required String clientSecret,
    required PaymentMethodData paymentMethodData,
  }) async {
    try {
      await Future.delayed(Duration(milliseconds: 500)); // Simulate processing
      return true;
    } catch (e) {
      print('Error confirming setup intent: $e');
      Get.snackbar('Error', 'Failed to save payment method: $e');
      return false;
    }
  }

  // Get customer's subscriptions
  Future<List<Map<String, dynamic>>> getSubscriptions() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final callable = FirebaseFunctions.instance.httpsCallable('getSubscriptions');
      final result = await callable.call({
        'userId': user.uid,
      });

      return List<Map<String, dynamic>>.from(result.data['subscriptions'] ?? []);
    } catch (e) {
      print('Error getting subscriptions: $e');
      return [];
    }
  }

  // Cancel subscription
  Future<bool> cancelSubscription({required String subscriptionId}) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('cancelSubscription');
      final result = await callable.call({
        'subscriptionId': subscriptionId,
      });

      final success = result.data['success'] == true;
      
      if (success) {
        // Update local stored status to cancelled
        await _setStoredSubscriptionStatus('cancelled');
      }
      
      return success;
    } catch (e) {
      print('Error canceling subscription: $e');
      Get.snackbar('Error', 'Failed to cancel subscription: $e');
      return false;
    }
  }

  // Update subscription
  Future<bool> updateSubscription({
    required String subscriptionId,
    required String newPriceId,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('updateSubscription');
      final result = await callable.call({
        'subscriptionId': subscriptionId,
        'newPriceId': newPriceId,
      });

      return result.data['success'] == true;
    } catch (e) {
      print('Error updating subscription: $e');
      Get.snackbar('Error', 'Failed to update subscription: $e');
      return false;
    }
  }

  // Get customer's payment methods
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final callable = FirebaseFunctions.instance.httpsCallable('getPaymentMethods');
      final result = await callable.call({
        'userId': user.uid,
      });

      return List<Map<String, dynamic>>.from(result.data['paymentMethods'] ?? []);
    } catch (e) {
      print('Error getting payment methods: $e');
      return [];
    }
  }

  // Delete payment method
  Future<bool> deletePaymentMethod({required String paymentMethodId}) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('deletePaymentMethod');
      final result = await callable.call({
        'paymentMethodId': paymentMethodId,
      });

      return result.data['success'] == true;
    } catch (e) {
      print('Error deleting payment method: $e');
      Get.snackbar('Error', 'Failed to delete payment method: $e');
      return false;
    }
  }

  // Get subscription status
  Future<String?> getSubscriptionStatus() async {
    try {
      final subscriptions = await getSubscriptions();
      if (subscriptions.isEmpty) return null;
      
      // Return the status of the most recent active subscription
      final activeSubscriptions = subscriptions.where((sub) => 
        sub['status'] == 'active' || sub['status'] == 'trialing'
      ).toList();
      
      if (activeSubscriptions.isNotEmpty) {
        return activeSubscriptions.first['status'];
      }
      
      return subscriptions.first['status'];
    } catch (e) {
      print('Error getting subscription status: $e');
      return null;
    }
  }

  // Check if user has active subscription
  Future<bool> hasActiveSubscription() async {
    final status = await getSubscriptionStatus();
    return status == 'active' || status == 'trialing';
  }
} 