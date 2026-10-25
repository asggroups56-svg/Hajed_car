import 'package:car/core/custom_widgets/custom_sar_text.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CustomMonthlyInstallmentCardWidget extends StatelessWidget {
  const CustomMonthlyInstallmentCardWidget({
    super.key,
    required this.fmt,
    required this.monthly,
    required this.totalPrice,
  });

  final NumberFormat fmt;
  final double monthly;
  final double totalPrice;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColor.primaryColor(context).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppLocaleKey.monthlyInstallment.tr(),
            style: AppTextStyle.bodyMedium(
              context,
            ).copyWith(color: AppColor.primaryColor(context), fontWeight: FontWeight.w700),
          ),
          Gap(15.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  fmt.format(monthly.round()),
                  style: AppTextStyle.titleLarge(
                    context,
                  ).copyWith(
                    color: AppColor.blackTextColor(context),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Gap(8.w),
                ValueWithCurrencyIcon(
                  text: AppLocaleKey.sar.tr(),
                  textStyle: AppTextStyle.titleLarge(
                    context,
                  ).copyWith(
                    color: AppColor.blackTextColor(context),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Gap(8.w),
                Text(
                  AppLocaleKey.agentMonthly.tr(),
                  style: AppTextStyle.titleLarge(
                    context,
                  ).copyWith(
                    color: AppColor.primaryColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Gap(15.h),
          Text(
            AppLocaleKey.agentEstimatePrice.tr(),
            style: AppTextStyle.bodySmall(
              context,
            ).copyWith(color: AppColor.greyColor(context), fontSize: 11.sp),
            textAlign: TextAlign.center,
          ),
          Gap(16.h),
          Divider(color: AppColor.greyColor(context), height: 1),
          Gap(16.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocaleKey.totalLoanPrice.tr(),
                  style: AppTextStyle.bodyMedium(
                    context,
                  ).copyWith(
                    color: AppColor.blackTextColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Gap(8.w),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fmt.format(totalPrice.round()),
                      style: AppTextStyle.bodyLarge(
                        context,
                      ).copyWith(
                        color: AppColor.primaryColor(context),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Gap(4.w),
                    ValueWithCurrencyIcon(
                      text: AppLocaleKey.sar.tr(),
                      textStyle: AppTextStyle.bodyLarge(
                        context,
                      ).copyWith(
                        color: AppColor.primaryColor(context),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap(15.h),
          Text(
            AppLocaleKey.agentEstimatePriceDesc.tr(),
            style: AppTextStyle.bodySmall(
              context,
            ).copyWith(color: AppColor.greyColor(context), fontSize: 11.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
