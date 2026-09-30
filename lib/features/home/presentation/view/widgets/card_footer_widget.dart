import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_sar_text.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/home/presentation/view/widgets/spec_badge_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CardFooter extends StatelessWidget {
  const CardFooter({super.key, required this.car});

  final Map<String, dynamic> car;

  List<Color> _parseCarColors(BuildContext context, String colorName) {
    final name = colorName.trim().toLowerCase();
    final List<Color> foundColors = [];

    final Map<List<String>, Color> colorKeywords = {
      ['أبيض', 'ابيض', 'white']: Colors.white,
      ['أسود', 'اسود', 'black']: Colors.black,
      ['فضي', 'silver']: Colors.grey.shade400,
      ['رمادي', 'رصاصي', 'grey', 'gray']: Colors.grey,
      ['أحمر', 'احمر', 'red']: Colors.red,
      ['أزرق', 'ازرق', 'كحلي', 'blue', 'navy']: Colors.blue,
      ['بيج', 'beige']: const Color(0xFFF5F5DC),
      ['بني', 'brown']: Colors.brown,
      ['أخضر', 'اخضر', 'زيتي', 'green']: AppColor.greenColor(context),
      ['أصفر', 'اصفر', 'yellow']: Colors.yellow,
      ['برتقالي', 'orange']: Colors.orange,
      ['ذهبي', 'gold']: const Color(0xFFFFD700),
      ['عنابي', 'خمري', 'maroon']: const Color(0xFF800000),
    };

    for (final entry in colorKeywords.entries) {
      for (final keyword in entry.key) {
        if (name.contains(keyword)) {
          if (!foundColors.contains(entry.value)) {
            foundColors.add(entry.value);
          }
          break;
        }
      }
    }

    return foundColors;
  }

  bool _isMultipleColors(String colorName) {
    final name = colorName.trim().toLowerCase();
    return name.contains('/') ||
        name.contains('\\') ||
        name.contains('+') ||
        name.contains('مع') ||
        name.contains('و') ||
        name.contains('two tone') ||
        name.contains('توتون') ||
        name.contains('لونين') ||
        name.contains('متعدد');
  }

  Widget _buildColorIcon(BuildContext context, String colorName) {
    final colors = _parseCarColors(context, colorName);
    final isMulti = colors.length >= 2 || _isMultipleColors(colorName);

    if (isMulti) {
      final List<Color> gradientColors = colors.length >= 2
          ? colors
          : const [
              Color(0xFFE53935),
              Color(0xFFFB8C00),
              Color(0xFF43A047),
              Color(0xFF1E88E5),
              Color(0xFF8E24AA),
            ];

      return ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        child: Icon(Icons.color_lens_rounded, size: 15.sp, color: Colors.white),
      );
    }

    if (colors.length == 1) {
      final singleColor = colors.first;
      return Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: singleColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: singleColor == Colors.white
                ? AppColor.greyColor(context).withValues(alpha: 0.6)
                : AppColor.blackTextColor(context).withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: singleColor.withValues(alpha: 0.25),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      );
    }

    return Icon(
      Icons.palette_outlined,
      color: AppColor.blackTextColor(context).withValues(alpha: 0.54),
      size: 14.sp,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String rawColor =
        (car['color'] ?? car['Color'] ?? car['bodyColor'] ?? car['BODY_COLOR'] ?? '')
            .toString()
            .trim();
    final String displayColor = rawColor.isNotEmpty && rawColor.toLowerCase() != 'null'
        ? rawColor
        : '—';
    final String? priceRaw = car['price']?.toString();
    final bool hasPrice =
        priceRaw != null && priceRaw != '0' && priceRaw.isNotEmpty && priceRaw != 'null';

    // الحصول على نسبة الضريبة من الـ API
    final String? vatSerial = HiveMethods.getVatNumber();
    final double vatPercentage = double.tryParse(vatSerial.toString()) ?? 15;

    // حساب السعر شامل الضريبة
    String priceWithVatText = '0';
    if (hasPrice) {
      final isAlreadyFormatted = priceRaw.contains(',');
      final cleanPrice = priceRaw.replaceAll(RegExp(r'[^0-9.]'), '');
      final double originalPrice = double.tryParse(cleanPrice) ?? 0;
      if (isAlreadyFormatted) {
        final formatter = NumberFormat('#,##0', 'en_US');
        priceWithVatText = formatter.format(originalPrice);
      } else {
        final double priceWithVat = originalPrice * (1 + (vatPercentage / 100));
        final formatter = NumberFormat('#,##0', 'en_US');
        priceWithVatText = formatter.format(priceWithVat);
      }
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: AppColor.secondAppColor(context),
        border: Border(
          top: BorderSide(color: AppColor.blackTextColor(context).withValues(alpha: 0.06)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(8.h),
          Text(
            car['name'] ?? '',
            style: AppTextStyle.titleMedium(
              context,
            ).copyWith(color: AppColor.blackTextColor(context), fontWeight: FontWeight.w900),
          ),
          Gap(12.h),

          if (hasPrice) ...[
            Gap(4.h),
            Row(
              children: [
                ValueWithCurrencyIcon(
                  text: '$priceWithVatText ${AppLocaleKey.sar.tr()}',
                  textStyle: AppTextStyle.bodySmall(
                    context,
                  ).copyWith(color: AppColor.blackTextColor(context), fontWeight: FontWeight.w600),
                ),
                Gap(8.w),
                Text(
                  AppLocaleKey.taxIncluded.tr(),
                  style: AppTextStyle.bodySmall(
                    context,
                  ).copyWith(color: AppColor.greyColor(context)),
                ),
              ],
            ),
          ],
          Gap(16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SpecBadgeWidget(
                icon: Icons.calendar_today_rounded,
                text: car['year']?.toString() ?? 'N/A',
              ),
              SpecBadgeWidget(icon: Icons.speed_rounded, text: car['mileage'] ?? '0 كم'),
              SpecBadgeWidget(
                customIcon: _buildColorIcon(context, displayColor),
                text: displayColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
