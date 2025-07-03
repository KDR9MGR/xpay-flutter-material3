const functions = require('firebase-functions');
const admin = require('firebase-admin');
const stripe = require('stripe')(functions.config().stripe.secret_key);
const axios = require('axios');

admin.initializeApp();
const db = admin.firestore();

// Moov configuration
const MOOV_API_KEY = functions.config().moov ? functions.config().moov.api_key : 'stGOlQhih6BdxYhV';
const MOOV_BASE_URL = 'https://api.moov.io';

const moovHeaders = {
  'Authorization': `Bearer ${MOOV_API_KEY}`,
  'Content-Type': 'application/json',
  'Accept': 'application/json',
};

// Create Stripe customer
exports.createStripeCustomer = functions.https.onCall(async (data, context) => {
  // Verify user authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { email, name, phone, userId } = data;

  try {
    // Check if customer already exists
    const userDoc = await db.collection('users').doc(userId).get();
    if (userDoc.exists && userDoc.data().stripeCustomerId) {
      return { customerId: userDoc.data().stripeCustomerId };
    }

    // Create customer in Stripe
    const customer = await stripe.customers.create({
      email: email,
      name: name,
      phone: phone,
      metadata: {
        firebaseUserId: userId,
      },
    });

    // Save customer ID to Firestore
    await db.collection('users').doc(userId).update({
      stripeCustomerId: customer.id,
    });

    return { customerId: customer.id };
  } catch (error) {
    console.error('Error creating customer:', error);
    throw new functions.https.HttpsError('internal', 'Failed to create customer');
  }
});

// Create subscription
exports.createSubscription = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { customerId, priceId, paymentMethodId, userId } = data;

  try {
    // Create ephemeral key
    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer: customerId },
      { apiVersion: '2020-08-27' }
    );

    // Create subscription
    const subscription = await stripe.subscriptions.create({
      customer: customerId,
      items: [{
        price: priceId,
      }],
      payment_behavior: 'default_incomplete',
      payment_settings: { save_default_payment_method: 'on_subscription' },
      expand: ['latest_invoice.payment_intent'],
      metadata: {
        firebaseUserId: userId,
      },
    });

    // Save subscription to Firestore
    await db.collection('subscriptions').doc(subscription.id).set({
      userId: userId,
      customerId: customerId,
      subscriptionId: subscription.id,
      priceId: priceId,
      status: subscription.status,
      created: admin.firestore.FieldValue.serverTimestamp(),
      currentPeriodStart: new Date(subscription.current_period_start * 1000),
      currentPeriodEnd: new Date(subscription.current_period_end * 1000),
    });

    return {
      subscriptionId: subscription.id,
      clientSecret: subscription.latest_invoice.payment_intent.client_secret,
      ephemeralKey: ephemeralKey.secret,
    };
  } catch (error) {
    console.error('Error creating subscription:', error);
    throw new functions.https.HttpsError('internal', 'Failed to create subscription');
  }
});

// Get user subscriptions
exports.getSubscriptions = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { userId } = data;

  try {
    const subscriptionsSnapshot = await db
      .collection('subscriptions')
      .where('userId', '==', userId)
      .orderBy('created', 'desc')
      .get();

    const subscriptions = [];
    for (const doc of subscriptionsSnapshot.docs) {
      const subscriptionData = doc.data();
      
      // Get latest subscription data from Stripe
      const stripeSubscription = await stripe.subscriptions.retrieve(
        subscriptionData.subscriptionId
      );

      subscriptions.push({
        id: stripeSubscription.id,
        status: stripeSubscription.status,
        price_id: stripeSubscription.items.data[0].price.id,
        current_period_start: stripeSubscription.current_period_start,
        current_period_end: stripeSubscription.current_period_end,
        created: stripeSubscription.created,
        cancel_at_period_end: stripeSubscription.cancel_at_period_end,
      });
    }

    return { subscriptions };
  } catch (error) {
    console.error('Error getting subscriptions:', error);
    throw new functions.https.HttpsError('internal', 'Failed to get subscriptions');
  }
});

// Cancel subscription
exports.cancelSubscription = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { subscriptionId } = data;

  try {
    // Cancel subscription in Stripe (at period end)
    const subscription = await stripe.subscriptions.update(subscriptionId, {
      cancel_at_period_end: true,
    });

    // Update subscription in Firestore
    await db.collection('subscriptions').doc(subscriptionId).update({
      status: subscription.status,
      cancelAtPeriodEnd: subscription.cancel_at_period_end,
      updated: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true };
  } catch (error) {
    console.error('Error canceling subscription:', error);
    throw new functions.https.HttpsError('internal', 'Failed to cancel subscription');
  }
});

// Update subscription
exports.updateSubscription = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { subscriptionId, newPriceId } = data;

  try {
    // Get current subscription
    const subscription = await stripe.subscriptions.retrieve(subscriptionId);

    // Update subscription item
    const updatedSubscription = await stripe.subscriptions.update(subscriptionId, {
      items: [{
        id: subscription.items.data[0].id,
        price: newPriceId,
      }],
      proration_behavior: 'create_prorations',
    });

    // Update subscription in Firestore
    await db.collection('subscriptions').doc(subscriptionId).update({
      priceId: newPriceId,
      status: updatedSubscription.status,
      updated: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true };
  } catch (error) {
    console.error('Error updating subscription:', error);
    throw new functions.https.HttpsError('internal', 'Failed to update subscription');
  }
});

// Create setup intent for saving payment method
exports.createSetupIntent = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { customerId } = data;

  try {
    const setupIntent = await stripe.setupIntents.create({
      customer: customerId,
      usage: 'on_session',
      payment_method_types: ['card'],
    });

    return { clientSecret: setupIntent.client_secret };
  } catch (error) {
    console.error('Error creating setup intent:', error);
    throw new functions.https.HttpsError('internal', 'Failed to create setup intent');
  }
});

// Get customer payment methods
exports.getPaymentMethods = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { userId } = data;

  try {
    // Get customer ID from Firestore
    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists || !userDoc.data().stripeCustomerId) {
      return { paymentMethods: [] };
    }

    const customerId = userDoc.data().stripeCustomerId;

    // Get payment methods from Stripe
    const paymentMethods = await stripe.paymentMethods.list({
      customer: customerId,
      type: 'card',
    });

    return {
      paymentMethods: paymentMethods.data.map(pm => ({
        id: pm.id,
        brand: pm.card.brand,
        last4: pm.card.last4,
        exp_month: pm.card.exp_month,
        exp_year: pm.card.exp_year,
      })),
    };
  } catch (error) {
    console.error('Error getting payment methods:', error);
    throw new functions.https.HttpsError('internal', 'Failed to get payment methods');
  }
});

// Delete payment method
exports.deletePaymentMethod = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { paymentMethodId } = data;

  try {
    await stripe.paymentMethods.detach(paymentMethodId);
    return { success: true };
  } catch (error) {
    console.error('Error deleting payment method:', error);
    throw new functions.https.HttpsError('internal', 'Failed to delete payment method');
  }
});

// Webhook handler for Stripe events
exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers['stripe-signature'];
  const endpointSecret = functions.config().stripe.webhook_secret;

  let event;

  try {
    event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
  } catch (err) {
    console.error('Webhook signature verification failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Handle the event
  switch (event.type) {
    case 'customer.subscription.created':
    case 'customer.subscription.updated':
    case 'customer.subscription.deleted':
      const subscription = event.data.object;
      
      // Update subscription in Firestore
      await db.collection('subscriptions').doc(subscription.id).update({
        status: subscription.status,
        currentPeriodStart: new Date(subscription.current_period_start * 1000),
        currentPeriodEnd: new Date(subscription.current_period_end * 1000),
        cancelAtPeriodEnd: subscription.cancel_at_period_end,
        updated: admin.firestore.FieldValue.serverTimestamp(),
      });
      break;

    case 'invoice.payment_succeeded':
      const invoice = event.data.object;
      
      // Log successful payment
      await db.collection('payments').add({
        invoiceId: invoice.id,
        subscriptionId: invoice.subscription,
        amount: invoice.amount_paid,
        currency: invoice.currency,
        status: 'succeeded',
        created: admin.firestore.FieldValue.serverTimestamp(),
      });
      break;

    case 'invoice.payment_failed':
      const failedInvoice = event.data.object;
      
      // Log failed payment
      await db.collection('payments').add({
        invoiceId: failedInvoice.id,
        subscriptionId: failedInvoice.subscription,
        amount: failedInvoice.amount_due,
        currency: failedInvoice.currency,
        status: 'failed',
        created: admin.firestore.FieldValue.serverTimestamp(),
      });
      break;

    default:
      console.log(`Unhandled event type ${event.type}`);
  }

  res.json({ received: true });
});

// Moov webhook handler
exports.moovWebhook = functions.https.onRequest(async (req, res) => {
  try {
    const event = req.body;
    
    console.log('Received Moov webhook:', event.type);
    
    // Handle different Moov event types
    switch (event.type) {
      case 'account.created':
        await handleAccountCreated(event);
        break;
      case 'transfer.completed':
        await handleTransferCompleted(event);
        break;
      case 'transfer.failed':
        await handleTransferFailed(event);
        break;
      case 'payment_method.created':
        await handlePaymentMethodCreated(event);
        break;
      default:
        console.log(`Unhandled Moov event type: ${event.type}`);
    }
    
    res.status(200).json({received: true});
  } catch (error) {
    console.error('Error handling Moov webhook:', error);
    res.status(500).json({error: 'Webhook processing failed'});
  }
});

// Handle account created event
async function handleAccountCreated(event) {
  try {
    const accountData = event.data;
    console.log('Account created:', accountData.accountID);
    
    // Store account info in Firestore if needed
    if (accountData.foreignId) {
      await db.collection('users').doc(accountData.foreignId).update({
        moovAccountId: accountData.accountID,
        moovAccountStatus: accountData.status,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  } catch (error) {
    console.error('Error handling account created:', error);
  }
}

// Handle transfer completed event
async function handleTransferCompleted(event) {
  try {
    const transferData = event.data;
    console.log('Transfer completed:', transferData.transferID);
    
    // Update subscription status if this was a subscription payment
    if (transferData.metadata && transferData.metadata.subscriptionId) {
      await db.collection('subscriptions').doc(transferData.metadata.subscriptionId).update({
        status: 'active',
        lastPaymentDate: admin.firestore.FieldValue.serverTimestamp(),
        transferId: transferData.transferID,
        paymentStatus: 'completed',
      });
      
      // Store payment record
      await db.collection('payments').add({
        subscriptionId: transferData.metadata.subscriptionId,
        transferId: transferData.transferID,
        amount: transferData.amount.value,
        currency: transferData.amount.currency,
        status: 'completed',
        userId: transferData.metadata.userId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  } catch (error) {
    console.error('Error handling transfer completed:', error);
  }
}

// Handle transfer failed event
async function handleTransferFailed(event) {
  try {
    const transferData = event.data;
    console.log('Transfer failed:', transferData.transferID);
    
    // Update subscription status if this was a subscription payment
    if (transferData.metadata && transferData.metadata.subscriptionId) {
      await db.collection('subscriptions').doc(transferData.metadata.subscriptionId).update({
        status: 'payment_failed',
        lastPaymentAttempt: admin.firestore.FieldValue.serverTimestamp(),
        transferId: transferData.transferID,
        paymentStatus: 'failed',
        failureReason: transferData.failureReason || 'Payment failed',
      });
    }
  } catch (error) {
    console.error('Error handling transfer failed:', error);
  }
}

// Handle payment method created event
async function handlePaymentMethodCreated(event) {
  try {
    const paymentMethodData = event.data;
    console.log('Payment method created:', paymentMethodData.paymentMethodID);
    
    // Store payment method info if needed
    // This is typically handled on the client side
  } catch (error) {
    console.error('Error handling payment method created:', error);
  }
}

// Create Moov account
exports.createMoovAccount = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { email, firstName, lastName, phone, userId } = data;

  try {
    // Check if account already exists
    const userDoc = await db.collection('users').doc(userId).get();
    if (userDoc.exists && userDoc.data().moovAccountId) {
      return { accountId: userDoc.data().moovAccountId };
    }

    // Create account in Moov
    const response = await axios.post(`${MOOV_BASE_URL}/accounts`, {
      accountType: 'individual',
      profile: {
        individual: {
          name: {
            firstName: firstName,
            lastName: lastName,
          },
          email: email,
          phone: {
            number: phone || '',
            countryCode: '1',
          },
        },
      },
      termsOfService: {
        token: 'kgT1uxoMAk7QKuyJcmQE8nqW_HjpyuXBabiXPi6T83fUQoxGpWKvqPNDfhruYEp6_JW7HjooGhBs5mAvXNPMoA',
      },
      capabilities: ['transfers', 'send-funds', 'collect-funds'],
      foreignId: userId,
    }, { headers: moovHeaders });

    const accountId = response.data.accountID;

    // Save account ID to Firestore
    await db.collection('users').doc(userId).update({
      moovAccountId: accountId,
      moovAccountStatus: response.data.status,
    });

    return { accountId: accountId };
  } catch (error) {
    console.error('Error creating Moov account:', error);
    throw new functions.https.HttpsError('internal', 'Failed to create Moov account');
  }
});

// Process subscription payment
exports.processMoovSubscription = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { accountId, paymentMethodId, amount, currency, subscriptionId } = data;

  try {
    // Process payment via Moov
    const response = await axios.post(`${MOOV_BASE_URL}/transfers`, {
      source: {
        paymentMethodID: paymentMethodId,
      },
      destination: {
        account: {
          accountID: 'your_merchant_account_id', // Your business account ID
        },
      },
      amount: {
        currency: currency,
        value: Math.round(amount * 100), // Convert to cents
      },
      description: 'Super Payments Monthly Subscription',
      metadata: {
        subscriptionId: subscriptionId,
        userId: context.auth.uid,
        planType: 'super_payments_monthly',
      },
    }, { headers: moovHeaders });

    return {
      success: true,
      transferId: response.data.transferID,
      status: response.data.status,
    };
  } catch (error) {
    console.error('Error processing Moov subscription:', error);
    throw new functions.https.HttpsError('internal', 'Failed to process subscription payment');
  }
}); 