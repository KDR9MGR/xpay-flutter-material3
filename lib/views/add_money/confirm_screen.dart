import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpay/widgets/buttons/primary_button.dart';

import '../../../../utils/custom_color.dart';
import '../../../../utils/custom_style.dart';
import '../../../../utils/dimensions.dart';
import '../../../../utils/strings.dart';
import '../../controller/add_money_controller.dart';

class ConfirmAddMoneyScreen extends StatelessWidget {
  ConfirmAddMoneyScreen({super.key});
  final dynamicPasswordFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddMoneyController());
    return Scaffold(
      backgroundColor: CustomColor.screenBGColor,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: _bodyWidget(context, controller),
      ),
    );
  }

  // body widget that contain all the widget
  _bodyWidget(BuildContext context, AddMoneyController controller) {
    return Padding(
        padding: EdgeInsets.only(
          left: Dimensions.marginSize - 5,
          right: Dimensions.marginSize - 5,
          top: Dimensions.marginSize * 0.5,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _upperLogoInfoWidget(context),
            SizedBox(
              height: Dimensions.heightSize * 2,
            ),
            _nextButton(context, controller),
          ],
        ));
  }

  // bank info widget
  _upperLogoInfoWidget(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(Dimensions.defaultWidgetHeight),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: Dimensions.defaultPaddingSize),
            child: Column(
              children: [
                Image.asset(Strings.congratulationsImagePath),
                Text(
                  Strings.congratulations.tr,
                  style: TextStyle(
                    color: CustomColor.primaryTextColor.withValues(alpha: 0.8),
                    fontSize: Dimensions.smallTextSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: Dimensions.heightSize * 2,
                ),
                Text(
                  Strings.addMoneyConfirm.tr,
                  style: CustomStyle.bankToXPayReviewStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _nextButton(BuildContext context, AddMoneyController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.defaultWidgetWidth),
      child: Column(
        children: [
          PrimaryButton(
            title: Strings.okay.tr,
            onPressed: () {
              controller.navigateToDashboardScreen();
              Get.delete<AddMoneyController>();
            },
          ),
          SizedBox(
            height: Dimensions.heightSize * 2,
          ),
        ],
      ),
    );
  }
}
