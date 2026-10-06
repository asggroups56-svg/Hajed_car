import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PremiumAvatar extends StatelessWidget {
  final String? initials;
  final String? localizedInitials;

  const PremiumAvatar({super.key, this.initials, this.localizedInitials});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColor.blueColor(context);
    final text = localizedInitials != null ? localizedInitials!.tr() : (initials ?? '');

    return Container(
      width: 60.w,
      height: 60.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withAlpha(200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColor.whiteColor(context).withValues(alpha: 0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: AppTextStyle.titleLarge(context).copyWith(
            color: AppColor.whiteColor(context),
            fontWeight: FontWeight.w900,
            fontSize: 18.sp,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
