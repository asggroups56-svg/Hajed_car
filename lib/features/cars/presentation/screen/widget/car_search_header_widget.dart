import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/navigator_methods.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CarSearchHeaderWidget extends StatelessWidget {
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final Widget? sortAction;
  final Widget? viewToggleAction;

  const CarSearchHeaderWidget({
    super.key,
    this.controller,
    this.onChanged,
    this.sortAction,
    this.viewToggleAction,
  });

  OutlineInputBorder _border(Color color, {double width = 1}) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14.r),
    borderSide: BorderSide(color: color, width: width),
  );

  @override
  Widget build(BuildContext context) {
    final divider = AppColor.dividerColor(context);
    final primary = AppColor.primaryColor(context);
    final hint = AppColor.hintColor(context);

    Widget? clearButton() {
      if (controller == null) return null;
      return ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller!,
        builder: (context, value, _) {
          if (value.text.isEmpty) return const SizedBox.shrink();
          return IconButton(
            splashRadius: 18.r,
            icon: Icon(Icons.close_rounded, size: 18.sp, color: hint),
            onPressed: () {
              controller!.clear();
              onChanged?.call('');
            },
          );
        },
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 46.w,
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                textAlignVertical: TextAlignVertical.center,
                style: AppTextStyle.bodyMedium(
                  context,
                ).copyWith(color: AppColor.blackTextColor(context), fontWeight: FontWeight.w600),
                cursorColor: primary,
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: AppColor.secondAppColor(context),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                  hintText: AppLocaleKey.searchForYourDreamCar.tr(),
                  hintStyle: AppTextStyle.bodyMedium(
                    context,
                  ).copyWith(color: hint, fontSize: 13.sp),
                  prefixIcon: Icon(Icons.search_rounded, size: 21.sp, color: hint),
                  suffixIcon: clearButton(),
                  enabledBorder: _border(divider),
                  focusedBorder: _border(primary.withValues(alpha: 0.6), width: 1.4),
                  border: _border(divider),
                ),
              ),
            ),
          ),
          if (viewToggleAction != null) ...[Gap(8.w), viewToggleAction!],
          if (sortAction != null) ...[Gap(8.w), sortAction!],
          Gap(8.w),
          GestureDetector(
            onTap: () => NavigatorMethods.pushNamed(context, RoutesName.filterScreen),
            child: Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                color: AppColor.blackColor(context),
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(Icons.tune_rounded, color: AppColor.whiteColor(context), size: 21.sp),
            ),
          ),
        ],
      ),
    );
  }
}
