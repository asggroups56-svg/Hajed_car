import 'dart:ui' as ui;

import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/buttons/custom_button.dart';
import 'package:car/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:car/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:car/core/images/app_images.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/common_methods.dart';
import 'package:car/core/utils/navigator_methods.dart';
import 'package:car/features/favorites/presentation/view/cubit/favorites_cubit.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:car/features/home/data/model/financing_ad_model.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:car/features/home/presentation/view/widgets/mini_detail_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

/// A modern car card combining the horizontal Favorites-style layout
/// with the rich, dual-pricing and styling language of the Home screen.
class HomeHorizontalCarCard extends StatelessWidget {
  const HomeHorizontalCarCard({
    super.key,
    required this.car,
    this.heroTag,
    this.onTap,
    this.showFavoriteButton = true,
    this.showCompareButton = true,
    this.showInstallment = true,
    this.isOffer = false,
    this.offerBadgeText,
  });

  /// Factory constructor to support [GetBrandCarsDataModel] directly.
  factory HomeHorizontalCarCard.fromModel({
    Key? key,
    required GetBrandCarsDataModel model,
    String? heroTag,
    VoidCallback? onTap,
    bool showFavoriteButton = true,
    bool showCompareButton = true,
    bool showInstallment = true,
    bool isOffer = false,
    String? offerBadgeText,
  }) {
    return HomeHorizontalCarCard(
      key: key,
      car: model.toMap(),
      heroTag: heroTag,
      onTap: onTap,
      showFavoriteButton: showFavoriteButton,
      showCompareButton: showCompareButton,
      showInstallment: showInstallment,
      isOffer: isOffer || model.isVehicleOffer,
      offerBadgeText: offerBadgeText,
    );
  }

  final Map<String, dynamic> car;
  final String? heroTag;
  final VoidCallback? onTap;
  final bool showFavoriteButton;
  final bool showCompareButton;
  final bool showInstallment;
  final bool isOffer;
  final String? offerBadgeText;

  String get _resolvedHeroTag =>
      heroTag ?? 'home_horiz_car_${HiveMethods.getCarUniqueId(car)}';

  String get _name => car['name']?.toString().trim() ?? '';

  String get _brand => car['brand']?.toString().trim() ?? '';

  String get _year {
    final value = car['year']?.toString().trim() ?? '';
    return value.toLowerCase() == 'null' ? '' : value;
  }

  String get _colorName {
    final value = (car['color'] ??
            car['Color'] ??
            car['bodyColor'] ??
            car['BODY_COLOR'] ??
            '')
        .toString()
        .trim();
    return value.toLowerCase() == 'null' ? '' : value;
  }

  double get _platesValue =>
      (car['PaintingsVal'] as num?)?.toDouble() ??
      (car['PAINTINGS_VAL'] as num?)?.toDouble() ??
      (car['paintingsVal'] as num?)?.toDouble() ??
      double.tryParse(car['PaintingsVal']?.toString() ?? '') ??
      double.tryParse(car['PAINTINGS_VAL']?.toString() ?? '') ??
      double.tryParse(car['paintingsVal']?.toString() ?? '') ??
      0.0;

  String get _formattedCashPrice {
    final rawPrice = car['price']?.toString() ?? '';
    if (rawPrice.isEmpty || rawPrice == '0' || rawPrice == 'null' || rawPrice == '---') {
      return '---';
    }

    final isAlreadyFormatted = rawPrice.contains(',');
    final numericStr = rawPrice.replaceAll(RegExp(r'[^0-9.]'), '');
    final double parsedPrice = double.tryParse(numericStr) ?? 0;
    if (parsedPrice <= 0) return rawPrice;

    final formatter = NumberFormat('#,##0', 'en_US');
    if (isAlreadyFormatted) {
      return formatter.format(parsedPrice + _platesValue);
    }

    final vatNumber = HiveMethods.getVatNumber();
    final double vatPercentage =
        double.tryParse(vatNumber?.toString() ?? '') ?? 15.0;
    final double priceWithVat = parsedPrice * (1 + (vatPercentage / 100));
    final double totalCash = priceWithVat + _platesValue;
    return formatter.format(totalCash);
  }

  String? _formattedMonthlyInstallment(List<FinancingAdModel> offers) {
    final rawPrice = car['price']?.toString() ?? '';
    final price = double.tryParse(rawPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    final formatter = NumberFormat('#,##0', 'en_US');

    final vehicle = GetBrandCarsDataModel.fromJson(car);
    final offerInstallment = FinancingAdModel.vehicleOfferMonthlyInstallment(
      vehicle,
      platesVal: _platesValue,
    );
    if (offerInstallment != null && offerInstallment > 0) {
      return formatter.format(offerInstallment);
    }

    if (price <= 0) return null;

    final monthlyInstallment = _numberValue(car['monthlyInstallment']);
    if (monthlyInstallment > 0) return formatter.format(monthlyInstallment);

    final interestRate = _numberValue(car['interestRate']);
    if (interestRate > 0) {
      final vatPercentage =
          double.tryParse(HiveMethods.getVatNumber()?.toString() ?? '') ?? 15.0;
      final carPrice =
          (price + 3000) * (1 + vatPercentage / 100) + _platesValue;
      return formatter.format((carPrice + carPrice * (interestRate / 100) * 5) / 60);
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
            a.monthlyInstallmentForPrice(price, platesVal: _platesValue) <=
                b.monthlyInstallmentForPrice(price, platesVal: _platesValue)
            ? a
            : b,
      );
      return formatter.format(
        lowestOffer.monthlyInstallmentForPrice(price, platesVal: _platesValue),
      );
    }

    final vatPercentage =
        double.tryParse(HiveMethods.getVatNumber()?.toString() ?? '') ?? 15.0;
    final carPrice = (price + 3000) * (1 + vatPercentage / 100) + _platesValue;
    return formatter.format((carPrice * 1.225) / 60);
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
        child: Icon(Icons.color_lens_rounded, size: 14.w, color: Colors.white),
      );
    }

    if (colors.length == 1) {
      final singleColor = colors.first;
      return Container(
        width: 11.w,
        height: 11.w,
        decoration: BoxDecoration(
          color: singleColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: singleColor == Colors.white
                ? AppColor.greyColor(context).withValues(alpha: 0.6)
                : AppColor.blackTextColor(context).withValues(alpha: 0.2),
            width: 0.8,
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

    return Icon(Icons.palette_outlined, color: AppColor.greyColor(context), size: 13.w);
  }

  void _toggleComparison(BuildContext context) {
    if (HiveMethods.isInComparison(car)) {
      HiveMethods.removeFromComparison(car);
      CommonMethods.showToast(
        message: AppLocaleKey.removeFromCompare.tr(),
        type: ToastType.success,
      );
      return;
    }

    final added = HiveMethods.addToComparison(car);
    if (added) {
      CommonMethods.showToast(
        message: AppLocaleKey.added_to_compare.tr(),
        type: ToastType.success,
      );
    }
  }

  void _handleTap(BuildContext context) {
    if (onTap != null) {
      onTap!();
      return;
    }
    NavigatorMethods.pushNamed(
      context,
      RoutesName.carDetailsScreen,
      arguments: {'car': car, 'heroTag': _resolvedHeroTag},
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = AppColor.primaryColor(context);
    final Color grey = AppColor.greyColor(context);
    final Color textDark = AppColor.blackTextColor(context);

    final bool hasOffer = isOffer || (car['isOffer'] == true);

    return Container(
      decoration: BoxDecoration(
        color: AppColor.secondAppColor(context),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.blackColor(context).withValues(alpha: 0.06),
            blurRadius: 16,
            spreadRadius: 1.5,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: textDark.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _handleTap(context),
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Thumbnail Image with Badges ──
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _CarThumbnail(car: car, heroTag: _resolvedHeroTag),

                    // Offer Ribbon Badge
                    if (hasOffer)
                      PositionedDirectional(
                        top: 6.h,
                        start: 6.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            offerBadgeText ??
                                (context.locale.languageCode == 'ar'
                                    ? 'عرض خاص'
                                    : 'Offer'),
                            style: AppTextStyle.bodySmall(context).copyWith(
                              color: AppColor.whiteColor(context),
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),

                    // Favorite Toggle Button
                    if (showFavoriteButton)
                      PositionedDirectional(
                        top: 4.w,
                        end: 4.w,
                        child: _FavoriteButton(car: car),
                      ),
                  ],
                ),

                Gap(12.w),

                // ── Trailing Details Section ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Brand
                      if (_brand.isNotEmpty) ...[
                        Text(
                          _brand,
                          style: AppTextStyle.bodySmall(context).copyWith(
                            color: primary,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Gap(2.h),
                      ],

                      // Car Title
                      Text(
                        _name,
                        style: AppTextStyle.bodyMedium(context).copyWith(
                          color: textDark,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Specs Badges (Year & Color)
                      if (_year.isNotEmpty || _colorName.isNotEmpty) ...[
                        Gap(6.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 4.h,
                          children: [
                            if (_year.isNotEmpty)
                              MiniDetailWidget(
                                icon: Icons.calendar_today_outlined,
                                label: _year,
                              ),
                            if (_colorName.isNotEmpty)
                              MiniDetailWidget(
                                customIcon: _buildColorIcon(context, _colorName),
                                label: _colorName,
                              ),
                          ],
                        ),
                      ],

                      Gap(8.h),

                      // Dual Pricing Row (Cash + Installment)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Cash Price
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
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _formattedCashPrice,
                                        style: AppTextStyle.bodyMedium(context).copyWith(
                                          color: AppColor.greenColor(context),
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w900,
                                          fontFamily: 'Arial',
                                        ),
                                      ),
                                      Gap(2.w),
                                      SvgPicture.asset(
                                        AppImages.sar,
                                        width: 14.w,
                                        height: 14.h,
                                        colorFilter: ColorFilter.mode(
                                          AppColor.greenColor(context),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Installment Price (if enabled)
                          if (showInstallment) ...[
                            Container(
                              width: 1.2.w,
                              height: 28.h,
                              color: textDark.withValues(alpha: 0.1),
                              margin: EdgeInsets.symmetric(horizontal: 6.w),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    AppLocaleKey.agentInstallments.tr(),
                                    style: AppTextStyle.bodySmall(context).copyWith(
                                      color: grey,
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Gap(1.h),
                                  BlocBuilder<HomeCubit, HomeState>(
                                    builder: (context, state) {
                                      final installment = _formattedMonthlyInstallment(
                                        state.normalFinancingStatus.data ?? const [],
                                      );
                                      if (installment == null) {
                                        return const SizedBox.shrink();
                                      }

                                      return FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: AlignmentDirectional.centerStart,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              installment,
                                              style: AppTextStyle.bodyMedium(context).copyWith(
                                                color: primary,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w900,
                                                fontFamily: 'Arial',
                                              ),
                                            ),
                                            Gap(2.w),
                                            SvgPicture.asset(
                                              AppImages.sar,
                                              width: 13.w,
                                              height: 13.h,
                                              colorFilter: ColorFilter.mode(
                                                primary,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                            Gap(2.w),
                                            Text(
                                              '/ ${AppLocaleKey.month.tr()}',
                                              style: AppTextStyle.bodySmall(context).copyWith(
                                                color: primary,
                                                fontSize: 8.5.sp,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),

                      Gap(5.h),

                      // Tax and Plates Note
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: grey,
                            size: 11.sp,
                          ),
                          Gap(4.w),
                          Expanded(
                            child: Text(
                              context.locale.languageCode == 'ar'
                                  ? 'شامل الضريبة واللوحات'
                                  : 'Tax and plates included',
                              style: AppTextStyle.bodySmall(context).copyWith(
                                color: grey,
                                fontSize: 8.5.sp,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      // Action Buttons (Details + Compare or Arrow)
                      Gap(8.h),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              onPressed: () => _handleTap(context),
                              height: 28.h,
                              color: primary,
                              radius: 8.r,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  AppLocaleKey.details.tr(),
                                  style: AppTextStyle.bodySmall(context).copyWith(
                                    color: AppColor.whiteColor(context),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (showCompareButton) ...[
                            Gap(6.w),
                            Expanded(
                              child: CustomButton(
                                onPressed: () => _toggleComparison(context),
                                height: 28.h,
                                color: textDark.withValues(alpha: 0.04),
                                borderColor: textDark.withValues(alpha: 0.1),
                                radius: 8.r,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.add_rounded,
                                        size: 14.sp,
                                        color: textDark,
                                      ),
                                      Gap(2.w),
                                      Text(
                                        AppLocaleKey.compare.tr(),
                                        style: AppTextStyle.bodySmall(context).copyWith(
                                          color: textDark,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10.5.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            Gap(6.w),
                            Container(
                              width: 28.h,
                              height: 28.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primary.withValues(alpha: 0.08),
                              ),
                              child: Icon(
                                Directionality.of(context) == ui.TextDirection.rtl
                                    ? Icons.arrow_back_ios_new_rounded
                                    : Icons.arrow_forward_ios_rounded,
                                size: 12.sp,
                                color: primary,
                              ),
                            ),
                          ],
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
    final String image = (car['image'] ?? car['carimage'] ?? '').toString().trim();
    final Color primary = AppColor.primaryColor(context);

    final Widget fallback = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withValues(alpha: 0.14),
            primary.withValues(alpha: 0.03),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.directions_car_rounded,
          size: 36.sp,
          color: primary.withValues(alpha: 0.4),
        ),
      ),
    );

    final Widget imageChild = image.startsWith('http')
        ? CustomNetworkImage(
            imageUrl: image,
            fit: BoxFit.cover,
            width: 116.w,
            height: 142.h,
            errorWidget: fallback,
          )
        : image.isNotEmpty
        ? Image.asset(
            image,
            fit: BoxFit.cover,
            width: 116.w,
            height: 142.h,
            errorBuilder: (context, error, stackTrace) => fallback,
          )
        : fallback;

    return SizedBox(
      width: 116.w,
      height: 142.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Hero(tag: heroTag, child: imageChild),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.car});

  final Map<String, dynamic> car;

  @override
  Widget build(BuildContext context) {
    final Color red = AppColor.redColor(context);
    final Color dark = AppColor.blackTextColor(context);

    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        final isFav = context.read<FavoritesCubit>().isFavorite(car);

        return Semantics(
          button: true,
          label: isFav
              ? AppLocaleKey.removeFromFavorites.tr()
              : AppLocaleKey.addCarsToFavorites.tr(),
          child: SizedBox(
            width: 38.w,
            height: 38.w,
            child: InkResponse(
              onTap: () => context.read<FavoritesCubit>().toggleFavorite(car),
              radius: 19.w,
              containedInkWell: true,
              highlightShape: BoxShape.circle,
              child: Center(
                child: Container(
                  width: 30.w,
                  height: 30.w,
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
                  child: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFav ? red : dark,
                    size: 16.sp,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
