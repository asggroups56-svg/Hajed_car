import 'package:car/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:car/core/custom_widgets/custom_sar_text.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/admin/data/model/cars_response_model.dart';
import 'package:car/features/agent/presentation/screens/widget/spec_chip_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ReservedCarCard extends StatelessWidget {
  final CarModel car;
  final VoidCallback onCancelTap;
  final VoidCallback onDetailsTap;
  const ReservedCarCard({
    super.key,
    required this.car,
    required this.onCancelTap,
    required this.onDetailsTap,
  });
  @override
  Widget build(BuildContext context) {
    final carName = car.itemName ?? AppLocaleKey.agentUnnamedCar.tr();
    final price = car.costPrice ?? 0.0;
    final advancedAmount = car.ADVANCED_AMOUNT != null
        ? double.tryParse(car.ADVANCED_AMOUNT!) ?? 0.0
        : 0.0;
    final chassisNo = car.chassisNo ?? '—';
    final year = car.makeYear != null ? car.makeYear.toString() : '—';
    final color = car.bodyColor ?? '—';
    final lpoNo = car.lpoNo ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: AppColor.cardColor(context),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColor.borderColor(context).withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColor.blackColor(context).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: const Color(0xFF10B981), size: 14.sp),
                      Gap(6.w),
                      Text(
                        AppLocaleKey.agentReserved.tr(),
                        style: AppTextStyle.bodySmall(
                          context,
                        ).copyWith(color: const Color(0xFF10B981), fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                if (lpoNo.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor(context).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '${AppLocaleKey.reservationNumber.tr()}: $lpoNo',
                      style: AppTextStyle.bodySmall(context).copyWith(
                        color: AppColor.primaryColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),

            Gap(12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor(context).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: car.imageUrls.isNotEmpty
                      ? CustomNetworkImage(
                          imageUrl: car.imageUrls.first,
                          width: 64.w,
                          height: 64.w,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Icon(
                            Icons.directions_car_rounded,
                            size: 34.sp,
                            color: AppColor.primaryColor(context),
                          ),
                        ),
                ),
                Gap(14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        carName,
                        style: AppTextStyle.titleMedium(context).copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16.sp,
                          color: AppColor.blackTextColor(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gap(6.h),
                      Row(
                        children: [
                          Icon(
                            Icons.fingerprint_rounded,
                            size: 14.sp,
                            color: AppColor.greyColor(context),
                          ),
                          Gap(4.w),
                          Expanded(
                            child: Text(
                              AppLocaleKey.agentChassisLabel.tr(namedArgs: {'chassis': chassisNo}),
                              style: AppTextStyle.bodySmall(context).copyWith(
                                color: AppColor.greyColor(context),

                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gap(14.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColor.scaffoldColor(context),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SpecChip(
                      icon: Icons.calendar_today_rounded,
                      label: AppLocaleKey.agentSpecModel.tr(),
                      value: year,
                    ),
                  ),
                  Container(
                    height: 24.h,
                    width: 1,
                    color: AppColor.borderColor(context).withValues(alpha: 0.2),
                  ),
                  Expanded(
                    child: SpecChip(
                      icon: Icons.palette_rounded,
                      label: AppLocaleKey.agentSpecColor.tr(),
                      value: color,
                    ),
                  ),
                  if (car.storeCode != null && car.storeCode!.isNotEmpty) ...[
                    Container(
                      height: 24.h,
                      width: 1,
                      color: AppColor.borderColor(context).withValues(alpha: 0.2),
                    ),
                    Expanded(
                      child: SpecChip(
                        icon: Icons.store_rounded,
                        label: AppLocaleKey.agentSpecStore.tr(),
                        value: car.storeCode!,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (price > 0 || advancedAmount > 0) ...[
              Gap(14.h),
              Row(
                children: [
                  if (price > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocaleKey.agentCarValue.tr(),
                          style: AppTextStyle.bodySmall(
                            context,
                          ).copyWith(color: AppColor.greyColor(context), fontSize: 11.sp),
                        ),
                        Gap(2.h),
                        ValueWithCurrencyIcon(
                          text: '${price.toStringAsFixed(0)} ${AppLocaleKey.agentCurrencySar.tr()}',
                          textStyle: AppTextStyle.titleMedium(context).copyWith(
                            color: AppColor.primaryColor(context),
                            fontWeight: FontWeight.w900,
                            fontSize: 17.sp,
                          ),
                        ),
                      ],
                    ),
                  if (price > 0 && advancedAmount > 0) const Spacer(),
                  if (advancedAmount > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocaleKey.ADVANCED_AMOUNT.tr(),
                          style: AppTextStyle.bodySmall(
                            context,
                          ).copyWith(color: AppColor.greyColor(context), fontSize: 11.sp),
                        ),
                        Gap(2.h),
                        ValueWithCurrencyIcon(
                          text:
                              '${advancedAmount.toStringAsFixed(0)} ${AppLocaleKey.agentCurrencySar.tr()}',
                          textStyle: AppTextStyle.titleMedium(context).copyWith(
                            color: AppColor.primaryColor(context),
                            fontWeight: FontWeight.w900,
                            fontSize: 17.sp,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
            Gap(14.h),
            Row(
              children: [
                // Buttons
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCancelTap,
                    icon: Icon(Icons.cancel_outlined, size: 16.sp, color: AppColor.redColor(context)),
                    label: Text(
                      AppLocaleKey.cancelReservation.tr(),
                      style: AppTextStyle.bodySmall(
                        context,
                      ).copyWith(color: AppColor.redColor(context), fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColor.redColor(context).withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    ),
                  ),
                ),
                Gap(8.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onDetailsTap,
                    icon: Icon(
                      Icons.visibility_outlined,
                      size: 16.sp,
                      color: AppColor.whiteColor(context),
                    ),
                    label: Text(
                      AppLocaleKey.agentDetails.tr(),
                      style: AppTextStyle.bodySmall(
                        context,
                      ).copyWith(color: AppColor.whiteColor(context), fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor(context),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
