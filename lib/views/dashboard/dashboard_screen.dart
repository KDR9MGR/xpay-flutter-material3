import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:xpay/views/auth/user_provider.dart';
import 'package:xpay/widgets/primary_appbar.dart';

import '../../controller/dashboard_controller.dart';
import '../../utils/custom_color.dart';
import '../../utils/dimensions.dart';
import '../../utils/strings.dart';
import '../../widgets/dashboard_option_widget.dart';
import '../../widgets/navigation_drawer_widget.dart';
import '../../widgets/slider_widget.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<SliderWidget> sliderList = [
    const SliderWidget(),
    const SliderWidget(),
    const SliderWidget(),
    const SliderWidget(),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    return Scaffold(
      backgroundColor: CustomColor.screenBGColor,
      body: SafeArea(
        child: Column(
          children: [
            _modernAppBarWidget(context, controller),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(Dimensions.defaultPaddingSize - 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _balanceCardWidget(context, controller),
                      SizedBox(height: Dimensions.heightSize * 2),
                      _quickActionsWidget(context, controller),
                      SizedBox(height: Dimensions.heightSize * 2),
                      _additionalFeaturesWidget(context, controller),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      endDrawer: const NavigationDrawerWidget(),
    );
  }

  // Modern app bar widget with clean design
  Widget _modernAppBarWidget(BuildContext context, DashboardController controller) {
    return Container(
      padding: EdgeInsets.all(Dimensions.defaultPaddingSize),
      decoration: BoxDecoration(
        color: CustomColor.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Consumer<UserProvider>(
        builder: (BuildContext context, UserProvider userProvider, Widget? child) {
          return Row(
            children: [
              // Profile section
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: CustomColor.onPrimaryTextColor.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: (userProvider.user!.profilePhoto!.isNotEmpty &&
                            userProvider.user!.profilePhoto != null)
                        ? CircleAvatar(
                            radius: 26,
                            backgroundImage: NetworkImage(userProvider.user!.profilePhoto!))
                        : CircleAvatar(
                            radius: 26,
                            backgroundColor: CustomColor.onPrimaryTextColor.withOpacity(0.1),
                            child: Icon(
                              Icons.person,
                              color: CustomColor.onPrimaryTextColor,
                              size: 28,
                            ),
                          ),
                  ),
                  SizedBox(width: Dimensions.widthSize),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          color: CustomColor.onPrimaryTextColor.withOpacity(0.7),
                          fontSize: Dimensions.smallestTextSize,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        userProvider.user!.firstName,
                        style: TextStyle(
                          color: CustomColor.onPrimaryTextColor,
                          fontSize: Dimensions.mediumTextSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Spacer(),
              // Menu button
              Builder(
                builder: (context) => Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: CustomColor.onPrimaryTextColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    icon: Icon(
                      Icons.menu_rounded,
                      color: CustomColor.onPrimaryTextColor,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Balance card widget with modern design
  Widget _balanceCardWidget(BuildContext context, DashboardController controller) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Card(
          color: CustomColor.surfaceColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: CustomColor.primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(Dimensions.defaultPaddingSize * 1.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Balance',
                          style: TextStyle(
                            color: CustomColor.secondaryTextColor,
                            fontSize: Dimensions.smallestTextSize,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: Dimensions.heightSize * 0.5),
                        Obx(() => AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: controller.showBalance.value
                              ? Text(
                                  'Tap to view',
                                  key: const Key('tap'),
                                  style: TextStyle(
                                    color: CustomColor.primaryTextColor,
                                    fontSize: Dimensions.largeTextSize,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : Text(
                                  '\$${userProvider.user?.walletBalances['USD']?.toStringAsFixed(2) ?? '0.00'}',
                                  key: const Key('balance'),
                                  style: TextStyle(
                                    color: CustomColor.primaryColor,
                                    fontSize: Dimensions.largeTextSize,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        )),
                      ],
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: CustomColor.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          controller.changeBalanceStatus();
                        },
                        icon: Icon(
                          controller.showBalance.value
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: CustomColor.primaryColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Quick actions widget with modern card design
  Widget _quickActionsWidget(BuildContext context, DashboardController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            color: CustomColor.primaryTextColor,
            fontSize: Dimensions.mediumTextSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Dimensions.heightSize),
        Row(
          children: [
            Expanded(
              child: _actionCard(
                context,
                icon: Icons.add_circle_outline_rounded,
                title: 'Add Money',
                subtitle: 'Top up wallet',
                onTap: () => controller.navigateToAddMoneyScreen(),
              ),
            ),
            SizedBox(width: Dimensions.widthSize),
            Expanded(
              child: _actionCard(
                context,
                icon: Icons.send_rounded,
                title: 'Send Money',
                subtitle: 'Transfer funds',
                onTap: () => controller.navigateToMoneyOutScreen(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Action card widget
  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: CustomColor.surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: CustomColor.outlineColor,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(Dimensions.defaultPaddingSize),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: CustomColor.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: CustomColor.primaryColor,
                  size: 24,
                ),
              ),
              SizedBox(height: Dimensions.heightSize),
              Text(
                title,
                style: TextStyle(
                  color: CustomColor.primaryTextColor,
                  fontSize: Dimensions.smallTextSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: CustomColor.secondaryTextColor,
                  fontSize: Dimensions.smallestTextSize,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Additional features widget
  Widget _additionalFeaturesWidget(BuildContext context, DashboardController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'More Services',
          style: TextStyle(
            color: CustomColor.primaryTextColor,
            fontSize: Dimensions.mediumTextSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Dimensions.heightSize),
        Card(
          color: CustomColor.surfaceColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: CustomColor.outlineColor,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _serviceListTile(
                icon: Icons.qr_code_scanner_rounded,
                title: 'Scan QR Code',
                subtitle: 'Quick payments',
                onTap: () {},
              ),
              Divider(color: CustomColor.outlineColor, height: 1),
              _serviceListTile(
                icon: Icons.history_rounded,
                title: 'Transactions',
                subtitle: 'View history',
                onTap: () {},
              ),
              Divider(color: CustomColor.outlineColor, height: 1),
              _serviceListTile(
                icon: Icons.support_agent_rounded,
                title: 'Support',
                subtitle: 'Get help',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Service list tile widget
  Widget _serviceListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: CustomColor.primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: CustomColor.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: CustomColor.primaryTextColor,
          fontSize: Dimensions.smallTextSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: CustomColor.secondaryTextColor,
          fontSize: Dimensions.smallestTextSize,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: CustomColor.secondaryTextColor,
        size: 16,
      ),
    );
  }

  // middle slider widget made with Carousel slider and smooth page indicator
  _middleSliderWidget(BuildContext context, DashboardController controller) {
    return Container(
      padding: EdgeInsets.only(bottom: Dimensions.defaultPaddingSize * 0.5),
      color: CustomColor.secondaryColor,
      child: Obx(
        () => Center(
          child: Column(
            children: [
              CarouselSlider.builder(
                itemCount: sliderList.length,
                itemBuilder: (context, index, realIndex) {
                  return _buildSlider(context, index);
                },
                options: CarouselOptions(
                    enlargeCenterPage: true,
                    viewportFraction: 0.70,
                    height: MediaQuery.of(context).size.height / 4,
                    onPageChanged: (index, reason) =>
                        controller.changeIndicator(index)),
              ),
              SizedBox(
                height: Dimensions.heightSize,
              ),
              _buildIndicator(context, controller),
            ],
          ),
        ),
      ),
    );
  }

  // for slider banner
  _buildSlider(BuildContext context, int index) {
    return sliderList[index];
  }

  // for slider dot indicator
  _buildIndicator(BuildContext context, DashboardController controller) {
    return AnimatedSmoothIndicator(
      activeIndex: controller.activeIndex.value,
      count: sliderList.length,
      effect: SlideEffect(
        dotHeight: 8,
        dotWidth: 8,
        activeDotColor: CustomColor.primaryColor,
        dotColor: Colors.grey.withOpacity(0.5),
      ),
    );
  }

  _verificationInfoWidget(
      BuildContext context, DashboardController controller, bool isPending) {
    return Container(
      decoration: const BoxDecoration(color: CustomColor.secondaryColor),
      child: Container(
        margin: const EdgeInsets.only(top: 10, left: 15, right: 15),
        padding: const EdgeInsets.only(left: 10, right: 10),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: CustomColor.screenBGColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(Dimensions.radius * 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.idCard,
                  color: CustomColor.primaryColor,
                  size: Dimensions.iconSizeDefault,
                ),
                SizedBox(
                  width: Dimensions.widthSize,
                ),
              ],
            ),
            Expanded(
              child: Text(
                Strings.verificationSubmitInfo.tr,
                style: TextStyle(
                  color: CustomColor.primaryTextColor.withOpacity(0.8),
                  fontSize: Dimensions.smallestTextSize * 0.7,
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: Dimensions.widthSize * 7,
              height: Dimensions.heightSize * 2,
              child: ElevatedButton(
                onPressed: () {
                  controller.navigateToVerifyAccountScreen();
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    isPending
                        ? const Color(0xffff8e2c)
                        : CustomColor.primaryColor,
                  ),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radius * 2),
                    ),
                  ),
                ),
                child: Text(
                  isPending ? Strings.pending.tr : Strings.submit.tr,
                  style: TextStyle(
                    fontSize: Dimensions.smallestTextSize * 0.7,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
