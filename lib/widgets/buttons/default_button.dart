import 'package:flutter/material.dart';

import '../../utils/custom_color.dart';
import '../../utils/custom_style.dart';

class DefaultButton extends StatelessWidget {
  const DefaultButton({super.key, required this.title, required this.onPressed});
  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: CustomColor.primaryColor,
      ),
      child: Text(
        title,
        style: CustomStyle.defaultButtonStyle,
      ),
    );
  }
}
