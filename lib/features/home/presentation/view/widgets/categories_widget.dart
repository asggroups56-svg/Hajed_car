import 'package:animate_do/animate_do.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/network/status.state.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/home/data/model/cars_models_response.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:car/features/home/presentation/view/widgets/custom_item_categories_widget.dart';
import 'package:car/features/home/presentation/view/widgets/loading_and_empty_placeholder_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CategoriesWidget extends StatelessWidget {
  const CategoriesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final status = state.carsModelsStatus;

        if (status.isLoading) {
          return const CategoriesLoadingPlaceholder();
        }

        if (status.isFailure) {
          return bulidCategriesFailure(status);
        }

        final List<CarModel> brands = List<CarModel>.from(status.data ?? []);

        if (brands.isEmpty) {
          return bulidCategoriesEmpty(context);
        }

        return SizedBox(
          height: 120.h,
          width: double.infinity,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            physics: const BouncingScrollPhysics(),
            // "All" is a separate item, followed by a preview of brands and
            // a button that opens the complete brands screen when needed.
            itemCount: 1 + brands.take(4).length + (brands.length > 4 ? 1 : 0),
            separatorBuilder: (context, index) => Gap(20.w),
            itemBuilder: (context, index) {
              if (index == 0) {
                return FadeInRight(
                  child: _AllCategoriesItem(
                    isSelected: state.selectedBrandId == null,
                    onTap: () => context.read<HomeCubit>().selectAllBrands(),
                  ),
                );
              }

              final brandIndex = index - 1;
              if (brandIndex == brands.take(4).length) {
                return FadeInRight(
                  delay: Duration(milliseconds: index * 50),
                  child: _MoreCategoriesItem(
                    onTap: () => Navigator.pushNamed(context, RoutesName.allBrandsScreen),
                  ),
                );
              }

              final item = brands[brandIndex];
              final isSelected = state.selectedBrandId == item.groupCode;

              return FadeInRight(
                delay: Duration(milliseconds: index * 50),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.read<HomeCubit>().selectBrand(
                          brandIndex,
                          item.groupCode.toString(),
                        );
                      },
                      child: CustomItemCategoriesWidget(isSelected: isSelected, item: item),
                    ),
                    Gap(10.h),
                    Text(
                      context.locale.languageCode == 'ar' ? item.groupName : item.groupEName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.bodySmall(context).copyWith(
                        color: isSelected
                            ? AppColor.primaryColor(context)
                            : AppColor.blackTextColor(context).withValues(alpha: 0.8),
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  SizedBox bulidCategoriesEmpty(BuildContext context) {
    return SizedBox(
      height: 140.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 40.sp,
              color: AppColor.blackTextColor(context).withValues(alpha: .1),
            ),
            Gap(16.h),
            Text(AppLocaleKey.agentNoCategoriesFound.tr(), style: AppTextStyle.bodyMedium(context)),
          ],
        ),
      ),
    );
  }

  SizedBox bulidCategriesFailure(StatusState<dynamic> status) {
    return SizedBox(
      height: 140.h,
      child: Center(child: Text(status.error ?? 'Error')),
    );
  }
}

class _AllCategoriesItem extends StatelessWidget {
  const _AllCategoriesItem({required this.isSelected, required this.onTap});

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedScale(
            scale: isSelected ? 1.08 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? AppColor.primaryColor(context)
                      : AppColor.blackTextColor(context).withValues(alpha: 0.1),
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Text(
                  AppLocaleKey.all.tr(),
                  style: AppTextStyle.bodySmall(context).copyWith(
                    color: isSelected
                        ? AppColor.primaryColor(context)
                        : AppColor.blackTextColor(context).withValues(alpha: 0.8),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          Gap(10.h),
          Text(
            AppLocaleKey.all.tr(),
            style: AppTextStyle.bodySmall(context).copyWith(
              color: isSelected
                  ? AppColor.primaryColor(context)
                  : AppColor.blackTextColor(context).withValues(alpha: 0.8),
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreCategoriesItem extends StatelessWidget {
  const _MoreCategoriesItem({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: AppColor.primaryColor(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.add_rounded, color: AppColor.primaryColor(context), size: 28.sp),
          ),
          Gap(10.h),
          Text(
            AppLocaleKey.more.tr(),
            style: AppTextStyle.bodySmall(
              context,
            ).copyWith(color: AppColor.primaryColor(context), fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
