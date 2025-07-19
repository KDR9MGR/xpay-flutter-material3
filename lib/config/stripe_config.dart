class StripeConfig {
  // Test keys - replace with live keys in production
  static const String publishableKey = 'pk_test_51ReQBJ028B6QVjzzvWtq8SbZB3dkm3SdEKh3heSISE8GV3gW94EXqGeL9q9Qyo5CtDv0ATfC3sSICwap41UJTluA00zznGdNnv';
  
  // Firebase Functions base URL
  static const String functionsBaseUrl = 'https://your-region-your-project.cloudfunctions.net';
  
  // Subscription price ID (from your Stripe test dashboard)
  static const Map<String, String> subscriptionPrices = {
    'premium_monthly': 'price_1RgVqCP16wcjAs88IIjV3fqT', // Your actual $1.99/month Price ID
  };
  
  // Subscription plan details
  static const Map<String, Map<String, dynamic>> subscriptionPlans = {
    'premium_monthly': {
      'name': 'Premium Plan',
      'price': 1.99,
      'currency': 'USD',
      'interval': 'month',
      'features': [
        'Unlimited transactions',
        'Priority customer support',
        'Reduced transaction fees',
        'Advanced analytics',
        'Multiple payment methods',
        'Premium features access',
        'Enhanced security',
        'Real-time notifications',
      ],
    },
  };
} 