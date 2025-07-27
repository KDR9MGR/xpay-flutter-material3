import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:xpay/firebase_options.dart';
import 'package:xpay/routes/routes.dart';
import 'package:xpay/utils/language/local_strings.dart';
import 'package:xpay/utils/threading_utils.dart';
import 'package:xpay/views/auth/login_vm.dart';
import 'package:xpay/views/auth/wallet_view_model.dart';
import 'controller/auth_controller.dart';
import 'controller/subscription_controller.dart';
import 'services/stripe_service.dart';
import 'services/moov_service.dart';
import 'services/platform_payment_service.dart';

import 'utils/custom_color.dart';
import 'utils/strings.dart';
import 'views/auth/user_provider.dart';

void main() async {
  // Add crash prevention wrapper
  runZonedGuarded(
    () async {
      try {
        WidgetsFlutterBinding.ensureInitialized();

        // Initialize Firebase first on background thread with crash protection
        // Initialize Firebase on main thread to avoid isolate issues
        try {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
          print('Firebase initialized successfully');
        } catch (e) {
          print('Firebase initialization error: $e');
          // Continue without Firebase if it fails
        }

        // Lock Device Orientation on main thread with crash protection
        await ThreadingUtils.runUIOperation(() async {
          try {
            await SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
          } catch (e) {
            print('Device orientation error: $e');
            // Continue without orientation lock if it fails
          }
        });

        // Initialize storage on background thread with crash protection
        // Initialize storage on main thread
        try {
          await GetStorage.init();
          print('Storage initialized successfully');
        } catch (e) {
          print('Storage initialization error: $e');
          // Continue without storage if it fails
        }

        // Initialize Platform Payment Service (Primary for subscriptions) on background thread
        bool platformPaymentInitialized = false;
        try {
          await ThreadingUtils.runFirebaseOperation(() async {
            try {
              await PlatformPaymentService.init();
              platformPaymentInitialized = true;
              print('Platform Payment Service initialized successfully');
            } catch (e) {
              print('Platform Payment Service initialization error: $e');
            }
          }, operationName: 'Platform Payment Service initialization');
        } catch (e) {
          print('Error initializing Platform Payment Service: $e');
        }

        // Initialize Moov (Primary backend) on background thread
        bool moovInitialized = false;
        try {
          await ThreadingUtils.runFirebaseOperation(() async {
            try {
              await MoovService.init();
              moovInitialized = true;
              print('Moov initialized successfully');
            } catch (e) {
              print('Moov initialization error: $e');
            }
          }, operationName: 'Moov initialization');
        } catch (e) {
          print('Error initializing Moov: $e');
        }

        // Initialize Stripe (Fallback only) on background thread
        bool stripeInitialized = false;
        try {
          await ThreadingUtils.runFirebaseOperation(() async {
            try {
              await StripeService.init();
              stripeInitialized = true;
              print('Stripe initialized successfully (fallback)');
            } catch (e) {
              print('Stripe initialization error: $e');
            }
          }, operationName: 'Stripe initialization');
        } catch (e) {
          print('Error initializing Stripe: $e');
        }

        // Check if at least one payment service is available
        if (!platformPaymentInitialized &&
            !moovInitialized &&
            !stripeInitialized) {
          print('Warning: No payment services initialized successfully');
        }

        // Initialize controllers on main thread with crash protection
        await ThreadingUtils.runUIOperation(() async {
          try {
            Get.put(AuthController());
          } catch (e) {
            print('Auth controller initialization error: $e');
          }
        });

        // Initialize subscription controller with error handling on background thread
        try {
          await ThreadingUtils.runFirebaseOperation(() async {
            try {
              Get.put(SubscriptionController());
              print('Subscription controller initialized');
            } catch (e) {
              print('Subscription controller initialization error: $e');
            }
          }, operationName: 'Subscription controller initialization');
        } catch (e) {
          print('Warning: Subscription controller initialization failed: $e');
          // App can still work without subscription controller
        }

        // Yield control to prevent main thread blocking
        await ThreadingUtils.yieldControl();

        // Run the app on main thread with crash protection
        await ThreadingUtils.runUIOperation(() async {
          try {
            runApp(
              MultiProvider(
                providers: [
                  // Only create LoginViewModel after Firebase is initialized
                  ChangeNotifierProvider<LoginViewModel>(
                    create: (context) {
                      try {
                        return LoginViewModel();
                      } catch (e) {
                        print('LoginViewModel creation error: $e');
                        // Return a fallback or handle the error
                        return LoginViewModel();
                      }
                    },
                  ),
                  ChangeNotifierProvider(create: (_) => UserProvider()),
                  ChangeNotifierProvider(create: (_) => WalletViewModel()),
                ],
                child: const MyApp(),
              ),
            );
          } catch (e) {
            print('App initialization error: $e');
            // Run minimal error app
            runApp(
              MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'App Initialization Error',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('$e', textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        });
      } catch (e) {
        print('Critical error during app initialization: $e');
        // Run a minimal app that shows the error on main thread
        await ThreadingUtils.runUIOperation(() async {
          runApp(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'Critical App Error',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('$e', textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      }
    },
    (error, stack) {
      // Global error handler for uncaught exceptions
      print('Uncaught error: $error');
      print('Stack trace: $stack');
    },
  );
}

// This widget is the root of your application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      minTextAdapt: true,
      splitScreenMode: true,
      builder:
          (context, child) => GetMaterialApp(
            title: Strings.appName,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.dark(
                primary: CustomColor.primaryColor,
                secondary: CustomColor.secondaryColor,
                surface: CustomColor.surfaceColor,
                onPrimary: CustomColor.onPrimaryTextColor,
                onSecondary: CustomColor.onPrimaryTextColor,
                onSurface: CustomColor.primaryTextColor,
                error: CustomColor.errorColor,
                outline: CustomColor.outlineColor,
              ),
              scaffoldBackgroundColor: CustomColor.screenBGColor,
              appBarTheme: AppBarTheme(
                backgroundColor: CustomColor.appBarColor,
                foregroundColor: CustomColor.primaryTextColor,
                elevation: 0,
                centerTitle: true,
                systemOverlayStyle: SystemUiOverlayStyle.light,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColor.primaryColor,
                  foregroundColor: CustomColor.onPrimaryTextColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              cardTheme: CardThemeData(
                color: CustomColor.surfaceColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: CustomColor.outlineColor, width: 1),
                ),
              ),
              textTheme: GoogleFonts.josefinSansTextTheme(
                Theme.of(context).textTheme.apply(
                  bodyColor: CustomColor.primaryTextColor,
                  displayColor: CustomColor.primaryTextColor,
                ),
              ),
            ),
            navigatorKey: Get.key,
            initialRoute: Routes.splashScreen,
            getPages: Routes.list,
            builder: (context, widget) {
              ScreenUtil.init(context);
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(1.0)),
                child: widget!,
              );
            },
            translations: LocalString(),
            locale: const Locale('en', 'US'),
            fallbackLocale: const Locale('en', 'US'),
            onInit: () {
              // Initialize any app-wide threading resources
            },
            onDispose: () {
              // Clean up threading resources when app is disposed
              ThreadingUtils.dispose();
            },
          ),
    );
  }
}
