import 'package:car/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BulidIconWidget extends StatelessWidget {
  const BulidIconWidget({super.key, required this.isSuccess});
  final bool isSuccess;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120.w,
      height: 120.w,
      decoration: BoxDecoration(
        color: isSuccess
            ? AppColor.greenColor(context).withValues(alpha: 0.1)
            : AppColor.redColor(context).withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
        size: 80.sp,
        color: isSuccess ? AppColor.greenColor(context) : AppColor.redColor(context),
      ),
    );
  }
}
