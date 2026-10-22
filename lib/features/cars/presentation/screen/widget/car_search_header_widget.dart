import 'package:car/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/utils/navigator_methods.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CarSearchHeaderWidget extends StatelessWidget {
  final TextEditingController? controller;
  final void Function(String)? onChanged;

  const CarSearchHeaderWidget({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Expanded(
            child: CustomFormField(
              controller: controller,
              onChanged: onChanged,
              hintText: AppLocaleKey.searchForYourDreamCar.tr(),
              prefixIcon: const Icon(Icons.search_rounded),
              radius: 12.r,
            ),
          ),
          Gap(12.w),
          GestureDetector(
            onTap: () => NavigatorMethods.pushNamed(context, RoutesName.filterScreen),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColor.blackColor(context),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(Icons.tune_rounded, color: AppColor.whiteColor(context)),
            ),
          ),
        ],
      ),
    );
  }
}
