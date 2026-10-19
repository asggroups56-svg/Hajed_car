import 'dart:io';

import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/cars/presentation/widget/otp_bottom_sheet.dart';
import 'package:car/features/home/data/model/add_loan_application_model.dart';
import 'package:car/features/home/data/model/banks_data_model.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:car/features/home/data/model/financing_ad_model.dart';
import 'package:car/features/home/data/model/send_otp_model.dart';
import 'package:car/features/home/data/model/send_whatsapp_model.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:car/features/services/presentation/widgets/financing_bottom_bar.dart';
import 'package:car/features/services/presentation/widgets/financing_calculator_bottom_sheet.dart';
import 'package:car/features/services/presentation/widgets/financing_cancel_dialog.dart';
import 'package:car/features/services/presentation/widgets/financing_documents_tab.dart';
import 'package:car/features/services/presentation/widgets/financing_personal_info_tab.dart';
import 'package:car/features/services/presentation/widgets/financing_requirements_bottom_sheet.dart';
import 'package:car/features/services/presentation/widgets/financing_tab_bar.dart';
import 'package:car/features/services/presentation/widgets/financing_work_info_tab.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FinancingScreen extends StatefulWidget {
  final GetBrandCarsDataModel? car;
  final double? initialCarPrice;
  final bool initialPriceIncludesVat;
  final double? initialDownPayment;
  final double? initialLastPayment;
  final int? initialDuration;
  final String? bankNameKey;
  final FinancingAdModel? offer;
  final List<FinancingAdModel> offers;

  const FinancingScreen({
    super.key,
    this.car,
    this.initialCarPrice,
    this.initialPriceIncludesVat = false,
    this.initialDownPayment,
    this.initialLastPayment,
    this.initialDuration,
    this.bankNameKey,
    this.offer,
    this.offers = const [],
  });

  @override
  State<FinancingScreen> createState() => _FinancingScreenState();
}

class _FinancingScreenState extends State<FinancingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  // Personal Info Form
  final _fullNameCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _selectedGender = 'male';

  // Work Info Form
  final _employerCtrl = TextEditingController();
  final _jobTitleCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  String _employmentType = 'private';
  BANKSDATAModel? _selectedBank;

  // Documents
  Map<String, File?> _uploadedFiles = {};

  bool _hasReviewedCalculator = false;

  // OTP state
  String _phoneNumber = '';
  String? _expectedOtp;
  bool _isOtpSheetOpen = false;
  bool _isSendingOtp = false;
  bool _isSubmittingLoan = false;

  static const double _defaultApr = 4.5;

  late double _carPrice;
  int _durationYears = 5;
  double _downPayment = 0;
  double _lastPayment = 0;
  FinancingAdModel? _selectedOffer;

  FinancingAdModel? get _activeOffer => _selectedOffer ?? widget.offer;
  bool get _isOffer => _activeOffer != null;
  double get _apr {
    final userBank = _bankCtrl.text.trim();
    final offer = _activeOffer;
    if (offer != null && userBank.isNotEmpty) {
      final offerBank = offer.displayBankName ?? offer.bankName;
      final isSame = FinancingAdModel.isSameBankName(userBank, offerBank);
      if (!isSame && (offer.interestRateOther != null && offer.interestRateOther! > 0)) {
        return offer.interestRateOther!;
      }
    }
    return _activeOffer?.interestRate ?? _defaultApr;
  }
  double get _insurancePercent => double.tryParse(_activeOffer?.InsurancePct ?? '0') ?? 0;

  double get _financedAmount {
    final financed = _carPrice - _downPayment;
    return financed > 0 ? financed : 0;
  }

  double get _totalInterest {
    return _financedAmount * (_apr / 100) * _durationYears;
  }

  double get _totalInsurance {
    return _financedAmount * (_insurancePercent / 100) * _durationYears;
  }

  double get _totalFinancedWithInterest {
    return _financedAmount + _totalInterest + _totalInsurance;
  }

  double get _monthlyInstallment {
    final total = _totalFinancedWithInterest;
    if (total <= 0 || _durationYears <= 0) return 0;
    final remaining = total - _lastPayment;
    return remaining > 0 ? (remaining / (_durationYears * 12)) : 0;
  }

  @override
  void initState() {
    super.initState();
    _fullNameCtrl.text = HiveMethods.getname() ?? '';
    _phoneCtrl.text = HiveMethods.getphone() ?? '';

    _selectedOffer = widget.offer ?? (widget.offers.isNotEmpty ? widget.offers.first : null);
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        if (mounted) setState(() {});
      });

    final raw = widget.car?.price?.toString() ?? '150000';
    final basePrice =
        widget.initialCarPrice ??
        (double.tryParse(raw.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 150000);
    final vatPercentage = double.tryParse(HiveMethods.getVatNumber()?.toString() ?? '') ?? 15.0;
    final double platesVal = widget.car?.paintingsVal ?? 0.0;
    final double priceWithFee = basePrice + 3000;
    final double priceWithVat =
        widget.initialPriceIncludesVat ? priceWithFee : priceWithFee * (1 + vatPercentage / 100);
    _carPrice = priceWithVat + platesVal;

    _downPayment =
        widget.initialDownPayment ?? (_carPrice * ((_activeOffer?.firstInstallmentPct ?? 0) / 100));
    _durationYears = (widget.initialDuration ?? ((_activeOffer?.totalMonths ?? 60) / 12).round())
        .clamp(1, 5);
    _lastPayment =
        widget.initialLastPayment ?? (_carPrice * ((_activeOffer?.lastInstallmentPct ?? 0) / 100));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeCubit = context.read<HomeCubit>();
      if (homeCubit.state.banksStatus.data == null || homeCubit.state.banksStatus.data!.isEmpty) {
        homeCubit.getBanks();
      }
      if (homeCubit.state.normalFinancingStatus.data == null ||
          homeCubit.state.normalFinancingStatus.data!.isEmpty) {
        homeCubit.getNormalFinancing();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fullNameCtrl.dispose();
    _idCtrl.dispose();
    _phoneCtrl.dispose();
    _employerCtrl.dispose();
    _jobTitleCtrl.dispose();
    _salaryCtrl.dispose();
    _bankCtrl.dispose();
    super.dispose();
  }

  void _showRequirementsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (ctx, scrollController) => const FinancingRequirementsBottomSheet(),
      ),
    );
  }

  Future<bool> _showCalculatorSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.92,
          maxChildSize: 0.97,
          minChildSize: 0.5,
          builder: (ctx, scrollController) => FinancingCalculatorBottomSheet(
            carPrice: _carPrice,
            initialDownPayment: _downPayment,
            initialLastPayment: _lastPayment,
            initialDuration: _durationYears,
            interestRate: _isOffer ? _apr : null,
            isOffer: _isOffer,
            bankName: _activeOffer?.displayBankName,
            firstInstallmentPct: _activeOffer?.firstInstallmentPct,
            lastInstallmentPct: _activeOffer?.lastInstallmentPct,
            adminFeesPct: _activeOffer?.adminFeesPct,
            userSalaryBank: _bankCtrl.text.trim(),
            offers: widget.offers,
            initialOffer: _activeOffer,
          ),
        ),
      ),
    );

    if (!mounted) return false;

    if (result != null) {
      setState(() {
        _hasReviewedCalculator = true;
        _durationYears = result['duration'] ?? _durationYears;
        _downPayment = (result['down'] as num?)?.toDouble() ?? _downPayment;
        _lastPayment = (result['last'] as num?)?.toDouble() ?? _lastPayment;
        if (result['offer'] is FinancingAdModel) {
          _selectedOffer = result['offer'];
        }
      });
      return true;
    }
    return false;
  }

  Future<void> _onNextStep() async {
    final current = _tabController.index;

    if (current == 0) {
      if (!(_formKey1.currentState?.validate() ?? false)) return;
      _phoneNumber = _phoneCtrl.text;
      context.read<HomeCubit>().sendOtp(SendOtpModel(mobileNumber: _phoneNumber));
    } else if (current == 1) {
      if (!(_formKey2.currentState?.validate() ?? false)) return;
      if (!_hasReviewedCalculator) {
        final confirmed = await _showCalculatorSheet();
        if (confirmed && current < 2) {
          _tabController.animateTo(current + 1);
        } else if (!confirmed) {
          _showSnack(AppLocaleKey.pleaseConfirmFinancing.tr());
        }
      } else {
        if (current < 2) _tabController.animateTo(current + 1);
      }
    } else if (current == 2) {
      final requiredDocs = FinancingDocumentsTab.requiredDocuments;
      final missingDocs = requiredDocs.where((doc) => _uploadedFiles[doc] == null).toList();
      if (missingDocs.isNotEmpty) {
        _showSnack('يرجى رفع المستندات المطلوبة للمتابعة (${missingDocs.first})');
        return;
      }
      _submitLoanApplication();
    }
  }

  void _submitLoanApplication() {
    final double workTypeValue = _employmentType == 'government'
        ? 2.0
        : (_employmentType == 'self' ? 3.0 : 1.0);

    final int genderValue = _selectedGender == 'female' ? 2 : 1;

    final String makeYearStr = widget.car?.makeYear.toString() ?? DateTime.now().year.toString();

    final int customerNoVal = int.tryParse(HiveMethods.getcode() ?? '') ?? 0;

    // ── Guard: validate required server fields before sending ──
    if (customerNoVal == 0) {
      _showSnack(
        context.locale.languageCode == 'ar'
            ? 'خطأ: رقم العميل غير موجود، يرجى تسجيل الخروج وإعادة الدخول'
            : 'Error: Customer number not found, please log out and log in again',
      );
      return;
    }
    final salary = double.tryParse(_salaryCtrl.text.trim()) ?? 0.0;
    if (salary <= 0) {
      _showSnack(
        context.locale.languageCode == 'ar'
            ? 'يرجى إدخال الراتب الشهري بشكل صحيح'
            : 'Please enter a valid monthly salary',
      );
      return;
    }
    if (_idCtrl.text.trim().isEmpty) {
      _showSnack(
        context.locale.languageCode == 'ar'
            ? 'يرجى إدخال رقم الهوية'
            : 'Please enter your ID number',
      );
      return;
    }

    final bank = _bankCtrl.text.trim();
    final baseProgramName =
        _activeOffer?.programName ?? _activeOffer?.displayBankName ?? 'Auto Finance Premium';
    final programNameWithBank = bank.isNotEmpty
        ? '$baseProgramName | البنك المحول له: $bank'
        : baseProgramName;

    final int repCode = int.tryParse(HiveMethods.getRepresentativeNo() ?? '') ?? 0;
    final int bankCode = _selectedBank?.bankCode ?? int.tryParse(_bankCtrl.text.trim()) ?? 1;

    final model = AddLoanApplicationModel(
      applicationId: 0,
      programId: _activeOffer?.programId ?? 3,
      programName: programNameWithBank,
      customerNo: customerNoVal,
      REPRESCODE: repCode > 0 ? repCode : 1,
      idNo: _idCtrl.text.trim(),
      areaNo: '1',
      groupCode: (widget.car?.groupCode != null && widget.car!.groupCode > 0)
          ? widget.car!.groupCode.toString()
          : '100710131',
      itemCode: widget.car?.itemCode ?? '',
      itemName: widget.car?.itemName ?? '',
      makeYear: makeYearStr,
      colorCode: (widget.car?.colorCode != null && widget.car!.colorCode > 0)
          ? widget.car!.colorCode
          : 1,
      salePrice: _carPrice,
      workType: workTypeValue,
      employer: _employerCtrl.text.trim(),
      jobTitle: _jobTitleCtrl.text.trim(),
      monthlySalary: double.tryParse(_salaryCtrl.text.trim()) ?? 0.0,
      bank: bankCode,
      termMonths: _durationYears * 12,
      downPayment: _downPayment,
      lastPayment: _lastPayment,
      loanAmount: _financedAmount,
      monthlyInstallment: _monthlyInstallment,
      applicationStatus: 0,
      gender: genderValue,
    );

    final filesList = _uploadedFiles.values.whereType<File>().toList();

    context.read<HomeCubit>().addLoanApplicationWithFiles(model: model, files: filesList);
  }

  void _showOtpSheet() {
    if (_isOtpSheetOpen) return;
    _isOtpSheetOpen = true;
    final homeCubit = context.read<HomeCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: OtpBottomSheet(
            phoneNumber: _phoneNumber,
            homeCubit: homeCubit,
            expectedOtp: _expectedOtp,
            onVerified: () {
              Navigator.pop(ctx);
              _tabController.animateTo(1);
            },
          ),
        ),
      ),
    ).then((_) {
      _isOtpSheetOpen = false;
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.end),
        backgroundColor: AppColor.primaryColor(context, listen: false),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }

  Future<void> _showCancelDialog() async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CancelDialog(context: ctx),
    );
    if (shouldCancel == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<HomeCubit, HomeState>(
          listenWhen: (prev, curr) => prev.sendOtpStatus != curr.sendOtpStatus,
          listener: (context, state) {
            final status = state.sendOtpStatus;
            if (status.isLoading) {
              setState(() => _isSendingOtp = true);
            } else {
              setState(() => _isSendingOtp = false);
              if (status.isSuccess && status.data != null) {
                _expectedOtp = status.data!.message;
                if (status.data!.success) {
                  _showOtpSheet();
                }
              }
            }
          },
        ),
        BlocListener<HomeCubit, HomeState>(
          listenWhen: (prev, curr) =>
              prev.addLoanApplicationStatus != curr.addLoanApplicationStatus,
          listener: (context, state) {
            final status = state.addLoanApplicationStatus;
            if (status.isLoading) {
              setState(() => _isSubmittingLoan = true);
            } else if (status.isFailure) {
              setState(() => _isSubmittingLoan = false);
              _showSnack(status.error ?? 'حدث خطأ أثناء تقديم طلب التمويل');
            } else if (status.isSuccess && status.data != null) {
              setState(() => _isSubmittingLoan = false);
              final phone = _phoneCtrl.text.trim();
              final bank = _bankCtrl.text.trim();
              final textMsg =
                  'طلب تمويل جديد: ${_activeOffer?.programName ?? _activeOffer?.displayBankName ?? "برنامج التمويل"}\n'
                  'السيارة: ${widget.car?.itemName ?? "غير محدد"}\n'
                  'سعر السيارة الكاش :  ${_carPrice.toStringAsFixed(2)} ر.س\n'
                  'مبلغ التمويل: ${_financedAmount.toStringAsFixed(2)} ر.س\n'
                  'القسط الشهري: ${_monthlyInstallment.toStringAsFixed(2)} ر.س\n'
                  'الدفعة الأولى: ${_downPayment.toStringAsFixed(2)} ر.س\n'
                  'الدفعة الأخيرة: ${_lastPayment.toStringAsFixed(2)} ر.س\n'
                  'عدد السنوات: $_durationYears\n'
                  'اسم العميل: ${_fullNameCtrl.text.trim()}\n'
                  'رقم الهوية: ${_idCtrl.text.trim()}\n'
                  'رقم التواصل: $phone\n'
                  'جهة العمل: ${_employerCtrl.text.trim()}\n'
                  'المسمى الوظيفي: ${_jobTitleCtrl.text.trim()}\n'
                  'الراتب الشهري: ${_salaryCtrl.text.trim()} ر.س\n'
                  'البنك المحول له: ${bank.isNotEmpty ? bank : "غير محدد"}';

              context.read<HomeCubit>().sendWhatsApp(
                SendWhatsAppModel(toNumber: phone, text: textMsg),
              );

              final msg = status.data!.msg.isNotEmpty
                  ? status.data!.msg
                  : AppLocaleKey.requestSubmittedSuccess.tr();
              _showSnack(msg);
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) Navigator.of(context).pop();
              });
            }
          },
        ),
      ],
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showCancelDialog();
      },
      child: Scaffold(
        backgroundColor: AppColor.scaffoldColor(context),
        appBar: _buildAppBar(),
        body: SafeArea(
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              FinancingPersonalInfoTab(
                formKey: _formKey1,
                car: widget.car?.toMap(),
                monthlyInstallment: _monthlyInstallment,
                durationYears: _durationYears,
                downPayment: _downPayment,
                lastPayment: _lastPayment,
                bankName: _activeOffer?.displayBankName,
                onEditCalculator: () => _showCalculatorSheet(),
                onShowRequirements: _showRequirementsSheet,
                onPhoneChanged: (phone) => _phoneNumber = phone,
                fullNameCtrl: _fullNameCtrl,
                idCtrl: _idCtrl,
                phoneCtrl: _phoneCtrl,
                selectedGender: _selectedGender,
                onGenderChanged: (g) => setState(() => _selectedGender = g ?? 'male'),
              ),
              FinancingWorkInfoTab(
                formKey: _formKey2,
                onShowCalculator: () => _showCalculatorSheet(),
                employerCtrl: _employerCtrl,
                jobTitleCtrl: _jobTitleCtrl,
                salaryCtrl: _salaryCtrl,
                bankCtrl: _bankCtrl,
                employmentType: _employmentType,
                onEmploymentTypeChanged: (t) => setState(() => _employmentType = t ?? 'private'),
                onBankSelected: (bank) => setState(() => _selectedBank = bank),
              ),
              FinancingDocumentsTab(
                uploadedFiles: _uploadedFiles,
                onFilesChanged: (files) => setState(() => _uploadedFiles = files),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(bottom: 20.r),
          child: FinancingBottomBar(
            currentIndex: _tabController.index,
            isLoading: _isSendingOtp || _isSubmittingLoan,
            onNext: _onNextStep,
            onBack: () => _tabController.animateTo(_tabController.index - 1),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColor.appBarColor(context),
      elevation: 0,
      centerTitle: true,
      leading: const SizedBox.shrink(),
      title: Text(
        AppLocaleKey.personalInfo.tr(),
        style: AppTextStyle.titleMedium(
          context,
        ).copyWith(fontWeight: FontWeight.w900, color: AppColor.primaryColor(context)),
      ),
      actions: [
        TextButton(
          onPressed: _showCancelDialog,
          child: Text(
            AppLocaleKey.cancel.tr(),
            style: AppTextStyle.bodyMedium(
              context,
            ).copyWith(color: AppColor.greyColor(context), fontWeight: FontWeight.bold),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(48.h),
        child: FinancingTabBar(controller: _tabController),
      ),
    );
  }
}
