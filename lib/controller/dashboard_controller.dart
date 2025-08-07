import 'package:firebase_auth/firebase_auth.dart';
import '/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../routes/routes.dart';

List<String> languageList = ['English ', 'Spanish', 'Chinese', 'Hindi'];

class DashboardController extends GetxController {
  RxBool showBalance = true.obs;
  RxInt activeIndex = 0.obs;
  RxBool isPending = false.obs;
  RxString termDropdownValue = languageList[0].obs;

  final List<String> languageValueList = languageList;

  final changeNameController = TextEditingController();
  final chatController = TextEditingController();
  final dropdownController = TextEditingController();
  final nidNameController = TextEditingController();
  final nidNumberController = TextEditingController();

  @override
  void dispose() {
    changeNameController.dispose();
    chatController.dispose();
    dropdownController.dispose();
    super.dispose();
  }

  void navigateToDashboardScreen() {
    Get.toNamed(Routes.navigationScreen);
  }

  Future<void> changeBalanceStatus() async {
    showBalance.value = !showBalance.value;
    await Future.delayed(const Duration(seconds: 5));
    showBalance.value = !showBalance.value;
  }

  void changeIndicator(int value) {
    activeIndex.value = value;
  }

  void navigateToInvoiceScreen() {
    Get.toNamed(Routes.invoiceScreen);
  }

  void navigateToVoucherScreen() {
    Get.toNamed(Routes.voucherScreen);
  }

  void navigateToSendMoney() {
    Get.toNamed(Routes.addNumberSendMoneyScreen);
  }

  void navigateToMakePaymentScreen() {
    Get.toNamed(Routes.makePaymentScreen);
  }

  void navigateToMoneyOutScreen() {
    Get.toNamed(Routes.moneyOutScreen);
  }

  void navigateToAddNumberPaymentScreen() {
    Get.toNamed(Routes.addNumberPaymentScreen);
  }

  void navigateToAddMoneyScreen() {
    Get.toNamed(Routes.addMoneyMoneyScreen);
  }

  void navigateToRequestScreen() {
    Get.toNamed(Routes.requestScreen);
  }

  void navigateToTransferMoneyScreen() {
    Get.toNamed(Routes.transferMoneyScreen);
  }

  void navigateToCurrencyExchangeScreen() {
    Get.toNamed(Routes.currencyExchangeScreen);
  }

  void navigateToSavingRulesScreen() {
    Get.toNamed(Routes.savingRulesScreen);
  }

  void navigateToRemittanceSourceScreen() {
    Get.toNamed(Routes.remittanceSourceScreen);
  }

  void navigateToWithdrawScreen() {
    Get.toNamed(Routes.withdrawScreen);
  }

  void navigateToRequestToMeScreen() {
    Get.toNamed(Routes.requestToMeScreen);
  }

  void navigateToAddMoneyHistoryScreen() {
    Get.toNamed(Routes.addMoneyHistoryScreen);
  }

  void navigateToTransactionHistoryScreen() {
    Get.toNamed(Routes.transactionsHistoryScreen);
  }

  void navigateToWithdrawHistoryScreen() {
    Get.toNamed(Routes.withdrawHistoryScreen);
  }

  void navigateToMyQrCodeScreen() {
    Get.toNamed(Routes.myQrCodeScreen);
  }

  void navigateToXPayMapScreen() {
    Get.toNamed(Routes.xPayMapScreen);
  }

  void navigateToSettingScreen() {
    Get.toNamed(Routes.settingsScreen);
  }

  void navigateToChangeNameScreen() {
    Get.toNamed(Routes.changeNameScreen);
  }

  void navigateToChangePictureScreen() {
    Get.toNamed(Routes.changePictureScreen);
  }

  void navigateToSupportScreen() {
    Get.toNamed(Routes.supportScreen);
  }

  void navigateToLiveChatScreen() {
    Get.toNamed(Routes.liveChatScreen);
  }

  void navigateToVerifyAccountScreen() {
    Get.toNamed(Routes.verifyAccountScreen);
  }

  Future<void> signOut() async {
    try {
      await GetStorage().erase();

      await FirebaseAuth.instance.signOut();
      Get.offAllNamed(Routes.onBoardScreen);
    } catch (e) {
      AppLogger.log('Error signing out: $e');
    }
  }
}
