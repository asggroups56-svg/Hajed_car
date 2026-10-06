import 'package:car/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:car/core/network/contants.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/home/data/model/cars_models_response.dart';
import 'package:easy_localization/easy_localization.dart';
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
        width: 90.w,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [AppColor.primaryColor(context), const Color(0xff0047BB)])
              : null,
          color: isSelected ? null : AppColor.secondAppColor(context),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColor.whiteColor(context).withValues(alpha: 0.9)
                    : AppColor.blackTextColor(context).withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: CustomNetworkImage(
                imageUrl:
                    "${Constants.baseImage}${item.picturePath.replaceAll('../../Img/Emp/', '')}",
                width: 32.w,
                height: 32.w,
                fit: BoxFit.contain,
              ),
            ),
            Gap(10.h),
            Text(
              context.locale.languageCode == 'ar' ? item.groupName : item.groupEName ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.bodySmall(context).copyWith(
                color: isSelected
                    ? AppColor.whiteColor(context)
                    : AppColor.blackTextColor(context).withValues(alpha: 0.8),
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
