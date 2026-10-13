import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:car/core/custom_widgets/custom_sar_text.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/agent/data/model/agent_models.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CarListCard extends StatelessWidget {
  final AgentCar car;
  final VoidCallback? onTap;

  const CarListCard({super.key, required this.car, this.onTap});

  @override
  Widget build(BuildContext context) {
    final availabilityColor = car.getAvailabilityColor(context);
    final double basePrice = car.price;
    final double vatPercentage =
        double.tryParse(HiveMethods.getVatNumber()?.toString() ?? '') ?? 15.0;
    final double priceWithVat = basePrice * (1 + vatPercentage / 100);
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: AppColor.cardColor(context),
        margin: EdgeInsets.only(bottom: 18.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// =========================
            /// Car Image
            /// =========================
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28.r),
                    topRight: Radius.circular(28.r),
                  ),
                  child: Container(
                    height: 200.h,
                    width: double.infinity,
                    color: AppColor.blueColor(context).withValues(alpha: 0.05),

                    child: car.imageUrl.trim().isNotEmpty
                        ? CustomNetworkImage(
                            imageUrl: car.imageUrl,
                            width: double.infinity,
                            height: 200.h,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.directions_car_filled_rounded,
                            size: 90.sp,
                            color: AppColor.blueColor(context).withValues(alpha: .35),
                          ),
                  ),
                ),

                Positioned(
                  top: 14.h,
                  right: 14.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: availabilityColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      car.availabilityLabel,
                      style: AppTextStyle.bodySmall(
                        context,
                      ).copyWith(color: AppColor.whiteColor(context), fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.all(18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Brand
                  Text(
                    car.brand,
                    style: AppTextStyle.bodySmall(
                      context,
                    ).copyWith(color: AppColor.greyColor(context), fontWeight: FontWeight.w700),
                  ),

                  Gap(6.h),

                  /// Car Name
                  Text(
                    car.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.bodyLarge(context).copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColor.blackTextColor(context),
                    ),
                  ),

                  Gap(14.h),

                  /// Price
                  ValueWithCurrencyIcon(
                    text: '${NumberFormat('#,###').format(priceWithVat)} ${AppLocaleKey.sar.tr()}',
                    textStyle: AppTextStyle.bodyLarge(context).copyWith(
                      color: AppColor.blueColor(context),
                      fontWeight: FontWeight.w900,
                      fontSize: 24.sp,
                    ),
                  ),

                  Gap(18.h),

                  /// Specs
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _SpecChip(icon: Icons.calendar_month_rounded, text: car.year),
                      _SpecChip(icon: Icons.numbers, text: '${car.mileage} '),
                      _SpecChip(icon: Icons.palette_outlined, text: car.color),
                    ],
                  ),

                  Gap(20.h),

                  /// Reservation Info (only for reserved cars)
                  if (car.availability == CarAvailability.reserved) ...[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: AppColor.orangeColor(context).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColor.orangeColor(context).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (car.customerName.isNotEmpty)
                            Row(
                              children: [
                                Icon(
                                  Icons.person_rounded,
                                  size: 14.sp,
                                  color: AppColor.orangeColor(context),
                                ),
                                Gap(6.w),
                                Expanded(
                                  child: Text(
                                    car.customerName,
                                    style: AppTextStyle.bodySmall(context).copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColor.blackTextColor(context),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          if (car.customerName.isNotEmpty && car.reservedName.isNotEmpty) Gap(6.h),
                          if (car.reservedName.isNotEmpty)
                            Row(
                              children: [
                                Icon(
                                  Icons.badge_rounded,
                                  size: 14.sp,
                                  color: AppColor.greyColor(context),
                                ),
                                Gap(6.w),
                                Expanded(
                                  child: Text(
                                    car.reservedName,
                                    style: AppTextStyle.bodySmall(context).copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.greyColor(context),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    Gap(12.h),
                  ],

                  /// Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColor.blueColor(context),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      ),
                      child: Text(
                        AppLocaleKey.details.tr(),
                        style: AppTextStyle.bodyMedium(context).copyWith(
                          color: AppColor.whiteColor(context),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
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
}

class _SpecChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SpecChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColor.blackTextColor(context).withValues(alpha: .04),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15.sp, color: AppColor.hintColor(context)),
          Gap(6.w),
          Text(text, style: AppTextStyle.bodySmall(context).copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
