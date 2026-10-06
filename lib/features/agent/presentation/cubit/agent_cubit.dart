import 'package:car/core/network/status.state.dart';
import 'package:car/features/agent/data/model/creat_offer_model.dart';
import 'package:car/features/agent/data/repo/agent_repo.dart';
import 'package:car/features/agent/presentation/cubit/agent_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AgentCubit extends Cubit<AgentState> {
  final AgentRepo agentRepo;

  AgentCubit(this.agentRepo) : super(const AgentState());

  Future<void> getColors(String? searchVal) async {
    emit(state.copyWith(colorsStatus: const StatusState.loading()));
    final result = await agentRepo.getColors(searchVal);
    result.fold(
      (failure) {
        emit(state.copyWith(colorsStatus: StatusState.failure(failure.errMessage)));
      },
      (response) {
        emit(state.copyWith(colorsStatus: StatusState.success(response)));
      },
    );
  }

  Future<void> getCustomer(String? Searchval) async {
    emit(state.copyWith(customersStatus: const StatusState.loading()));
    final result = await agentRepo.getCustomer(Searchval);
    result.fold(
      (failure) {
        emit(state.copyWith(customersStatus: StatusState.failure(failure.errMessage)));
      },
      (response) {
        emit(state.copyWith(customersStatus: StatusState.success(response)));
      },
    );
  }

  Future<void> getOffers(String? Searchval, int REPRESNO, int? LISTNO) async {
    emit(state.copyWith(offersStatus: const StatusState.loading()));
    final result = await agentRepo.getOffers(Searchval, REPRESNO, LISTNO);
    result.fold(
      (failure) {
        emit(state.copyWith(offersStatus: StatusState.failure(failure.errMessage)));
      },
      (response) {
        emit(state.copyWith(offersStatus: StatusState.success(response)));
      },
    );
  }

  Future<void> getExternalOffers(String? searchVal, int represNo, int? listNo) async {
    emit(state.copyWith(externalOffersStatus: const StatusState.loading()));
    final result = await agentRepo.getExternalOffers(searchVal, represNo, listNo);
    result.fold(
      (failure) {
        emit(state.copyWith(externalOffersStatus: StatusState.failure(failure.errMessage)));
      },
      (response) {
        emit(state.copyWith(externalOffersStatus: StatusState.success(response)));
      },
    );
  }

  Future<void> getSingleOffer(int REPRESNO, int LISTNO) async {
    emit(state.copyWith(singleOfferStatus: const StatusState.loading()));
    final result = await agentRepo.getOffers(null, REPRESNO, LISTNO);
    result.fold(
      (failure) {
        emit(state.copyWith(singleOfferStatus: StatusState.failure(failure.errMessage)));
      },
      (response) {
        final offer = response.isNotEmpty ? response.first : null;
        emit(state.copyWith(singleOfferStatus: StatusState.success(offer)));
      },
    );
  }

  Future<void> addbookingpermission(CreatOfferModel offer) async {
    emit(state.copyWith(createOfferStatus: const StatusState.loading()));
    final result = await agentRepo.addbookingpermission(offer);
    result.fold(
      (failure) {
        emit(state.copyWith(createOfferStatus: StatusState.failure(failure.errMessage)));
      },
      (response) {
        emit(state.copyWith(createOfferStatus: StatusState.success(response)));
      },
    );
  }

  Future<void> addExternalofferprice(CreatOfferModel offer) async {
    emit(state.copyWith(createOfferStatus: const StatusState.loading()));
    final result = await agentRepo.addExternalofferprice(offer);
    result.fold(
      (failure) {
        emit(state.copyWith(createOfferStatus: StatusState.failure(failure.errMessage)));
      },
      (response) {
        emit(state.copyWith(createOfferStatus: StatusState.success(response)));
      },
    );
  }

  Future<void> getCustomerProfile(String code) async {
    emit(state.copyWith(customerProfileStatus: const StatusState.loading()));
    final result = await agentRepo.getCustomerProfile(code);
    result.fold(
      (failure) {
        emit(state.copyWith(customerProfileStatus: StatusState.failure(failure.errMessage)));
      },
      (profile) {
        emit(state.copyWith(customerProfileStatus: StatusState.success(profile)));
      },
    );
  }

  void resetCreateOfferStatus() {
    emit(state.copyWith(createOfferStatus: const StatusState.initial()));
  }

  void resetCustomerProfileStatus() {
    emit(state.copyWith(customerProfileStatus: const StatusState.initial()));
  }
}
