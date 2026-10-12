import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:car/core/images/app_images.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/navigator_methods.dart';
import 'package:car/features/home/presentation/view/widgets/custom_price_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class HorizontalCarCardWidget extends StatelessWidget {
  final Map<String, dynamic> car;
  final VoidCallback? onTap;
  final String? heroTag;
  const HorizontalCarCardWidget({super.key, required this.car, this.onTap, this.heroTag});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        NavigatorMethods.pushNamed(
          context,
          RoutesName.carDetailsScreen,
          arguments: {'car': car, 'heroTag': heroTag},
        );
      },
      child: Container(
        width: 320.w,
        height: MediaQuery.of(context).size.height * 0.15,
        margin: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(
          color: AppColor.secondAppColor(context),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColor.blackColor(context).withValues(alpha: (0.05)),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColor.blackTextColor(context).withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 100.h,
              decoration: BoxDecoration(
                color: AppColor.blackTextColor(context).withValues(alpha: 0.02),
                borderRadius: BorderRadius.horizontal(left: Radius.circular(20.r)),
              ),

              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
                child: Hero(
                  tag: heroTag ?? 'car_image_${HiveMethods.getCarUniqueId(car)}',
                  child: (car['image'] != null && car['image'].toString().trim().startsWith('http'))
                      ? CustomNetworkImage(
                          imageUrl: car['image'],
                          fit: BoxFit.fill,
                          width: double.infinity,
                        )
                      : Image.asset(
                          (car['image'] != null && car['image'].toString().trim().isNotEmpty)
                              ? car['image']
                              : AppImages.assetsImagesCar,
                          fit: BoxFit.fill,
                          width: double.infinity,
                        ),
                ),
              ),
            ),

            // Right Side: Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      car['name'] ?? '',
                      style: AppTextStyle.titleSmall(context).copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap(30.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomPriceWidget(
                          car: car,
                          title: AppLocaleKey.cash.tr(),
                          price: car['cashPrice'] ?? '',
                        ),
                        Gap(4.h),
                        Container(
                          width: 3.w,
                          height: 30.h,
                          color: AppColor.blackTextColor(context).withValues(alpha: 0.5),
                        ),
                        Gap(4.h),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              RoutesName.financingScreen,
                              arguments: car,
                            );
                          },
                          child: CustomPriceWidget(
                            car: car,
                            title: AppLocaleKey.installments.tr(),
                            price: car['installmentPrice'] ?? '',
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),
                    if (car['isTamaraAvailable'] == true)
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Image.asset(
                          AppImages.assetsImagesTamara,
                          width: 60.w,
                          height: 20.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
