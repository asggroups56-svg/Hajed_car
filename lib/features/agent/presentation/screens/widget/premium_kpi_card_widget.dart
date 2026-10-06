import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/agent/data/model/agent_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class PremiumKpiCard extends StatelessWidget {
  final AgentKpi kpi;
  const PremiumKpiCard({super.key, required this.kpi});

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColor.cardColor(context),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: kpi.color.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: kpi.color.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kpi.color.withValues(alpha: 0.15), kpi.color.withValues(alpha: 0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: kpi.color.withValues(alpha: 0.2)),
                ),
                child: Icon(kpi.icon, color: kpi.color, size: 20.sp),
              ),
            ],
          ),
          const Spacer(),
          Text(
            kpi.value,
            style: AppTextStyle.titleLarge(context).copyWith(
              color: AppColor.blackTextColor(context),
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          Gap(4.h),
          Text(
            kpi.label,
            style: AppTextStyle.bodySmall(context).copyWith(
              color: AppColor.greyColor(context),
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
