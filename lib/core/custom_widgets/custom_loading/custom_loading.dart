import 'package:flutter/material.dart';

import '../../images/app_images.dart';

class CustomLoading extends StatelessWidget {
  final double size;
  final Color? color;
  const CustomLoading({super.key, this.size = 180, this.color});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppImages.assetsImagesLogeBlack,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
    );
  }
}
