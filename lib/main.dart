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
import '/utils/app_logger.dart';
import 'controller/auth_controller.dart';
import 'controller/subscription_controller.dart';

import 'utils/custom_color.dart';
import 'utils/strings.dart';
import 'views/auth/user_provider.dart';

void main() async {
  print('🚀 App starting...');
  // Add crash prevention wrapper
  runZonedGuarded(
    () async {
      try {
        WidgetsFlutterBinding.ensureInitialized();

        // Initialize Firebase (temporarily disabled for debugging)
        try {
          // await Firebase.initializeApp(
          //   options: DefaultFirebaseOptions.currentPlatform,
          // );
          print('✅ Firebase initialization skipped for debugging');
        } catch (e) {
          print('❌ Firebase initialization failed: $e');
        }

        // Lock Device Orientation
        try {
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
        } catch (e) {
          AppLogger.log('Device orientation error: $e');
        }

        // Initialize storage
        try {
          await GetStorage.init();
          AppLogger.log('Storage initialized successfully');
        } catch (e) {
          AppLogger.log('Storage initialization error: $e');
        }

        // Initialize services (optional - app can work without them)
        // Temporarily commenting out service initializations to test for hanging
        /*
        try {
          await PlatformPaymentService.init();
          AppLogger.log('Platform Payment Service initialized');
        } catch (e) {
          AppLogger.log('Platform Payment Service error: $e');
        }

        try {
          await MoovService.init();
          AppLogger.log('Moov initialized');
        } catch (e) {
          AppLogger.log('Moov error: $e');
        }

        try {
          await StripeService.init();
          AppLogger.log('Stripe initialized');
        } catch (e) {
          AppLogger.log('Stripe error: $e');
        }
        */
        AppLogger.log('Skipping service initializations for testing');

        // Initialize controllers
        try {
          Get.put(AuthController());
        } catch (e) {
          AppLogger.log('Auth controller error: $e');
        }

        try {
          Get.put(SubscriptionController());
          AppLogger.log('Subscription controller initialized');
        } catch (e) {
          AppLogger.log('Subscription controller error: $e');
        }

        // Run the app
        print('🎯 About to run app...');
        runApp(
          MultiProvider(
            providers: [
              // Simplified providers for debugging
              ChangeNotifierProvider(create: (_) => UserProvider()),
              ChangeNotifierProvider<LoginViewModel>(
                create: (context) => LoginViewModel(),
              ),
              ChangeNotifierProvider(create: (_) => WalletViewModel()),
            ],
            child: const MyApp(),
          ),
        );
        print('✅ App started successfully');
      } catch (e) {
        AppLogger.log('App initialization error: $e');
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
    },
    (error, stack) {
      // Global error handler for uncaught exceptions
      AppLogger.log('Uncaught error: $error');
      AppLogger.log('Stack trace: $stack');
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
        // Threading utilities don't need explicit initialization
      },
            onDispose: () {
              // Clean up threading utilities
              ThreadingUtils.dispose();
            },
          ),
    );
  }
}
