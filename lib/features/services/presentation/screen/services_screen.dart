import 'package:animate_do/animate_do.dart';
import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/common_methods.dart';
import 'package:car/features/settings/presentation/screen/widget/logout_button_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 20.h),
              child: FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocaleKey.ourServices.tr(),
                          style: AppTextStyle.titleLarge(context).copyWith(
                            color: AppColor.blackTextColor(context),
                            fontWeight: FontWeight.w900,
                            fontSize: 28.sp,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Gap(4.h),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pushNamed(context, RoutesName.settingsScreen),
                      icon: Icon(
                        Icons.settings,
                        color: AppColor.blackTextColor(context).withValues(alpha: 0.70),
                        size: 26.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // High-Contrast Hero: Sell Your Car
          SliverToBoxAdapter(
            child: FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: _buildEliteHeroHighlight(context),
            ),
          ),

          // Main Services Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 32.h, 20.w, 16.h),
              child: FadeInLeft(
                child: Text(
                  AppLocaleKey.services.tr(),
                  style: AppTextStyle.titleMedium(context).copyWith(
                    color: AppColor.blackTextColor(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final services = _getServicesData();
                return FadeInUp(
                  delay: Duration(milliseconds: 150 * index),
                  child: _buildImmersiveServiceCard(context, services[index], index),
                );
              }, childCount: _getServicesData().length),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: const LogoutButtonWidget(),
                );
              }, childCount: 1),
            ),
          ),
          SliverToBoxAdapter(child: Gap(120.h)),
        ],
      ),
    );
  }

  Widget _buildEliteHeroHighlight(BuildContext context) {
    return Opacity(
      opacity: 0.8,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40.r),
          child: Image.asset('assets/images/loge.png', height: 160.h, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _buildImmersiveServiceCard(BuildContext context, Map<String, dynamic> service, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      height: 110.h,
      decoration: BoxDecoration(
        color: AppColor.secondAppColor(context),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColor.blackTextColor(context).withValues(alpha: 0.03)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (service['label'] == AppLocaleKey.compareCars.tr() ||
                service['label'] == AppLocaleKey.aboutCompany.tr() ||
                service['label'] == AppLocaleKey.support.tr()) {
              _navigateToService(context, service['label']);
            } else if (HiveMethods.getToken() == null) {
              CommonMethods.showLoginRequiredDialog(context);
            } else {
              _navigateToService(context, service['label']);
            }
          },
          borderRadius: BorderRadius.circular(22.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 70.w,
                  height: 70.h,
                  decoration: BoxDecoration(
                    color: (service['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(service['icon'], color: service['color'], size: 30.sp),
                ),
                Gap(16.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['label'],
                        style: AppTextStyle.bodyMedium(context).copyWith(
                          color: AppColor.blackTextColor(context),
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      Gap(4.h),
                      Text(
                        _getServiceDescription(service['label']),
                        style: AppTextStyle.bodySmall(context).copyWith(
                          color: AppColor.blackTextColor(context).withValues(alpha: 0.38),
                          fontSize: 11.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColor.blackTextColor(context).withValues(alpha: 0.10),
                  size: 16.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getServicesData() {
    return [
      {
        'icon': Icons.compare_arrows_rounded,
        'label': AppLocaleKey.compareCars.tr(),
        'color': const Color(0xFFF43F5E),
      },
      {
        'icon': Icons.info_outline_rounded,
        'label': AppLocaleKey.aboutCompany.tr(),
        'color': Colors.blueGrey,
      },
      {
        'icon': Icons.support_agent_rounded,
        'label': AppLocaleKey.support.tr(),
        'color': Colors.purpleAccent,
      },
    ];
  }

  String _getServiceDescription(String label) {
    if (label == AppLocaleKey.requestCar.tr()) {
      return AppLocaleKey.requestCarDesc.tr();
    }
    if (label == AppLocaleKey.importOnDemand.tr()) {
      return AppLocaleKey.importOnDemandDesc.tr();
    }

    if (label == AppLocaleKey.showroomShine.tr()) {
      return AppLocaleKey.showroomShineDesc.tr();
    }
    if (label == AppLocaleKey.vipShipping.tr()) {
      return AppLocaleKey.vipShippingDesc.tr();
    }
    if (label == AppLocaleKey.bespokeSelection.tr()) {
      return AppLocaleKey.bespokeSelectionDesc.tr();
    }
    return AppLocaleKey.defaultServiceDesc.tr();
  }

  void _navigateToService(BuildContext context, String label) {
    if (label == AppLocaleKey.requestCar.tr()) {
      Navigator.pushNamed(context, RoutesName.requestCarScreen);
    } else if (label == AppLocaleKey.importOnDemand.tr()) {
      Navigator.pushNamed(context, RoutesName.importOnDemandScreen);
    } else if (label == AppLocaleKey.showroomShine.tr()) {
      Navigator.pushNamed(context, RoutesName.carDetailingScreen);
    } else if (label == AppLocaleKey.vipShipping.tr()) {
      Navigator.pushNamed(context, RoutesName.shippingScreen);
    } else if (label == AppLocaleKey.bespokeSelection.tr()) {
      Navigator.pushNamed(context, RoutesName.bespokeSelectionScreen);
    } else if (label == AppLocaleKey.carValuation.tr() || label == AppLocaleKey.valuation.tr()) {
      Navigator.pushNamed(context, RoutesName.carValuationScreen);
    } else if (label == AppLocaleKey.compareCars.tr()) {
      Navigator.pushNamed(context, RoutesName.carComparisonScreen);
    } else if (label == AppLocaleKey.aboutCompany.tr()) {
      Navigator.pushNamed(context, RoutesName.aboutScreen);
    } else if (label == AppLocaleKey.support.tr()) {
      Navigator.pushNamed(context, RoutesName.supportScreen);
    }
  }
}
