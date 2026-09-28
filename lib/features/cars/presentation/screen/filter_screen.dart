import 'package:car/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:car/core/extension/context_extension.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/common_methods.dart';
import 'package:car/features/cars/presentation/widget/filter_apply_button_widget.dart';
import 'package:car/features/cars/presentation/widget/filter_chips_group_widget.dart';
import 'package:car/features/cars/presentation/widget/filter_range_slider_widget.dart';
import 'package:car/features/cars/presentation/widget/filter_widgets.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final int _currentYear = DateTime.now().year;
  late RangeValues _yearRange = RangeValues(2000, _currentYear.toDouble());
  RangeValues _priceRange = const RangeValues(10000, 1000000);
  bool _isTaxInclusive = false;
  bool _isDiscountApplied = false;
  bool _isTestDriveAvailable = false;

  int? _selectedBrandId;
  String? _selectedBrandName;
  bool _showAllBrands = false;

  String? _getFuelTypeString(String? key) {
    if (key == null) return null;
    if (key == AppLocaleKey.petrol) return 'بنزين';
    if (key == AppLocaleKey.diesel) return 'ديزل';
    if (key == AppLocaleKey.hybrid) return 'هايبرد';
    if (key == AppLocaleKey.electric) return 'كهرباء';
    return key.tr();
  }

  @override
  void initState() {
    super.initState();
    final state = context.read<HomeCubit>().state;
    if (state.brands.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<HomeCubit>().getCarsModels();
      });
    }
    _selectedBrandId = state.brandId;
    if (_selectedBrandId != null && state.brands.isNotEmpty) {
      try {
        final matched = state.brands.firstWhere((b) => b.groupCode.toString() == _selectedBrandId);
        _selectedBrandName = context.apiTr(
          ar: matched.groupName,
          en: matched.groupEName ?? matched.groupName,
        );
      } catch (_) {}
    }
    if (state.fuelType != null) {
      if (state.fuelType == 'بنزين') {
        _selectedItems[AppLocaleKey.engineSystem] = AppLocaleKey.petrol;
      } else if (state.fuelType == 'ديزل') {
        _selectedItems[AppLocaleKey.engineSystem] = AppLocaleKey.diesel;
      } else if (state.fuelType == 'هايبرد') {
        _selectedItems[AppLocaleKey.engineSystem] = AppLocaleKey.hybrid;
      } else if (state.fuelType == 'كهرباء') {
        _selectedItems[AppLocaleKey.engineSystem] = AppLocaleKey.electric;
      } else {
        _selectedItems[AppLocaleKey.engineSystem] = state.fuelType!;
      }
    }
    if (state.fromMakeYear != null && state.toMakeYear != null) {
      _yearRange = RangeValues(
        double.tryParse(state.fromMakeYear!) ?? 2000,
        double.tryParse(state.toMakeYear!) ?? _currentYear.toDouble(),
      );
    }
    if (state.fromPrice != null && state.toPrice != null) {
      _priceRange = RangeValues(state.fromPrice!.toDouble(), state.toPrice!.toDouble());
    }
  }

  final Map<String, List<String>> _selectionGroups = {
    AppLocaleKey.brands: [
      AppLocaleKey.mercedes,
      AppLocaleKey.bmw,
      AppLocaleKey.toyota,
      AppLocaleKey.tesla,
      AppLocaleKey.audi,
      AppLocaleKey.ford,
      AppLocaleKey.hyundai,
      AppLocaleKey.kia,
      AppLocaleKey.mazda,
    ],
    AppLocaleKey.status: [
      AppLocaleKey.available,
      AppLocaleKey.unavailable,
      AppLocaleKey.availableOnRequest,
    ],
    AppLocaleKey.engineSystem: [
      AppLocaleKey.petrol,
      AppLocaleKey.diesel,
      AppLocaleKey.hybrid,
      AppLocaleKey.electric,
    ],
    AppLocaleKey.driveType: [
      AppLocaleKey.normal,
      AppLocaleKey.sport,
      AppLocaleKey.sand,
      AppLocaleKey.snow,
      AppLocaleKey.mud,
    ],
    AppLocaleKey.bodyType: [
      AppLocaleKey.hatchback,
      AppLocaleKey.sedan,
      AppLocaleKey.suv,
      AppLocaleKey.family,
      AppLocaleKey.commercial,
      AppLocaleKey.coupe,
    ],
    AppLocaleKey.countryOfOrigin: [
      AppLocaleKey.japan,
      AppLocaleKey.china,
      AppLocaleKey.korea,
      AppLocaleKey.usa,
      AppLocaleKey.europe,
    ],
  };

  final Map<String, String> _selectedItems = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close_rounded, color: AppColor.blackTextColor(context), size: 24.sp),
        ),
        title: Text(
          AppLocaleKey.filter.tr(),
          style: AppTextStyle.titleMedium(
            context,
          ).copyWith(color: AppColor.blackTextColor(context), fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedItems.clear();
                _selectedBrandId = null;
                _selectedBrandName = null;
                _isTestDriveAvailable = false;
                _isTaxInclusive = false;
                _isDiscountApplied = false;
                _yearRange = RangeValues(2000, _currentYear.toDouble());
                _priceRange = const RangeValues(10000, 1000000);
              });
              context.read<HomeCubit>().fetchAllCars(
                brandId: null,
                fromMakeYear: null,
                toMakeYear: null,
                fromPrice: null,
                toPrice: null,
                fuelType: null,
              );
            },
            child: Text(
              AppLocaleKey.clearAll.tr(),
              style: AppTextStyle.bodySmall(
                context,
              ).copyWith(color: AppColor.primaryColor(context), fontWeight: FontWeight.bold),
            ),
          ),
          Gap(10.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24.h,
          children: [
            BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state.brands.isEmpty) return const SizedBox.shrink();

                if (_selectedBrandId != null && _selectedBrandName == null) {
                  try {
                    final matched = state.brands.firstWhere(
                      (b) => b.groupCode.toString() == _selectedBrandId.toString(),
                    );
                    _selectedBrandName = context.apiTr(
                      ar: matched.groupName,
                      en: matched.groupEName ?? matched.groupName,
                    );
                  } catch (_) {}
                }

                final allBrands = state.brands;
                final displayedBrands = _showAllBrands ? allBrands : allBrands.take(4).toList();

                return FilterSection(
                  title: AppLocaleKey.brands.tr(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FilterChipsGroup(
                        groupKey: AppLocaleKey.brands,
                        items: allBrands
                            .map(
                              (b) =>
                                  context.apiTr(ar: b.groupName, en: b.groupEName ?? b.groupName),
                            )
                            .toList(),
                        displayedItems: displayedBrands
                            .map(
                              (b) =>
                                  context.apiTr(ar: b.groupName, en: b.groupEName ?? b.groupName),
                            )
                            .toList(),
                        selectedItem: _selectedBrandName,
                        onSelected: (itemName) {
                          setState(() {
                            _selectedBrandName = itemName;
                            if (itemName == null) {
                              _selectedBrandId = null;
                            } else {
                              final matched = state.brands.firstWhere(
                                (b) =>
                                    context.apiTr(
                                      ar: b.groupName,
                                      en: b.groupEName ?? b.groupName,
                                    ) ==
                                    itemName,
                              );
                              _selectedBrandId = matched.groupCode;
                            }
                          });
                        },
                      ),
                      if (allBrands.length > 4)
                        TextButton(
                          onPressed: () => setState(() => _showAllBrands = !_showAllBrands),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            _showAllBrands
                                ? AppLocaleKey.showLess.tr()
                                : AppLocaleKey.showMore.tr(),
                            style: AppTextStyle.bodySmall(context).copyWith(
                              color: AppColor.primaryColor(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            FilterSection(
              title: AppLocaleKey.manufacturingYear.tr(),
              child: FilterRangeSlider(
                values: _yearRange,
                min: 1990,
                max: (_currentYear + 1).toDouble(),
                onChanged: (values) => setState(() => _yearRange = values),
              ),
            ),

            FilterSection(
              title: AppLocaleKey.status.tr(),
              child: _buildChipsGroup(AppLocaleKey.status),
            ),
            FilterSection(
              title: AppLocaleKey.price.tr(),
              child: FilterRangeSlider(
                values: _priceRange,
                min: 0,
                max: 2000000,
                onChanged: (values) => setState(() => _priceRange = values),
                isPrice: true,
              ),
            ),
            FilterSection(
              title: AppLocaleKey.engineSystem.tr(),
              child: _buildChipsGroup(AppLocaleKey.engineSystem),
            ),
            FilterSection(
              title: AppLocaleKey.driveType.tr(),
              child: _buildChipsGroup(AppLocaleKey.driveType),
            ),
            FilterSection(
              title: AppLocaleKey.bodyType.tr(),
              child: _buildChipsGroup(AppLocaleKey.bodyType),
            ),
            FilterSection(
              title: AppLocaleKey.countryOfOrigin.tr(),
              child: _buildChipsGroup(AppLocaleKey.countryOfOrigin),
            ),
            FilterApplyButton(
              onPressed: () {
                final fuelKey = _selectedItems[AppLocaleKey.engineSystem];

                final hasBrand = _selectedBrandId != null;
                final hasFuel = fuelKey != null;
                final hasTestDrive = _isTestDriveAvailable;
                final hasTax = _isTaxInclusive;
                final hasDiscount = _isDiscountApplied;
                final hasOtherSelections = _selectedItems.isNotEmpty;

                if (!hasBrand &&
                    !hasFuel &&
                    !hasTestDrive &&
                    !hasTax &&
                    !hasDiscount &&
                    !hasOtherSelections) {
                  CommonMethods.showToast(
                    message: AppLocaleKey.selectionRequired.tr(),
                    type: ToastType.warning,
                  );
                  return;
                }

                context.read<HomeCubit>().fetchAllCars(
                  brandId: _selectedBrandId,
                  fromMakeYear: _yearRange.start.round().toString(),
                  toMakeYear: _yearRange.end.round().toString(),
                  fromPrice: _priceRange.start.round(),
                  toPrice: _priceRange.end.round(),
                  fuelType: _getFuelTypeString(fuelKey),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipsGroup(String groupKey) {
    return FilterChipsGroup(
      groupKey: groupKey,
      items: _selectionGroups[groupKey]!,
      selectedItem: _selectedItems[groupKey],
      onSelected: (item) {
        setState(() {
          if (item == null) {
            _selectedItems.remove(groupKey);
          } else {
            _selectedItems[groupKey] = item;
          }
        });
      },
    );
  }
}
