import 'package:flutter/material.dart';

import '../utils/custom_color.dart';
import '../utils/dimensions.dart';

// transaction card widget
class MySupportTicketsItemWidget extends StatelessWidget {
  const MySupportTicketsItemWidget({
    super.key,
    required this.imagePath,
    required this.title,
    required this.dateAndTime,
    required this.subTitle,
    required this.isSolved,
    required this.isRejected,
    required this.transactionNumber,
  });
  final String imagePath;
  final String title;
  final String dateAndTime;

  final String subTitle;
  final String transactionNumber;

  final bool isSolved;
  final bool isRejected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 8,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultPaddingSize - 15,
        ),
        child: Row(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 10,
              width: MediaQuery.of(context).size.height / 12,
              child: CircleAvatar(
                backgroundColor: CustomColor.secondaryColor,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              width: Dimensions.widthSize,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: CustomColor.primaryTextColor,
                          fontSize: Dimensions.mediumTextSize * 0.8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        dateAndTime,
                        style: TextStyle(
                          color: CustomColor.primaryTextColor.withValues(alpha: 0.5),
                          fontSize: Dimensions.smallestTextSize * 0.8,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: Dimensions.heightSize * 0.5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        subTitle,
                        style: TextStyle(
                          color: CustomColor.primaryTextColor.withValues(alpha: 0.5),
                          fontSize: Dimensions.smallestTextSize * 0.9,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      SizedBox(
                        height: 25,
                        width: 80,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(
                              isSolved
                                  ? const Color(0xff13c366)
                                  : isRejected
                                      ? Colors.red
                                      : const Color(0xffff8e2c),
                            ),
                            shape: WidgetStateProperty.all<
                                ContinuousRectangleBorder>(
                              ContinuousRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(Dimensions.radius),
                              ),
                            ),
                          ),
                          child: Text(
                            isSolved
                                ? 'Solved'
                                : isRejected
                                    ? 'Rejected'
                                    : 'Pending',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: Dimensions.smallestTextSize * 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    transactionNumber,
                    style: TextStyle(
                      color: CustomColor.primaryTextColor.withValues(alpha: 0.5),
                      fontSize: Dimensions.smallestTextSize * 0.9,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
