import 'package:car/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:car/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/home/data/model/banks_data_model.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:car/features/services/presentation/widgets/calculator_banner.dart';
import 'package:car/features/services/presentation/widgets/employment_type_butto.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class FinancingWorkInfoTab extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback onShowCalculator;
  final TextEditingController? employerCtrl;
  final TextEditingController? jobTitleCtrl;
  final TextEditingController? salaryCtrl;
  final TextEditingController? bankCtrl;
  final String? employmentType;
  final ValueChanged<String?>? onEmploymentTypeChanged;
  final ValueChanged<String?>? onBankChanged;
  final ValueChanged<BANKSDATAModel?>? onBankSelected;

  const FinancingWorkInfoTab({
    super.key,
    required this.formKey,
    required this.onShowCalculator,
    this.employerCtrl,
    this.jobTitleCtrl,
    this.salaryCtrl,
    this.bankCtrl,
    this.employmentType,
    this.onEmploymentTypeChanged,
    this.onBankChanged,
    this.onBankSelected,
  });

  @override
  State<FinancingWorkInfoTab> createState() => _FinancingWorkInfoTabState();
}

class _FinancingWorkInfoTabState extends State<FinancingWorkInfoTab> {
  late TextEditingController _employerCtrl;
  late TextEditingController _jobTitleCtrl;
  late TextEditingController _salaryCtrl;
  late TextEditingController _bankCtrl;

  String? _employmentType;

  @override
  void initState() {
    super.initState();
    _employerCtrl = widget.employerCtrl ?? TextEditingController();
    _jobTitleCtrl = widget.jobTitleCtrl ?? TextEditingController();
    _salaryCtrl = widget.salaryCtrl ?? TextEditingController();
    _bankCtrl = widget.bankCtrl ?? TextEditingController();
    _employmentType = widget.employmentType ?? 'private';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeCubit = context.read<HomeCubit>();
      if (homeCubit.state.banksStatus.data == null ||
          homeCubit.state.banksStatus.data!.isEmpty) {
        homeCubit.getBanks();
      }
    });
  }

  @override
  void dispose() {
    if (widget.employerCtrl == null) _employerCtrl.dispose();
    if (widget.jobTitleCtrl == null) _jobTitleCtrl.dispose();
    if (widget.salaryCtrl == null) _salaryCtrl.dispose();
    if (widget.bankCtrl == null) _bankCtrl.dispose();
    super.dispose();
  }

  void _showBankPicker() {
    final homeCubit = context.read<HomeCubit>();
    if (homeCubit.state.banksStatus.data == null ||
        homeCubit.state.banksStatus.data!.isEmpty) {
      homeCubit.getBanks();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            return BlocBuilder<HomeCubit, HomeState>(
              builder: (context, homeState) {
                // Collect bank names directly from endpoint
                final List<String> apiBankNames = [];

                if (homeState.banksStatus.data != null &&
                    homeState.banksStatus.data!.isNotEmpty) {
                  for (final BANKSDATAModel bank in homeState.banksStatus.data!) {
                    final isEn = context.locale.languageCode == 'en';
                    final name = (isEn ? bank.bankNameEng : bank.bankName) ??
                        bank.bankName ??
                        bank.bankNameEng;
                    if (name != null &&
                        name.trim().isNotEmpty &&
                        !apiBankNames.contains(name.trim())) {
                      apiBankNames.add(name.trim());
                    }
                  }
                }

                // Also merge any bank names from normal financing endpoint if available
                if (homeState.normalFinancingStatus.data != null) {
                  for (final offer in homeState.normalFinancingStatus.data!) {
                    final name = offer.displayBankName ?? offer.bankName;
                    if (name != null &&
                        name.trim().isNotEmpty &&
                        !apiBankNames.contains(name.trim())) {
                      apiBankNames.add(name.trim());
                    }
                  }
                }

                final List<String> allBanks = [
                  ...apiBankNames,
                  context.locale.languageCode == 'ar' ? 'أخرى' : 'Other',
                ];

                final filteredBanks = allBanks.where((bank) {
                  if (searchQuery.trim().isEmpty) return true;
                  return bank.toLowerCase().contains(searchQuery.toLowerCase());
                }).toList();

                final isLoading =
                    homeState.banksStatus.isLoading && apiBankNames.isEmpty;
                final isFailure =
                    homeState.banksStatus.isFailure && apiBankNames.isEmpty;

                return Container(
                  height: 0.68.sh,
                  padding: EdgeInsets.fromLTRB(
                    20.w,
                    16.h,
                    20.w,
                    MediaQuery.of(context).viewInsets.bottom + 16.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.scaffoldColor(context),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24.r)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color:
                              AppColor.greyColor(context).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      Gap(16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: AppColor.borderColor(context),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                size: 16.sp,
                                color: AppColor.blackTextColor(context),
                              ),
                            ),
                          ),
                          Text(
                            AppLocaleKey.selectTransferredBank.tr(),
                            style: AppTextStyle.titleMedium(context).copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 16.sp,
                            ),
                          ),
                          const SizedBox(width: 28),
                        ],
                      ),
                      Gap(16.h),
                      CustomFormField(
                        hintText: context.locale.languageCode == 'ar'
                            ? 'بحث عن بنك...'
                            : 'Search bank...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColor.greyColor(context),
                          size: 20.sp,
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            searchQuery = val;
                          });
                        },
                      ),
                      Gap(12.h),
                      if (isLoading)
                        const Expanded(
                          child: Center(
                            child: CustomLoading(),
                          ),
                        )
                      else if (isFailure)
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  size: 40.sp,
                                  color: AppColor.greyColor(context),
                                ),
                                Gap(10.h),
                                Text(
                                  context.locale.languageCode == 'ar'
                                      ? 'فشل تحميل قائمة البنوك'
                                      : 'Failed to load banks',
                                  style: AppTextStyle.bodyMedium(context),
                                ),
                                Gap(10.h),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColor.primaryColor(context),
                                  ),
                                  onPressed: () => homeCubit.getBanks(),
                                  child: Text(
                                    AppLocaleKey.tryAgain.tr(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: filteredBanks.length +
                                (searchQuery.trim().isNotEmpty &&
                                        !filteredBanks
                                            .contains(searchQuery.trim())
                                    ? 1
                                    : 0),
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: AppColor.borderColor(context)
                                  .withValues(alpha: 0.5),
                            ),
                            itemBuilder: (context, index) {
                              if (index < filteredBanks.length) {
                                final bank = filteredBanks[index];
                                final isSelected = _bankCtrl.text.trim() == bank;
                                return ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 2.h,
                                  ),
                                  leading: Container(
                                    padding: EdgeInsets.all(8.w),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColor.primaryColor(context)
                                              .withValues(alpha: 0.1)
                                          : AppColor.cardColor(context),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.account_balance_rounded,
                                      color: isSelected
                                          ? AppColor.primaryColor(context)
                                          : AppColor.greyColor(context),
                                      size: 18.sp,
                                    ),
                                  ),
                                  title: Text(
                                    bank,
                                    style: AppTextStyle.bodyMedium(context)
                                        .copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.w900
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? AppColor.primaryColor(context)
                                          : AppColor.blackTextColor(context),
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? Icon(
                                          Icons.check_circle_rounded,
                                          color: AppColor.primaryColor(context),
                                          size: 20.sp,
                                        )
                                      : null,
                                  onTap: () {
                                    if (bank == 'أخرى' || bank == 'Other') {
                                      Navigator.pop(context);
                                      _showCustomBankDialog();
                                    } else {
                                      // Find the matching BANKSDATAModel to get bankCode
                                      final matchedModel = homeState.banksStatus.data?.firstWhere(
                                        (b) {
                                          final isEn = context.locale.languageCode == 'en';
                                          final name = (isEn ? b.bankNameEng : b.bankName) ?? b.bankName ?? b.bankNameEng;
                                          return name?.trim() == bank;
                                        },
                                        orElse: () => BANKSDATAModel(bankName: bank),
                                      );
                                      setState(() {
                                        _bankCtrl.text = bank;
                                      });
                                      widget.onBankChanged?.call(bank);
                                      widget.onBankSelected?.call(matchedModel);
                                      Navigator.pop(context);
                                    }
                                  },
                                );
                              } else {
                                final customBank = searchQuery.trim();
                                return ListTile(
                                  leading: Icon(
                                    Icons.add_circle_outline,
                                    color: AppColor.primaryColor(context),
                                  ),
                                  title: Text(
                                    context.locale.languageCode == 'ar'
                                        ? 'استخدام: "$customBank"'
                                        : 'Use: "$customBank"',
                                    style: AppTextStyle.bodyMedium(context)
                                        .copyWith(
                                      color: AppColor.primaryColor(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _bankCtrl.text = customBank;
                                    });
                                    widget.onBankChanged?.call(customBank);
                                    Navigator.pop(context);
                                  },
                                );
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showCustomBankDialog() {
    final customCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColor.scaffoldColor(context),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          context.locale.languageCode == 'ar'
              ? 'أدخل اسم البنك'
              : 'Enter Bank Name',
          style: AppTextStyle.titleMedium(context)
              .copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: CustomFormField(
          controller: customCtrl,
          hintText:
              context.locale.languageCode == 'ar' ? 'اسم البنك' : 'Bank Name',
          radius: 10,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppLocaleKey.cancel.tr(),
              style: TextStyle(color: AppColor.greyColor(context)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor(context),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
            ),
            onPressed: () {
              final text = customCtrl.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  _bankCtrl.text = text;
                });
                widget.onBankChanged?.call(text);
              }
              Navigator.pop(ctx);
            },
            child: Text(
              context.locale.languageCode == 'ar' ? 'حفظ' : 'Save',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                AppLocaleKey.agentEmploymentType.tr(),
                style: AppTextStyle.bodyMedium(
                  context,
                ).copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColor.blackTextColor(context)),
              ),
            ),
            Gap(10.h),
            Row(
              children: [
                Expanded(
                  child: EmploymentTypeButton(
                    value: 'private',
                    label: AppLocaleKey.agentPrivateSector.tr(),
                    selectedType: _employmentType,
                    onTap: (v) {
                      setState(() => _employmentType = v);
                      widget.onEmploymentTypeChanged?.call(v);
                    },
                  ),
                ),
                Gap(10.w),
                Expanded(
                  child: EmploymentTypeButton(
                    value: 'government',
                    label: AppLocaleKey.agentGovSector.tr(),
                    selectedType: _employmentType,
                    onTap: (v) {
                      setState(() => _employmentType = v);
                      widget.onEmploymentTypeChanged?.call(v);
                    },
                  ),
                ),
                Gap(10.w),
                Expanded(
                  child: EmploymentTypeButton(
                    value: 'self',
                    label: AppLocaleKey.agentFreelance.tr(),
                    selectedType: _employmentType,
                    onTap: (v) {
                      setState(() => _employmentType = v);
                      widget.onEmploymentTypeChanged?.call(v);
                    },
                  ),
                ),
              ],
            ),
            Gap(20.h),
            CustomFormField(
              controller: _employerCtrl,
              hintText: AppLocaleKey.agentEmployer.tr(),
              radius: 12,
              validator: (v) => (v == null || v.isEmpty)
                  ? AppLocaleKey.agentEmployerRequired.tr()
                  : null,
            ),
            Gap(16.h),
            CustomFormField(
              controller: _jobTitleCtrl,
              hintText: AppLocaleKey.agentJobTitle.tr(),
              radius: 12,
              validator: (v) => (v == null || v.isEmpty)
                  ? AppLocaleKey.agentJobTitleRequired.tr()
                  : null,
            ),
            Gap(16.h),
            CustomFormField(
              controller: _salaryCtrl,
              hintText: AppLocaleKey.agentMonthlySalary.tr(),
              radius: 12,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => (v == null || v.isEmpty)
                  ? AppLocaleKey.agentSalaryRequired.tr()
                  : null,
            ),
            Gap(16.h),
            CustomFormField(
              controller: _bankCtrl,
              hintText: AppLocaleKey.selectTransferredBank.tr(),
              radius: 12,
              readOnly: true,
              onTap: _showBankPicker,
              prefixIcon: Icon(
                Icons.account_balance_outlined,
                color: AppColor.primaryColor(context),
                size: 20.sp,
              ),
              suffixIcon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColor.blackTextColor(context),
                size: 24.sp,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? AppLocaleKey.transferredBankRequired.tr()
                  : null,
            ),
            Gap(20.h),
            CalculatorBanner(
              onTap: () {
                if (_bankCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        context.locale.languageCode == 'ar'
                            ? 'يرجى اختيار البنك المحول إليه الراتب أولاً'
                            : 'Please select your salary transfer bank first',
                        textAlign: TextAlign.end,
                      ),
                      backgroundColor: AppColor.primaryColor(context, listen: false),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  );
                  _showBankPicker();
                  return;
                }
                widget.onShowCalculator();
              },
            ),
            Gap(16.h),
          ],
        ),
      ),
    );
  }
}
