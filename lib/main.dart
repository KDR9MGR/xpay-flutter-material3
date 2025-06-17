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

import 'utils/custom_color.dart';
import 'utils/strings.dart';
import 'views/auth/user_provider.dart';

void main() async {
  // Locking Device Orientation
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await GetStorage.init(); // initializing getStorage
  // main app
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<LoginViewModel>(
        create: (context) => LoginViewModel()),
    ChangeNotifierProvider(create: (_) => UserProvider()),
    ChangeNotifierProvider(create: (_) => WalletViewModel())
  ], child: const MyApp()));
}

// This widget is the root of your application.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      builder: (_, child) => GetMaterialApp(
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
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(1.0)),
              child: widget!);
        },
        translations: LocalString(),
        locale: Locale('en', 'US'),
      ),
    );
  }
}
