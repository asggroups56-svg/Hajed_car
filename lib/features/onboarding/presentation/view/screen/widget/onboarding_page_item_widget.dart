import 'package:animate_do/animate_do.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/onboarding/data/model/on_boarding_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class OnboardingPageItem extends StatelessWidget {
  final OnboardingModel model;

  const OnboardingPageItem({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        child: Column(
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: _buildHeroCard(context),
            ),
            Gap(16.h),
            FadeIn(
              duration: const Duration(milliseconds: 600),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (dotIndex) {
                  final bool isSelected = model.pageIndex == dotIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    height: 6.h,
                    width: isSelected ? 22.w : 6.w,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColor.primaryColor(context)
                          : AppColor.primaryColor(
                              context,
                            ).withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  );
                }),
              ),
            ),
            Gap(16.h),
            FadeInUp(
              duration: const Duration(milliseconds: 550),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Column(
                  children: [
                    Text(
                      model.title,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.titleLarge(context).copyWith(
                        fontSize: 21.sp,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                        color: AppColor.blackTextColor(context),
                      ),
                    ),
                    Gap(10.h),
                    Text(
                      model.description,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.bodyMedium(context).copyWith(
                        fontSize: 13.5.sp,
                        height: 1.5,
                        color: AppColor.blackTextColor(
                          context,
                        ).withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    switch (model.pageIndex) {
      case 0:
        return _buildShowroomCarCard(context);
      case 1:
        return _buildDealerWarrantyCard(context);
      case 2:
      default:
        return _buildDeliveryTrackerCard(context);
    }
  }

  /// Page 1: Showroom car card with trust badges (Dealer Warranty & Price Includes VAT)
  Widget _buildShowroomCarCard(BuildContext context) {
    return Container(
      height: 245.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.whiteColor(context),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                model.image as String,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.65),
                    ],
                    stops: const [0.4, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 12.h,
              left: 12.w,
              right: 12.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          size: 13.sp,
                          color: Colors.white,
                        ),
                        Gap(5.w),
                        Text(
                          AppLocaleKey.dealerWarranty.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 13.sp,
                          color: Colors.white,
                        ),
                        Gap(5.w),
                        Text(
                          AppLocaleKey.priceIncludesVat.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Page 2: Dealer Warranty & Status Card ("سياراتك لدى الوكيل")
  Widget _buildDealerWarrantyCard(BuildContext context) {
    return Container(
      height: 245.h,
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.whiteColor(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColor.primaryColor(context).withValues(alpha: 0.12),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor(context).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: AppColor.primaryColor(context),
              borderRadius: BorderRadius.circular(15.r),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primaryColor(context).withValues(alpha: 0.32),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.verified_user_rounded,
              color: Colors.white,
              size: 26.sp,
            ),
          ),
          Gap(12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColor.primaryColor(context).withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: AppColor.primaryColor(context).withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocaleKey.vehicleStatusDealer.tr(),
                      style: AppTextStyle.bodySmall(context).copyWith(
                        color: AppColor.blackTextColor(
                          context,
                        ).withValues(alpha: 0.55),
                        fontSize: 10.5.sp,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shield_rounded,
                            size: 10.sp,
                            color: const Color(0xFF10B981),
                          ),
                          Gap(3.w),
                          Text(
                            context.locale.languageCode == 'ar'
                                ? 'معتمد 100%'
                                : '100% Certified',
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              color: const Color(0xFF10B981),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Gap(6.h),
                Text(
                  AppLocaleKey.dealerCertifiedWarranty.tr(),
                  style: AppTextStyle.bodyLarge(context).copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: AppColor.blackTextColor(context),
                  ),
                ),
                Gap(4.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 13.sp,
                      color: AppColor.blackTextColor(
                        context,
                      ).withValues(alpha: 0.5),
                    ),
                    Gap(4.w),
                    Expanded(
                      child: Text(
                        AppLocaleKey.dealerServiceKingdom.tr(),
                        style: AppTextStyle.bodySmall(context).copyWith(
                          color: AppColor.blackTextColor(
                            context,
                          ).withValues(alpha: 0.6),
                          fontSize: 10.5.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Gap(8.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: Color(0xFF10B981),
                      ),
                      Gap(6.w),
                      Expanded(
                        child: Text(
                          AppLocaleKey.inspectionReportReady.tr(),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF047857),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Page 3: Delivery & Tracking Preview Card ("نوصل سيارتك حق باب بيتك")
  Widget _buildDeliveryTrackerCard(BuildContext context) {
    return Container(
      height: 245.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColor.whiteColor(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColor.primaryColor(context).withValues(alpha: 0.12),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor(context).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.h,
                decoration: BoxDecoration(
                  color: AppColor.primaryColor(context),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              Gap(10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocaleKey.carOnTheWay.tr(),
                      style: AppTextStyle.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5.sp,
                        color: AppColor.blackTextColor(context),
                      ),
                    ),
                    Text(
                      AppLocaleKey.expectedArrivalTime.tr(),
                      style: AppTextStyle.bodySmall(context).copyWith(
                        color: AppColor.blackTextColor(
                          context,
                        ).withValues(alpha: 0.55),
                        fontSize: 10.5.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap(10.h),
          Divider(
            height: 1,
            color: AppColor.primaryColor(context).withValues(alpha: 0.1),
          ),
          Gap(10.h),
          _buildStepRow(
            context,
            title: AppLocaleKey.orderStepConfirmed.tr(),
            isCompleted: true,
            isCurrent: false,
            isLast: false,
          ),
          _buildStepRow(
            context,
            title: AppLocaleKey.orderStepPrep.tr(),
            isCompleted: true,
            isCurrent: false,
            isLast: false,
          ),
          _buildStepRow(
            context,
            title: AppLocaleKey.orderStepTransit.tr(),
            isCompleted: false,
            isCurrent: true,
            isLast: false,
          ),
          _buildStepRow(
            context,
            title: AppLocaleKey.orderStepDelivered.tr(),
            isCompleted: false,
            isCurrent: false,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(
    BuildContext context, {
    required String title,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (isCompleted)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF10B981),
                size: 15,
              )
            else if (isCurrent)
              Container(
                width: 15.w,
                height: 15.h,
                decoration: BoxDecoration(
                  color: AppColor.primaryColor(context),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.circle, color: Colors.white, size: 5),
                ),
              )
            else
              Container(
                width: 15.w,
                height: 15.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColor.blackTextColor(
                      context,
                    ).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
              ),
            if (!isLast)
              Container(
                width: 1.8,
                height: 12.h,
                color: isCompleted
                    ? const Color(0xFF10B981)
                    : AppColor.blackTextColor(
                        context,
                      ).withValues(alpha: 0.15),
              ),
          ],
        ),
        Gap(10.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Text(
              title,
              style: AppTextStyle.bodySmall(context).copyWith(
                fontSize: 11.sp,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                color: isCurrent
                    ? AppColor.primaryColor(context)
                    : isCompleted
                        ? AppColor.blackTextColor(context)
                        : AppColor.blackTextColor(
                            context,
                          ).withValues(alpha: 0.45),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
