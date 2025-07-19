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
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Firebase first
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    
    // Lock Device Orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Initialize storage
    await GetStorage.init();
    
    // Initialize Platform Payment Service (Primary for subscriptions)
    bool platformPaymentInitialized = false;
    try {
      await PlatformPaymentService.init();
      platformPaymentInitialized = true;
      print('Platform Payment Service initialized successfully');
    } catch (e) {
      print('Error initializing Platform Payment Service: $e');
    }
    
    // Initialize Moov (Primary backend)
    bool moovInitialized = false;
    try {
      await MoovService.init();
      moovInitialized = true;
      print('Moov initialized successfully');
    } catch (e) {
      print('Error initializing Moov: $e');
    }
    
    // Initialize Stripe (Fallback only)
    bool stripeInitialized = false;
    try {
      await StripeService.init();
      stripeInitialized = true;
      print('Stripe initialized successfully (fallback)');
    } catch (e) {
      print('Error initializing Stripe: $e');
    }
    
    // Check if at least one payment service is available
    if (!platformPaymentInitialized && !moovInitialized && !stripeInitialized) {
      print('Warning: No payment services initialized successfully');
    }
    
    // Initialize controllers
    Get.put(AuthController());
    
    // Initialize subscription controller with error handling
    try {
      Get.put(SubscriptionController());
      print('Subscription controller initialized');
    } catch (e) {
      print('Warning: Subscription controller initialization failed: $e');
      // App can still work without subscription controller
    }
    
    // Run the app
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<LoginViewModel>(create: (context) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => WalletViewModel())
      ],
      child: const MyApp(),
    ));
  } catch (e) {
    print('Error during app initialization: $e');
    // Run a minimal app that shows the error
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('App Initialization Error', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text('$e', textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
    ));
  }
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
      builder: (context, child) => GetMaterialApp(
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
              side: BorderSide(
                color: CustomColor.outlineColor,
                width: 1,
              ),
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
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
            child: widget!,
          );
        },
        translations: LocalString(),
        locale: const Locale('en', 'US'),
        fallbackLocale: const Locale('en', 'US'),
      ),
    );
  }
}
