import 'package:car/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReportDividerWidget extends StatelessWidget {
  const ReportDividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Divider(color: AppColor.blackTextColor(context).withValues(alpha: 0.05), height: 1),
    );
  }
}
