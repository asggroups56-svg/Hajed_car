import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:car/core/images/app_images.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/cars/presentation/widget/full_image_gallery_screen.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final hasMultipleImages = _displayImages.length > 1;
    final hasPreviousImage = _currentImageIndex > 0;
    final hasNextImage = _currentImageIndex < _displayImages.length - 1;
    final isLastDisplayImage = _currentImageIndex == _displayImages.length - 1;
    final hasMoreImagesInFull = _fullImagesList.length > _displayImages.length;

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
      ],
    );
  }
}
