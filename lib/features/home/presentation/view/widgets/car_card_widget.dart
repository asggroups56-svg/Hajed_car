import 'package:car/core/theme/app_colors.dart';
import 'package:car/features/home/presentation/view/widgets/card_content_section_widget.dart';
import 'package:car/features/home/presentation/view/widgets/card_image_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CarCard extends StatelessWidget {
  const CarCard({
    super.key,
    required this.car,
    required this.isSelected,
    required this.onTap,
    this.heroTag,
    this.onImageTap,
  });

  final Map<String, dynamic> car;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onImageTap;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
          color: AppColor.secondAppColor(context),
          elevation: 4,
          child: Column(
            children: [
              Expanded(
                flex: 10,
                child: CardImageSection(
                  car: car,
                  isSelected: isSelected,
                  heroTag: heroTag,
                  onTap: onImageTap ?? onTap,
                ),
              ),
              Expanded(
                flex: 15,
                child: CardContentSection(car: car, onTap: onTap),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
