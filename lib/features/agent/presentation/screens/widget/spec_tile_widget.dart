import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class SpecTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const SpecTile({super.key, required this.icon, required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.cardColor(context),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColor.primaryColor(context).withValues(alpha: .08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AppColor.primaryColor(context)),
          ),
          Gap(14.w),
          Flexible(
            child: Text(
              title,
              style: AppTextStyle.bodyMedium(context).copyWith(
                color: AppColor.blackTextColor(context).withValues(alpha: 0.7),
              ),
            ),
          ),
          Gap(12.w),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.bodyMedium(context).copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
