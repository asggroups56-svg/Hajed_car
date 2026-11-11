import 'dart:ui' as ui;

import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:car/core/custom_widgets/custom_sar_text.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/navigator_methods.dart';
import 'package:car/features/favorites/presentation/view/cubit/favorites_cubit.dart';
import 'package:car/features/home/presentation/view/widgets/mini_detail_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

/// Horizontal saved-car card: the Favorites layout dressed in the Home card
/// language — soft surface, year/colour pills, a green cash price and the
/// "tax included" note.
class FavoriteItemWidget extends StatelessWidget {
  const FavoriteItemWidget({super.key, required this.car});

  final Map<String, dynamic> car;

  String get _heroTag => 'fav_car_image_${HiveMethods.getCarUniqueId(car)}';

  String get _name => car['name']?.toString().trim() ?? '';

  String get _brand => car['brand']?.toString().trim() ?? '';

  String get _year {
    final value = car['year']?.toString().trim() ?? '';
    return value.toLowerCase() == 'null' ? '' : value;
  }

  String get _colorName {
    final value = (car['color'] ?? car['Color'] ?? car['bodyColor'] ?? car['BODY_COLOR'] ?? '')
        .toString()
        .trim();
    return value.toLowerCase() == 'null' ? '' : value;
  }

  String get _formattedPrice {
    final priceRaw = car['price']?.toString() ?? '0';
    if (priceRaw.isEmpty || priceRaw == '0') return '0';

    final double originalPrice = double.tryParse(priceRaw) ?? 0.0;
    if (originalPrice <= 0) return '0';

    final double vatPercentage = double.tryParse(car['VAT_SERIAL']?.toString() ?? '') ?? 15.0;
    final double priceWithVat = originalPrice * (vatPercentage / 100) + originalPrice;
    final double paintingsVal =
        (car['PaintingsVal'] as num?)?.toDouble() ??
        (car['PAINTINGS_VAL'] as num?)?.toDouble() ??
        (car['paintingsVal'] as num?)?.toDouble() ??
        double.tryParse(car['PaintingsVal']?.toString() ?? '') ??
        double.tryParse(car['PAINTINGS_VAL']?.toString() ?? '') ??
        double.tryParse(car['paintingsVal']?.toString() ?? '') ??
        0.0;
    final double totalCashPrice = priceWithVat + paintingsVal;

    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(totalCashPrice);
  }

  /// Best-effort mapping from the paint name to a swatch. These are physical
  /// car colours, so literal values are intentional rather than theme tokens.
  Color? _colorFromName(String name) {
    final value = name.toLowerCase();
    const keywords = <String, Color>{
      'أبيض': Colors.white,
      'ابيض': Colors.white,
      'white': Colors.white,
      'أسود': Colors.black,
      'اسود': Colors.black,
      'black': Colors.black,
      'فضي': Color(0xFFB0B7C3),
      'silver': Color(0xFFB0B7C3),
      'رمادي': Colors.grey,
      'رصاصي': Colors.grey,
      'grey': Colors.grey,
      'gray': Colors.grey,
      'أحمر': Color(0xFFE53935),
      'احمر': Color(0xFFE53935),
      'red': Color(0xFFE53935),
      'أزرق': Color(0xFF1E88E5),
      'ازرق': Color(0xFF1E88E5),
      'كحلي': Color(0xFF1A237E),
      'blue': Color(0xFF1E88E5),
      'beige': Color(0xFFF5F5DC),
      'بيج': Color(0xFFF5F5DC),
      'بني': Colors.brown,
      'brown': Colors.brown,
      'أخضر': Color(0xFF43A047),
      'اخضر': Color(0xFF43A047),
      'green': Color(0xFF43A047),
      'أصفر': Color(0xFFFDD835),
      'اصفر': Color(0xFFFDD835),
      'yellow': Color(0xFFFDD835),
      'برتقالي': Colors.orange,
      'orange': Colors.orange,
      'ذهبي': Color(0xFFF5A623),
      'gold': Color(0xFFF5A623),
      'عنابي': Color(0xFF800000),
      'خمري': Color(0xFF800000),
      'maroon': Color(0xFF800000),
    };

    for (final entry in keywords.entries) {
      if (value.contains(entry.key)) return entry.value;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = AppColor.primaryColor(context);
    final Color grey = AppColor.greyColor(context);
    final Color? swatch = _colorFromName(_colorName);

    return Container(
      decoration: BoxDecoration(
        color: AppColor.secondAppColor(context),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.blackColor(context).withValues(alpha: 0.06),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: AppColor.blackTextColor(context).withValues(alpha: 0.04)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => NavigatorMethods.pushNamed(
            context,
            RoutesName.carDetailsScreen,
            arguments: {'car': car, 'heroTag': _heroTag},
          ),
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [_CarThumbnail(car: car, heroTag: _heroTag)],
                ),
                Gap(12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_brand.isNotEmpty) ...[
                        Row(
                          children: [
                            // Text(
                            //   _brand,
                            //   style: AppTextStyle.bodySmall(context).copyWith(
                            //     color: primary,
                            //     fontSize: 10.sp,
                            //     fontWeight: FontWeight.w800,
                            //     letterSpacing: 0.2,
                            //   ),
                            //   maxLines: 1,
                            //   overflow: TextOverflow.ellipsis,
                            // ),
                            const Spacer(),
                            _FavoriteToggleButton(car: car),
                          ],
                        ),
                        Gap(3.h),
                      ],
                      Text(
                        _name,
                        style: AppTextStyle.bodyMedium(context).copyWith(
                          color: AppColor.blackTextColor(context),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_year.isNotEmpty || _colorName.isNotEmpty) ...[
                        Gap(7.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 4.h,
                          children: [
                            if (_year.isNotEmpty)
                              MiniDetailWidget(icon: Icons.calendar_today_outlined, label: _year),
                            if (_colorName.isNotEmpty)
                              MiniDetailWidget(
                                customIcon: swatch == null ? null : _ColorDot(color: swatch),
                                icon: swatch == null ? Icons.palette_outlined : null,
                                label: _colorName,
                              ),
                          ],
                        ),
                      ],
                      Gap(8.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppLocaleKey.cash.tr(),
                                  style: AppTextStyle.bodySmall(context).copyWith(
                                    color: grey,
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Gap(1.h),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: AlignmentDirectional.centerStart,
                                  child: ValueWithCurrencyIcon(
                                    text: '$_formattedPrice SAR',
                                    textStyle: AppTextStyle.bodyMedium(context).copyWith(
                                      color: AppColor.greenColor(context),
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'Arial',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Gap(6.w),
                          Container(
                            width: 26.w,
                            height: 26.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primary.withValues(alpha: 0.08),
                            ),
                            child: Icon(
                              Directionality.of(context) == ui.TextDirection.rtl
                                  ? Icons.arrow_back_ios_new_rounded
                                  : Icons.arrow_forward_ios_rounded,
                              size: 11.sp,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                      Gap(4.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 1.h),
                            child: Icon(Icons.info_outline_rounded, color: grey, size: 11.sp),
                          ),
                          Gap(4.w),
                          Flexible(
                            child: Text(
                              AppLocaleKey.taxIncluded.tr(),
                              style: AppTextStyle.bodySmall(context).copyWith(
                                color: grey,
                                fontSize: 8.5.sp,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                              maxLines: 2,
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CarThumbnail extends StatelessWidget {
  const _CarThumbnail({required this.car, required this.heroTag});

  final Map<String, dynamic> car;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final String image = car['image']?.toString().trim() ?? '';
    final Color primary = AppColor.primaryColor(context);

    final Widget fallback = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary.withValues(alpha: 0.14), primary.withValues(alpha: 0.03)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.directions_car_rounded,
          size: 34.sp,
          color: primary.withValues(alpha: 0.4),
        ),
      ),
    );

    final Widget imageChild = image.startsWith('http')
        ? CustomNetworkImage(imageUrl: image, fit: BoxFit.cover, width: 108.w, height: 126.h)
        : image.isNotEmpty
        ? Image.asset(
            image,
            fit: BoxFit.cover,
            width: 108.w,
            height: 126.h,
            errorBuilder: (context, error, stackTrace) => fallback,
          )
        : fallback;

    return SizedBox(
      width: 108.w,
      height: 126.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Hero(tag: heroTag, child: imageChild),
      ),
    );
  }
}

class _FavoriteToggleButton extends StatelessWidget {
  const _FavoriteToggleButton({required this.car});

  final Map<String, dynamic> car;

  @override
  Widget build(BuildContext context) {
    final Color red = AppColor.redColor(context);

    return Semantics(
      button: true,
      label: AppLocaleKey.removeFromFavorites.tr(),
      child: SizedBox(
        width: 44.w,
        height: 44.w,
        child: InkResponse(
          onTap: () => context.read<FavoritesCubit>().toggleFavorite(car),
          radius: 22.w,
          containedInkWell: true,
          highlightShape: BoxShape.circle,
          child: Center(
            child: Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.secondAppColor(context),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.blackColor(context).withValues(alpha: 0.18),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.favorite_rounded, color: red, size: 17.sp),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 11.w,
      height: 11.w,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColor.blackTextColor(context).withValues(alpha: 0.22),
          width: 0.8,
        ),
      ),
    );
  }
}
