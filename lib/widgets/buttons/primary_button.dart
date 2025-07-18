import 'package:flutter/material.dart';
import 'package:xpay/utils/dimensions.dart';

import '../../utils/custom_color.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.borderColorName = CustomColor.appBarColor,
    this.borderWidth = 0,
    this.height,
    this.buttonColor = CustomColor.appBarColor,
    this.buttonTextColor = Colors.white,
  });
  final String title;
  final VoidCallback onPressed;
  final Color borderColorName;
  final double borderWidth;
  final double? height;
  final Color buttonColor;
  final Color buttonTextColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? Dimensions.buttonHeight,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          side: BorderSide(
            width: borderWidth,
            color: borderColorName,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: Dimensions.mediumTextSize,
            color: buttonTextColor,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
