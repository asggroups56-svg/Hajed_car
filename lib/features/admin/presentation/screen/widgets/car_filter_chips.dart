import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CarFilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const CarFilterChips({super.key, required this.selectedFilter, required this.onFilterChanged});

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'key': 'available', 'label': AppLocaleKey.agentCarAvailable.tr()},
      {'key': 'reserved', 'label': AppLocaleKey.adminPendingApprovals.tr()},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          for (int i = 0; i < filters.length; i++) ...[
            if (i != 0) SizedBox(width: 8.w),
            Expanded(child: _buildChip(context, filters[i])),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, Map<String, String> f) {
    final isActive = selectedFilter == f['key'];
    return GestureDetector(
      onTap: () => onFilterChanged(f['key']!),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive
              ? AppColor.primaryColor(context)
              : AppColor.whiteColor(context).withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : AppColor.blackTextColor(context).withValues(alpha: 0.08),
          ),
        ),
        child: Center(
          child: Text(
            f['label']!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.bodyMedium(context).copyWith(
              fontWeight: FontWeight.w500,
              color: isActive
                  ? AppColor.whiteColor(context)
                  : AppColor.blackTextColor(context).withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
