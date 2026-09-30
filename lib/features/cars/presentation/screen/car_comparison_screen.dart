import 'package:animate_do/animate_do.dart';
import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:car/core/images/app_images.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/utils/navigator_methods.dart';
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
      appBar: AppBar(
        title: Text(
          AppLocaleKey.comparisonTitle.tr(),
          style: AppTextStyle.titleMedium(context).copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColor.appBarColor(context),
        elevation: 0,
        actions: [
          ValueListenableBuilder(
            valueListenable: Hive.box('app').listenable(keys: ['comparisonList']),
            builder: (context, box, _) {
              final list = box.get('comparisonList', defaultValue: []);
              if (list.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: () => HiveMethods.clearComparisonList(),
                icon: Icon(Icons.delete_outline_rounded, color: AppColor.redColor(context)),
                tooltip: AppLocaleKey.clearHistory.tr(),
              );
            },
          ),
          Gap(12.w),
        ],
      ),
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
      {'key': AppLocaleKey.brand.tr(), 'field': 'brand', 'fallback': 'MAKE_NAME'},
      {'key': AppLocaleKey.modelYear.tr(), 'field': 'year', 'fallback': 'MAKE_YEAR'},
      {'key': AppLocaleKey.engine.tr(), 'field': 'engine', 'fallback': 'CYLINDER'},
      {'key': AppLocaleKey.transmission.tr(), 'field': 'transmission', 'fallback': 'TRANSMISSION'},
      {'key': AppLocaleKey.fuelTypeLabel.tr(), 'field': 'FUEL_TYPE', 'fallback': 'fuel_type'},
      {'key': AppLocaleKey.color.tr(), 'field': 'Color', 'fallback': 'BODY_COLOR'},
    ];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: isArabic ? arabicFont : regularFont, bold: arabicFont),
        build: (pw.Context context) => [
          pw.Directionality(
            textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
            child: pw.Column(
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        AppLocaleKey.carComparisonReport.tr(),
                        style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(DateFormat('yyyy-MM-dd').format(DateTime.now())),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.TableHelper.fromTextArray(
                  headers: [AppLocaleKey.spec.tr(), ...list.map((c) => c['name'])],
                  data: specs
                      .map(
                        (spec) => [
                          spec['key']!,
                          ...list.map(
                            (c) => (c[spec['field']] ?? c[spec['fallback']] ?? 'N/A').toString(),
                          ),
                        ],
                      )
                      .toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
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

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'car_comparison.pdf');
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeInUp(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.compare_arrows_rounded, size: 80.sp, color: AppColor.hintColor(context)),
            Gap(16.h),
            Text(
              AppLocaleKey.comparisonEmpty.tr(),
              style: AppTextStyle.bodyLarge(context).copyWith(color: AppColor.greyColor(context)),
            ),
            Gap(24.h),
            ElevatedButton(
              onPressed: () {
                MainLayout.tabIndex.value = 1; // Switch to Cars tab
                NavigatorMethods.pushNamedAndRemoveUntil(context, RoutesName.mainLayout);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor(context),
                foregroundColor: AppColor.whiteColor(context),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text("تصفح السيارات", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonGrid(List<dynamic> list) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocaleKey.comparisonTitle.tr(),
            style: AppTextStyle.titleMedium(context).copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 20.sp,
              color: AppColor.blackTextColor(context),
            ),
          ),
          Gap(16.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: list
                .map(
                  (car) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: _buildCarColumn(car),
                    ),
                  ),
                )
                .toList(),
          ),
          Gap(32.h),
          _buildSpecsTable(list),
          Gap(40.h),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primaryColor(context).withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => _generatePdf(list),
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: Text(
                  AppLocaleKey.downloadComparison.tr(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor(context),
                  foregroundColor: AppColor.whiteColor(context),
                  minimumSize: Size(double.infinity, 56.h),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarColumn(Map<dynamic, dynamic> car) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 120.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.cardColor(context),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColor.dividerColor(context).withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.blackColor(context).withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: car['image'].toString().startsWith('http')
                    ? CustomNetworkImage(
                        imageUrl: car['image'],
                        fit: BoxFit.contain,
                        width: double.infinity,
                      )
                    : Image.asset(
                        (car['image'] != null && car['image'].toString().trim().isNotEmpty)
                            ? car['image']
                            : AppImages.assetsImagesPlaceholder,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  HiveMethods.removeFromComparison(car);
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColor.redColor(context).withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.blackColor(context).withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.close, color: AppColor.whiteColor(context), size: 14.sp),
                ),
              ),
            ),
          ],
        ),
        Gap(12.h),
        Text(
          car['name'],
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.bodyMedium(
            context,
          ).copyWith(fontWeight: FontWeight.bold, height: 1.2),
        ),
        Gap(6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColor.primaryColor(context).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            car['price'] ?? '---',
            style: AppTextStyle.bodySmall(context).copyWith(
              color: AppColor.primaryColor(context),
              fontWeight: FontWeight.w900,
              fontSize: 12.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecsTable(List<dynamic> list) {
    final specs = [
      {
        'key': AppLocaleKey.carValue.tr(),
        'field': 'price',
        'fallback': 'PRICE',
        'icon': Icons.payments_rounded,
      },
      {
        'key': AppLocaleKey.info_tab_brand.tr(),
        'field': 'brand',
        'fallback': 'MAKE_NAME',
        'icon': Icons.stars_rounded,
      },
      {
        'key': AppLocaleKey.info_tab_model.tr(),
        'field': 'year',
        'fallback': 'MAKE_YEAR',
        'icon': Icons.calendar_today_rounded,
      },
      {
        'key': 'Engine',
        'field': 'engine',
        'fallback': 'CYLINDER',
        'icon': Icons.settings_input_component_rounded,
      },
      {
        'key': 'Transmission',
        'field': 'transmission',
        'fallback': 'TRANSMISSION',
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
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColor.cardColor(context),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColor.dividerColor(context).withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColor.blackColor(context).withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: specs.map((spec) {
          final bool isLast = spec == specs.last;
          return Container(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(
                        color: AppColor.dividerColor(context).withValues(alpha: 0.3),
                      ),
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      spec['icon'] as IconData,
                      size: 14.sp,
                      color: AppColor.primaryColor(context),
                    ),
                    Gap(6.w),
                    Text(
                      spec['key'].toString(),
                      style: AppTextStyle.bodySmall(context).copyWith(
                        color: AppColor.greyColor(context),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Gap(8.h),
                Row(
                  children: list.map((car) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Text(
                          (car[spec['field']] ?? car[spec['fallback']] ?? 'N/A').toString(),
                          style: AppTextStyle.bodyMedium(context).copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColor.blackTextColor(context),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
