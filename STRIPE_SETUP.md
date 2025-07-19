# Stripe Subscription Integration Setup Guide

This guide will walk you through setting up Stripe subscription payments in your XPay Flutter app with Firebase Functions backend.

## Prerequisites

1. Stripe Account (Test mode for development)
2. Firebase Project with Blaze plan (for Cloud Functions)
3. Flutter development environment
4. Node.js (for Firebase Functions)

## Step 1: Stripe Dashboard Setup

### 1.1 Create Product and Price

1. Go to your Stripe Dashboard → Products
2. Create a product for your subscription plan:

**Premium Plan**
- Name: "Premium Plan"
- Description: "Unlock all premium features"
- Create monthly price: $1.99/month

3. Copy the Price ID and update `lib/config/stripe_config.dart`:

```dart
static const Map<String, String> subscriptionPrices = {
  'premium_monthly': 'price_your_actual_price_id_here', // Replace with actual price ID
};
```

### 1.2 Get API Keys

1. Go to Developers → API Keys
2. Copy your Publishable Key (already added to your config)
3. Copy your Secret Key (needed for Firebase Functions)

### 1.3 Create Webhook Endpoint

1. Go to Developers → Webhooks
2. Add endpoint: `https://your-region-your-project.cloudfunctions.net/stripeWebhook`
3. Select events:
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
4. Copy the Signing Secret

## Step 2: Firebase Functions Setup

### 2.1 Initialize Firebase Functions

```bash
# In your project root
npm install -g firebase-tools
firebase login
firebase init functions
```

Select:
- Use an existing project
- JavaScript/TypeScript
- Install dependencies

### 2.2 Install Dependencies

```bash
cd functions
npm install stripe firebase-admin firebase-functions
```

### 2.3 Configure Environment Variables

```bash
firebase functions:config:set stripe.secret_key="sk_test_your_secret_key"
firebase functions:config:set stripe.webhook_secret="whsec_your_webhook_secret"
```

### 2.4 Deploy Functions

```bash
firebase deploy --only functions
```

### 2.5 Update Firebase Functions URL

Update `lib/config/stripe_config.dart` with your deployed functions URL:

```dart
static const String functionsBaseUrl = 'https://your-region-your-project.cloudfunctions.net';
```

## Step 3: Firebase Security Rules

### 3.1 Firestore Rules

Add these rules to your `firestore.rules`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can read their own subscriptions
    match /subscriptions/{subscriptionId} {
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
      allow write: if false; // Only functions can write subscriptions
    }
    
    // Users can read their own payment records
    match /payments/{paymentId} {
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
      allow write: if false; // Only functions can write payments
    }
  }
}
```

## Step 4: Android Configuration

### 4.1 Update `android/app/build.gradle`

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21  // Minimum for Stripe
        targetSdkVersion 34
    }
}
```

### 4.2 Add Permissions

In `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## Step 5: iOS Configuration

### 5.1 Update `ios/Runner/Info.plist`

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### 5.2 Set Minimum iOS Version

In `ios/Podfile`:

```ruby
platform :ios, '13.0'  # Minimum for Stripe
```

## Step 6: Test the Integration

### 6.1 Test Cards

Use Stripe's test cards:

- **Successful payment**: `4242 4242 4242 4242`
- **Declined payment**: `4000 0000 0000 0002`
- **3D Secure**: `4000 0025 0000 3155`

Use any future expiry date and any 3-digit CVC.

### 6.2 Test Subscription Flow

1. Run your app
2. Navigate to subscription screen
3. Tap "Subscribe for $1.99/month"
4. Complete payment with test card
5. Verify subscription in Stripe Dashboard
6. Test subscription management features

## Step 7: Production Deployment

### 7.1 Switch to Live Mode

1. Get live API keys from Stripe Dashboard
2. Update environment variables:

```bash
firebase functions:config:set stripe.secret_key="sk_live_your_live_secret_key"
```

3. Update `lib/config/stripe_config.dart` with live publishable key
4. Update webhook endpoint to production URL
5. Test thoroughly before going live

### 7.2 Security Checklist

- [ ] Use live API keys in production
- [ ] Webhook endpoint is secured
- [ ] Firebase security rules are properly configured
- [ ] Test subscription flow thoroughly
- [ ] Monitor error logs and webhooks

## Subscription Features

### What Users Get:
- **Premium Plan**: $1.99/month
- Unlimited transactions
- Priority customer support
- Reduced transaction fees
- Advanced analytics
- Multiple payment methods
- Premium features access
- Enhanced security
- Real-time notifications

### Management Features:
- Subscribe/Cancel subscription
- View subscription status and history
- Manage payment methods
- Real-time webhook updates
- Secure payment processing

## Troubleshooting

### Common Issues

1. **"No such price" error**: Verify price ID in `stripe_config.dart`
2. **Webhook failures**: Check endpoint URL and signing secret
3. **Payment sheet not showing**: Ensure proper initialization
4. **Android build issues**: Check minimum SDK version

### Debugging

1. Check Firebase Functions logs: `firebase functions:log`
2. Monitor Stripe Dashboard → Events
3. Use `flutter logs` for client-side debugging

## Support

- Stripe Documentation: https://stripe.com/docs
- Firebase Functions: https://firebase.google.com/docs/functions
- Flutter Stripe Plugin: https://pub.dev/packages/flutter_stripe

## Security Best Practices

1. Never expose secret keys in client code
2. Always validate webhooks
3. Use HTTPS for all endpoints
4. Implement proper error handling
5. Log important events for monitoring
6. Regularly update dependencies

---

Your Stripe subscription integration is now complete! Users can subscribe to the premium plan for $1.99/month and you have a secure backend handling all payment processing. 