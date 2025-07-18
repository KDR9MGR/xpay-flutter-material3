import 'package:flutter/material.dart';

import '../../utils/dimensions.dart';

class TextLabelWidget extends StatelessWidget {
  final String text;

  const TextLabelWidget(
      {super.key, required this.text, this.color = Colors.white});
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          textAlign: TextAlign.left,
          style: TextStyle(
            color: color,
            fontSize: Dimensions.mediumTextSize,
          ),
        ),
      ),
    );
  }
}
