import 'package:equatable/equatable.dart';

class AddLoanApplicationModel extends Equatable {
  final int applicationId;
  final int programId;
  final String programName;
  final int customerNo;
  final String idNo;
  final String? areaNo;
  final String itemCode;
  final String itemName;
  final String makeYear;
  final double salePrice;
  final double workType;
  final String employer;
  final String jobTitle;
  final double monthlySalary;
  final int termMonths;
  final double downPayment;
  final double lastPayment;
  final double loanAmount;
  final double monthlyInstallment;
  final int applicationStatus;
  final int gender;
  final int REPRESCODE;
  final int? bank;
  final String? groupCode;
  final int? colorCode;

  const AddLoanApplicationModel({
    this.applicationId = 0,
    required this.programId,
    required this.programName,
    required this.customerNo,
    required this.idNo,
    this.areaNo,
    required this.itemCode,
    required this.itemName,
    required this.makeYear,
    required this.salePrice,
    required this.workType,
    required this.employer,
    required this.jobTitle,
    required this.monthlySalary,
    required this.termMonths,
    required this.downPayment,
    required this.lastPayment,
    required this.loanAmount,
    required this.monthlyInstallment,
    this.applicationStatus = 0,
    required this.gender,
    required this.REPRESCODE,
    this.bank,
    this.groupCode,
    this.colorCode,
  });

  static double _round2(double val) {
    return double.parse(val.toStringAsFixed(2));
  }

  static String _getAreaNo(String cityName) {
    if (cityName.isEmpty) return '1';
    if (cityName.contains('رياض') || cityName.toLowerCase().contains('riyadh')) return '1';
    if (cityName.contains('جدة') || cityName.toLowerCase().contains('jeddah')) return '2';
    if (cityName.contains('مكة') || cityName.toLowerCase().contains('mecca')) return '3';
    if (cityName.contains('مدين') || cityName.toLowerCase().contains('medina')) return '4';
    if (cityName.contains('دمام') || cityName.toLowerCase().contains('dammam')) return '5';
    if (cityName.contains('خبر') || cityName.toLowerCase().contains('khobar')) return '6';
    if (cityName.contains('ظهران') || cityName.toLowerCase().contains('dhahran')) return '7';
    if (cityName.contains('أبها') ||
        cityName.contains('ابها') ||
        cityName.toLowerCase().contains('abha'))
      return '8';
    if (cityName.contains('تبوك') || cityName.toLowerCase().contains('tabuk')) return '9';
    if (cityName.contains('بريد') || cityName.toLowerCase().contains('buraidah')) return '10';
    if (cityName.contains('حائل') || cityName.toLowerCase().contains('hail')) return '11';
    if (cityName.contains('نجران') || cityName.toLowerCase().contains('najran')) return '12';
    if (cityName.contains('جازان') || cityName.toLowerCase().contains('jazan')) return '13';
    if (cityName.contains('طائف') || cityName.toLowerCase().contains('taif')) return '14';
    if (cityName.contains('جبيل') || cityName.toLowerCase().contains('jubail')) return '15';
    if (int.tryParse(cityName) != null) return cityName;
    return '1';
  }

  Map<String, dynamic> toJson() {
    return {
      'ApplicationID': applicationId,
      'ProgramID': programId,
      'ProgramName': programName,
      'CUSTOMERNO': customerNo,
      'REPRESCODE': REPRESCODE != 0 ? REPRESCODE : 1,
      'IDNO': idNo,
      'AREANO': _getAreaNo(areaNo ?? ''),
      'GroupCode': groupCode ?? '',
      'ITEMCODE': itemCode.toString(),
      'ITEMNAME': itemName,
      'MAKEYEAR': makeYear.toString(),
      'colorcode': colorCode ?? 1,
      'SALEPRICE': _round2(salePrice),
      'WorkType': workType.toInt(),
      'Employer': employer,
      'Jobtitle': jobTitle,
      'monthlysalary': _round2(monthlySalary),
      'Bank': bank ?? 1,
      'TermMonths': termMonths,
      'DownPayment': _round2(downPayment),
      'lastPayment': _round2(lastPayment),
      'LoanAmount': _round2(loanAmount),
      'MonthlyInstallment': _round2(monthlyInstallment),
      'ApplicationStatus': applicationStatus,
      'Gender': gender,
    };
  }

  factory AddLoanApplicationModel.fromJson(Map<String, dynamic> json) {
    return AddLoanApplicationModel(
      applicationId: json['ApplicationID'] ?? 0,
      programId: json['ProgramID'] ?? 0,
      programName: json['ProgramName'] ?? '',
      customerNo: json['CUSTOMERNO'] ?? 0,
      REPRESCODE: json['REPRESCODE'] ?? 0,
      idNo: json['IDNO'] ?? '',
      areaNo: json['AREANO']?.toString() ?? '1',
      groupCode: json['GroupCode']?.toString(),
      itemCode: json['ITEMCODE'] ?? '',
      itemName: json['ITEMNAME'] ?? '',
      makeYear: json['MAKEYEAR']?.toString() ?? '',
      colorCode: (json['colorcode'] as num?)?.toInt(),
      salePrice: (json['SALEPRICE'] as num?)?.toDouble() ?? 0.0,
      workType: (json['WorkType'] as num?)?.toDouble() ?? 1.0,
      employer: json['Employer'] ?? '',
      jobTitle: json['Jobtitle'] ?? '',
      monthlySalary: (json['monthlysalary'] as num?)?.toDouble() ?? 0.0,
      bank: (json['Bank'] as num?)?.toInt(),
      termMonths: json['TermMonths'] ?? 0,
      downPayment: (json['DownPayment'] as num?)?.toDouble() ?? 0.0,
      lastPayment: (json['lastPayment'] as num?)?.toDouble() ?? 0.0,
      loanAmount: (json['LoanAmount'] as num?)?.toDouble() ?? 0.0,
      monthlyInstallment: (json['MonthlyInstallment'] as num?)?.toDouble() ?? 0.0,
      applicationStatus: json['ApplicationStatus'] ?? 0,
      gender: json['Gender'] ?? 1,
    );
  }

  @override
  List<Object?> get props => [
    applicationId,
    programId,
    programName,
    customerNo,
    REPRESCODE,
    idNo,
    areaNo,
    groupCode,
    itemCode,
    itemName,
    makeYear,
    colorCode,
    salePrice,
    workType,
    employer,
    jobTitle,
    monthlySalary,
    bank,
    termMonths,
    downPayment,
    lastPayment,
    loanAmount,
    monthlyInstallment,
    applicationStatus,
    gender,
  ];
}
