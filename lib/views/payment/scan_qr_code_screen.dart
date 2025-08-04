import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';

import '../../utils/custom_color.dart';
import '../../utils/custom_style.dart';
import '../../utils/dimensions.dart';
import '../../utils/strings.dart';
import '../../widgets/primary_appbar.dart';

class MakePaymentScanQrCodeScreen extends StatefulWidget {
  const MakePaymentScanQrCodeScreen({super.key});

  @override
  MakePaymentScanQrCodeScreenState createState() =>
      MakePaymentScanQrCodeScreenState();
}

class MakePaymentScanQrCodeScreenState
    extends State<MakePaymentScanQrCodeScreen> {
  bool isDetected = false;

  void onBarcodeDetected(String value) {
    if (!isDetected) {
      setState(() {
        isDetected = true;
      });
      // Process the QR code data
      // print('QR Code detected: $value');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PrimaryAppBar(
        appbarColor: CustomColor.primaryColor,
        backgroundColor: CustomColor.primaryColor,
        autoLeading: false,
        elevation: 1,
        appBar: AppBar(),
        title: Text(
          Strings.scanQrTitle.tr,
          style: CustomStyle.commonTextTitleWhite,
        ),
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
        appbarSize: Dimensions.defaultAppBarHeight,
        toolbarHeight: Dimensions.defaultAppBarHeight,
      ),
      backgroundColor: CustomColor.screenBGColor,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: _bodyWidget(context),
      ),
    );
  }

  // body widget containing all widget elements
  Center _bodyWidget(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Positioned(child: _scanQrCodeWidget(context)),
          Positioned(
            bottom: 50,
            right: 20,
            left: 20,
            child: _qrCodeBottomMessageWidget(context),
          ),
        ],
      ),
    );
  }

  // QR code scan with qr code image
  SizedBox _scanQrCodeWidget(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: _buildQrViewWidget(context),
    );
  }

  // bottom qr code message
  InkWell _qrCodeBottomMessageWidget(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isDetected = false;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultPaddingSize,
        ),
        height: 70,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radius),
        ),
        child: Row(
          children: [
            Image.asset(Strings.qrCodeIconImagePath),
            SizedBox(width: Dimensions.widthSize),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  Strings.qrCodeMessage.tr,
                  style: TextStyle(
                    color: CustomColor.primaryColor,
                    fontSize: Dimensions.smallTextSize * 0.9,
                    fontWeight: FontWeight.w500,
                  ),
                  softWrap: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrViewWidget(BuildContext context) {
    return AiBarcodeScanner(
      onScan: onBarcodeDetected,
      showOverlay: true,
      overlayColor: Colors.black.withOpacity(0.5),
      borderColor: CustomColor.primaryColor,
      borderWidth: 2.0,
      borderLength: 30.0,
      borderRadius: 10.0,
      cutOutSize: 250.0,
    );
  }

}
}
