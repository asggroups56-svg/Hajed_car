import 'dart:typed_data';

import 'package:car/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:car/core/network/api_consumer.dart';
import 'package:car/core/network/end_points.dart';
import 'package:car/core/services/services_locator.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:printing/printing.dart';

class AccountComparisonReportsScreen extends StatefulWidget {
  const AccountComparisonReportsScreen({super.key});

  @override
  State<AccountComparisonReportsScreen> createState() =>
      _AccountComparisonReportsScreenState();
}

class _AccountComparisonReportsScreenState
    extends State<AccountComparisonReportsScreen> {
  int _reportKind = 0;
  int _accountType = 3;
  String _chartType = 'Bar';
  bool _loading = false;
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _generateReport() async {
    setState(() => _loading = true);
    try {
      final isAccount = _reportKind == 0;
      final reportName = isAccount
          ? 'AGL003_$_chartType'
          : 'AGL008_$_chartType';
      final fromValue = int.tryParse(_fromController.text.trim());
      final toValue = int.tryParse(_toController.text.trim());
      if (fromValue != null && toValue != null && fromValue > toValue) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('invalid_report_range'.tr())),
        );
        return;
      }
      final response = await sl<ApiConsumer>().post(
        isAccount
            ? EndPoints.monthlyAccountComparisonReport
            : EndPoints.monthlyCostCentersComparisonReport,
        body: isAccount
            ? {
                'FromAccountNo': fromValue,
                'ToAccountNo': toValue,
                'AccountType': _accountType,
                'ReportName': reportName,
                'ExportType': 'pdf',
              }
            : {
                'FromCostCenterNo': fromValue,
                'ToCostCenterNo': toValue,
                'AccountType': _accountType,
                'ReportName': reportName,
                'ExportType': 'pdf',
              },
        asBytes: true,
      );
      if (!mounted) return;
      final bytes = response is Uint8List
          ? response
          : Uint8List.fromList(response as List<int>);
      if (bytes.isEmpty) throw StateError('Empty PDF response');
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              _ReportPdfPreview(bytes: bytes, fileName: '$reportName.pdf'),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('report_generation_failed'.tr())),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
      appBar: CustomAppBar(
        context,
        title: Text(
          'comparison_reports'.tr(),
          style: AppTextStyle.titleMedium(context),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColor.blackTextColor(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 28.h),
        children: [
          _buildIntro(context),
          SizedBox(height: 22.h),
          _sectionCard(
            context,
            icon: Icons.dataset_rounded,
            title: 'report_category'.tr(),
            child: Row(
              children: [
                Expanded(
                  child: _kindOption(
                    context,
                    title: 'account_comparison'.tr(),
                    icon: Icons.account_tree_rounded,
                    selected: _reportKind == 0,
                    onTap: () => setState(() => _reportKind = 0),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _kindOption(
                    context,
                    title: 'cost_center_comparison'.tr(),
                    icon: Icons.business_rounded,
                    selected: _reportKind == 1,
                    onTap: () => setState(() => _reportKind = 1),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          _sectionCard(
            context,
            icon: Icons.tune_rounded,
            title: 'search_filters'.tr(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _rangeField(
                        context,
                        controller: _fromController,
                        label: 'from_number'.tr(),
                        hint: _reportKind == 0
                            ? 'from_account_hint'.tr()
                            : 'from_cost_center_hint'.tr(),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _rangeField(
                        context,
                        controller: _toController,
                        label: 'to_number'.tr(),
                        hint: _reportKind == 0
                            ? 'to_account_hint'.tr()
                            : 'to_cost_center_hint'.tr(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                _label(context, 'account_type'.tr()),
                _dropdown<int>(
                  value: _accountType,
                  items: [
                    DropdownMenuItem(
                      value: 1,
                      child: Text('main_accounts'.tr()),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('sub_accounts'.tr()),
                    ),
                    DropdownMenuItem(
                      value: 3,
                      child: Text('all_accounts'.tr()),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _accountType = value ?? 3),
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton.icon(
                    onPressed: () {
                      _fromController.clear();
                      _toController.clear();
                      setState(() => _accountType = 3);
                    },
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: Text('reset_filters'.tr()),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          _sectionCard(
            context,
            icon: Icons.insert_chart_rounded,
            title: 'chart_type'.tr(),
            child: Row(
              children: [
                _chartOption(
                  context,
                  'Bar',
                  Icons.bar_chart_rounded,
                  'bar_chart'.tr(),
                ),
                SizedBox(width: 8.w),
                _chartOption(
                  context,
                  'Line',
                  Icons.show_chart_rounded,
                  'line_chart'.tr(),
                ),
                SizedBox(width: 8.w),
                _chartOption(
                  context,
                  'Pie',
                  Icons.pie_chart_rounded,
                  'pie_chart'.tr(),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 56.h,
            child: FilledButton.icon(
              onPressed: _loading ? null : _generateReport,
              icon: _loading
                  ? SizedBox.square(
                      dimension: 18.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf_rounded),
              label: Text('search_and_view_report'.tr()),
              style: FilledButton.styleFrom(
                backgroundColor: AppColor.primaryColor(context),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro(BuildContext context) => Container(
    padding: EdgeInsets.all(20.w),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22.r),
      gradient: LinearGradient(
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
        colors: [
          AppColor.primaryColor(context),
          AppColor.primaryColor(context).withValues(alpha: .78),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: AppColor.primaryColor(context).withValues(alpha: .18),
          blurRadius: 18,
          offset: Offset(0, 8.h),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'comparison_reports'.tr(),
                style: AppTextStyle.titleMedium(
                  context,
                ).copyWith(color: Colors.white, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 6.h),
              Text(
                'comparison_reports_desc'.tr(),
                style: AppTextStyle.bodySmall(
                  context,
                ).copyWith(color: Colors.white.withValues(alpha: .85)),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Container(
          width: 52.w,
          height: 52.w,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .16),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.analytics_rounded,
            color: Colors.white,
            size: 27.sp,
          ),
        ),
      ],
    ),
  );

  Widget _sectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) => Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: AppColor.cardColor(context),
      borderRadius: BorderRadius.circular(18.r),
      border: Border.all(
        color: AppColor.borderColor(context).withValues(alpha: .35),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColor.primaryColor(context), size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              title,
              style: AppTextStyle.bodyMedium(
                context,
              ).copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        child,
      ],
    ),
  );

  Widget _kindOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14.r),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      constraints: BoxConstraints(minHeight: 82.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: selected
            ? AppColor.primaryColor(context).withValues(alpha: .08)
            : AppColor.scaffoldColor(context),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: selected
              ? AppColor.primaryColor(context)
              : AppColor.borderColor(context).withValues(alpha: .4),
          width: selected ? 1.4 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22.sp,
            color: selected
                ? AppColor.primaryColor(context)
                : AppColor.greyColor(context),
          ),
          SizedBox(height: 6.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyle.bodySmall(context).copyWith(
              color: AppColor.blackTextColor(context),
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _chartOption(
    BuildContext context,
    String value,
    IconData icon,
    String label,
  ) {
    final selected = _chartType == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _chartType = value),
        borderRadius: BorderRadius.circular(12.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: selected
                ? AppColor.primaryColor(context).withValues(alpha: .08)
                : AppColor.scaffoldColor(context),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: selected
                  ? AppColor.primaryColor(context)
                  : AppColor.borderColor(context).withValues(alpha: .4),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 21.sp,
                color: selected
                    ? AppColor.primaryColor(context)
                    : AppColor.greyColor(context),
              ),
              SizedBox(height: 5.h),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyle.bodySmall(context).copyWith(
                  color: selected
                      ? AppColor.primaryColor(context)
                      : AppColor.blackTextColor(context),
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rangeField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(context, label),
      TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: AppTextStyle.bodyMedium(context),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyle.bodySmall(
            context,
          ).copyWith(color: AppColor.hintColor(context)),
          filled: true,
          fillColor: AppColor.scaffoldColor(context),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 13.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: AppColor.borderColor(context).withValues(alpha: .35),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: AppColor.primaryColor(context),
              width: 1.4,
            ),
          ),
        ),
      ),
    ],
  );

  Widget _label(BuildContext context, String title) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Text(
      title,
      style: AppTextStyle.bodyMedium(context).copyWith(
        color: AppColor.blackTextColor(context),
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _dropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) => DropdownButtonFormField<T>(
    initialValue: value,
    items: items,
    onChanged: onChanged,
    decoration: InputDecoration(
      filled: true,
      fillColor: AppColor.cardColor(context),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: AppColor.borderColor(context).withValues(alpha: .5),
        ),
      ),
    ),
  );
}

class _ReportPdfPreview extends StatelessWidget {
  const _ReportPdfPreview({required this.bytes, required this.fileName});
  final Uint8List bytes;
  final String fileName;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(
      context,
      title: Text(
        'report_preview'.tr(),
        style: AppTextStyle.titleMedium(context),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColor.blackTextColor(context),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: PdfPreview(
      build: (_) async => bytes,
      pdfFileName: fileName,
      canChangeOrientation: false,
      canChangePageFormat: false,
      canDebug: false,
    ),
  );
}
