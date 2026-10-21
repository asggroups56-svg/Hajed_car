import 'package:animate_do/animate_do.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/onboarding/data/model/on_boarding_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class OnboardingPageItem extends StatelessWidget {
  final OnboardingModel model;

  const OnboardingPageItem({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          FadeInDown(
            duration: const Duration(milliseconds: 650),
            child: Container(
              height: 280.h,
              width: 230.w,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColor.primaryColor(context).withValues(alpha: 0.12),
                borderRadius: BorderRadius.vertical(
                  top: Radius.elliptical(115.w, 140.h),
                  bottom: Radius.elliptical(115.w, 140.h),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.elliptical(105.w, 130.h),
                  bottom: Radius.elliptical(105.w, 130.h),
                ),
                child: model.isImage
                    ? Image.asset(model.image, fit: BoxFit.cover)
                    : Center(
                        child: Icon(
                          model.image as IconData,
                          size: 112.h,
                          color: AppColor.primaryColor(context),
                        ),
                      ),
              ),
            ),
          ),
          Gap(32.h),
          FadeInUp(
            duration: const Duration(milliseconds: 1000),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Column(
                children: [
                  Text(
                    model.title,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.titleLarge(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColor.blackTextColor(context),
                    ),
                  ),
                  Gap(14.h),
                  Text(
                    model.description,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.bodyLarge(context).copyWith(
                      color: AppColor.blackTextColor(
                        context,
                      ).withValues(alpha: 0.8),
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
