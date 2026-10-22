import 'package:car/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/cars/presentation/screen/widget/car_search_header_widget.dart';
import 'package:car/features/cars/presentation/screen/widget/cars_list_widget.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:car/features/home/data/model/financing_ad_model.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:car/features/home/presentation/view/screen/main_layout.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CarsScreen extends StatefulWidget {
  const CarsScreen({super.key});

  @override
  State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchQuery = MainLayout.carsSearchQuery.value.trim().toLowerCase();
    _searchController.text = _searchQuery;
    MainLayout.carsSearchQuery.addListener(_applyHomeSearchQuery);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeCubit>().fetchAllCars();
      context.read<HomeCubit>().getNormalFinancing();
    });
  }

  @override
  void dispose() {
    MainLayout.carsSearchQuery.removeListener(_applyHomeSearchQuery);
    _searchController.dispose();
    super.dispose();
  }

  void _applyHomeSearchQuery() {
    final query = MainLayout.carsSearchQuery.value.trim().toLowerCase();
    if (_searchQuery == query) return;
    setState(() {
      _searchQuery = query;
      _searchController.text = query;
    });
  }

  GetBrandCarsDataModel _localizeCarData(GetBrandCarsDataModel car) {
    return car;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              final bool isFilteredByOffer =
                  state.programCarsStatus.isSuccess &&
                  state.programCarsStatus.data != null &&
                  state.programCarsStatus.data!.isNotEmpty;

              final activeOffer = isFilteredByOffer
                  ? state.programCarsStatus.data!.first
                  : null;
              final offersByItemCode = <String, FinancingAdModel>{
                for (final offer in state.programCarsStatus.data ?? [])
                  if (offer.itemCode != null) offer.itemCode!: offer,
              };
              final normalOffers =
                  state.normalFinancingStatus.data ??
                  const <FinancingAdModel>[];
              final sortedNormalOffers =
                  List<FinancingAdModel>.from(normalOffers)..sort(
                    (a, b) => (a.interestRate ?? double.infinity).compareTo(
                      b.interestRate ?? double.infinity,
                    ),
                  );

              if (state.allCarsStatus.isLoading ||
                  state.programCarsStatus.isLoading) {
                return const Center(child: CustomLoading());
              } else if (state.allCarsStatus.isFailure && !isFilteredByOffer) {
                return Center(
                  child: Text(
                    state.allCarsStatus.message ?? 'Error loading cars',
                    style: AppTextStyle.bodyMedium(
                      context,
                    ).copyWith(color: AppColor.redColor(context)),
                  ),
                );
              }

              List<GetBrandCarsDataModel> baseCarsList = [];
              final homeCubit = context.read<HomeCubit>();
              if (isFilteredByOffer) {
                final allCars = state.allCarsStatus.data ?? [];
                baseCarsList = state.programCarsStatus.data!.map((ad) {
                  final offerCar = ad.toCarDataModel();
                  final originalCar = allCars
                      .cast<GetBrandCarsDataModel?>()
                      .firstWhere(
                        (car) => car?.itemCode == offerCar.itemCode,
                        orElse: () => null,
                      );
                  if (originalCar != null) return offerCar.merge(originalCar);

                  final nameParts = offerCar.itemName.trim().split(
                    RegExp(r'\s+'),
                  );
                  if (nameParts.isEmpty || nameParts.first.isEmpty) {
                    return offerCar;
                  }
                  return offerCar.copyWith(
                    grName: nameParts.first,
                    groupName: nameParts.last,
                  );
                }).toList();
              } else {
                baseCarsList = (state.allCarsStatus.data ?? [])
                    .where(
                      (car) =>
                          car.carStatus == 1 &&
                          !homeCubit.isCarLocallyReserved(car.itemCode),
                    )
                    .toList();
              }

              // An offer can retain its old data briefly, so apply the same
              // reservation exclusion to both regular and offer listings.
              baseCarsList = baseCarsList
                  .where((car) => !homeCubit.isCarLocallyReserved(car.itemCode))
                  .toList();

              final availableCars = _searchQuery.isEmpty
                  ? baseCarsList
                  : baseCarsList.where((car) {
                      final name = car.itemName.toLowerCase();
                      final brand = car.groupName.toLowerCase();
                      final year = car.makeYear.toString();
                      return name.contains(_searchQuery) ||
                          brand.contains(_searchQuery) ||
                          year.contains(_searchQuery);
                    }).toList();

              return Column(
                children: [
                  CarSearchHeaderWidget(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim().toLowerCase();
                      });
                    },
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                        context.read<HomeCubit>().clearProgramCarsFilter();
                        await Future.wait([
                          context.read<HomeCubit>().getCarsModels(),
                          context.read<HomeCubit>().fetchAllCars(),
                          context.read<HomeCubit>().getNormalFinancing(
                            force: true,
                          ),
                        ]);
                      },
                      color: AppColor.primaryColor(context),
                      backgroundColor: AppColor.secondAppColor(context),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        children: [
                          if (isFilteredByOffer && activeOffer != null) ...[
                            if (activeOffer.displayPicUrl.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20.w,
                                  vertical: 10.h,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Image.network(
                                    activeOffer.displayPicUrl,
                                    width: double.infinity,
                                    height: 120.h,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const SizedBox.shrink(),
                                  ),
                                ),
                              ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 8.h,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.primaryColor(
                                  context,
                                ).withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocaleKey.CAR_OFFERS.tr(),
                                    style: AppTextStyle.bodyMedium(context)
                                        .copyWith(
                                          color: AppColor.blackTextColor(
                                            context,
                                          ).withValues(alpha: 0.6),
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      context
                                          .read<HomeCubit>()
                                          .clearProgramCarsFilter();
                                    },
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: AppColor.blackTextColor(
                                        context,
                                      ).withValues(alpha: 0.5),
                                      size: 18.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          Gap(16.h),
                          CarsList(
                            cars: availableCars,
                            localizeCarData: _localizeCarData,
                            isOffer: isFilteredByOffer,
                            offersByItemCode: offersByItemCode,
                            normalOffer: sortedNormalOffers.isEmpty
                                ? null
                                : sortedNormalOffers.first,
                            normalOffers: normalOffers,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
