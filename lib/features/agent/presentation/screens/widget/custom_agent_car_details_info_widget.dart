import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_sar_text.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/agent/data/model/agent_models.dart';
import 'package:car/features/agent/presentation/screens/widget/quick_info_widget.dart';
import 'package:car/features/agent/presentation/screens/widget/spec_tile_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CustomAgentCarDetailsInfoWidget extends StatelessWidget {
  const CustomAgentCarDetailsInfoWidget({super.key, required this.car});

  final AgentCar car;

  @override
  Widget build(BuildContext context) {
    final double basePrice = car.price;
    final double vatPercentage =
        double.tryParse(HiveMethods.getVatNumber()?.toString() ?? '') ?? 15.0;
    final double paintingsVal = car.paintingsVal ?? 0.0;
    final double taxAmount = car.taxAmount;
    final double priceWithVat = car.priceWithVat;
    final isArabic = context.locale.languageCode == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// QUICK INFO
        Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: AppColor.cardColor(context),
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: AppColor.blackColor(context).withValues(alpha: .04),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              QuickInfo(
                icon: Icons.calendar_today_rounded,
                title: AppLocaleKey.agentYearMade.tr(),
                value: car.year,
              ),
              QuickInfo(
                icon: Icons.numbers,
                title: AppLocaleKey.agentSimNumber.tr(),
                value: car.chassisNo,
              ),
              QuickInfo(
                icon: Icons.palette_rounded,
                title: AppLocaleKey.agentColor.tr(),
                value: car.color,
              ),
            ],
          ),
        ),

        Gap(22.h),

        /// FINANCIAL / PRICE BREAKDOWN
        Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: AppColor.cardColor(context),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: AppColor.primaryColor(context).withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor.blackColor(context).withValues(alpha: .04),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor(context).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: AppColor.primaryColor(context),
                      size: 20.sp,
                    ),
                  ),
                  Gap(10.w),
                  Expanded(
                    child: Text(
                      isArabic ? 'تفاصيل السعر والضريبة' : 'Price & Tax Breakdown',
                      style: AppTextStyle.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      isArabic ? 'شامل الضريبة واللوحات' : 'Inc. VAT & Plates',
                      style: TextStyle(
                        color: const Color(0xFF10B981),
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Gap(16.h),
              _buildPriceRow(
                context,
                title: isArabic ? 'السعر الإجمالي (النهائي)' : 'Total Price',
                value:
                    '${NumberFormat('#,##0', 'en_US').format(priceWithVat)} ${AppLocaleKey.sar.tr()}',
                isTotal: true,
              ),
              Divider(
                height: 20.h,
                thickness: 1,
                color: AppColor.borderColor(context).withValues(alpha: 0.2),
              ),
              _buildPriceRow(
                context,
                title: isArabic ? 'السعر الأساسي (غير شامل الضريبة)' : 'Base Price (Excl. Tax)',
                value:
                    '${NumberFormat('#,##0', 'en_US').format(basePrice)} ${AppLocaleKey.sar.tr()}',
              ),
              Gap(10.h),
              _buildPriceRow(
                context,
                title: isArabic
                    ? 'ضريبة القيمة المضافة (${vatPercentage.toStringAsFixed(0)}%)'
                    : 'VAT (${vatPercentage.toStringAsFixed(0)}%)',
                value:
                    '${NumberFormat('#,##0.##', 'en_US').format(taxAmount)} ${AppLocaleKey.sar.tr()}',
              ),
              if (paintingsVal > 0) ...[
                Gap(10.h),
                _buildPriceRow(
                  context,
                  title: isArabic ? 'رسوم اللوحات' : 'Plates Fee',
                  value:
                      '${NumberFormat('#,##0', 'en_US').format(paintingsVal)} ${AppLocaleKey.sar.tr()}',
                ),
              ],
            ],
          ),
        ),

        Gap(26.h),

        Text(
          AppLocaleKey.agentMainSpecs.tr(),
          style: AppTextStyle.bodyLarge(context).copyWith(fontWeight: FontWeight.w900),
        ),
        Gap(16.h),
        SpecTile(
          icon: Icons.calendar_today_rounded,
          title: AppLocaleKey.agentYearMade.tr(),
          value: car.year,
        ),
        SpecTile(
          icon: Icons.numbers,
          title: AppLocaleKey.agentSimNumber.tr(),
          value: '${car.chassisNo} ',
        ),
        SpecTile(
          icon: Icons.palette_rounded,
          title: AppLocaleKey.agentColor.tr(),
          value: car.color,
        ),
        SpecTile(
          icon: Icons.settings_rounded,
          title: AppLocaleKey.agentTransmission.tr(),
          value: AppLocaleKey.agentAutomatic.tr(),
        ),
        Gap(120.h),
      ],
    );
  }

  static Widget _buildPriceRow(
    BuildContext context, {
    required String title,
    required String value,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyle.bodySmall(context).copyWith(
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: isTotal
                ? AppColor.blackTextColor(context)
                : AppColor.greyColor(context),
            fontSize: isTotal ? 13.sp : 12.sp,
          ),
        ),
        ValueWithCurrencyIcon(
          text: value,
          textStyle: (isTotal
                  ? AppTextStyle.titleMedium(context)
                  : AppTextStyle.bodyMedium(context))
              .copyWith(
            fontWeight: FontWeight.w900,
            color: isTotal
                ? AppColor.primaryColor(context)
                : AppColor.blackTextColor(context),
            fontSize: isTotal ? 16.sp : 13.sp,
          ),
        ),
      ],
    );
  }
}
