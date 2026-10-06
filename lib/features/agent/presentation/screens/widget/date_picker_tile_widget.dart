import 'package:car/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DatePickerTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final String? dateText;
  final VoidCallback onTap;
  final BuildContext context;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const DatePickerTile({
    super.key,
    required this.label,
    this.date,
    this.dateText,
    required this.onTap,
    required this.context,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext ctx) {
    return CustomFormField(
      radius: 12.r,
      readOnly: true,
      onTap: onTap,
      title: label,
      hintText: dateText,
      suffixIcon: Icon(
        Icons.calendar_month_rounded,
        color: AppColor.primaryColor(context),
        size: 14.sp,
      ),
      controller: controller ?? (dateText != null ? TextEditingController(text: dateText) : null),
      validator: validator,
    );
  }
}
