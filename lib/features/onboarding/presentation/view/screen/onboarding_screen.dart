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

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingModel> _pages = [
    OnboardingModel(
      title: AppLocaleKey.exploreLuxuryCars.tr(),
      description: AppLocaleKey.exploreLuxuryCarsDescription.tr(),
      image: AppImages.assetsImagesOnboardingCarSelection,
      isImage: true,
    ),
    OnboardingModel(
      title: AppLocaleKey.carsAtDealer.tr(),
      description: AppLocaleKey.keepCarTopCondition.tr(),
      image: AppImages.assetsImagesOnboardingCarService,
      isImage: true,
    ),
    OnboardingModel(
      title: AppLocaleKey.fastSecureDelivery.tr(),
      description: AppLocaleKey.experienceSeamlessDelivery.tr(),
      image: Icons.speed_rounded,
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
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColor.whiteColor(context),
              AppColor.whiteColor(context),
              AppColor.primaryColor(context).withValues(alpha: 0.18),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.only(start: 20.w, top: 8.h),
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: _currentPage == _pages.length - 1 ? 0 : 1,
                    child: IgnorePointer(
                      ignoring: _currentPage == _pages.length - 1,
                      child: TextButton(
                        onPressed: _finishOnboarding,
                        child: Text(
                          AppLocaleKey.skip.tr(),
                          style: AppTextStyle.bodyLarge(context).copyWith(
                            color: AppColor.primaryColor(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) =>
                      OnboardingPageItem(model: _pages[index]),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 28.h),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          height: 6.h,
                          width: _currentPage == index ? 22.w : 6.w,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? AppColor.primaryColor(context)
                                : AppColor.primaryColor(
                                    context,
                                  ).withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 22.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage < _pages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _finishOnboarding();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryColor(context),
                          foregroundColor: AppColor.whiteColor(context),
                          minimumSize: Size.fromHeight(54.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? AppLocaleKey.getStarted.tr()
                              : AppLocaleKey.next.tr(),
                          style: AppTextStyle.bodyLarge(context).copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _finishOnboarding() {
    HiveMethods.updateFirstTime();
    HiveMethods.updateIsGuest(true);
    NavigatorMethods.pushReplacementNamed(context, RoutesName.mainLayout);
  }
}
