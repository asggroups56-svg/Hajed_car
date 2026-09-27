import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class MiniDetailWidget extends StatelessWidget {
  const MiniDetailWidget({
    super.key,
    this.icon,
    this.customIcon,
    required this.label,
  });

  final IconData? icon;
  final Widget? customIcon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColor.blackTextColor(context).withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColor.blackTextColor(context).withValues(alpha: (0.02))),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (customIcon != null)
            customIcon!
          else if (icon != null)
            Icon(icon, color: AppColor.greyColor(context), size: 14.w),
          Gap(4.w),
          Flexible(
            child: Text(
              label,
              style: AppTextStyle.bodySmall(context).copyWith(
                color: AppColor.greyColor(context),
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
