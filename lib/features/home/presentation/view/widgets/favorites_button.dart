import 'package:car/core/theme/app_colors.dart';
import 'package:car/features/favorites/presentation/view/cubit/favorites_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FavoritesButton extends StatelessWidget {
  const FavoritesButton({super.key, required this.car});

  final Map<String, dynamic> car;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        final isFav = context.read<FavoritesCubit>().isFavorite(car);
        return GestureDetector(
          onTap: () => context.read<FavoritesCubit>().toggleFavorite(car),
          child: CircleAvatar(
            radius: 18.r,
            backgroundColor: AppColor.blackColor(context).withValues(alpha: (0.1)),
            child: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
              color: isFav ? AppColor.redColor(context) : AppColor.blackTextColor(context),
              size: 20.sp,
            ),
          ),
        );
      },
    );
  }
}
