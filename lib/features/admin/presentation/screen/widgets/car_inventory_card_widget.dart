import 'package:cached_network_image/cached_network_image.dart';
import 'package:car/core/images/app_images.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/admin/presentation/screen/widgets/inventory_action_widget.dart';
import 'package:car/features/agent/presentation/screens/widget/quote_builder_dialog.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class CarInventoryCardWidget extends StatelessWidget {
  const CarInventoryCardWidget({super.key, required this.car});
  final GetBrandCarsDataModel car;
  @override
  Widget build(BuildContext context) {
    final statusColor = car.carStatus == 1
        ? AppColor.greenColor(context)
        : (car.carStatus == 2
              ? Colors.orangeAccent
              : AppColor.redColor(context));

    final statusLabel = switch (car.carStatus) {
      1 => AppLocaleKey.agentCarAvailable,
      2 => AppLocaleKey.adminPendingApprovals,
      3 => AppLocaleKey.agentCarSold,
      4 => AppLocaleKey.horizontal,
      _ => AppLocaleKey.agentCarAvailable,
    };

    return Container(
      decoration: BoxDecoration(
        color: AppColor.blackTextColor(context).withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(color: AppColor.blackTextColor(context).withValues(alpha: 0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32.r),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 160.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor.blackTextColor(context).withValues(alpha: 0.05),
                  ),
                  child: car.fullCarImage.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: car.fullCarImage,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                                color: AppColor.blackTextColor(context).withValues(alpha: 0.05),
                              ),
                        )
                      : Container(
                          color: AppColor.blackTextColor(context).withValues(alpha: 0.05),
                          child: Icon(Icons.directions_car_rounded, size: 48.sp, color: Colors.grey),
                        ),
                ),
                Positioned(
                  top: 16.h,
                  right: 16.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColor.blackColor(context).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: AppColor.whiteColor(context).withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      car.makeYear.toString(),
                      style: AppTextStyle.bodySmall(
                        context,
                      ).copyWith(color: AppColor.whiteColor(context), fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16.h,
                  left: 16.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      statusLabel.tr(),
                      style: AppTextStyle.bodySmall(context).copyWith(
                        color: AppColor.blackColor(context),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              car.itemName,
                              style: TextStyle(
                                color: AppColor.blackTextColor(context),
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Gap(4.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.speed_rounded,
                                  size: 14.sp,
                                  color: AppColor.blackTextColor(context).withValues(alpha: 0.4),
                                ),
                                Gap(4.w),
                                Text(
                                  car.chassisNo,
                                  style: AppTextStyle.bodySmall(context).copyWith(
                                    color: AppColor.blackTextColor(context).withValues(alpha: 0.4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            car.formattedPriceWithVat,
                            style: AppTextStyle.bodyMedium(context).copyWith(
                              color: AppColor.primaryColor(context),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SvgPicture.asset(
                            AppImages.sar,
                            height: 16.h,
                            width: 16.w,
                            colorFilter: ColorFilter.mode(
                              AppColor.greenColor(context),
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Gap(20.h),
                  Row(
                    children: [
                      if (car.carStatus == 1) ...[
                        Gap(8.w),
                        Expanded(
                          child: InventoryActionWidget(
                            icon: Icons.description_outlined,
                            label: AppLocaleKey.generateQuote.tr(),
                            color: AppColor.primaryColor(context),
                            onTap: () {
                              QuoteBuilderDialog.show(
                                context,
                                car: car.toCarModel(),
                                existingSpecs: {
                                  AppLocaleKey.manufacturingYear.tr(): car.makeYear.toString(),
                                  AppLocaleKey.mileage.tr(): car.chassisNo,
                                  if (car.luxury != null && car.luxury!.trim().isNotEmpty)
                                    (context.locale.languageCode == 'ar' ? 'درجة الفخامة' : 'Luxury'): car.luxury!.trim(),
                                  if (car.specificName != null && car.specificName!.trim().isNotEmpty)
                                    (context.locale.languageCode == 'ar' ? 'المواصفات' : 'Specifications'): car.specificName!.trim(),
                                },
                              );
                            },
                          ),
                        ),
                      ],
                      Gap(8.w),
                      Expanded(
                        child: InventoryActionWidget(
                          icon: Icons.delete_sweep_rounded,
                          label: AppLocaleKey.delete.tr(),
                          color: AppColor.redColor(context),
                        ),
                      ),
                    ],
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
