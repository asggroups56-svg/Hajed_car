import 'package:animate_do/animate_do.dart';
import 'package:car/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:car/features/cars/presentation/screen/widget/grid_car_card_widget.dart';
import 'package:car/features/favorites/presentation/view/cubit/favorites_cubit.dart';
import 'package:car/features/favorites/presentation/view/screen/widget/empty_state_widget.dart';
import 'package:car/features/favorites/presentation/view/screen/widget/favorite_item_widget.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        if (state is FavoritesLoaded) {
          if (state.favorites.isEmpty) {
            return FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: const EmptyStateWidget(),
            );
          }

          return ValueListenableBuilder<Box>(
            valueListenable: Hive.box('app').listenable(keys: ['cars_view_mode_grid']),
            builder: (context, box, _) {
              final isGrid = box.get('cars_view_mode_grid', defaultValue: false);

              if (isGrid) {
                // Rows of two cards: each row is as tall as its tallest card,
                // so the cards fit their content instead of a fixed ratio.
                final rowCount = (state.favorites.length + 1) ~/ 2;

                Widget cardAt(int index) {
                  final carModel = GetBrandCarsDataModel.fromJson(state.favorites[index]);
                  return GridCarCardWidget(car: carModel);
                }

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
                  physics: const BouncingScrollPhysics(),
                  itemCount: rowCount,
                  separatorBuilder: (context, index) => Gap(14.h),
                  itemBuilder: (context, row) {
                    final first = row * 2;
                    final second = first + 1;
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: cardAt(first)),
                          Gap(12.w),
                          Expanded(
                            child: second < state.favorites.length
                                ? cardAt(second)
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }

              return ListView.separated(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
                physics: const BouncingScrollPhysics(),
                itemCount: state.favorites.length,
                separatorBuilder: (context, index) => Gap(16.h),
                itemBuilder: (context, index) {
                  final car = state.favorites[index];
                  return FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    delay: Duration(milliseconds: (index * 50).clamp(0, 500)),
                    child: FavoriteItemWidget(car: car),
                  );
                },
              );
            },
          );
        }
        return const Center(child: CustomLoading());
      },
    );
  }
}
