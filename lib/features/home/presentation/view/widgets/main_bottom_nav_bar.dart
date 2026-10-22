import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const MainBottomNavBar({super.key, required this.currentIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.only(left: 8.w, right: 8.w, top: 8.h, bottom: 6.h + bottomPadding),
      decoration: BoxDecoration(
        color: AppColor.secondAppColor(context),
        boxShadow: [
          BoxShadow(
            color: AppColor.blackTextColor(context).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MainNavItem(
            index: 0,
            currentIndex: currentIndex,
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: AppLocaleKey.home.tr(),
            onTap: () => onItemSelected(0),
          ),
          MainNavItem(
            index: 1,
            currentIndex: currentIndex,
            icon: Icons.directions_car_outlined,
            activeIcon: Icons.directions_car,
            label: AppLocaleKey.cars.tr(),
            onTap: () => onItemSelected(1),
          ),
          MainNavItem(
            index: 2,
            currentIndex: currentIndex,
            icon: Icons.favorite_outline_rounded,
            activeIcon: Icons.favorite_rounded,
            label: AppLocaleKey.favorites.tr(),
            onTap: () => onItemSelected(2),
          ),
          MainNavItem(
            index: 3,
            currentIndex: currentIndex,
            icon: Icons.miscellaneous_services_outlined,
            activeIcon: Icons.miscellaneous_services,
            label: AppLocaleKey.services.tr(),
            onTap: () => onItemSelected(3),
          ),
        ],
      ),
    );
  }
}

class MainNavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final VoidCallback onTap;

  const MainNavItem({
    super.key,
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isSelected = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 36.w,
                height: 32.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r)),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? AppColor.primaryColor(context) : AppColor.greyColor(context),
                  size: 21.sp,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bodySmall(context).copyWith(
                  color: isSelected ? AppColor.primaryColor(context) : AppColor.greyColor(context),
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
