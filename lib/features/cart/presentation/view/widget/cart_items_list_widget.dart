import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/admin/data/model/cars_response_model.dart';
import 'package:car/features/cart/presentation/view/widget/cart_item_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CartItemsListWidget extends StatelessWidget {
  final List<CarModel> cars;
  final String? selectedCarId;
  const CartItemsListWidget({super.key, required this.cars, this.selectedCarId});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        physics: const BouncingScrollPhysics(),
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColor.primaryColor(context).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColor.primaryColor(context).withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor(context),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.directions_car_filled_rounded,
                    color: AppColor.whiteColor(context),
                    size: 14.sp,
                  ),
                ),
                Gap(10.w),
                Expanded(
                  child: Text(
                    '${cars.length} ${cars.length == 1 ? AppLocaleKey.cartCarSingular.tr() : AppLocaleKey.cartCarPlural.tr()} ${AppLocaleKey.inYourCart.tr()}',
                    style: AppTextStyle.bodyMedium(context).copyWith(
                      color: AppColor.primaryColor(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),

          ..._orderedCars.map((car) => CartItemWidget(car: car)),
          Gap(12.h),
        ],
      ),
    );
  }

  List<CarModel> get _orderedCars {
    if (selectedCarId == null) return cars;
    final ordered = [...cars];
    ordered.sort((a, b) {
      final aSelected = a.itemCode == selectedCarId || a.lpoNo == selectedCarId;
      final bSelected = b.itemCode == selectedCarId || b.lpoNo == selectedCarId;
      return bSelected.toString().compareTo(aSelected.toString());
    });
    return ordered;
  }
}
