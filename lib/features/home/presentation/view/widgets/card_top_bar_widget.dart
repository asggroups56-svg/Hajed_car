import 'package:car/features/home/presentation/view/widgets/favorites_button.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CardTopBar extends StatelessWidget {
  const CardTopBar({super.key, required this.car});

  final Map<String, dynamic> car;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (car['isAvailable'] == true)
                _CarBadge(label: 'متاحة', color: Colors.green.shade700),
              if (car['isPopular'] == true) ...[
                SizedBox(width: 6.w),
                _CarBadge(label: 'شائعة', color: AppColor.primaryColor(context)),
              ],
            ],
          ),
          FavoritesButton(car: car),
        ],
      ),
    );
  }
}

class _CarBadge extends StatelessWidget {
  const _CarBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .92),
      borderRadius: BorderRadius.circular(20.r),
    ),
    child: Text(label, style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w700)),
  );
}
