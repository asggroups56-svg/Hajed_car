import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/copyright_widget.dart';
import 'package:car/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/navigator_methods.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late Animation<double> _avatarScale;
  late Animation<double> _avatarFade;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subTitleFade;
  late Animation<double> _badgeFade;
  late Animation<double> _badgeScale;
  late Animation<double> _pulseGlow;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _avatarScale = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
    );

    _avatarFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
    );

    _titleFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.25, 0.65, curve: Curves.easeOut),
    );

    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.25, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _subTitleFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
    );

    _badgeFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.55, 0.95, curve: Curves.easeOut),
    );

    _badgeScale = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.55, 0.95, curve: Curves.easeOutBack),
    );

    _pulseGlow = Tween<double>(
      begin: 0.9,
      end: 1.12,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _entranceController.forward();
    _navigateToNextScreen();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(milliseconds: 3200)).then((value) {
      if (mounted) {
        if (HiveMethods.isFirstTime()) {
          NavigatorMethods.pushReplacementNamed(context, RoutesName.onboardingScreen);
        } else if (HiveMethods.getToken() != null) {
          if (HiveMethods.isUserRole()) {
            NavigatorMethods.pushReplacementNamed(context, RoutesName.mainLayout);
          } else if (HiveMethods.isAgentRole()) {
            NavigatorMethods.pushReplacementNamed(context, RoutesName.agentDashboard);
          } else {
            NavigatorMethods.pushReplacementNamed(context, RoutesName.adminDashboard);
          }
        } else {
          HiveMethods.updateIsGuest(true);
          NavigatorMethods.pushReplacementNamed(context, RoutesName.mainLayout);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: isDark
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF1E293B),
                    AppColor.primaryColor(context).withValues(alpha: 0.2),
                  ]
                : [
                    AppColor.secondAppColor(context),
                    AppColor.gradientSecondaryColor(context),
                    AppColor.primaryColor(context).withValues(alpha: 0.25),
                  ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return ScaleTransition(
                            scale: _avatarScale,
                            child: FadeTransition(
                              opacity: _avatarFade,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Transform.scale(
                                    scale: _pulseGlow.value,
                                    child: Container(
                                      width: 175.w,
                                      height: 175.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColor.primaryColor(
                                              context,
                                            ).withValues(alpha: isDark ? 0.45 : 0.35),
                                            blurRadius: 45,
                                            spreadRadius: 8,
                                          ),
                                          BoxShadow(
                                            color: isDark
                                                ? AppColor.whiteColor(
                                                    context,
                                                  ).withValues(alpha: 0.1)
                                                : AppColor.secondAppColor(
                                                    context,
                                                  ).withValues(alpha: 0.4),
                                            blurRadius: 25,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  Container(
                                    width: 145.w,
                                    height: 145.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDark
                                            ? AppColor.whiteColor(context).withValues(alpha: 0.3)
                                            : AppColor.whiteColor(context).withValues(alpha: 0.8),
                                        width: 3.w,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColor.blackColor(
                                            context,
                                          ).withValues(alpha: 0.15),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                      image: const DecorationImage(
                                        image: AssetImage('assets/images/loge.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      Gap(28.h),

                      SlideTransition(
                        position: _titleSlide,
                        child: FadeTransition(
                          opacity: _titleFade,
                          child: Text(
                            AppLocaleKey.carApp.tr(),
                            textAlign: TextAlign.center,
                            style: AppTextStyle.titleLarge(context).copyWith(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColor.blackTextColor(context),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                      Gap(8.h),

                      FadeTransition(
                        opacity: _subTitleFade,
                        child: Column(
                          children: [
                            Text(
                              AppLocaleKey.qualityReliability.tr(),
                              style: AppTextStyle.text14RGrey(context).copyWith(
                                color: AppColor.blackTextColor(context).withValues(alpha: 0.75),
                                letterSpacing: 1.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Gap(12.h),
                            Container(
                              width: 50.w,
                              height: 3.h,
                              decoration: BoxDecoration(
                                color: AppColor.primaryColor(context).withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap(24.h),

                      ScaleTransition(
                        scale: _badgeScale,
                        child: FadeTransition(
                          opacity: _badgeFade,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColor.whiteColor(context).withValues(alpha: 0.05)
                                  : AppColor.whiteColor(context).withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: isDark
                                    ? AppColor.whiteColor(context).withValues(alpha: 0.1)
                                    : AppColor.primaryColor(context).withValues(alpha: 0.15),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.blackColor(
                                    context,
                                  ).withValues(alpha: isDark ? 0.2 : 0.04),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.verified_rounded,
                                      color: AppColor.primaryColor(context),
                                      size: 18.sp,
                                    ),
                                    Gap(6.w),
                                    Text(
                                      AppLocaleKey.authorizedDistributor.tr(),
                                      style: AppTextStyle.bodyLarge(context).copyWith(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.primaryColor(context),
                                      ),
                                    ),
                                  ],
                                ),
                                Gap(10.h),
                                Text(
                                  '${AppLocaleKey.brandsLine1.tr()} - ${AppLocaleKey.brandsLine2.tr()}',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyle.bodySmall(context).copyWith(
                                    fontSize: 12.5.sp,
                                    height: 1.4,
                                    color: AppColor.blackTextColor(context).withValues(alpha: 0.85),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Gap(12.h),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: AppColor.primaryColor(context).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(30.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.account_balance_rounded,
                                        color: AppColor.primaryColor(context),
                                        size: 14.sp,
                                      ),
                                      Gap(6.w),
                                      Text(
                                        AppLocaleKey.financingAvailable.tr(),
                                        style: AppTextStyle.bodyMedium(context).copyWith(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColor.primaryColor(context),
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
                      Gap(80.h),
                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: 50.h,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _subTitleFade,
                  child: Center(
                    child: SizedBox(
                      width: 70.w,
                      height: 70.w,
                      child: CustomLoading(size: 70.r),
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 12.h,
                left: 16.w,
                right: 16.w,
                child: FadeTransition(
                  opacity: _subTitleFade,
                  child: const Center(child: CopyrightWidget()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
