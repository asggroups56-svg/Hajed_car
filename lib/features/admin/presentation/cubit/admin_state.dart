import 'package:car/core/network/status.state.dart';
import 'package:car/features/admin/data/model/cars_response_model.dart';
import 'package:car/features/admin/data/model/customer_model.dart';
import 'package:car/features/admin/data/model/representative_model.dart';
import 'package:car/features/admin/data/model/stock_statistics_model.dart';
import 'package:equatable/equatable.dart';

class AdminState extends Equatable {
  final StatusState<List<StockStatisticsModel>> getCarsCountStatus;
  final StatusState<CarsModel> getCarsStatus;
  final StatusState<List<RepresentativeModel>> searchRepresentativesStatus;
  final StatusState<List<CustomerModel>> searchCustomersStatus;
  final StatusState<List<CustomerModel>> searchSuppliersStatus;
  const AdminState({
    this.getCarsCountStatus = const StatusState.initial(),
    this.getCarsStatus = const StatusState.initial(),
    this.searchRepresentativesStatus = const StatusState.initial(),
    this.searchCustomersStatus = const StatusState.initial(),
    this.searchSuppliersStatus = const StatusState.initial(),
  });
  AdminState copyWith({
    StatusState<List<StockStatisticsModel>>? getCarsCountStatus,
    StatusState<CarsModel>? getCarsStatus,
    StatusState<List<RepresentativeModel>>? searchRepresentativesStatus,
    StatusState<List<CustomerModel>>? searchCustomersStatus,
    StatusState<List<CustomerModel>>? searchSuppliersStatus,
  }) {
    return AdminState(
      getCarsCountStatus: getCarsCountStatus ?? this.getCarsCountStatus,
      getCarsStatus: getCarsStatus ?? this.getCarsStatus,
      searchRepresentativesStatus: searchRepresentativesStatus ?? this.searchRepresentativesStatus,
      searchCustomersStatus: searchCustomersStatus ?? this.searchCustomersStatus,
      searchSuppliersStatus: searchSuppliersStatus ?? this.searchSuppliersStatus,
    );
  }

  @override
  List<Object?> get props => [
    getCarsCountStatus,
    getCarsStatus,
    searchRepresentativesStatus,
    searchCustomersStatus,
    searchSuppliersStatus,
  ];
}
