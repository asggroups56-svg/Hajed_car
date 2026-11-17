import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:car/core/images/app_images.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/cars/presentation/widget/full_image_gallery_screen.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:car/features/home/data/model/financing_ad_model.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CardImageSection extends StatefulWidget {
  const CardImageSection({
    super.key,
    required this.car,
    required this.isSelected,
    this.heroTag,
    this.onTap,
  });

  final Map<String, dynamic> car;
  final bool isSelected;
  final String? heroTag;
  final VoidCallback? onTap;

  @override
  State<CardImageSection> createState() => _CardImageSectionState();
}

class _CardImageSectionState extends State<CardImageSection> {
  int _currentImageIndex = 0;
  late List<String> _displayImages;
  late List<String> _fullImagesList;

  @override
  void initState() {
    super.initState();
    _initializeImages();
  }

  @override
  void didUpdateWidget(CardImageSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.car != widget.car) {
      _initializeImages();
      _currentImageIndex = 0;
    }
  }

  void _initializeImages() {
    _fullImagesList = [
      (widget.car['image'] as String? ?? '').trim(),
      ...List<String>.from(widget.car['extraImages'] ?? [])
          .where((image) => image.trim().isNotEmpty),
    ];
    _fullImagesList.removeWhere((image) => image.isEmpty);
    _displayImages = _fullImagesList.take(4).toList();
  }

  Widget _logoPlaceholder() => Container(
    color: AppColor.secondAppColor(context),
    alignment: Alignment.center,
    padding: EdgeInsets.all(28.w),
    child: Image.asset(AppImages.assetsImagesLogeStatic, fit: BoxFit.contain),
  );

  void _nextImage() {
    if (_displayImages.isEmpty) return;
    setState(() {
      _currentImageIndex = (_currentImageIndex + 1) % _displayImages.length;
    });
  }

  void _previousImage() {
    if (_displayImages.isEmpty) return;
    setState(() {
      _currentImageIndex =
          (_currentImageIndex - 1 + _displayImages.length) %
          _displayImages.length;
    });
  }

  void _openGallery() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullImageGalleryScreen(
          images: _fullImagesList,
          initialIndex: _currentImageIndex,
          car: GetBrandCarsDataModel.fromJson(widget.car),
        ),
      ),
    );
  }

  static String _formatPercentage(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }

  /// Returns a map containing first-installment and last-installment percentages:
  /// `{'first': firstPct, 'last': lastPct}`.
  /// Returns null when the car has no financing offer.
  Map<String, double>? _getInstallmentRates(BuildContext context) {
    double? parseVal(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    final vehicle = GetBrandCarsDataModel.fromJson(widget.car);

    // Direct values from vehicle model or raw map
    final double? firstPct = vehicle.firstInstallmentPct ??
        vehicle.firstInstallmentPctOther ??
        parseVal(widget.car['FirstInstallmentPct']) ??
        parseVal(widget.car['firstInstallmentPct']) ??
        parseVal(widget.car['FirstInstallmentPctother']);

    final double? lastPct = vehicle.lastInstallmentPct ??
        vehicle.lastInstallmentPctOther ??
        parseVal(widget.car['LastInstallmentPct']) ??
        parseVal(widget.car['lastInstallmentPct']) ??
        parseVal(widget.car['LastInstallmentPctother']);

    final bool isDirectOffer = vehicle.isVehicleOffer ||
        widget.car['isVehicleOffer'] == true ||
        widget.car['isOffer'] == true ||
        (lastPct != null && lastPct > 0 && vehicle.isOfferActive);

    if (isDirectOffer && (lastPct != null || firstPct != null)) {
      return {
        'first': firstPct ?? 0.0,
        'last': lastPct ?? 0.0,
      };
    }

    // Otherwise try to locate a matching promo offer
    List<FinancingAdModel> promoOffers = const [];
    try {
      promoOffers = context.select<HomeCubit, List<FinancingAdModel>>(
        (c) => c.state.promoCarOffers,
      );
    } catch (_) {}

    final itemCode = vehicle.itemCode.trim();
    final name = vehicle.itemName.trim().toLowerCase();
    final year = vehicle.makeYear;
    for (final promo in promoOffers) {
      final pItemCode = promo.itemCode?.trim() ?? '';
      final pName = promo.itemName?.trim().toLowerCase() ?? '';
      final pYear = promo.makeYear ?? promo.modelYear ?? 0;
      final bool matches =
          (itemCode.isNotEmpty && pItemCode == itemCode) ||
          (name.isNotEmpty &&
              pName == name &&
              (year == 0 || pYear == 0 || pYear == year));
      if (matches) {
        final pFirst = promo.firstInstallmentPct ?? promo.firstInstallmentPctOther;
        final pLast = promo.lastInstallmentPct ?? promo.lastInstallmentPctOther;
        if (pFirst != null || pLast != null) {
          return {
            'first': pFirst ?? 0.0,
            'last': pLast ?? 0.0,
          };
        }
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final hasMultipleImages = _displayImages.length > 1;
    final hasPreviousImage = _currentImageIndex > 0;
    final hasNextImage = _currentImageIndex < _displayImages.length - 1;
    final isLastDisplayImage = _currentImageIndex == _displayImages.length - 1;
    final hasMoreImagesInFull = _fullImagesList.length > _displayImages.length;
    final installmentRates = _getInstallmentRates(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: widget.onTap ?? _openGallery,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
            ),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 400),
              scale: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
                child: Hero(
                  tag:
                      widget.heroTag ??
                      'car_image_${HiveMethods.getCarUniqueId(widget.car)}_$_currentImageIndex',
                  child: Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: [
                      if (_displayImages.isEmpty)
                        _logoPlaceholder()
                      else
                        CustomNetworkImage(
                          imageUrl: _displayImages[_currentImageIndex],
                          fit: BoxFit.cover,
                          errorWidget: _logoPlaceholder(),
                        ),
                      if (widget.onTap == null &&
                          isLastDisplayImage &&
                          hasMoreImagesInFull)
                        Container(
                          decoration: BoxDecoration(
                            color: AppColor.blackColor(
                              context,
                            ).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(18.r),
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.grid_view_rounded,
                                  color: AppColor.whiteColor(context),
                                  size: 24.sp,
                                ),
                                Text(
                                  AppLocaleKey.see_all.tr(),
                                  style: AppTextStyle.bodySmall(context)
                                      .copyWith(
                                        color: AppColor.whiteColor(context),
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (hasMultipleImages) ...[
          if (hasPreviousImage)
            Positioned(
              left: 5.w,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  onPressed: _previousImage,
                  icon: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: AppColor.blackColor(
                        context,
                      ).withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColor.whiteColor(context),
                      size: 16.sp,
                    ),
                  ),
                ),
              ),
            ),
          if (hasNextImage)
            Positioned(
              right: 5.w,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  onPressed: _nextImage,
                  icon: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: AppColor.blackColor(
                        context,
                      ).withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: AppColor.whiteColor(context),
                      size: 16.sp,
                    ),
                  ),
                ),
              ),
            ),
        ],
        if (installmentRates != null)
          PositionedDirectional(
            start: 16.w,
            top: 0,
            child: IgnorePointer(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor(context),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12.r),
                    bottomRight: Radius.circular(12.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // الدفعة الأولى
                    Text(
                      context.locale.languageCode == 'ar'
                          ? 'أولى ${_formatPercentage(installmentRates["first"]!)}%'
                          : '1st ${_formatPercentage(installmentRates["first"]!)}%',
                      style: AppTextStyle.bodySmall(context).copyWith(
                        color: AppColor.whiteColor(context),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    // الدفعة الأخيرة
                    Text(
                      context.locale.languageCode == 'ar'
                          ? 'أخيرة ${_formatPercentage(installmentRates["last"]!)}%'
                          : 'Last ${_formatPercentage(installmentRates["last"]!)}%',
                      style: AppTextStyle.bodySmall(context).copyWith(
                        color: AppColor.whiteColor(context),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    // فاصل أفقي خفيف
                    Container(
                      height: 1,
                      width: 42.w,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    SizedBox(height: 3.h),
                    // نص "عرض تمويل"
                    Text(
                      context.locale.languageCode == 'ar'
                          ? 'عرض تمويل'
                          : 'Financing Offer',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.bodySmall(context).copyWith(
                        color: AppColor.whiteColor(context),
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
