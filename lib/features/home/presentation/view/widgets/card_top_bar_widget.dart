import 'package:car/features/home/presentation/view/widgets/favorites_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CardTopBar extends StatelessWidget {
  const CardTopBar({super.key, required this.car});

  final Map<String, dynamic> car;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // BrandBadge(brand: car['GROUP_NAME']),
          FavoritesButton(car: car),
        ],
      ),
    );
  }
}
