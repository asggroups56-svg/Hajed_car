import 'package:car/core/custom_widgets/custom_sar_text.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CarSummaryCard extends StatelessWidget {
  final Map<String, dynamic>? car;
  final double monthlyInstallment;
  final int durationYears;
  final double downPayment;
  final double lastPayment;
  final VoidCallback onEdit;

  const CarSummaryCard({
    super.key,
    required this.car,
    required this.monthlyInstallment,
    required this.durationYears,
    required this.downPayment,
    required this.lastPayment,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'en_US');
    final carName =
        car?['name'] as String? ?? car?['model'] as String? ?? AppLocaleKey.agentCarFallback.tr();
    final carYear = car?['year']?.toString() ?? '';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.cardColor(context),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColor.borderColor(context)),
      ),
      child: Column(
        children: [
          _buildTopRow(context, fmt, carName, carYear),
          Gap(14.h),
          Divider(height: 1, color: AppColor.dividerColor(context)),
          Gap(14.h),
          _buildBottomRow(context),
          Gap(14.h),
          _buildEstimateNote(context),
        ],
      ),
    );
  }

  Widget _buildTopRow(BuildContext context, NumberFormat fmt, String carName, String carYear) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMonthlyInstallment(context, fmt),
        Expanded(child: _buildCarInfo(context, carName, carYear)),
      ],
    );
  }

  Widget _buildMonthlyInstallment(BuildContext context, NumberFormat fmt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocaleKey.agentFirstInstallment.tr(),
          style: AppTextStyle.bodySmall(
            context,
          ).copyWith(color: AppColor.greyColor(context), fontSize: 11.sp),
        ),
        Gap(4.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            ValueWithCurrencyIcon(
              text: AppLocaleKey.sar.tr(),
              textStyle: AppTextStyle.bodyMedium(
                context,
              ).copyWith(color: AppColor.primaryColor(context), fontWeight: FontWeight.w900),
            ),
            Gap(4.w),
            Text(
              fmt.format(monthlyInstallment.round()),
              style: AppTextStyle.bodyLarge(context).copyWith(
                color: AppColor.primaryColor(context),
                fontWeight: FontWeight.w900,
                fontSize: 20.sp,
              ),
            ),
          ],
        ),
        Text(
          AppLocaleKey.agentMonthly.tr(),
          style: AppTextStyle.bodySmall(
            context,
          ).copyWith(color: AppColor.primaryColor(context), fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildCarInfo(BuildContext context, String carName, String carYear) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          AppLocaleKey.agentRequest.tr(),
          style: AppTextStyle.bodySmall(
            context,
          ).copyWith(color: AppColor.greyColor(context), fontSize: 11.sp),
        ),
        Gap(4.h),
        Text(
          carName,
          style: AppTextStyle.bodyMedium(
            context,
          ).copyWith(fontWeight: FontWeight.w900, fontSize: 14.sp),
          textAlign: TextAlign.end,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (carYear.isNotEmpty)
          Text(
            carYear,
            style: AppTextStyle.bodySmall(context).copyWith(color: AppColor.greyColor(context)),
          ),
      ],
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // GestureDetector(
        //   onTap: onEdit,
        //   child: Container(
        //     padding: EdgeInsets.all(8.w),
        //     decoration: BoxDecoration(
        //       color: AppColor.primaryColor(context),
        //       borderRadius: BorderRadius.circular(8.r),
        //     ),
        //     child: Icon(Icons.edit_rounded, color: AppColor.whiteColor(context), size: 16.sp),
        //   ),
        // ),
        // const Spacer(),
        _buildChip(
          context,
          label: AppLocaleKey.agentLastPayment.tr(),
          value: '${AppLocaleKey.sar.tr()}  ${lastPayment.toStringAsFixed(1)}',
        ),
        Gap(16.w),
        _buildChip(
          context,
          label: AppLocaleKey.agentFirstPayment.tr(),
          value: '${AppLocaleKey.sar.tr()}  ${downPayment.toStringAsFixed(1)}',
        ),
        Gap(16.w),
        _buildChip(
          context,
          label: AppLocaleKey.agentInstallmentsDuration.tr(),
          value: '$durationYears  ${AppLocaleKey.agentYear.tr()}',
        ),
      ],
    );
  }

  Widget _buildChip(BuildContext context, {required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: AppTextStyle.bodySmall(
            context,
          ).copyWith(color: AppColor.greyColor(context), fontSize: 10.sp),
        ),
        Gap(2.h),
        ValueWithCurrencyIcon(
          text: value,
          textStyle: AppTextStyle.bodySmall(context).copyWith(
            color: AppColor.blackTextColor(context),
            fontWeight: FontWeight.w700,
            fontSize: 11.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildEstimateNote(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.info_outline_rounded, color: AppColor.greyColor(context), size: 12.sp),
        Gap(4.w),
        Text(
          AppLocaleKey.agentEstimatePrices.tr(),
          style: AppTextStyle.bodySmall(
            context,
          ).copyWith(color: AppColor.greyColor(context), fontSize: 10.sp),
        ),
      ],
    );
  }
}
