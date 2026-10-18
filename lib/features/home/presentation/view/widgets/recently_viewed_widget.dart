import 'package:animate_do/animate_do.dart';
import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:car/core/images/app_images.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/navigator_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class RecentlyViewedWidget extends StatelessWidget {
  final List<dynamic> cars;

  const RecentlyViewedWidget({super.key, required this.cars});

  void _navigateToDetails(BuildContext context, Map<String, dynamic> car) {
    NavigatorMethods.pushNamed(context, RoutesName.carDetailsScreen, arguments: car);
  }

  double _getPriceWithVat(Map<String, dynamic> car) {
    final priceRaw = car['price']?.toString() ?? '0';
    if (priceRaw.isEmpty || priceRaw == '0') return 0.0;

    final cleanPrice = priceRaw.replaceAll(RegExp(r'[^0-9.]'), '');
    final double originalPrice = double.tryParse(cleanPrice) ?? 0.0;

    if (originalPrice <= 0) return 0.0;

    final vatSerial = HiveMethods.getVatNumber();
    final double vatPercentage = double.tryParse(vatSerial.toString()) ?? 15.0;
    final double paintingsVal = (car['PaintingsVal'] as num?)?.toDouble() ??
        (car['PAINTINGS_VAL'] as num?)?.toDouble() ??
        (car['paintingsVal'] as num?)?.toDouble() ??
        double.tryParse(car['PaintingsVal']?.toString() ?? '') ??
        double.tryParse(car['PAINTINGS_VAL']?.toString() ?? '') ??
        double.tryParse(car['paintingsVal']?.toString() ?? '') ??
        0.0;

    return originalPrice * (1 + (vatPercentage / 100)) + paintingsVal;
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0', 'en_US');

    return SizedBox(
      height: 240.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: cars.length,
        separatorBuilder: (context, index) => Gap(12.w),
        itemBuilder: (context, index) {
          final Map<String, dynamic> car = Map<String, dynamic>.from(cars[index]);

          // حساب السعر مع الضريبة
          final double priceWithVat = _getPriceWithVat(car);
          final String formattedPrice = priceWithVat > 0
              ? formatter.format(priceWithVat)
              : car['price']?.toString() ?? '0';

          // الحصول على نسبة الضريبة للعرض
          double vatPercentage = 15.0;
          if (car.containsKey('VAT_SERIAL')) {
            final vatSerial = car['VAT_SERIAL']?.toString();
            if (vatSerial != null && vatSerial.isNotEmpty) {
              vatPercentage = double.tryParse(vatSerial) ?? 15.0;
            }
          }

          return FadeInRight(
            duration: Duration(milliseconds: 500 + (index * 100)),
            child: GestureDetector(
              onTap: () => _navigateToDetails(context, car),
              child: Container(
                width: 200.w,
                decoration: BoxDecoration(
                  color: AppColor.cardColor(context),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.blackColor(context).withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: AppColor.dividerColor(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.blackTextColor(context).withValues(alpha: (0.02)),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.r),
                            topRight: Radius.circular(16.r),
                          ),
                        ),
                        child: Center(
                          child: car['image'].toString().trim().startsWith('http')
                              ? ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16.r),
                                    topRight: Radius.circular(16.r),
                                  ),
                                  child: CustomNetworkImage(
                                    imageUrl: car['image'],
                                    fit: BoxFit.fill,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16.r),
                                    topRight: Radius.circular(16.r),
                                  ),
                                  child: Image.asset(
                                    car['image']!,
                                    fit: BoxFit.fill,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              car['name'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.bodyMedium(context).copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColor.blackTextColor(context),
                                height: 1.2,
                              ),
                            ),
                            Gap(6.h),
                            // السعر شامل الضريبة
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    formattedPrice,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyle.titleMedium(context).copyWith(
                                      color: AppColor.primaryColor(context),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 19.sp,
                                      fontFamily: 'Arial',
                                    ),
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                SvgPicture.asset(
                                  AppImages.sar,
                                  width: 18.w,
                                  height: 18.h,
                                  colorFilter: ColorFilter.mode(
                                    AppColor.primaryColor(context),
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ],
                            ),
                            // إضافة نص شامل الضريبة
                            if (priceWithVat > 0) ...[
                              Gap(2.h),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: AppColor.primaryColor(context).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      'شامل الضريبة ${vatPercentage.toStringAsFixed(0)}%',
                                      style: AppTextStyle.bodySmall(context).copyWith(
                                        fontSize: 8.sp,
                                        color: AppColor.primaryColor(context),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
