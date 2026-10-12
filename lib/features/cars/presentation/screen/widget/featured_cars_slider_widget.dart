import 'dart:async';
import 'dart:ui';

import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/navigator_methods.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class FeaturedCarsSliderWidget extends StatefulWidget {
  final List<Map<String, String>> featuredCars;
  const FeaturedCarsSliderWidget({super.key, required this.featuredCars});

  @override
  State<FeaturedCarsSliderWidget> createState() => _FeaturedCarsSliderWidgetState();
}

class _FeaturedCarsSliderWidgetState extends State<FeaturedCarsSliderWidget> {
  late final PageController _pageController;
  int _currentSliderIndex = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92, initialPage: 0);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        if (_currentSliderIndex < widget.featuredCars.length - 1) {
          _currentSliderIndex++;
        } else {
          _currentSliderIndex = 0;
        }
        _pageController.animateToPage(
          _currentSliderIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.featuredCars.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 220.h,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentSliderIndex = index);
            },
            itemCount: widget.featuredCars.length,
            itemBuilder: (context, index) {
              final car = widget.featuredCars[index];
              final carId = HiveMethods.getCarUniqueId(car);
              final heroTag = 'featured_car_image_${carId.isNotEmpty ? carId : index}_$index';
              final isSelected = _currentSliderIndex == index;

              return AnimatedScale(
                scale: isSelected ? 1.0 : 0.94,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                child: GestureDetector(
                  onTap: () {
                    NavigatorMethods.pushNamed(
                      context,
                      RoutesName.carDetailsScreen,
                      arguments: {'car': car, 'heroTag': heroTag},
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 6.w),
                    decoration: BoxDecoration(
                      color: AppColor.secondAppColor(context),
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // Background Image with Hero
                        Positioned.fill(
                          child: Hero(
                            tag: heroTag,
                            child: (car['image'] != null && car['image']!.trim().isNotEmpty)
                                ? (car['image'].toString().trim().startsWith('http')
                                      ? CustomNetworkImage(
                                          imageUrl: car['image']!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          car['image']!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              _buildErrorImage(context),
                                        ))
                                : _buildErrorImage(context),
                          ),
                        ),

                        // Gradient Overlay for readability
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  AppColor.blackColor(context).withValues(alpha: 0.05),
                                  AppColor.blackColor(context).withValues(alpha: 0.7),
                                ],
                                stops: const [0.0, 0.4, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // Badge / Tag
                        Positioned(
                          top: 14.h,
                          left: 14.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColor.primaryColor(context),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              AppLocaleKey.specialOffersCars.tr(),
                              style: AppTextStyle.bodySmall(context).copyWith(
                                color: AppColor.whiteColor(context),
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // Bottom Info Section with Glassmorphism effect
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: ClipRRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                decoration: BoxDecoration(
                                  color: AppColor.blackColor(context).withValues(alpha: 0.2),
                                  border: Border(
                                    top: BorderSide(
                                      color: AppColor.whiteColor(context).withValues(alpha: 0.1),
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            car['name'] ?? '',
                                            style: AppTextStyle.titleMedium(context).copyWith(
                                              color: AppColor.whiteColor(context),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.sp,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (car['installments'] != null)
                                            Text(
                                              car['installments']!,
                                              style: TextStyle(
                                                color: AppColor.whiteColor(
                                                  context,
                                                ).withValues(alpha: 0.8),
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          car['price'] ?? '',
                                          style: AppTextStyle.titleMedium(context).copyWith(
                                            color: AppColor.primaryColor(context),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15.sp,
                                          ),
                                        ),
                                        Text(
                                          AppLocaleKey.taxIncluded.tr(),
                                          style: TextStyle(
                                            color: AppColor.whiteColor(
                                              context,
                                            ).withValues(alpha: 0.5),
                                            fontSize: 8.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Gap(12.h),
        // Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.featuredCars.length, (index) {
            final isActive = _currentSliderIndex == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              height: 6.h,
              width: isActive ? 24.w : 6.w,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColor.primaryColor(context)
                    : AppColor.greyColor(context).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12.r),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildErrorImage(BuildContext context) {
    return Container(
      color: AppColor.greyColor(context).withValues(alpha: 0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              color: AppColor.primaryColor(context).withValues(alpha: 0.5),
              size: 40.sp,
            ),
            Gap(8.h),
            Text('Image Not Available', style: TextStyle(fontSize: 10.sp)),
          ],
        ),
      ),
    );
  }
}
