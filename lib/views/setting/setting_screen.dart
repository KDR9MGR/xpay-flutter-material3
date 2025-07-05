import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/settings_controller.dart';
import '../../routes/routes.dart';
import '../../utils/custom_color.dart';
import '../../utils/custom_style.dart';
import '../../utils/dimensions.dart';
import '../../utils/strings.dart';
import '../../widgets/primary_appbar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    return Scaffold(
      appBar: PrimaryAppBar(
        appbarSize: Dimensions.defaultAppBarHeight,
        toolbarHeight: Dimensions.defaultAppBarHeight,
        title: Text(
          Strings.settings.tr,
          style: CustomStyle.commonTextTitleWhite,
        ),
        appBar: AppBar(),
        backgroundColor: CustomColor.appBarColor,
        autoLeading: false,
        elevation: 0,
        appbarColor: CustomColor.appBarColor,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: Dimensions.iconSizeDefault * 1.4,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: CustomColor.primaryGradient,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: _bodyWidget(context, controller),
        ),
      ),
    );
  }

  // body widget contain all the widgets
  _bodyWidget(BuildContext context, SettingsController controller) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          _selectOptionWidget(context, controller),
        ],
      ),
    );
  }

  _selectOptionWidget(BuildContext context, SettingsController controller) {
    return Expanded(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            settingsItemWidget(
              controller,
              onTap: () {
                controller.navigateToUpdateProfileScreen();
              },
              title: Strings.updateProfile.tr,
              icon: Icons.person_outline,
            ),
            SizedBox(
              height: Dimensions.heightSize,
            ),
            // Subscription Management Option
            settingsItemWidget(
              controller,
              onTap: () {
                Get.toNamed(Routes.subscriptionScreen);
              },
              title: 'Subscription Management',
              icon: Icons.subscriptions_outlined,
              isPremium: true,
            ),
            SizedBox(
              height: Dimensions.heightSize,
            ),
            settingsItemWidget(
              controller,
              onTap: () {
                controller.navigateToChangePasswordScreen();
              },
              title: Strings.changePassword.tr,
              icon: Icons.lock_outline,
            ),
            // SizedBox(
            //   height: Dimensions.heightSize,
            // ),
            // settingsItemWidget(
            //   controller,
            //   onTap: () {
            //     controller.navigateToTwoFaSecurity();
            //   },
            //   title: Strings.twoFASecurity.tr,
            // ),
            // SizedBox(
            //   height: Dimensions.heightSize,
            // ),
            // settingsItemWidget(
            //   controller,
            //   onTap: () {
            //     controller.navigateToChangeLanguageScreen();
            //   },
            //   title: Strings.changeLanguage.tr,
            // ),
            SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),
    );
  }

  settingsItemWidget(SettingsController controller,
      {required VoidCallback onTap, required String title, IconData? icon, bool isPremium = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: CustomColor.secondaryColor,
          borderRadius: BorderRadius.circular(Dimensions.radius * 2),
          border: isPremium ? Border.all(
            color: CustomColor.primaryColor.withValues(alpha: 0.3),
            width: 1,
          ) : null,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isPremium 
                    ? CustomColor.primaryColor.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isPremium ? CustomColor.primaryColor : Colors.white.withValues(alpha: 0.8),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
            ],
            Expanded(
              child: Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: Dimensions.smallTextSize,
                    ),
                  ),
                  if (isPremium) ...[
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [CustomColor.primaryColor, CustomColor.primaryColor.withValues(alpha: 0.7)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'PREMIUM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: CustomColor.primaryColor,
              size: Dimensions.iconSizeDefault * 1.5,
            )
          ],
        ),
      ),
    );
  }
}
