import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:car/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/cars/presentation/screen/widget/car_search_header_widget.dart';
import 'package:car/features/cars/presentation/screen/widget/premium_car_card_widget.dart';
import 'package:car/features/cars/presentation/widget/cars_brand_filter_bar_widget.dart';
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

enum _CarPriceSort { none, lowToHigh, highToLow }

class _CarsScreenState extends State<CarsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  _CarPriceSort _priceSort = _CarPriceSort.none;

  double _carBasePrice(GetBrandCarsDataModel car) {
    final value = car.effectivePrice ?? car.price ?? '';
    final normalized = value.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(normalized) ?? 0.0;
  }

  double _carPrice(GetBrandCarsDataModel car) {
    final base = _carBasePrice(car);
    if (base <= 0) return double.infinity;
    final vatPercentage =
        double.tryParse(HiveMethods.getVatNumber()?.toString() ?? '') ?? 15.0;
    return (base * (1 + vatPercentage / 100)) + car.platesCostWithVat;
  }

  @override
  void initState() {
    super.initState();
    _searchQuery = MainLayout.carsSearchQuery.value.trim().toLowerCase();
    _searchController.text = _searchQuery;
    MainLayout.carsSearchQuery.addListener(_applyHomeSearchQuery);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeCubit = context.read<HomeCubit>();
      final homeState = homeCubit.state;
      final selectedBrandId = homeState.selectedBrandId;
      if (selectedBrandId != null) {
        // The user came from the brands section, so this tab must show that
        // brand's inventory instead of the complete catalog.
        if (!homeState.brandCarsStatus.isSuccess &&
            !homeState.brandCarsStatus.isLoading) {
          homeCubit.getBrandCars(selectedBrandId.toString());
        }
      } else if (homeState.allCarsStatus.data == null ||
          homeState.allCarsStatus.data!.isEmpty) {
        homeCubit.fetchAllCars();
      }
      if (homeState.normalFinancingStatus.data == null ||
          homeState.normalFinancingStatus.data!.isEmpty) {
        homeCubit.getNormalFinancing();
      }
      // Financing programs also list cars that stay in the regular inventory.
      // Load their rows so those cards can show the promotional terms.
      homeCubit.loadPromoCarOffers();
    });
  }

  /// Clears the brand selection and makes sure the full inventory is loaded
  /// before the list switches back to "All".
  void _clearBrandFilter() {
    final cubit = context.read<HomeCubit>();
    cubit.selectAllBrands();
    final allCarsStatus = cubit.state.allCarsStatus;
    if (!allCarsStatus.isSuccess && !allCarsStatus.isLoading) {
      cubit.fetchAllCars();
    }
  }

  /// Resolves the selected brand (or one of its model types) to its display
  /// name. The brand list is the source of truth, while the loaded cars are a
  /// fallback when the selection came from a deep link.
  String? _selectedBrandName(HomeState state) {
    final selectedBrandId = state.selectedBrandId;
    if (selectedBrandId == null) return null;

    String localizedName(String arName, String? enName) {
      if (context.locale.languageCode == 'ar') return arName;
      final english = enName?.trim() ?? '';
      return english.isEmpty ? arName : english;
    }

    for (final brand in state.brands) {
      if (brand.groupCode == selectedBrandId) {
        return localizedName(brand.groupName, brand.groupEName);
      }
      for (final child in brand.children) {
        if (child.groupCode == selectedBrandId) {
          return localizedName(child.groupName, child.groupEName);
        }
      }
    }

    final brandCars = state.brandCarsStatus.data;
    if (brandCars != null && brandCars.isNotEmpty) {
      return brandCars.first.groupName;
    }
    return null;
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

  /// Finds the inventory row that a financing-program car came from.
  ///
  /// Program cars often have an empty `ITEM_CODE`, so matching on it alone can
  /// pick the wrong row (or the first row of the brand). `ITEM_NAME` plus the
  /// model year is the most reliable identity left in that case.
  GetBrandCarsDataModel? _findInventoryRow(
    List<GetBrandCarsDataModel> allCars,
    GetBrandCarsDataModel offerCar,
  ) {
    final itemCode = offerCar.itemCode.trim();
    if (itemCode.isNotEmpty) {
      for (final car in allCars) {
        if (car.itemCode.trim() == itemCode) return car;
      }
    }

    final chassis = offerCar.chassisNo.trim();
    if (chassis.isNotEmpty && chassis != 'null') {
      for (final car in allCars) {
        if (car.chassisNo.trim() == chassis) return car;
      }
    }

    final name = offerCar.itemName.trim().toLowerCase();
    if (name.isEmpty) return null;
    // Several inventory cars can share a model name and year (different
    // colours, or empty item codes on the program rows). Reusing one of them
    // for every program row would show the same car twice, so an ambiguous
    // match is treated as no match and the program row keeps its own data.
    GetBrandCarsDataModel? match;
    for (final car in allCars) {
      if (car.itemName.trim().toLowerCase() != name) continue;
      if (offerCar.makeYear != 0 &&
          car.makeYear != 0 &&
          car.makeYear != offerCar.makeYear) {
        continue;
      }
      if (match != null) return null;
      match = car;
    }
    return match;
  }

  /// Finds the financing-program row that belongs to [car], if the car is part
  /// of a promotion.
  ///
  /// A promotional car can also be part of the regular inventory, where its
  /// row only carries the standard terms. The program row has the terms the
  /// customer sees in the offers section, so it must drive the card's
  /// installment and profit rate. Identity follows the same priority used to
  /// merge an offer with its inventory row: item code, chassis, then name and
  /// model year (program rows often leave the item code empty).
  FinancingAdModel? _findPromoOffer(
    GetBrandCarsDataModel car,
    List<FinancingAdModel> promoOffers,
  ) {
    if (promoOffers.isEmpty) return null;

    final itemCode = car.itemCode.trim();
    final chassisNo = car.chassisNo.trim();
    final chassisKey = chassisNo.toLowerCase();
    final name = car.itemName.trim().toLowerCase();
    final year = car.makeYear;

    FinancingAdModel? best;
    double bestInstallment = double.infinity;

    for (final offer in promoOffers) {
      final offerItemCode = offer.itemCode?.trim() ?? '';
      final offerChassisNo = offer.chassisNo?.trim() ?? '';
      final offerName = offer.itemName?.trim().toLowerCase() ?? '';
      final offerYear = offer.makeYear ?? offer.modelYear ?? 0;

      final bool matches =
          (itemCode.isNotEmpty && offerItemCode == itemCode) ||
          (chassisKey.isNotEmpty &&
              chassisKey != 'null' &&
              offerChassisNo.toLowerCase() == chassisKey) ||
          (name.isNotEmpty &&
              offerName == name &&
              (year == 0 || offerYear == 0 || offerYear == year));
      if (!matches) continue;

      final price = (offer.price ?? 0) > 0 ? offer.price! : _carBasePrice(car);
      if (price <= 0 || price.isInfinite) {
        best ??= offer;
        continue;
      }

      final plates = car.paintingsVal ?? offer.paintingsVal ?? 0.0;
      final installment = offer.monthlyInstallmentForPrice(
        price,
        platesVal: plates,
      );
      if (installment < bestInstallment) {
        best = offer;
        bestInstallment = installment;
      }
    }

    return best;
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
              // A brand (or one of its model types) selected from the brands
              // section narrows the inventory to that brand. An explicit
              // financing-program filter still wins, because it already
              // describes the cars the customer asked for.
              final bool isBrandSelected =
                  state.selectedBrandId != null && !isFilteredByOffer;
              final selectedBrandName = isBrandSelected
                  ? _selectedBrandName(state)
                  : null;

              final activeOffer = isFilteredByOffer
                  ? state.programCarsStatus.data!.first
                  : null;
              final offersByItemCode = <String, FinancingAdModel>{
                for (final offer in state.programCarsStatus.data ?? [])
                  if (offer.itemCode != null) offer.itemCode!: offer,
              };
              // Also build a quick lookup from promoCarOffers so that regular
              // inventory cars that share an item code with a promo row can be
              // matched in O(1) even before _findPromoOffer runs its fuzzy search.
              final promoOffersByItemCode = <String, FinancingAdModel>{
                for (final offer in state.promoCarOffers)
                  if (offer.itemCode != null && offer.itemCode!.trim().isNotEmpty)
                    offer.itemCode!.trim(): offer,
              };
              final normalOffers =
                  state.normalFinancingStatus.data ??
                  const <FinancingAdModel>[];
              final sortedNormalOffers =
                  List<FinancingAdModel>.from(normalOffers)..sort((a, b) {
                    final aCost =
                        a.getEffectiveInterestRate() + a.insuranceForBank();
                    final bCost =
                        b.getEffectiveInterestRate() + b.insuranceForBank();
                    return aCost.compareTo(bCost);
                  });
              final normalOffer = sortedNormalOffers.isEmpty
                  ? null
                  : sortedNormalOffers.first;

              final bool isLoadingInventory = isFilteredByOffer
                  ? state.programCarsStatus.isLoading
                  : isBrandSelected
                  ? (state.brandCarsStatus.isLoading ||
                        state.brandCarsStatus.isInitial)
                  : state.allCarsStatus.isLoading;

              if (state.programCarsStatus.isLoading || isLoadingInventory) {
                return const Center(child: CustomLoading());
              }

              final inventoryFailure = isFilteredByOffer
                  ? null
                  : isBrandSelected
                  ? (state.brandCarsStatus.isFailure
                        ? state.brandCarsStatus
                        : null)
                  : (state.allCarsStatus.isFailure
                        ? state.allCarsStatus
                        : null);
              if (inventoryFailure != null) {
                return Center(
                  child: Text(
                    inventoryFailure.message ??
                        inventoryFailure.error ??
                        'Error loading cars',
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
                  final originalCar = _findInventoryRow(allCars, offerCar);
                  if (originalCar != null) {
                    // The inventory row can carry its own active offer. That
                    // row-level offer is the one the customer sees on the car,
                    // so the program car must not replace its terms (or its
                    // `IsActive`/`EndDate`) and silently turn it into standard
                    // financing.
                    return originalCar.isVehicleOffer
                        ? originalCar.merge(offerCar)
                        : offerCar.merge(originalCar);
                  }

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
              } else if (isBrandSelected) {
                baseCarsList =
                    (state.brandCarsStatus.data ??
                            const <GetBrandCarsDataModel>[])
                        .where(
                          (car) =>
                              car.carStatus == 1 &&
                              !homeCubit.isCarLocallyReserved(car.itemCode),
                        )
                        .toList();
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

              final filteredCars = _searchQuery.isEmpty
                  ? baseCarsList
                  : baseCarsList.where((car) {
                      final name = car.itemName.toLowerCase();
                      final brand = car.groupName.toLowerCase();
                      final year = car.makeYear.toString();
                      return name.contains(_searchQuery) ||
                          brand.contains(_searchQuery) ||
                          year.contains(_searchQuery);
                    }).toList();
              final availableCars = List<GetBrandCarsDataModel>.from(filteredCars);
              if (_priceSort != _CarPriceSort.none) {
                availableCars.sort((a, b) {
                  final priceA = _carPrice(a);
                  final priceB = _carPrice(b);
                  if (priceA.isInfinite) return priceB.isInfinite ? 0 : 1;
                  if (priceB.isInfinite) return -1;
                  final comparison = priceA.compareTo(priceB);
                  return _priceSort == _CarPriceSort.lowToHigh
                      ? comparison
                      : -comparison;
                });
              }

              return Column(
                children: [
                  CarSearchHeaderWidget(
                    controller: _searchController,
                    sortAction: PopupMenuButton<_CarPriceSort>(
                      tooltip: AppLocaleKey.sortBy.tr(),
                      initialValue: _priceSort,
                      onSelected: (sort) => setState(() => _priceSort = sort),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: _CarPriceSort.lowToHigh,
                          child: Text(AppLocaleKey.priceLowToHigh.tr()),
                        ),
                        PopupMenuItem(
                          value: _CarPriceSort.highToLow,
                          child: Text(AppLocaleKey.priceHighToLow.tr()),
                        ),
                        PopupMenuItem(
                          value: _CarPriceSort.none,
                          child: Text(AppLocaleKey.defaultSort.tr()),
                        ),
                      ],
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColor.secondAppColor(context),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColor.dividerColor(context),
                          ),
                        ),
                        child: Icon(
                          Icons.sort_rounded,
                          color: _priceSort == _CarPriceSort.none
                              ? AppColor.blackTextColor(context)
                              : AppColor.primaryColor(context),
                        ),
                      ),
                    ),
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
                        // Refresh the program cars in the background so the
                        // list does not wait for every financing program.
                        context.read<HomeCubit>().loadPromoCarOffers(
                          force: true,
                        );
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
                      child: CustomScrollView(
                        cacheExtent: 350,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        slivers: [
                          if (isFilteredByOffer && activeOffer != null) ...[
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20.w,
                                  vertical: 10.h,
                                ),
                                // Show the program's own artwork only. Falling
                                // back to a car photo here would repeat the
                                // first card's image right above it.
                                child: activeOffer.programArtworkUrl.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        child: CustomNetworkImage(
                                          imageUrl:
                                              activeOffer.programArtworkUrl,
                                          width: double.infinity,
                                          height: 120.h,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Container(
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
                            ),
                          ],
                          if (isBrandSelected)
                            SliverToBoxAdapter(
                              child: CarsBrandFilterBar(
                                brandName: selectedBrandName,
                                onClear: _clearBrandFilter,
                              ),
                            ),
                          SliverToBoxAdapter(child: Gap(16.h)),
                          if (availableCars.isEmpty)
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: 200.h,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Gap(20),
                                      Icon(
                                        Icons.directions_car_outlined,
                                        size: 80.sp,
                                        color: AppColor.hintColor(context)
                                            .withValues(alpha: 0.4),
                                      ),
                                      const Gap(12),
                                      Text(
                                        AppLocaleKey.noCars.tr(),
                                        style: AppTextStyle.bodyLarge(
                                          context,
                                        ).copyWith(
                                          color: AppColor.blackTextColor(
                                            context,
                                          ).withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding:
                                  EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
                              sliver: SliverList.separated(
                                addAutomaticKeepAlives: false,
                                addRepaintBoundaries: true,
                                itemCount: availableCars.length,
                                separatorBuilder: (context, index) => Gap(16.h),
                                itemBuilder: (context, index) {
                                  final car = _localizeCarData(
                                    availableCars[index],
                                  );
                                  final carId =
                                      HiveMethods.getCarUniqueId(car.toMap());

                                  // A vehicle can belong to an offer on its own
                                  // (GetprandcarsData returns the offer terms on
                                  // the car row) or through a financing program
                                  // while still being part of the regular
                                  // inventory. Both must drive the card
                                  // installment instead of the standard bank
                                  // financing numbers.
                                  final vehicleOffer = car.isVehicleOffer
                                      ? FinancingAdModel.fromCarOffer(car)
                                      : null;
                                  // Fuzzy match against promoCarOffers (name/year).
                                  final promoOffer = _findPromoOffer(
                                    car,
                                    state.promoCarOffers,
                                  );
                                  // Fast item-code lookup as a fallback when fuzzy
                                  // match returns null (avoids missing the banner
                                  // when promoCarOffers loaded before the fuzzy
                                  // match had a chance to run).
                                  final promoOfferByCode =
                                      car.itemCode.isNotEmpty
                                      ? promoOffersByItemCode[car.itemCode.trim()]
                                      : null;
                                  final resolvedPromoOffer =
                                      promoOffer ?? promoOfferByCode;
                                  final activeOffer = isFilteredByOffer
                                      ? (vehicleOffer ??
                                            (car.itemCode.isNotEmpty
                                                ? offersByItemCode[car.itemCode]
                                                : null))
                                      : (resolvedPromoOffer ?? vehicleOffer);
                                  final offer = activeOffer ??
                                      (isFilteredByOffer ? normalOffer : null);
                                  final offers =
                                      activeOffer != null || isFilteredByOffer
                                      ? const <FinancingAdModel>[]
                                      : normalOffers;

                                  return PremiumCarCardWidget(
                                    car: car,
                                    heroTag:
                                        'premium_car_image_${carId.isNotEmpty ? carId : index}_$index',
                                    isOffer:
                                        isFilteredByOffer ||
                                        resolvedPromoOffer != null ||
                                        car.isVehicleOffer,
                                    offer: offer,
                                    financingOffers: offers,
                                  );
                                },
                              ),
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
