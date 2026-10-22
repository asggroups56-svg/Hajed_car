import 'package:car/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:car/core/network/contants.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/features/home/data/model/cars_models_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CustomItemCategoriesWidget extends StatelessWidget {
  const CustomItemCategoriesWidget({super.key, required this.isSelected, required this.item});
  final bool isSelected;
  final CarModel item;
  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isSelected ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 60.w,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? AppColor.primaryColor(context)
                : AppColor.blackTextColor(context).withValues(alpha: 0.1),
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Gap(10.h),
            CustomNetworkImage(
              imageUrl:
                  "${Constants.baseImage}${item.picturePath.replaceAll('../../Img/Emp/', '')}",
              width: 32.w,
              height: 32.w,
              fit: BoxFit.contain,
            ),
            Gap(10.h),
          ],
        ),
      ),
    );
  }
}
