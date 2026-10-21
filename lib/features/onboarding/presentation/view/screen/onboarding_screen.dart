import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/images/app_images.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/navigator_methods.dart';
import 'package:car/features/onboarding/data/model/on_boarding_model.dart';
import 'package:car/features/onboarding/presentation/view/screen/widget/onboarding_page_item_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingModel> _getPages() => [
    OnboardingModel(
      pageIndex: 0,
      title: AppLocaleKey.onboarding1Title.tr(),
      description: AppLocaleKey.onboarding1Desc.tr(),
      image: AppImages.assetsImagesGclass,
      isImage: true,
    ),
    OnboardingModel(
      pageIndex: 1,
      title: AppLocaleKey.onboarding2Title.tr(),
      description: AppLocaleKey.onboarding2Desc.tr(),
      image: Icons.verified_user_rounded,
      isImage: false,
    ),
    OnboardingModel(
      pageIndex: 2,
      title: AppLocaleKey.onboarding3Title.tr(),
      description: AppLocaleKey.onboarding3Desc.tr(),
      image: Icons.local_shipping_rounded,
      isImage: false,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = _getPages();

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColor.whiteColor(context),
              AppColor.whiteColor(context),
              AppColor.whiteColor(context).withValues(alpha: 0.12),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header: Page Counter (Right in RTL) & Skip Button (Left in RTL)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_currentPage + 1} ${AppLocaleKey.pageCounterOf.tr()} ${pages.length}',
                      style: AppTextStyle.bodyMedium(context).copyWith(
                        color: AppColor.blackTextColor(context).withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: _currentPage == pages.length - 1 ? 0 : 1,
                      child: IgnorePointer(
                        ignoring: _currentPage == pages.length - 1,
                        child: TextButton(
                          onPressed: _finishOnboardingAsGuest,
                          child: Text(
                            AppLocaleKey.skip.tr(),
                            style: AppTextStyle.bodyMedium(context).copyWith(
                              color: AppColor.blackTextColor(context).withValues(alpha: 0.65),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) => OnboardingPageItem(model: pages[index]),
                ),
              ),

              // Bottom Actions
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 6.h, 24.w, 18.h),
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: _currentPage == pages.length - 1
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryColor(context),
                        foregroundColor: Colors.white,
                        minimumSize: Size.fromHeight(40.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                      child: Text(
                        AppLocaleKey.next.tr(),
                        style: AppTextStyle.bodyLarge(
                          context,
                        ).copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  secondChild: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Button 1: Create Account
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _finishOnboardingTo(RoutesName.registerScreen),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primaryColor(context),
                            foregroundColor: Colors.white,
                            minimumSize: Size.fromHeight(40.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            AppLocaleKey.createAccount.tr(),
                            style: AppTextStyle.bodyLarge(
                              context,
                            ).copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      Gap(10.h),

                      // Button 2: Browse as Guest
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _finishOnboardingAsGuest,
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size.fromHeight(35.h),
                            backgroundColor: AppColor.whiteColor(context),
                            side: BorderSide(
                              color: AppColor.greyColor(context).withValues(alpha: 0.44),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            AppLocaleKey.browseCarsAsGuest.tr(),
                            style: AppTextStyle.bodyMedium(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColor.blackTextColor(context),
                            ),
                          ),
                        ),
                      ),
                      Gap(10.h),

                      // Link: Already have account? Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocaleKey.alreadyHaveAccount.tr(),
                            style: AppTextStyle.bodySmall(context).copyWith(
                              color: AppColor.blackTextColor(context).withValues(alpha: 0.65),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _finishOnboardingTo(RoutesName.loginScreen),
                            child: Text(
                              AppLocaleKey.login.tr(),
                              style: AppTextStyle.bodySmall(context).copyWith(
                                color: AppColor.primaryColor(context),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _finishOnboardingTo(String routeName) {
    HiveMethods.updateFirstTime();
    NavigatorMethods.pushReplacementNamed(context, routeName);
  }

  void _finishOnboardingAsGuest() {
    HiveMethods.updateFirstTime();
    HiveMethods.updateIsGuest(true);
    NavigatorMethods.pushReplacementNamed(context, RoutesName.mainLayout);
  }
}
