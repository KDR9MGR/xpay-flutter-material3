import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:xpay/controller/auth_controller.dart';
import 'package:xpay/routes/routes.dart';
import 'package:xpay/utils/storage_service.dart';
import 'package:xpay/views/auth/login_vm.dart';
import 'package:xpay/views/auth/user_provider.dart';
import 'package:xpay/widgets/buttons/primary_button.dart';
import 'package:xpay/widgets/inputs/text_field_input_widget.dart';
import 'package:xpay/widgets/inputs/text_label_widget.dart';

import '../../utils/custom_color.dart';
import '../../utils/custom_style.dart';
import '../../utils/dimensions.dart';
import '../../utils/strings.dart';
import '../../utils/utils.dart';
import '../../widgets/auth_nav_bar.dart';
import '../../widgets/inputs/pin_and_password_input_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  late final LoginViewModel? _loginViewModel;
  late final UserProvider _userProvider;
  final _storageService = StorageService();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: CustomColor.primaryGradient,
        ),
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: _bodyWidget(context, controller),
          ),
        ),
      ),
    );
  }

  // body widget containing all widget elements
  _bodyWidget(BuildContext context, AuthController controller) {
    return Padding(
      padding: EdgeInsets.only(
        left: Dimensions.marginSize,
        right: Dimensions.marginSize,
        top: Dimensions.marginSize,
      ),
      child: ListView(
        children: [
          _naveBarWidget(context, controller),
          _loginInfoWidget(context),
          SizedBox(
            height: Dimensions.heightSize * 2,
          ),
          _loginInputs(context, controller),
          SizedBox(
            height: Dimensions.heightSize * 2,
          ),
          _buttonWidget(context, controller),
        ],
      ),
    );
  }

  // navigation  bar widget
  _naveBarWidget(BuildContext context, AuthController controller) {
    return AuthNavBarWidget(
      title: Strings.signUp.tr,
      onPressed: () {
        controller.navigateToRegisterScreen();
      },
    );
  }

  // Login input and info
  _loginInputs(BuildContext context, AuthController controller) {
    return Container(
      padding: EdgeInsets.all(Dimensions.defaultPaddingSize),
      decoration: BoxDecoration(
        color: CustomColor.secondaryColor,
        borderRadius: BorderRadius.circular(Dimensions.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _loginInputWidget(context, controller),
          SizedBox(
            height: Dimensions.heightSize,
          ),
          GestureDetector(
            onTap: () {
              controller.navigateToForgetPinScreen();
              // _incorrectPassword(context, controller);
            },
            child: Text(
              '${Strings.forgetPassword.tr}?',
              style: TextStyle(
                color: CustomColor.primaryTextColor.withValues(alpha: 0.8),
                fontSize: Dimensions.smallestTextSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),
    );
  }

  // login info
  _loginInfoWidget(BuildContext context) {
    return Column(
      children: [
        Text(
          Strings.signIn.tr,
          style: CustomStyle.commonLargeTextTitleWhite,
        ),
        SizedBox(
          height: Dimensions.heightSize,
        ),
        Text(
          Strings.loginMessage.tr,
          style: TextStyle(
            color: CustomColor.primaryTextColor.withValues(alpha: 0.5),
            fontSize: Dimensions.smallTextSize,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // login inputs
  _loginInputWidget(BuildContext context, AuthController controller) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextLabelWidget(text: Strings.usernameOrEmail.tr),
          TextFieldInputWidget(
            controller: controller.emailAuthController,
            hintText: Strings.enterEmailHint.tr,
            borderColor: CustomColor.primaryColor,
            keyboardType: TextInputType.emailAddress,
            validator: MultiValidator([
              RequiredValidator(errorText: 'Please enter an email address'),
              EmailValidator(errorText: 'Please enter a valid email address')
            ]).call,
            color: CustomColor.secondaryColor,
          ),
          SizedBox(
            height: Dimensions.heightSize,
          ),
          TextLabelWidget(text: Strings.password.tr),
          PinAndPasswordInputWidget(
            hintText: Strings.enterPasswordHint.tr,
            keyboardType: TextInputType.visiblePassword,
            controller: controller.pinLoginController,
            validator: MultiValidator([
              RequiredValidator(errorText: 'Please enter a password'),
              LengthRangeValidator(
                  min: 6,
                  max: 16,
                  errorText:
                      'Password should be minimum 6 and max 16 characters')
            ]).call,
            borderColor: CustomColor.primaryColor,
            color: CustomColor.secondaryColor,
          ),
        ],
      ),
    );
  }



  // Login Button
  _buttonWidget(BuildContext context, AuthController controller) {
    return PrimaryButton(
      title: Strings.signIn.tr,
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          try {
            Utils.showLoadingDialog(context);
            final errorMessage = await _loginViewModel?.signIn(
                controller.emailAuthController.text.trim().toLowerCase(),
                controller.pinLoginController.text.trim());
            print(
                '${controller.emailAuthController.text.trim()} ${controller.pinLoginController.text.trim()}');

            if (errorMessage != null && errorMessage.isNotEmpty) {
              Navigator.pop(context);
              Utils.showDialogMessage(context, 'Sign In Failed', errorMessage);
            } else {
              Navigator.pop(context);
              await _storageService.saveValue(Strings.isLoggedIn, true);
              await _userProvider.fetchUserDetails();
              Get.offAllNamed(Routes.dashboardScreen);
            }
          } catch (ex) {
            Navigator.pop(context);
            Utils.showDialogMessage(
                context, 'Sign In Failed', 'Failed to sign in. $ex');
          }
        }
      },
      borderColorName: CustomColor.primaryColor,
      borderWidth: 0,
    );
  }

  @override
  void initState() {
    super.initState();
    _loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false);
  }
}
