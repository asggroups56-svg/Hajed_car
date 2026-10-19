part of 'home_cubit.dart';


class HomeState extends Equatable {
  final StatusState carsModelsStatus;
  final StatusState brandCarsStatus;
  final StatusState<List<GetBrandCarsDataModel>> filteredCarsStatus;
  final StatusState<List<GetBrandCarsDataModel>> allCarsStatus;
  final StatusState allPopularCarsStatus;
  final int? selectedBrandId;
  final int selectedIndex;
  final List<CarModel> brands;
  final String searchQuery;
  final StatusState<AddBookingPermissionResponseModel> addBookingPermissionResponseModel;
  final StatusState<CancelReservedCarResponseModel> cancelReservedCarResponseModel;
  final int? brandId;
  final String? fromMakeYear;
  final String? toMakeYear;
  final int? fromPrice;
  final int? toPrice;
  final String? fuelType;
  final StatusState<List<BANKSDATAModel>> banksStatus;
  final StatusState<SendOtpResponseModel> sendOtpStatus;
  final StatusState<List<FinancingAdModel>> financingAdsStatus;
  final StatusState<List<FinancingAdModel>> programCarsStatus;
  final StatusState<List<FinancingAdModel>> normalFinancingStatus;
  final StatusState<AddLoanApplicationResponseModel> addLoanApplicationStatus;
  final StatusState<List<CustomerLoanApplicationModel>> custLoanApplicationsStatus;
  final StatusState<List<NotificationModel>> notificationsStatus;
  final StatusState<SendWhatsAppResponseModel> sendWhatsAppStatus;
  final StatusState<SendWhatsAppResponseModel> sendWhatsAppPdfStatus;

  const HomeState({
    this.carsModelsStatus = const StatusState.initial(),
    this.brandCarsStatus = const StatusState.initial(),
    this.filteredCarsStatus = const StatusState.initial(),
    this.allCarsStatus = const StatusState.initial(),
    this.allPopularCarsStatus = const StatusState.initial(),
    this.banksStatus = const StatusState.initial(),
    this.selectedBrandId,
    this.selectedIndex = 0,
    this.searchQuery = '',
    this.brands = const [],
    this.addBookingPermissionResponseModel = const StatusState.initial(),
    this.brandId,
    this.fromMakeYear,
    this.toMakeYear,
    this.fromPrice,
    this.toPrice,
    this.fuelType,
    this.cancelReservedCarResponseModel = const StatusState.initial(),
    this.sendOtpStatus = const StatusState.initial(),
    this.financingAdsStatus = const StatusState.initial(),
    this.programCarsStatus = const StatusState.initial(),
    this.normalFinancingStatus = const StatusState.initial(),
    this.addLoanApplicationStatus = const StatusState.initial(),
    this.custLoanApplicationsStatus = const StatusState.initial(),
    this.notificationsStatus = const StatusState.initial(),
    this.sendWhatsAppStatus = const StatusState.initial(),
    this.sendWhatsAppPdfStatus = const StatusState.initial(),
  });

  HomeState copyWith({
    StatusState? carsModelsStatus,
    StatusState? brandCarsStatus,
    StatusState<List<GetBrandCarsDataModel>>? filteredCarsStatus,
    StatusState<List<GetBrandCarsDataModel>>? allCarsStatus,
    StatusState? allPopularCarsStatus,
    StatusState<List<BANKSDATAModel>>? banksStatus,
    int? selectedBrandId,
    int? selectedIndex,
    List<CarModel>? brands,
    String? searchQuery,
    StatusState<AddBookingPermissionResponseModel>? addBookingPermissionResponseModel,
    int? brandId,
    String? fromMakeYear,
    String? toMakeYear,
    int? fromPrice,
    int? toPrice,
    String? fuelType,
    StatusState<CancelReservedCarResponseModel>? cancelReservedCarResponseModel,
    StatusState<SendOtpResponseModel>? sendOtpStatus,
    StatusState<List<FinancingAdModel>>? financingAdsStatus,
    StatusState<List<FinancingAdModel>>? programCarsStatus,
    StatusState<List<FinancingAdModel>>? normalFinancingStatus,
    StatusState<AddLoanApplicationResponseModel>? addLoanApplicationStatus,
    StatusState<List<CustomerLoanApplicationModel>>? custLoanApplicationsStatus,
    StatusState<List<NotificationModel>>? notificationsStatus,
    StatusState<SendWhatsAppResponseModel>? sendWhatsAppStatus,
    StatusState<SendWhatsAppResponseModel>? sendWhatsAppPdfStatus,
  }) {
    return HomeState(
      carsModelsStatus: carsModelsStatus ?? this.carsModelsStatus,
      brandCarsStatus: brandCarsStatus ?? this.brandCarsStatus,
      filteredCarsStatus: filteredCarsStatus ?? this.filteredCarsStatus,
      allCarsStatus: allCarsStatus ?? this.allCarsStatus,
      allPopularCarsStatus: allPopularCarsStatus ?? this.allPopularCarsStatus,
      banksStatus: banksStatus ?? this.banksStatus,
      selectedBrandId: selectedBrandId ?? this.selectedBrandId,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      brands: brands ?? this.brands,
      searchQuery: searchQuery ?? this.searchQuery,
      addBookingPermissionResponseModel:
          addBookingPermissionResponseModel ?? this.addBookingPermissionResponseModel,
      brandId: brandId ?? this.brandId,
      fromMakeYear: fromMakeYear ?? this.fromMakeYear,
      toMakeYear: toMakeYear ?? this.toMakeYear,
      fromPrice: fromPrice ?? this.fromPrice,
      toPrice: toPrice ?? this.toPrice,
      fuelType: fuelType ?? this.fuelType,
      cancelReservedCarResponseModel:
          cancelReservedCarResponseModel ?? this.cancelReservedCarResponseModel,
      sendOtpStatus: sendOtpStatus ?? this.sendOtpStatus,
      financingAdsStatus: financingAdsStatus ?? this.financingAdsStatus,
      programCarsStatus: programCarsStatus ?? this.programCarsStatus,
      normalFinancingStatus: normalFinancingStatus ?? this.normalFinancingStatus,
      addLoanApplicationStatus: addLoanApplicationStatus ?? this.addLoanApplicationStatus,
      custLoanApplicationsStatus:
          custLoanApplicationsStatus ?? this.custLoanApplicationsStatus,
      notificationsStatus: notificationsStatus ?? this.notificationsStatus,
      sendWhatsAppStatus: sendWhatsAppStatus ?? this.sendWhatsAppStatus,
      sendWhatsAppPdfStatus: sendWhatsAppPdfStatus ?? this.sendWhatsAppPdfStatus,
    );
  }

  @override
  List<Object?> get props => [
    carsModelsStatus,
    brandCarsStatus,
    filteredCarsStatus,
    allCarsStatus,
    allPopularCarsStatus,
    banksStatus,
    selectedBrandId,
    selectedIndex,
    brands,
    searchQuery,
    addBookingPermissionResponseModel,
    brandId,
    fromMakeYear,
    toMakeYear,
    fromPrice,
    toPrice,
    fuelType,
    cancelReservedCarResponseModel,
    sendOtpStatus,
    financingAdsStatus,
    programCarsStatus,
    normalFinancingStatus,
    addLoanApplicationStatus,
    custLoanApplicationsStatus,
    notificationsStatus,
    sendWhatsAppStatus,
    sendWhatsAppPdfStatus,
  ];
}
