package com.getdigitalpayments

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.util.Log
import com.google.android.gms.wallet.*
import com.google.android.gms.tasks.Task
import org.json.JSONObject
import org.json.JSONArray
import java.util.*

class MainActivity: FlutterActivity() {
    private val CHANNEL = "platform_payment"
    private lateinit var paymentsClient: PaymentsClient
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Initialize Google Pay
        val walletOptions = Wallet.WalletOptions.Builder()
            .setEnvironment(WalletConstants.ENVIRONMENT_TEST) // Change to PRODUCTION for live
            .build()
        paymentsClient = Wallet.getPaymentsClient(this, walletOptions)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initializeGooglePay" -> {
                    result.success("Google Pay initialized")
                }
                "isGooglePayAvailable" -> {
                    checkGooglePayAvailability(result)
                }
                "processGooglePayment" -> {
                    val amount = call.argument<Double>("amount")
                    val currency = call.argument<String>("currency")
                    val subscriptionId = call.argument<String>("subscriptionId")
                    
                    if (amount != null && currency != null && subscriptionId != null) {
                        processGooglePayment(amount, currency, subscriptionId, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Missing required arguments", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun checkGooglePayAvailability(result: MethodChannel.Result) {
        val request = IsReadyToPayRequest.fromJson(baseRequest.toString())
        
        val task: Task<Boolean> = paymentsClient.isReadyToPay(request)
        task.addOnCompleteListener { completedTask ->
            try {
                val available = completedTask.getResult(Exception::class.java) ?: false
                result.success(available)
            } catch (exception: Exception) {
                Log.e("GooglePay", "isReadyToPay failed", exception)
                result.success(false)
            }
        }
    }
    
    private fun processGooglePayment(amount: Double, currency: String, subscriptionId: String, result: MethodChannel.Result) {
        try {
            val paymentDataRequest = createPaymentDataRequest(amount, currency)
            val request = PaymentDataRequest.fromJson(paymentDataRequest.toString())
            
            val task: Task<PaymentData> = paymentsClient.loadPaymentData(request)
            task.addOnCompleteListener { completedTask ->
                try {
                    val paymentData = completedTask.getResult(Exception::class.java)
                    val paymentToken = paymentData?.toJson()
                    
                    result.success(mapOf(
                        "success" to true,
                        "paymentToken" to paymentToken,
                        "paymentMethod" to "google_pay",
                        "subscriptionId" to subscriptionId
                    ))
                } catch (exception: Exception) {
                    Log.e("GooglePay", "Payment failed", exception)
                    result.success(mapOf(
                        "success" to false,
                        "error" to exception.message
                    ))
                }
            }
        } catch (e: Exception) {
            result.success(mapOf(
                "success" to false,
                "error" to e.message
            ))
        }
    }
    
    private val baseRequest = JSONObject().apply {
        put("apiVersion", 2)
        put("apiVersionMinor", 0)
    }
    
    private val allowedCardAuthMethods = JSONArray(listOf(
        "PAN_ONLY",
        "CRYPTOGRAM_3DS"
    ))
    
    private val allowedCardNetworks = JSONArray(listOf(
        "AMEX",
        "DISCOVER",
        "JCB",
        "MASTERCARD",
        "VISA"
    ))
    
    private fun baseCardPaymentMethod(): JSONObject {
        return JSONObject().apply {
            put("type", "CARD")
            put("parameters", JSONObject().apply {
                put("allowedAuthMethods", allowedCardAuthMethods)
                put("allowedCardNetworks", allowedCardNetworks)
            })
        }
    }
    
    private fun cardPaymentMethod(): JSONObject {
        val cardPaymentMethod = baseCardPaymentMethod()
        cardPaymentMethod.put("tokenizationSpecification", JSONObject().apply {
            put("type", "PAYMENT_GATEWAY")
            put("parameters", JSONObject().apply {
                put("gateway", "moov")
                put("gatewayMerchantId", "your_moov_merchant_id")
            })
        })
        return cardPaymentMethod
    }
    
    private fun createPaymentDataRequest(amount: Double, currency: String): JSONObject {
        return baseRequest.apply {
            put("allowedPaymentMethods", JSONArray().put(cardPaymentMethod()))
            put("transactionInfo", JSONObject().apply {
                put("totalPrice", amount.toString())
                put("totalPriceStatus", "FINAL")
                put("currencyCode", currency)
            })
            put("merchantInfo", JSONObject().apply {
                put("merchantName", "XPay Digital Payments")
            })
        }
    }
}
