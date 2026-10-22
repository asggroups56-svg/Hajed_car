import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/buttons/custom_button.dart';
import 'package:car/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:car/core/images/app_images.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/common_methods.dart';
import 'package:car/features/home/data/model/financing_ad_model.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:car/features/home/presentation/view/widgets/mini_detail_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class CardContentSection extends StatelessWidget {
  const CardContentSection({
    super.key,
    required this.car,
    required this.onTap,
  });

  final Map<String, dynamic> car;
  final VoidCallback onTap;

  void _toggleComparison(BuildContext context) {
    if (HiveMethods.isInComparison(car)) {
      HiveMethods.removeFromComparison(car);
      CommonMethods.showToast(
        message: AppLocaleKey.removeFromCompare.tr(),
        type: ToastType.success,
      );
      return;
    }

    final countBefore = HiveMethods.getComparisonList().length;
    final added = HiveMethods.addToComparison(car);
    if (added) {
      CommonMethods.showToast(
        message: AppLocaleKey.added_to_compare.tr(),
        type: ToastType.success,
      );
      if (countBefore >= 1) {
        Navigator.pushNamed(context, RoutesName.carComparisonScreen);
      }
    } else {
      Navigator.pushNamed(context, RoutesName.carComparisonScreen);
    }
  }

  String get formattedPriceWithVat {
    final rawPrice = car['price']?.toString();
    if (rawPrice == null || rawPrice.isEmpty || rawPrice == 'null' || rawPrice == '---') {
      return '---';
    }
    final double paintingsVal =
        (car['PaintingsVal'] as num?)?.toDouble() ??
        (car['PAINTINGS_VAL'] as num?)?.toDouble() ??
        (car['paintingsVal'] as num?)?.toDouble() ??
        double.tryParse(car['PaintingsVal']?.toString() ?? '') ??
        double.tryParse(car['PAINTINGS_VAL']?.toString() ?? '') ??
        double.tryParse(car['paintingsVal']?.toString() ?? '') ??
        0.0;

    // If price already contains commas (already formatted from formattedPriceWithVat),
    // strip commas and return formatted adding paintingsVal
    final isAlreadyFormatted = rawPrice.contains(',');
    final numericStr = rawPrice.replaceAll(RegExp(r'[^0-9.]'), '');
    final double parsedPrice = double.tryParse(numericStr) ?? 0;
    if (parsedPrice <= 0) return rawPrice;

    final formatter = NumberFormat('#,##0', 'en_US');
    if (isAlreadyFormatted) {
      return formatter.format(parsedPrice + paintingsVal);
    }

    // Raw price without VAT - add VAT + paintings/plates value
    final vatNumber = HiveMethods.getVatNumber();
    final double vatPercentage = double.tryParse(vatNumber?.toString() ?? '') ?? 15.0;
    final double priceWithVat = parsedPrice * (1 + (vatPercentage / 100));
    final double totalCashPrice = priceWithVat + paintingsVal;
    return formatter.format(totalCashPrice);
  }

  /// Uses the same financing priority as the cars page: a car-specific
  /// installment, its interest rate, a supplied installment string, then the
  /// lowest available bank offer and finally the standard 60-month estimate.
  String? _formattedMonthlyInstallment(List<FinancingAdModel> offers) {
    final rawPrice = car['price']?.toString() ?? '';
    final price = double.tryParse(rawPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    if (price <= 0) return null;

    final formatter = NumberFormat('#,##0', 'en_US');
    final paintingsVal = _numberValue(
      car['PaintingsVal'] ?? car['PAINTINGS_VAL'] ?? car['paintingsVal'],
    );

    final monthlyInstallment = _numberValue(car['monthlyInstallment']);
    if (monthlyInstallment > 0) return formatter.format(monthlyInstallment);

    final interestRate = _numberValue(car['interestRate']);
    if (interestRate > 0) {
      final vatPercentage = double.tryParse(HiveMethods.getVatNumber()?.toString() ?? '') ?? 15.0;
      final priceWithVat = ((price + 3000) * (1 + vatPercentage / 100)) + paintingsVal;
      return formatter.format((priceWithVat + priceWithVat * (interestRate / 100) * 5) / 60);
    }

    final installments = car['installments']?.toString().trim();
    if (installments != null &&
        installments.isNotEmpty &&
        installments != '0' &&
        installments.toLowerCase() != 'null') {
      return installments;
    }

    if (offers.isNotEmpty) {
      final lowestOffer = offers.reduce(
        (a, b) =>
            a.monthlyInstallmentForPrice(price, platesVal: paintingsVal) <=
                b.monthlyInstallmentForPrice(price, platesVal: paintingsVal)
            ? a
            : b,
      );
      return formatter.format(
        lowestOffer.monthlyInstallmentForPrice(price, platesVal: paintingsVal),
      );
    }

    final vatPercentage = double.tryParse(HiveMethods.getVatNumber()?.toString() ?? '') ?? 15.0;
    final priceWithVat = ((price + 3000) * (1 + vatPercentage / 100)) + paintingsVal;
    return formatter.format((priceWithVat * 1.225) / 60);
  }

  double _numberValue(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '') ?? 0;

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
        child: Icon(Icons.color_lens_rounded, size: 15.w, color: Colors.white),
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
    final String rawColor =
        (car['color'] ?? car['Color'] ?? car['bodyColor'] ?? car['BODY_COLOR'] ?? '')
            .toString()
            .trim();
    final String displayColor = rawColor.isNotEmpty && rawColor.toLowerCase() != 'null'
        ? rawColor
        : '—';

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(5.h),
          Text(
            car['name']!,
            style: AppTextStyle.bodyMedium(
              context,
            ).copyWith(color: AppColor.blackTextColor(context), fontWeight: FontWeight.bold),
            maxLines: 3,
          ),
          Gap(5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MiniDetailWidget(icon: Icons.calendar_today_outlined, label: car['year'] ?? '—'),
              MiniDetailWidget(
                customIcon: _buildColorIcon(context, displayColor),
                label: displayColor,
              ),
            ],
          ),
          Gap(5.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColor.greyColor(context).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColor.primaryColor(context).withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocaleKey.cash.tr(),
                      style: AppTextStyle.bodySmall(
                        context,
                      ).copyWith(color: AppColor.greyColor(context), fontWeight: FontWeight.w900),
                    ),
                    Gap(4.h),
                    RichText(
                      text: TextSpan(
                        style: AppTextStyle.titleMedium(context).copyWith(
                          color: AppColor.blackColor(context),
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
                              color: AppColor.blackColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Gap(8.w),
                Container(
                  width: 2.w,
                  color: AppColor.blackTextColor(context).withValues(alpha: 0.1),
                  height: 40.h,
                ),
                Gap(8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocaleKey.agentInstallments.tr(),
                      style: AppTextStyle.bodySmall(
                        context,
                      ).copyWith(color: AppColor.greyColor(context), fontWeight: FontWeight.w900),
                    ),
                    Gap(4.h),
                    BlocBuilder<HomeCubit, HomeState>(
                      builder: (context, state) {
                        final installment = _formattedMonthlyInstallment(
                          state.normalFinancingStatus.data ?? const [],
                        );
                        if (installment == null) return const SizedBox.shrink();

                        return RichText(
                          text: TextSpan(
                            style: AppTextStyle.titleMedium(context).copyWith(
                              color: AppColor.primaryColor(context),
                              fontWeight: FontWeight.w900,
                              fontSize: 19.sp,
                              fontFamily: 'Arial',
                            ),
                            children: [
                              TextSpan(text: installment),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      AppImages.sar,
                                      width: 18.w,
                                      height: 18.h,
                                      color: AppColor.primaryColor(context),
                                    ),
                                    Gap(4.w),
                                    Text(
                                      '/ ${AppLocaleKey.month.tr()}',
                                      style: AppTextStyle.bodySmall(context).copyWith(
                                        color: AppColor.primaryColor(context),
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Gap(10.h),
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColor.greyColor(context), size: 16.w),
              Gap(4.w),
              Text(
                'شامل الضريبه واللوحات . والقسط مبدئي60 شهر ا بدون دفعه اولي ',
                style: AppTextStyle.bodySmall(context).copyWith(
                  color: AppColor.greyColor(context),
                  fontWeight: FontWeight.w900,
                  fontSize: 8.sp,
                ),
              ),
            ],
          ),
          Gap(5.h),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  onPressed: onTap,
                  height: 30.h,
                  color: AppColor.primaryColor(context),
                  radius: 12.r,
                  borderColor: AppColor.blackTextColor(context).withValues(alpha: 0.1),
                  child: Text(
                    AppLocaleKey.details.tr(),
                    style: AppTextStyle.bodySmall(
                      context,
                    ).copyWith(color: AppColor.whiteColor(context), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Gap(10.w),
              Expanded(
                child: CustomButton(
                  radius: 12.r,
                  onPressed: () => _toggleComparison(context),
                  color: AppColor.whiteColor(context).withValues(alpha: 0.1),
                  borderColor: AppColor.blackTextColor(context).withValues(alpha: 0.1),
                  height: 30.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: AppColor.blackTextColor(context), size: 16.w),
                      Gap(4.w),
                      Text(
                        AppLocaleKey.compare.tr(),
                        style: AppTextStyle.bodyMedium(context).copyWith(
                          color: AppColor.blackTextColor(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
