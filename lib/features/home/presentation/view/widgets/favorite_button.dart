import 'package:car/core/theme/app_colors.dart';
import 'package:car/features/favorites/presentation/view/cubit/favorites_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.car});

  final Map<String, dynamic> car;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        final isFav = context.read<FavoritesCubit>().isFavorite(car);
        return GestureDetector(
          onTap: () => context.read<FavoritesCubit>().toggleFavorite(car),
          child: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppColor.blackColor(context).withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFav ? AppColor.redColor(context) : AppColor.blackTextColor(context),
              size: 14.sp,
            ),
          ),
        );
      },
    );
  }
}
