import 'package:car/core/network/status.state.dart';
import 'package:car/features/agent/data/model/color_model.dart';
import 'package:car/features/agent/data/model/creat_offer_response_model.dart';
import 'package:car/features/agent/data/model/customer_model.dart';
import 'package:car/features/agent/data/model/customer_profile_model.dart';
import 'package:car/features/agent/data/model/offer_model.dart';
import 'package:equatable/equatable.dart' show Equatable;

class AgentState extends Equatable {
  final StatusState<List<CustomerModel>> customersStatus;
  final StatusState<List<ColorModel>> colorsStatus;
  final StatusState<List<OfferModel>> offersStatus;
  final StatusState<List<OfferModel>> externalOffersStatus;
  final StatusState<CreatOfferResponseModel> createOfferStatus;
  final StatusState<CreatOfferResponseModel> bookingPermissionStatus;
  final StatusState<CustomerProfileModel?> customerProfileStatus;
  final StatusState<OfferModel?> singleOfferStatus;

  const AgentState({
    this.customersStatus = const StatusState.initial(),
    this.colorsStatus = const StatusState.initial(),
    this.offersStatus = const StatusState.initial(),
    this.externalOffersStatus = const StatusState.initial(),
    this.createOfferStatus = const StatusState.initial(),
    this.bookingPermissionStatus = const StatusState.initial(),
    this.customerProfileStatus = const StatusState.initial(),
    this.singleOfferStatus = const StatusState.initial(),
  });

  AgentState copyWith({
    StatusState<List<CustomerModel>>? customersStatus,
    StatusState<List<ColorModel>>? colorsStatus,
    StatusState<List<OfferModel>>? offersStatus,
    StatusState<List<OfferModel>>? externalOffersStatus,
    StatusState<CreatOfferResponseModel>? createOfferStatus,
    StatusState<CreatOfferResponseModel>? bookingPermissionStatus,
    StatusState<CustomerProfileModel?>? customerProfileStatus,
    StatusState<OfferModel?>? singleOfferStatus,
  }) {
    return AgentState(
      customersStatus: customersStatus ?? this.customersStatus,
      colorsStatus: colorsStatus ?? this.colorsStatus,
      offersStatus: offersStatus ?? this.offersStatus,
      externalOffersStatus: externalOffersStatus ?? this.externalOffersStatus,
      createOfferStatus: createOfferStatus ?? this.createOfferStatus,
      bookingPermissionStatus:
          bookingPermissionStatus ?? this.bookingPermissionStatus,
      customerProfileStatus: customerProfileStatus ?? this.customerProfileStatus,
      singleOfferStatus: singleOfferStatus ?? this.singleOfferStatus,
    );
  }

  @override
  List<Object?> get props => [
    customersStatus,
    colorsStatus,
    offersStatus,
    externalOffersStatus,
    createOfferStatus,
    bookingPermissionStatus,
    customerProfileStatus,
    singleOfferStatus,
  ];
}
