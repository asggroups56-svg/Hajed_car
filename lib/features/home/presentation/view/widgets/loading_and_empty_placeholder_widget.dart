import 'package:car/core/custom_widgets/custom_loading/custom_shimmer.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class LoadingPlaceholder extends StatelessWidget {
  const LoadingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          // padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          //width: double.infinity,
          decoration: BoxDecoration(
            color: AppColor.whiteColor(context),
            borderRadius: BorderRadius.circular(12.r),
          ),
          height: 280.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(flex: 10, child: CustomShimmer(radius: 18)),
                Gap(18.h),
                CustomShimmer(width: 150.w, height: 16.h, radius: 6.r),
                Gap(12.h),
                Row(
                  children: [
                    CustomShimmer(width: 58.w, height: 12.h, radius: 6.r),
                    Gap(12.w),
                    CustomShimmer(width: 58.w, height: 12.h, radius: 6.r),
                    Gap(12.w),
                    CustomShimmer(width: 58.w, height: 12.h, radius: 6.r),
                  ],
                ),
                Gap(16.h),
              ],
            ),
          ),
        ),
        Gap(20.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColor.blackColor(context),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 12.r,
                height: 12.r,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: AppColor.whiteColor(context),
                ),
              ),
              Gap(8.w),
              Text(
                AppLocaleKey.loadingLatestCars.tr(),
                style: AppTextStyle.bodySmall(
                  context,
                ).copyWith(color: AppColor.whiteColor(context), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Placeholder matching the horizontal brand selector while its data loads.
class CategoriesLoadingPlaceholder extends StatelessWidget {
  const CategoriesLoadingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        itemCount: 5,
        separatorBuilder: (context, index) => Gap(20.w),
        itemBuilder: (context, index) => Column(
          children: [
            CustomShimmer(width: 60.w, height: 60.w, radius: 12.r),
            Gap(10.h),
            CustomShimmer(width: 48.w, height: 12.h, radius: 6.r),
          ],
        ),
      ),
    );
  }
}

/// Placeholder matching the compact car cards used in the budget section.
class BudgetCarsLoadingPlaceholder extends StatelessWidget {
  const BudgetCarsLoadingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 2,
        separatorBuilder: (context, index) => Gap(16.w),
        itemBuilder: (context, index) => SizedBox(
          width: 320.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomShimmer(height: 100.h, radius: 20.r),
              Gap(16.h),
              CustomShimmer(width: 130.w, height: 16.h, radius: 6.r),
              Gap(14.h),
              Row(
                children: [
                  Expanded(
                    child: CustomShimmer(height: 14.h, radius: 6.r),
                  ),
                  Gap(18.w),
                  Expanded(
                    child: CustomShimmer(height: 14.h, radius: 6.r),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.car_rental_rounded,
              size: 80.sp,
              color: AppColor.greyColor(context).withValues(alpha: (0.3)),
            ),
            Gap(5.h),
            Text(
              AppLocaleKey.agentNoCars.tr(),
              style: AppTextStyle.bodyMedium(
                context,
              ).copyWith(color: AppColor.greyColor(context), fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
