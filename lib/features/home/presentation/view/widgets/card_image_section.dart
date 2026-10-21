import 'package:car/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:car/core/images/app_images.dart';
import 'package:car/features/home/presentation/view/widgets/discount_badge_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'favorite_button.dart';

class CardImageSection extends StatelessWidget {
  const CardImageSection({super.key, required this.car});
  final Map<String, dynamic> car;
  @override
  Widget build(BuildContext context) {
    final imageUrl = car['image']?.toString() ?? '';
    final logoPlaceholder = Container(
      color: Theme.of(context).colorScheme.surface,
      alignment: Alignment.center,
      padding: EdgeInsets.all(28.w),
      child: Image.asset(AppImages.assetsImagesLogeStatic, fit: BoxFit.contain),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        Hero(
          tag: 'car_image_${car['itemCode'] ?? car['name']}',
          child: imageUrl.trim().isEmpty
              ? logoPlaceholder
              : imageUrl.trim().startsWith('http')
              ? CustomNetworkImage(
                  imageUrl: imageUrl,
                  height: 190.h,
                  fit: BoxFit.fill,
                  errorWidget: logoPlaceholder,
                )
              : Image.asset(imageUrl, height: 190.h, fit: BoxFit.fill),
        ),
        Positioned(
          top: 6.h,
          left: 10.w,
          child: DiscountBadge(discount: car['discount']),
        ),
        Positioned(
          top: 6.h,
          right: 10.w,
          child: FavoriteButton(car: car),
        ),
      ],
    );
  }
}
