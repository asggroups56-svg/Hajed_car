import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

/// Shows the brand (or model type) currently narrowing the cars inventory and
/// lets the customer switch back to the complete catalog.
class CarsBrandFilterBar extends StatelessWidget {
  const CarsBrandFilterBar({super.key, this.brandName, required this.onClear});

  final String? brandName;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 0),
      child: Row(
        children: [
          Icon(
            Icons.directions_car_filled_rounded,
            size: 18.sp,
            color: AppColor.primaryColor(context),
          ),
          Gap(8.w),
          Expanded(
            child: Text(
              brandName ?? AppLocaleKey.brands.tr(),
              style: AppTextStyle.bodyMedium(context).copyWith(
                color: AppColor.primaryColor(context),
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(20.r),
            onTap: onClear,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.close_rounded,
                    size: 16.sp,
                    color: AppColor.primaryColor(context),
                  ),
                  Gap(4.w),
                  Text(
                    AppLocaleKey.all.tr(),
                    style: AppTextStyle.bodySmall(context).copyWith(
                      color: AppColor.primaryColor(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
