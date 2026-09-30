import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/buttons/custom_button.dart';
import 'package:car/core/images/app_images.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/home/presentation/view/widgets/mini_detail_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class CardContentSection extends StatelessWidget {
  const CardContentSection({
    super.key,
    required this.car,
    required this.onTap,
    required this.onOrderNow,
  });

  final Map<String, dynamic> car;
  final VoidCallback onTap;
  final VoidCallback onOrderNow;
  String get formattedPriceWithVat {
    final rawPrice = car['price']?.toString();
    if (rawPrice == null || rawPrice.isEmpty || rawPrice == 'null' || rawPrice == '---') {
      return '---';
    }
    // If price already contains commas (already formatted from formattedPriceWithVat),
    // strip commas and return formatted without re-applying VAT
    final isAlreadyFormatted = rawPrice.contains(',');
    final numericStr = rawPrice.replaceAll(RegExp(r'[^0-9.]'), '');
    final double parsedPrice = double.tryParse(numericStr) ?? 0;
    if (parsedPrice <= 0) return rawPrice;

    if (isAlreadyFormatted) {
      // Price already includes VAT, just re-format to remove decimals
      final formatter = NumberFormat('#,##0', 'en_US');
      return formatter.format(parsedPrice);
    }

    // Raw price without VAT - add VAT
    final vatNumber = HiveMethods.getVatNumber();
    final double vatPercentage = double.tryParse(vatNumber?.toString() ?? '') ?? 15.0;
    final double priceWithVat = parsedPrice * (1 + (vatPercentage / 100));
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(priceWithVat);
  }

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

    // إذا كان هناك لونين أو ألوان متعددة -> عرض أيقونة الألوان المتعددة (Multi-color Lens / Palette)
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
        child: Icon(
          Icons.color_lens_rounded,
          size: 15.w,
          color: Colors.white,
        ),
      );
    }

    // إذا كان لوناً واحداً معروفاً
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

    // الحالة الافتراضية
    return Icon(Icons.palette_outlined, color: AppColor.greyColor(context), size: 14.w);
  }

  @override
  Widget build(BuildContext context) {
    final String rawColor = (car['color'] ?? car['Color'] ?? car['bodyColor'] ?? car['BODY_COLOR'] ?? '').toString().trim();
    final String displayColor = rawColor.isNotEmpty && rawColor.toLowerCase() != 'null' ? rawColor : '—';

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(16.h),
          Text(
            car['name']!,
            style: AppTextStyle.bodyMedium(
              context,
            ).copyWith(color: AppColor.blackTextColor(context), fontWeight: FontWeight.bold),
            maxLines: 3,
          ),
          Gap(10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MiniDetailWidget(icon: Icons.calendar_today_outlined, label: car['year'] ?? '—'),
              MiniDetailWidget(icon: Icons.speed_outlined, label: car['mileage'] ?? '—'),
              MiniDetailWidget(
                customIcon: _buildColorIcon(context, displayColor),
                label: displayColor,
              ),
            ],
          ),
          Gap(10.h),
          RichText(
            text: TextSpan(
              style: AppTextStyle.titleMedium(context).copyWith(
                color: AppColor.primaryColor(context),
                fontWeight: FontWeight.w900,
                fontSize: 19.sp,
                fontFamily: 'Arial',
              ),
              children: [
                TextSpan(text: formattedPriceWithVat),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: SvgPicture.asset(
                    AppImages.sar,
                    width: 18.w,
                    height: 18.h,
                    color: AppColor.primaryColor(context),
                  ),
                ),
              ],
            ),
          ),
          Gap(10.h),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  radius: 12.r,
                  onPressed: onOrderNow,
                  height: 30.h,
                  child: Text(
                    AppLocaleKey.orderNow.tr(),
                    style: AppTextStyle.bodyMedium(
                      context,
                    ).copyWith(color: AppColor.whiteColor(context), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Gap(10.w),
              Expanded(
                child: CustomButton(
                  onPressed: onTap,
                  height: 30.h,
                  color: AppColor.whiteColor(context),
                  radius: 12.r,
                  borderColor: AppColor.blackTextColor(context).withValues(alpha: 0.1),
                  child: Text(
                    AppLocaleKey.details.tr(),
                    style: AppTextStyle.bodySmall(
                      context,
                    ).copyWith(color: AppColor.blackColor(context), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
