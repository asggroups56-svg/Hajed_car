import 'package:animate_do/animate_do.dart';
import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:car/core/images/app_images.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/common_methods.dart';
import 'package:car/core/utils/navigator_methods.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:car/features/home/data/model/financing_ad_model.dart';
import 'package:car/features/home/presentation/view/screen/main_layout.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CarComparisonScreen extends StatefulWidget {
  const CarComparisonScreen({super.key});

  @override
  State<CarComparisonScreen> createState() => _CarComparisonScreenState();
}

class _CarComparisonScreenState extends State<CarComparisonScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('app').listenable(keys: ['comparisonList']),
        builder: (context, box, _) {
          final list = box.get('comparisonList', defaultValue: []);
          if (list.isEmpty) {
            return _buildEmptyState();
          }
          return _buildComparisonGrid(list);
        },
      ),
    );
  }

  Future<void> _generatePdf(List<dynamic> list) async {
    final pdf = pw.Document();
    final bool isArabic = context.locale.languageCode == 'ar';
    final arabicFont = await PdfGoogleFonts.notoKufiArabicBold();
    final regularFont = await PdfGoogleFonts.robotoRegular();

    final specs = [
      {'key': AppLocaleKey.price.tr(), 'field': 'price', 'fallback': 'PRICE'},
      {
        'key': AppLocaleKey.monthlyInstallment.tr(),
        'field': 'monthlyInstallment',
        'fallback': 'MonthlyInstallment',
      },
      {
        'key': AppLocaleKey.brand.tr(),
        'field': 'brand',
        'fallback': 'MAKE_NAME',
      },
      {
        'key': AppLocaleKey.modelYear.tr(),
        'field': 'year',
        'fallback': 'MAKE_YEAR',
      },
      {
        'key': AppLocaleKey.engine.tr(),
        'field': 'engine',
        'fallback': 'CYLINDER',
      },
      {
        'key': AppLocaleKey.transmission.tr(),
        'field': 'TRANSMISSION',
        'fallback': 'transmission',
      },
      {
        'key': AppLocaleKey.fuelTypeLabel.tr(),
        'field': 'FUEL_TYPE',
        'fallback': 'fuel_type',
      },
      {
        'key': AppLocaleKey.color.tr(),
        'field': 'Color',
        'fallback': 'BODY_COLOR',
      },
      {
        'key': AppLocaleKey.info_tab_interior_color.tr(),
        'field': 'BODY_COLOR',
        'fallback': 'bodyColor',
      },
      {
        'key': isArabic ? 'القوة' : 'Power',
        'field': 'POWER_HOURSE',
        'fallback': 'powerHourse',
      },
      {
        'key': isArabic ? 'سعة المحرك' : 'Engine Capacity',
        'field': 'FUEL_CAPACITY',
        'fallback': 'fuelCapacity',
      },
      {
        'key': isArabic ? 'المقاعد' : 'Seats',
        'field': 'SEAT_NO',
        'fallback': 'seatNo',
      },
      {
        'key': isArabic ? 'الأبواب' : 'Doors',
        'field': 'DOOR_NO',
        'fallback': 'doorNo',
      },
    ];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: isArabic ? arabicFont : regularFont,
          bold: arabicFont,
        ),
        build: (pw.Context context) => [
          pw.Directionality(
            textDirection: isArabic
                ? pw.TextDirection.rtl
                : pw.TextDirection.ltr,
            child: pw.Column(
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        AppLocaleKey.compareCars.tr(),
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        DateFormat('yyyy-MM-dd', 'en').format(DateTime.now()),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.TableHelper.fromTextArray(
                  headers: [
                    AppLocaleKey.spec.tr(),
                    ...list.map((c) => (c['name'] ?? '---').toString()),
                  ],
                  data: specs
                      .map(
                        (spec) => [
                          spec['key']!,
                          ...list.map((car) => _specValue(car, spec)),
                        ],
                      )
                      .toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  cellAlignment: pw.Alignment.centerLeft,
                ),
                pw.SizedBox(height: 40),
                pw.Footer(
                  title: pw.Text(
                    'Generated by Car App',
                    style: const pw.TextStyle(color: PdfColors.grey700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'car_comparison.pdf',
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeInUp(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.compare_arrows_rounded,
              size: 80.sp,
              color: AppColor.hintColor(context),
            ),
            Gap(16.h),
            Text(
              AppLocaleKey.comparisonEmpty.tr(),
              style: AppTextStyle.bodyLarge(
                context,
              ).copyWith(color: AppColor.greyColor(context)),
            ),
            Gap(24.h),
            ElevatedButton(
              onPressed: () {
                MainLayout.tabIndex.value = 1; // Switch to Cars tab
                NavigatorMethods.pushNamedAndRemoveUntil(
                  context,
                  RoutesName.mainLayout,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor(context),
                foregroundColor: AppColor.whiteColor(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                AppLocaleKey.compareCars.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonGrid(List<dynamic> list) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageHeader(list),
            Gap(18.h),
            Text(
              context.locale.languageCode == 'ar'
                  ? 'قارن المواصفات والأسعار لاتخاذ القرار المناسب لك'
                  : 'Compare specifications and prices side by side',
              style: AppTextStyle.bodySmall(
                context,
              ).copyWith(color: AppColor.greyColor(context), fontSize: 13.sp),
            ),
            Gap(16.h),
            Container(
              height: 240.h,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColor.cardColor(context),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColor.dividerColor(context).withValues(alpha: .55),
                ),
              ),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                itemCount:
                    list.length +
                    (list.length < HiveMethods.maxComparisonCars ? 1 : 0),
                separatorBuilder: (_, index) => Gap(10.w),
                itemBuilder: (context, index) => SizedBox(
                  width: 166.w,
                  child: index < list.length
                      ? _buildCarColumn(list[index], slot: index)
                      : _buildAddSecondCarSlot(),
                ),
              ),
            ),
            Gap(24.h),
            _buildSpecsTable(list),
            Gap(12.h),
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16.sp,
                  color: AppColor.primaryColor(context),
                ),
                Gap(6.w),
                Expanded(
                  child: Text(
                    context.locale.languageCode == 'ar'
                        ? 'يمكنك طلب أي سيارة من المقارنة، ثم العودة لطلب السيارة الأخرى.'
                        : 'You can request either car, then return to request the other one.',
                    style: AppTextStyle.bodySmall(context).copyWith(
                      color: AppColor.greyColor(context),
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(List<dynamic> list) => Row(
    children: [
      Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: AppColor.primaryColor(context).withValues(alpha: .1),
          borderRadius: BorderRadius.circular(13.r),
        ),
        child: Icon(
          Icons.compare_arrows_rounded,
          color: AppColor.primaryColor(context),
          size: 25.sp,
        ),
      ),
      Gap(11.w),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocaleKey.compareCars.tr(),
              style: AppTextStyle.titleMedium(context).copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 21.sp,
                color: AppColor.blackTextColor(context),
              ),
            ),
            Text(
              context.locale.languageCode == 'ar'
                  ? '${list.length} ${list.length == 1 ? 'سيارة مختارة' : 'سيارات مختارة'}'
                  : '${list.length} ${list.length == 1 ? 'car selected' : 'cars selected'}',
              style: AppTextStyle.bodySmall(context).copyWith(fontSize: 11.sp),
            ),
          ],
        ),
      ),
      IconButton.filledTonal(
        onPressed: () => _generatePdf(list),
        tooltip: AppLocaleKey.downloadComparison.tr(),
        icon: Icon(Icons.picture_as_pdf_outlined, size: 21.sp),
      ),
    ],
  );

  Widget _buildCarColumn(Map<dynamic, dynamic> car, {required int slot}) {
    final carId = HiveMethods.getCarUniqueId(Map<String, dynamic>.from(car));
    final heroTag =
        'comparison_car_image_${carId.isNotEmpty ? carId : car['name'] ?? 'car'}';
    return Column(
      children: [
        Text(
          context.locale.languageCode == 'ar'
              ? (slot == 0 ? 'السيارة الحالية' : 'السيارة المقارنة')
              : (slot == 0 ? 'Current car' : 'Comparison car'),
          style: AppTextStyle.bodySmall(context).copyWith(
            color: AppColor.primaryColor(context),
            fontWeight: FontWeight.w800,
            fontSize: 11.sp,
          ),
        ),
        Gap(9.h),
        Stack(
          children: [
            GestureDetector(
              onTap: () => NavigatorMethods.pushNamed(
                context,
                RoutesName.carDetailsScreen,
                arguments: {
                  'car': Map<String, dynamic>.from(car),
                  'heroTag': heroTag,
                },
              ),
              child: Container(
                height: 88.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColor.cardColor(context),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: AppColor.dividerColor(context).withValues(alpha: .5),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child:
                      (car['image'] != null &&
                          car['image'].toString().startsWith('http'))
                      ? CustomNetworkImage(
                          imageUrl: car['image'].toString(),
                          fit: BoxFit.contain,
                          width: double.infinity,
                        )
                      : Image.asset(
                          (car['image'] != null &&
                                  car['image'].toString().trim().isNotEmpty)
                              ? car['image'].toString()
                              : AppImages.assetsImagesPlaceholder,
                          fit: BoxFit.contain,
                        ),
                ),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () => HiveMethods.removeFromComparison(car),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColor.redColor(context),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: AppColor.whiteColor(context),
                    size: 14.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
        Gap(10.h),
        Text(
          _shortCarName(car),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.bodyMedium(
            context,
          ).copyWith(fontWeight: FontWeight.bold, height: 1.2),
        ),
        Gap(5.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColor.primaryColor(context).withValues(alpha: .1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            _priceWithVat(car),
            style: AppTextStyle.bodySmall(context).copyWith(
              color: AppColor.primaryColor(context),
              fontWeight: FontWeight.w900,
              fontSize: 11.sp,
            ),
          ),
        ),
        Gap(9.h),
        SizedBox(
          width: double.infinity,
          height: 30.h,
          child: FilledButton.icon(
            onPressed: () => _requestCar(car),
            icon: Icon(Icons.shopping_cart_checkout_rounded, size: 13.sp),
            label: Text(
              context.locale.languageCode == 'ar'
                  ? 'اطلب السيارة'
                  : 'Request car',
              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColor.primaryColor(context),
              foregroundColor: AppColor.whiteColor(context),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _requestCar(Map<dynamic, dynamic> car) {
    if (HiveMethods.getToken() == null) {
      CommonMethods.showLoginRequiredDialog(context);
      return;
    }

    NavigatorMethods.pushNamed(
      context,
      RoutesName.carReservationScreen,
      arguments: {'car': Map<String, dynamic>.from(car), 'isFromLink': false},
    );
  }

  Widget _buildAddSecondCarSlot() => InkWell(
    onTap: () {
      MainLayout.tabIndex.value = 1;
      NavigatorMethods.pushNamedAndRemoveUntil(context, RoutesName.mainLayout);
    },
    borderRadius: BorderRadius.circular(14.r),
    child: Column(
      children: [
        Text(
          context.locale.languageCode == 'ar' ? 'أضف سيارة' : 'Add a car',
          style: AppTextStyle.bodySmall(context).copyWith(
            color: AppColor.primaryColor(context),
            fontWeight: FontWeight.w800,
            fontSize: 11.sp,
          ),
        ),
        Gap(9.h),
        Container(
          height: 100.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColor.cardColor(context).withValues(alpha: .4),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: AppColor.primaryColor(context).withValues(alpha: .4),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline_rounded,
                color: AppColor.primaryColor(context),
                size: 30.sp,
              ),
              Gap(6.h),
              Text(
                context.locale.languageCode == 'ar' ? 'إضافة سيارة' : 'Add car',
                style: AppTextStyle.bodySmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColor.primaryColor(context),
                ),
              ),
            ],
          ),
        ),
        Gap(10.h),
        Text(
          context.locale.languageCode == 'ar'
              ? 'اختر سيارة للمقارنة'
              : 'Choose a car to compare',
          textAlign: TextAlign.center,
          maxLines: 2,
          style: AppTextStyle.bodySmall(
            context,
          ).copyWith(color: AppColor.greyColor(context), height: 1.2),
        ),
      ],
    ),
  );

  Widget _buildSpecsTable(List<dynamic> list) {
    final specs = [
      {
        'key': AppLocaleKey.carValue.tr(),
        'field': 'price',
        'fallback': 'PRICE',
        'icon': Icons.payments_rounded,
      },
      {
        'key': AppLocaleKey.monthlyInstallment.tr(),
        'field': 'monthlyInstallment',
        'fallback': 'MonthlyInstallment',
        'icon': Icons.calendar_month_rounded,
      },
      {
        'key': AppLocaleKey.info_tab_brand.tr(),
        'field': 'brand',
        'fallback': 'MAKE_NAME',
        'icon': Icons.stars_rounded,
      },
      {
        'key': AppLocaleKey.modelYear.tr(),
        'field': 'year',
        'fallback': 'MAKE_YEAR',
        'icon': Icons.calendar_today_rounded,
      },
      {
        'key': context.locale.languageCode == 'ar' ? 'المحرك' : 'Engine',
        'field': 'engine',
        'fallback': 'CYLINDER',
        'icon': Icons.settings_input_component_rounded,
      },
      {
        'key': context.locale.languageCode == 'ar'
            ? 'ناقل الحركة'
            : 'Transmission',
        'field': 'TRANSMISSION',
        'fallback': 'transmission',
        'icon': Icons.settings_suggest_rounded,
      },
      {
        'key': AppLocaleKey.info_tab_fuel_type.tr(),
        'field': 'FUEL_TYPE',
        'fallback': 'fuel_type',
        'icon': Icons.local_gas_station_rounded,
      },
      {
        'key': AppLocaleKey.info_tab_exterior_color.tr(),
        'field': 'Color',
        'fallback': 'BODY_COLOR',
        'icon': Icons.palette_rounded,
      },
      {
        'key': AppLocaleKey.info_tab_interior_color.tr(),
        'field': 'BODY_COLOR',
        'fallback': 'bodyColor',
        'icon': Icons.event_seat_rounded,
      },
      {
        'key': context.locale.languageCode == 'ar' ? 'القوة' : 'Power',
        'field': 'POWER_HOURSE',
        'fallback': 'powerHourse',
        'icon': Icons.bolt_rounded,
      },
      {
        'key': context.locale.languageCode == 'ar'
            ? 'سعة المحرك'
            : 'Engine capacity',
        'field': 'FUEL_CAPACITY',
        'fallback': 'fuelCapacity',
        'icon': Icons.speed_rounded,
      },
      {
        'key': context.locale.languageCode == 'ar' ? 'المقاعد' : 'Seats',
        'field': 'SEAT_NO',
        'fallback': 'seatNo',
        'icon': Icons.airline_seat_recline_extra_rounded,
      },
      {
        'key': context.locale.languageCode == 'ar' ? 'الأبواب' : 'Doors',
        'field': 'DOOR_NO',
        'fallback': 'doorNo',
        'icon': Icons.door_front_door_outlined,
      },
    ];
    final cars = List<dynamic>.from(list);
    return Container(
      decoration: BoxDecoration(
        color: AppColor.cardColor(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColor.dividerColor(context).withValues(alpha: .5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            _buildTableHeader(cars),
            ...specs.map((spec) => _buildSpecRow(spec, cars)),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(Map<String, dynamic> spec, List<dynamic> cars) =>
      Container(
        width: 118.w + (cars.length * 130.w),
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColor.dividerColor(context).withValues(alpha: .3),
            ),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 118.w,
              child: Row(
                children: [
                  Icon(
                    spec['icon'] as IconData,
                    size: 14.sp,
                    color: AppColor.primaryColor(context),
                  ),
                  Gap(5.w),
                  Expanded(
                    child: Text(
                      spec['key'].toString(),
                      style: AppTextStyle.bodySmall(context).copyWith(
                        color: AppColor.greyColor(context),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...cars.map((car) {
              final isDifferent = _isDifferentSpecValue(car, spec, cars);
              return SizedBox(
                width: 130.w,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isDifferent
                        ? AppColor.primaryColor(context).withValues(alpha: .10)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    _specValue(car, spec),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.bodySmall(context).copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDifferent
                          ? AppColor.primaryColor(context)
                          : AppColor.blackTextColor(context),
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      );

  Widget _buildTableHeader(List<dynamic> cars) => Container(
    width: 118.w + (cars.length * 130.w),
    padding: EdgeInsets.symmetric(vertical: 13.h),
    color: AppColor.primaryColor(context).withValues(alpha: .08),
    child: Row(
      children: [
        SizedBox(
          width: 118.w,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              context.locale.languageCode == 'ar'
                  ? 'المواصفات'
                  : 'Specifications',
              style: _tableHeaderStyle(),
            ),
          ),
        ),
        ...cars.map(
          (car) => SizedBox(
            width: 130.w,
            child: Text(
              _shortCarName(car),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _tableHeaderStyle(),
            ),
          ),
        ),
      ],
    ),
  );

  TextStyle _tableHeaderStyle() => AppTextStyle.bodySmall(context).copyWith(
    fontWeight: FontWeight.w800,
    fontSize: 9.sp,
    color: AppColor.primaryColor(context),
  );

  String _shortCarName(dynamic car) =>
      (car['name'] ?? car['itemName'] ?? car['ITEM_NAME'] ?? '---').toString();

  bool _isDifferentSpecValue(
    dynamic car,
    Map<String, dynamic> spec,
    List<dynamic> cars,
  ) {
    final values = cars.map((item) => _specValue(item, spec)).toSet();
    return values.length > 1 && _specValue(car, spec) != '—';
  }

  String _specValue(dynamic car, Map<String, dynamic> spec) {
    if (spec['field'] == 'price') return _priceWithVat(car);
    if (spec['field'] == 'monthlyInstallment') {
      return _monthlyInstallment(car);
    }

    final value = car[spec['field']] ?? car[spec['fallback']];
    if (value == null || value.toString().trim().isEmpty) return '—';

    if (spec['field'] == 'TRANSMISSION') {
      return value.toString() == '1'
          ? AppLocaleKey.agentAutomatic.tr()
          : AppLocaleKey.agentManual.tr();
    }
    if (spec['field'] == 'monthlyInstallment' ||
        spec['field'] == 'installments') {
      final amount = double.tryParse(
        value.toString().replaceAll(RegExp(r'[^0-9.]'), ''),
      );
      if (amount != null && amount > 0) {
        return '${NumberFormat('#,##0', 'en_US').format(amount)} ${AppLocaleKey.sar.tr()}';
      }
    }
    return value.toString();
  }

  /// Comparison entries may have been stored before the API returned a
  /// pre-calculated installment. Use the same fallback formula used on the
  /// car details card so the monthly payment is still available.
  String _monthlyInstallment(dynamic car) {
    final rawPrice = car['SALE_PRICE'] ?? car['price'] ?? car['PRICE'];
    final price =
        double.tryParse(
          rawPrice?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '',
        ) ??
        0;
    if (price <= 0) return '—';

    final formatter = NumberFormat('#,##0', 'en_US');

    // Comparison entries keep the raw car map, so a row that carries its own
    // offer terms must be financed with those terms.
    if (car is Map) {
      final carModel = GetBrandCarsDataModel.fromJson(
        Map<String, dynamic>.from(car),
      );
      final plates = _numberValue(
        car['paintingsVal'] ?? car['PaintingsVal'] ?? car['PAINTINGS_VAL'] ?? 0,
      );
      final offerMonthly = FinancingAdModel.vehicleOfferMonthlyInstallment(
        carModel,
        basePrice: price,
        platesVal: plates,
      );
      if (offerMonthly != null && offerMonthly > 0) {
        return '${formatter.format(offerMonthly)} ${AppLocaleKey.sar.tr()}';
      }
    }

    final explicitMonthly = _numberValue(
      car['monthlyInstallment'] ?? car['MonthlyInstallment'],
    );
    if (explicitMonthly > 0) {
      return '${formatter.format(explicitMonthly)} ${AppLocaleKey.sar.tr()}';
    }

    final installments = car['installments']?.toString().trim();
    if (installments != null &&
        installments.isNotEmpty &&
        installments != '0' &&
        installments.toLowerCase() != 'null') {
      return '$installments ${AppLocaleKey.sar.tr()}';
    }

    final vat =
        double.tryParse(HiveMethods.getVatNumber()?.toString() ?? '') ?? 15;
    final plates = _numberValue(
      car['paintingsVal'] ?? car['PaintingsVal'] ?? car['PAINTINGS_VAL'] ?? 0,
    );
    final financingPrice = (price + 3000) * (1 + vat / 100) + plates;
    final interestRate = _numberValue(
      car['interestRate'] ?? car['InterestRate'],
    );
    final monthly = interestRate > 0
        ? (financingPrice + financingPrice * (interestRate / 100) * 5) / 60
        : (financingPrice * 1.225) / 60;
    return '${formatter.format(monthly)} ${AppLocaleKey.sar.tr()}';
  }

  double _numberValue(dynamic value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '') ?? 0;

  String _priceWithVat(dynamic car) {
    final rawPrice = car['SALE_PRICE'] ?? car['price'] ?? car['PRICE'];
    final price = double.tryParse(
      rawPrice?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '',
    );
    if (price == null || price <= 0) return '—';

    final plates =
        double.tryParse(
          (car['paintingsVal'] ??
                  car['PaintingsVal'] ??
                  car['PAINTINGS_VAL'] ??
                  0)
              .toString(),
        ) ??
        0;
    final vat =
        double.tryParse(HiveMethods.getVatNumber()?.toString() ?? '') ?? 15;
    final isAlreadyVatInclusive = rawPrice.toString().contains(',');
    final total =
        (isAlreadyVatInclusive ? price : price * (1 + vat / 100)) + plates;
    return '${NumberFormat('#,##0', 'en_US').format(total)} ${AppLocaleKey.sar.tr()}';
  }
}
