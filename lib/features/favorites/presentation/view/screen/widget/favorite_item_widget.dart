import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:car/core/custom_widgets/custom_sar_text.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/navigator_methods.dart';
import 'package:car/features/favorites/presentation/view/cubit/favorites_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class FavoriteItemWidget extends StatelessWidget {
  const FavoriteItemWidget({super.key, required this.car});
  final Map<String, dynamic> car;

  String _getFormattedPriceWithVat(Map<String, dynamic> carData) {
    final priceRaw = carData['price']?.toString() ?? '0';
    if (priceRaw.isEmpty || priceRaw == '0') return '0';

    final double originalPrice = double.tryParse(priceRaw) ?? 0.0;

    if (originalPrice <= 0) return '0';

    double vatPercentage = 15.0;

    if (carData.containsKey('VAT_SERIAL')) {
      final vatSerial = carData['VAT_SERIAL']?.toString();
      if (vatSerial != null && vatSerial.isNotEmpty) {
        vatPercentage = double.tryParse(vatSerial) ?? 15.0;
      }
    }

    final double priceWithVat = originalPrice * ((vatPercentage / 100)) + originalPrice;
    final double paintingsVal = (carData['PaintingsVal'] as num?)?.toDouble() ??
        (carData['PAINTINGS_VAL'] as num?)?.toDouble() ??
        (carData['paintingsVal'] as num?)?.toDouble() ??
        double.tryParse(carData['PaintingsVal']?.toString() ?? '') ??
        double.tryParse(carData['PAINTINGS_VAL']?.toString() ?? '') ??
        double.tryParse(carData['paintingsVal']?.toString() ?? '') ??
        0.0;
    final double totalCashPrice = priceWithVat + paintingsVal;

    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(totalCashPrice);
  }

  String _getVatPercentageText(Map<String, dynamic> carData) {
    double vatPercentage = 15.0;
    if (carData.containsKey('VAT_SERIAL')) {
      final vatSerial = carData['VAT_SERIAL']?.toString();
      if (vatSerial != null && vatSerial.isNotEmpty) {
        vatPercentage = double.tryParse(vatSerial) ?? 15.0;
      }
    }
    return vatPercentage.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final String formattedPrice = _getFormattedPriceWithVat(car);
    final String vatPercentage = _getVatPercentageText(car);

    return Container(
      decoration: BoxDecoration(
        color: AppColor.secondAppColor(context),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.blackColor(context).withValues(alpha: 0.06),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: AppColor.blackTextColor(context).withValues(alpha: 0.04)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            final heroTag = 'fav_car_image_${HiveMethods.getCarUniqueId(car)}';
            NavigatorMethods.pushNamed(
              context,
              RoutesName.carDetailsScreen,
              arguments: {'car': car, 'heroTag': heroTag},
            );
          },
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Row(
              children: [
                Container(
                  width: 110.w,
                  height: 90.h,
                  decoration: BoxDecoration(
                    color: AppColor.blackTextColor(context).withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Hero(
                    tag: 'fav_car_image_${HiveMethods.getCarUniqueId(car)}',
                    child: car['image'] != null && car['image'].toString().trim().startsWith('http')
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: CustomNetworkImage(
                              imageUrl: car['image'].toString(),
                              fit: BoxFit.cover,
                              height: 90.h,
                              width: 110.w,
                            ),
                          )
                        : (car['image'] != null && car['image'].toString().trim().isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: Image.asset(
                              car['image'].toString(),
                              fit: BoxFit.cover,
                              height: double.infinity,
                              width: 110.w,
                            ),
                          )
                        : Icon(
                            Icons.directions_car_rounded,
                            size: 40.h,
                            color: AppColor.greyColor(context).withValues(alpha: 0.5),
                          ),
                  ),
                ),
                Gap(14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        car['brand'] ?? '',
                        style: AppTextStyle.bodySmall(context).copyWith(
                          color: AppColor.primaryColor(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Gap(4.h),
                      Text(
                        car['name'] ?? '',
                        style: AppTextStyle.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColor.blackTextColor(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gap(8.h),

                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor(context).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: ValueWithCurrencyIcon(
                          text: '$formattedPrice SAR',
                          textStyle: AppTextStyle.bodySmall(context).copyWith(
                            color: AppColor.primaryColor(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Gap(4.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor(context).withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          ' ${AppLocaleKey.inclusiveVat.tr()} $vatPercentage%',
                          style: AppTextStyle.bodySmall(context).copyWith(
                            fontSize: 9.sp,
                            color: AppColor.primaryColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 4.w, right: 8.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.redColor(context).withValues(alpha: 0.08),
                  ),
                  child: IconButton(
                    onPressed: () {
                      context.read<FavoritesCubit>().toggleFavorite(car);
                    },
                    icon: Icon(
                      Icons.favorite_rounded,
                      color: AppColor.redColor(context),
                      size: 22.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
