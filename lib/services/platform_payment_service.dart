import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../config/moov_config.dart';

class PlatformPaymentService {
  static const MethodChannel _channel = MethodChannel('platform_payment');
  
  // Initialize platform payment services
  static Future<void> init() async {
    try {
      if (Platform.isAndroid) {
        await _initializeGooglePay();
      } else if (Platform.isIOS) {
        await _initializeApplePay();
      }
      print('Platform payment service initialized');
    } catch (e) {
      print('Error initializing platform payment service: $e');
    }
  }

  // Initialize Google Pay
  static Future<void> _initializeGooglePay() async {
    try {
      await _channel.invokeMethod('initializeGooglePay', {
        'environment': MoovConfig.googlePayConfig['environment'],
        'merchantInfo': MoovConfig.googlePayConfig['merchantInfo'],
      });
    } catch (e) {
      print('Error initializing Google Pay: $e');
    }
  }

  // Initialize Apple Pay
  static Future<void> _initializeApplePay() async {
    try {
      await _channel.invokeMethod('initializeApplePay', {
        'merchantIdentifier': MoovConfig.applePayConfig['merchantIdentifier'],
        'countryCode': MoovConfig.applePayConfig['countryCode'],
        'currencyCode': MoovConfig.applePayConfig['currencyCode'],
      });
    } catch (e) {
      print('Error initializing Apple Pay: $e');
    }
  }

  // Check if Google Pay is available
  static Future<bool> isGooglePayAvailable() async {
    if (!Platform.isAndroid) return false;
    
    try {
      final bool isAvailable = await _channel.invokeMethod('isGooglePayAvailable');
      return isAvailable;
    } catch (e) {
      print('Error checking Google Pay availability: $e');
      return false;
    }
  }

  // Check if Apple Pay is available
  static Future<bool> isApplePayAvailable() async {
    if (!Platform.isIOS) return false;
    
    try {
      final bool isAvailable = await _channel.invokeMethod('isApplePayAvailable');
      return isAvailable;
    } catch (e) {
      print('Error checking Apple Pay availability: $e');
      return false;
    }
  }

  // Process subscription payment with Google Pay
  static Future<Map<String, dynamic>?> processGooglePaySubscription({
    required double amount,
    required String currency,
    required String subscriptionId,
  }) async {
    try {
      final result = await _channel.invokeMethod('processGooglePayment', {
        'amount': amount,
        'currency': currency,
        'subscriptionId': subscriptionId,
        'description': 'Super Payments Monthly Subscription',
        'paymentRequest': {
          'apiVersion': MoovConfig.googlePayConfig['apiVersion'],
          'apiVersionMinor': MoovConfig.googlePayConfig['apiVersionMinor'],
          'allowedPaymentMethods': MoovConfig.googlePayConfig['allowedPaymentMethods'],
          'transactionInfo': {
            'totalPrice': amount.toString(),
            'totalPriceStatus': 'FINAL',
            'currencyCode': currency,
            'transactionId': subscriptionId,
          },
          'merchantInfo': MoovConfig.googlePayConfig['merchantInfo'],
        }
      });

      return Map<String, dynamic>.from(result);
    } catch (e) {
      print('Error processing Google Pay subscription: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Process subscription payment with Apple Pay
  static Future<Map<String, dynamic>?> processApplePaySubscription({
    required double amount,
    required String currency,
    required String subscriptionId,
  }) async {
    try {
      final result = await _channel.invokeMethod('processApplePayment', {
        'amount': amount,
        'currency': currency,
        'subscriptionId': subscriptionId,
        'description': 'Super Payments Monthly Subscription',
        'paymentRequest': {
          'merchantIdentifier': MoovConfig.applePayConfig['merchantIdentifier'],
          'displayName': MoovConfig.applePayConfig['displayName'],
          'countryCode': MoovConfig.applePayConfig['countryCode'],
          'currencyCode': currency,
          'supportedNetworks': MoovConfig.applePayConfig['supportedNetworks'],
          'merchantCapabilities': MoovConfig.applePayConfig['merchantCapabilities'],
          'paymentSummaryItems': [
            {
              'label': 'Super Payments Monthly',
              'amount': amount.toString(),
              'type': 'final',
            }
          ],
        }
      });

      return Map<String, dynamic>.from(result);
    } catch (e) {
      print('Error processing Apple Pay subscription: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Show platform payment sheet
  static Future<Map<String, dynamic>?> showPaymentSheet({
    required double amount,
    required String currency,
    required String subscriptionId,
  }) async {
    try {
      if (Platform.isAndroid) {
        final isAvailable = await isGooglePayAvailable();
        if (isAvailable) {
          return await processGooglePaySubscription(
            amount: amount,
            currency: currency,
            subscriptionId: subscriptionId,
          );
        } else {
          Get.snackbar(
            'Google Pay Unavailable',
            'Google Pay is not available on this device',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return null;
        }
      } else if (Platform.isIOS) {
        final isAvailable = await isApplePayAvailable();
        if (isAvailable) {
          return await processApplePaySubscription(
            amount: amount,
            currency: currency,
            subscriptionId: subscriptionId,
          );
        } else {
          Get.snackbar(
            'Apple Pay Unavailable',
            'Apple Pay is not available on this device',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return null;
        }
      }
      
      return {
        'success': false,
        'error': 'Unsupported platform',
      };
    } catch (e) {
      print('Error showing payment sheet: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Get platform payment button widget
  static Widget getPlatformPaymentButton({
    required VoidCallback onPressed,
    required double amount,
    required String currency,
  }) {
    if (Platform.isAndroid) {
      return _buildGooglePayButton(
        onPressed: onPressed,
        amount: amount,
        currency: currency,
      );
    } else if (Platform.isIOS) {
      return _buildApplePayButton(
        onPressed: onPressed,
        amount: amount,
        currency: currency,
      );
    }
    
    return Container();
  }

  // Build Google Pay button
  static Widget _buildGooglePayButton({
    required VoidCallback onPressed,
    required double amount,
    required String currency,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Pay with Google Pay',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build Apple Pay button
  static Widget _buildApplePayButton({
    required VoidCallback onPressed,
    required double amount,
    required String currency,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.apple,
              size: 24,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              'Pay with Apple Pay',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 