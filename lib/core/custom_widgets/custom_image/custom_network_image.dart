import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../utils/navigator_methods.dart';
import '../zoom_image/zoom_image_screen.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final double radius;
  final BoxFit? fit;
  final bool hasZoom;
  final Widget? errorWidget;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.radius = 0,
    this.hasZoom = false,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Safety check for a known broken Unsplash URL from dummy data
    String effectiveUrl = imageUrl;
    if (imageUrl.contains('1617788131775-ddb49554618a')) {
      effectiveUrl =
          'https://images.unsplash.com/photo-1560958089-b8a1929cea89?q=80&w=800';
    }

    return GestureDetector(
      onTap: hasZoom
          ? () {
              NavigatorMethods.pushNamed(
                context,
                ZoomImageScreen.routeName,
                arguments: ZoomImageArgs(imageUrl: effectiveUrl),
              );
            }
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CachedNetworkImage(
          imageUrl: effectiveUrl,
          fit: fit,
          width: width,
          height: height,
          memCacheWidth: (width != null && width!.isFinite && width! > 0)
              ? (width! * 2).round().clamp(100, 800)
              : 600,
          memCacheHeight: (height != null && height!.isFinite && height! > 0)
              ? (height! * 2).round().clamp(100, 600)
              : 400,
          maxWidthDiskCache: 800,
          maxHeightDiskCache: 600,
          placeholder: (context, url) => Container(
            color: AppColor.greyColor(context).withValues(alpha: 0.05),
            child: Center(
              child: CupertinoActivityIndicator(
                color: AppColor.primaryColor(context),
              ),
            ),
          ),
          errorWidget: (context, url, error) =>
              errorWidget ??
              Container(
                color: AppColor.greyColor(context).withValues(alpha: (0.1)),
                child: Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColor.primaryColor(
                      context,
                    ).withValues(alpha: (0.4)),
                    size: 24,
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
