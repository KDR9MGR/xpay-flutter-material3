class MoovConfig {
  // Moov API credentials
  static const String apiKey = 'stGOlQhih6BdxYhV';
  static const String baseUrl = 'https://api.moov.io';
  static const bool isProduction = false; // Set to true for production
  
  // Subscription details
  static const Map<String, Map<String, dynamic>> subscriptionPlans = {
    'super_payments': {
      'id': 'super_payments_monthly',
      'name': 'Super Payments',
      'description': 'Get Coupons, Brand Deals and Discounts on various brands and purchase Terms & Condition Apply',
      'price': 1.99,
      'currency': 'USD',
      'interval': 'month',
      'features': [
        'Get Coupons and Brand Deals',
        'Discounts on various brands',
        'Special purchase offers',
        'Priority customer support',
        'Enhanced transaction features',
        'Premium payment methods',
        'Advanced security features',
        'Real-time notifications',
      ],
    },
  };
  
  // Google Pay configuration
  static const Map<String, dynamic> googlePayConfig = {
    'environment': 'TEST', // Change to 'PRODUCTION' for live
    'apiVersion': 2,
    'apiVersionMinor': 0,
    'allowedPaymentMethods': [
      {
        'type': 'CARD',
        'parameters': {
          'allowedAuthMethods': ['PAN_ONLY', 'CRYPTOGRAM_3DS'],
          'allowedCardNetworks': ['AMEX', 'DISCOVER', 'JCB', 'MASTERCARD', 'VISA']
        },
        'tokenizationSpecification': {
          'type': 'PAYMENT_GATEWAY',
          'parameters': {
            'gateway': 'moov',
            'gatewayMerchantId': 'your_moov_merchant_id'
          }
        }
      }
    ],
    'merchantInfo': {
      'merchantId': '12345678901234567890',
      'merchantName': 'XPay Digital Payments'
    }
  };
  
  // Apple Pay configuration
  static const Map<String, dynamic> applePayConfig = {
    'merchantIdentifier': 'merchant.com.getdigitalpayments.xpay',
    'displayName': 'XPay Digital Payments',
    'countryCode': 'US',
    'currencyCode': 'USD',
    'supportedNetworks': ['visa', 'masterCard', 'amex', 'discover'],
    'merchantCapabilities': ['3DS', 'debit', 'credit']
  };
} 