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

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  final List<SliderWidget> sliderList = [
    const SliderWidget(),
    const SliderWidget(),
    const SliderWidget(),
    const SliderWidget(),
  ];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    return Scaffold(
      backgroundColor: CustomColor.screenBGColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _modernAppBarWidget(context, controller),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24),
                      _balanceCardWidget(context, controller),
                      SizedBox(height: 32),
                      _quickActionsWidget(context, controller),
                      SizedBox(height: 32),
                      _featuredServicesWidget(context, controller),
                      SizedBox(height: 32),
                      _additionalFeaturesWidget(context, controller),
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      endDrawer: const NavigationDrawerWidget(),
    );
  }

  // Modern app bar with glassmorphism effect
  Widget _modernAppBarWidget(BuildContext context, DashboardController controller) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CustomColor.appBarColor,
            CustomColor.appBarColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: CustomColor.appBarColor.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Consumer<UserProvider>(
        builder: (BuildContext context, UserProvider userProvider, Widget? child) {
          return Row(
            children: [
              // Enhanced Profile section
              Expanded(
                child: InkWell(
                  onTap: () => Get.toNamed('/updateProfileScreen'),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.2),
                                    Colors.white.withOpacity(0.1),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: (userProvider.user!.profilePhoto!.isNotEmpty &&
                                      userProvider.user!.profilePhoto != null)
                                  ? CircleAvatar(
                                      radius: 30,
                                      backgroundImage: NetworkImage(userProvider.user!.profilePhoto!))
                                  : CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.white.withOpacity(0.1),
                                      child: Icon(
                                        Icons.person_rounded,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: CustomColor.successColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                userProvider.user!.firstName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Enhanced Menu button
              Builder(
                builder: (context) => Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    icon: Icon(
                      Icons.menu_rounded,
                      color: Colors.white,
                      size: 28,
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

  // Enhanced balance card with glassmorphism
  Widget _balanceCardWidget(BuildContext context, DashboardController controller) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                CustomColor.surfaceColor.withOpacity(0.9),
                CustomColor.surfaceColor.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white.withOpacity(0.6),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Total Balance',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Obx(() => AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: controller.showBalance.value
                              ? Text(
                                  'Tap to view',
                                  key: const Key('tap'),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                )
                              : Text(
                                  '\$${userProvider.user?.walletBalances['USD']?.toStringAsFixed(2) ?? '0.00'}',
                                  key: const Key('balance'),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                ),
                        )),
                      ],
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          controller.changeBalanceStatus();
                        },
                        icon: Icon(
                          controller.showBalance.value
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.trending_up_rounded,
                        color: CustomColor.successColor,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '+12.5% this month',
                        style: TextStyle(
                          color: CustomColor.successColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Enhanced quick actions with modern design
  Widget _quickActionsWidget(BuildContext context, DashboardController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: CustomColor.appBarColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Quick Actions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _modernActionCard(
                  context,
                  icon: Icons.add_circle_outline_rounded,
                  title: 'Add Money',
                  subtitle: 'Top up wallet',
                  color: CustomColor.appBarColor,
                  onTap: () => controller.navigateToAddMoneyScreen(),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _modernActionCard(
                  context,
                  icon: Icons.send_rounded,
                  title: 'Send Money',
                  subtitle: 'Transfer funds',
                  color: CustomColor.successColor,
                  onTap: () => controller.navigateToMoneyOutScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Modern action card with enhanced design
  Widget _modernActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CustomColor.surfaceColor.withOpacity(0.8),
            CustomColor.surfaceColor.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Featured services section
  Widget _featuredServicesWidget(BuildContext context, DashboardController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: CustomColor.appBarColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Featured Services',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            child: Row(
              children: [
                _featuredServiceCard(
                  icon: Icons.qr_code_scanner_rounded,
                  title: 'QR Pay',
                  color: CustomColor.appBarColor,
                  onTap: () => Get.toNamed('/scanQeCodeScreen'),
                ),
                SizedBox(width: 16),
                _featuredServiceCard(
                  icon: Icons.credit_card_rounded,
                  title: 'Cards',
                  color: CustomColor.warningColor,
                  onTap: () {},
                ),
                SizedBox(width: 16),
                _featuredServiceCard(
                  icon: Icons.savings_rounded,
                  title: 'Savings',
                  color: CustomColor.successColor,
                  onTap: () {},
                ),
                SizedBox(width: 16),
                _featuredServiceCard(
                  icon: Icons.analytics_rounded,
                  title: 'Analytics',
                  color: Colors.purple,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featuredServiceCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Enhanced more services section
  Widget _additionalFeaturesWidget(BuildContext context, DashboardController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: CustomColor.appBarColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'More Services',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CustomColor.surfaceColor.withOpacity(0.8),
                  CustomColor.surfaceColor.withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _modernServiceListTile(
                  icon: Icons.history_rounded,
                  title: 'Transactions',
                  subtitle: 'View history',
                  onTap: () => controller.navigateToTransactionHistoryScreen(),
                ),
                Divider(color: Colors.white.withOpacity(0.1), height: 1),
                _modernServiceListTile(
                  icon: Icons.support_agent_rounded,
                  title: 'Support',
                  subtitle: 'Get help',
                  onTap: () => controller.navigateToSupportScreen(),
                ),
                Divider(color: Colors.white.withOpacity(0.1), height: 1),
                _modernServiceListTile(
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  subtitle: 'Manage account',
                  onTap: () => controller.navigateToSettingScreen(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Modern service list tile
  Widget _modernServiceListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CustomColor.appBarColor.withOpacity(0.3),
                      CustomColor.appBarColor.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: CustomColor.appBarColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
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
