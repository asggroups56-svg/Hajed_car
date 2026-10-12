import 'package:cached_network_image/cached_network_image.dart';
import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:car/core/images/app_images.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class FullImageGalleryScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final GetBrandCarsDataModel car;

  const FullImageGalleryScreen({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.car,
  });

  @override
  State<FullImageGalleryScreen> createState() => _FullImageGalleryScreenState();
}

class _FullImageGalleryScreenState extends State<FullImageGalleryScreen> {
  late PageController _pageController;
  late ScrollController _thumbnailController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _thumbnailController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToThumbnail(widget.initialIndex);
    });
  }

  void _scrollToThumbnail(int index) {
    if (_thumbnailController.hasClients) {
      _thumbnailController.animateTo(
        index * 80.w,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.blackColor(context),
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
                _scrollToThumbnail(index);
              },
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                final imageUrl = widget.images[index];
                final isNetwork = imageUrl.startsWith('http');

                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Hero(
                    tag: 'car_image_full_${HiveMethods.getCarUniqueId(widget.car.toMap())}_$index',
                    child: Center(
                      child: isNetwork
                          ? CustomNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.fill,
                              width: double.infinity,
                            )
                          : Image.asset(
                              imageUrl.isEmpty ? AppImages.assetsImagesPlaceholder : imageUrl,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10.h,
            right: 20.w,
            child: IconButton(
              icon: Icon(Icons.close_rounded, color: AppColor.whiteColor(context), size: 30.sp),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: 40.h,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocaleKey.uploadImage.tr(),
                      style: TextStyle(
                        color: AppColor.whiteColor(context).withValues(alpha: (0.8)),
                        fontSize: 14.sp,
                      ),
                    ),
                    Gap(8.w),
                    Icon(
                      Icons.touch_app_outlined,
                      color: AppColor.whiteColor(context).withValues(alpha: (0.8)),
                      size: 18.sp,
                    ),
                  ],
                ),
                Gap(24.h),

                SizedBox(
                  height: 60.h,
                  child: ListView.builder(
                    controller: _thumbnailController,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: widget.images.length,
                    itemBuilder: (context, index) {
                      final imageUrl = widget.images[index];
                      final isSelected = index == _currentIndex;
                      final isNetwork = imageUrl.startsWith('http');

                      return GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(right: 12.w),
                          width: 80.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: isSelected
                                  ? AppColor.primaryColor(context)
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                            image: DecorationImage(
                              image: isNetwork
                                  ? CachedNetworkImageProvider(
                                          imageUrl.contains('1617788131775-ddb49554618a')
                                              ? 'https://images.unsplash.com/photo-1560958089-b8a1929cea89?q=80&w=800'
                                              : imageUrl,
                                        )
                                        as ImageProvider
                                  : AssetImage(
                                      imageUrl.isEmpty
                                          ? AppImages.assetsImagesPlaceholder
                                          : imageUrl,
                                    ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Gap(20.h),
                Text(
                  '${widget.images.length} / ${_currentIndex + 1}',
                  style: AppTextStyle.bodyLarge(context).copyWith(
                    color: AppColor.whiteColor(context).withValues(alpha: (0.8)),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
