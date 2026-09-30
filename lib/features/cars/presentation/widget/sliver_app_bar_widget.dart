import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:car/core/images/app_images.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/common_methods.dart';
import 'package:car/features/cars/presentation/widget/full_image_gallery_screen.dart';
import 'package:car/features/favorites/presentation/view/cubit/favorites_cubit.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';

class SliverAppBarWidget extends StatefulWidget {
  const SliverAppBarWidget({
    super.key,
    required this.car,
    required this.imagePageController,
    required this.currentImageIndex,
    required this.carImages,
    this.heroTag,
  });
  final GetBrandCarsDataModel car;
  final PageController imagePageController;
  final int currentImageIndex;
  final List<String> carImages;
  final String? heroTag;
  @override
  State<SliverAppBarWidget> createState() => _SliverAppBarWidgetState();
}

class _SliverAppBarWidgetState extends State<SliverAppBarWidget> {
  late int _currentImageIndex;

  @override
  void initState() {
    super.initState();
    _currentImageIndex = widget.currentImageIndex;
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300.h,
      pinned: true,
      elevation: 0,
      stretch: true,
      backgroundColor: AppColor.scaffoldColor(context),
      leading: Padding(
        padding: EdgeInsets.all(5.w),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColor.blackTextColor(context),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            final isFav = context.read<FavoritesCubit>().isFavorite(widget.car.toMap());
            return Padding(
              padding: EdgeInsets.all(8.w),
              child: IconButton(
                icon: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                  color: isFav ? AppColor.redColor(context) : AppColor.blackTextColor(context),
                  size: 20,
                ),
                onPressed: () {
                  context.read<FavoritesCubit>().toggleFavorite(widget.car.toMap());
                },
              ),
            );
          },
        ),
        Gap(12.w),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            List<String> displayedImages = widget.car.allImages;
            if (displayedImages.isEmpty) {
              displayedImages = [AppImages.assetsImagesPlaceholder];
            }

            final safeIndex = _currentImageIndex < displayedImages.length ? _currentImageIndex : 0;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullImageGalleryScreen(
                      images: displayedImages,
                      initialIndex: safeIndex,
                      car: widget.car,
                    ),
                  ),
                );
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: widget.imagePageController,
                    onPageChanged: (index) => setState(() => _currentImageIndex = index),
                    itemCount: displayedImages.length,
                    itemBuilder: (context, index) {
                      final imageUrl = displayedImages[index];
                      final isNetwork = imageUrl.startsWith('http');
                      return Hero(
                        tag: index == 0
                            ? (widget.heroTag ?? 'car_image_${widget.car.itemCode}')
                            : 'car_image_full_${widget.car.itemCode}_$index',
                        child: Container(
                          height: 50.h,
                          width: 50.w,
                          decoration: BoxDecoration(color: AppColor.scaffoldColor(context)),
                          child: isNetwork
                              ? CustomNetworkImage(imageUrl: imageUrl, fit: BoxFit.contain)
                              : Image.asset(
                                  imageUrl.isEmpty ? AppImages.assetsImagesPlaceholder : imageUrl,
                                  fit: BoxFit.contain,
                                ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 100.h,
                    left: 20.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColor.blackTextColor(context).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '${safeIndex + 1} / ${displayedImages.length}',
                        style: AppTextStyle.bodySmall(context).copyWith(
                          color: AppColor.whiteColor(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 80.h,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: AppColor.blackTextColor(context).withValues(alpha: (0.2)),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fullscreen_rounded,
                              color: AppColor.whiteColor(context),
                              size: 18.sp,
                            ),
                            Gap(6.w),
                            Text(
                              AppLocaleKey.agentImageZoom.tr(),
                              style: AppTextStyle.bodySmall(
                                context,
                              ).copyWith(color: AppColor.whiteColor(context)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (displayedImages.length > 1)
                    Positioned(
                      bottom: 50.h,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(displayedImages.length, (index) {
                          final isSelected = index == safeIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(horizontal: 3.w),
                            height: 4.h,
                            width: isSelected ? 30.w : 15.w,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColor.primaryColor(context)
                                  : AppColor.blackTextColor(context).withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          );
                        }),
                      ),
                    ),
                  Positioned(
                    bottom: -1,
                    left: 0,
                    right: 0,
                    height: 40.h,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppColor.scaffoldColor(context),
                            AppColor.scaffoldColor(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
