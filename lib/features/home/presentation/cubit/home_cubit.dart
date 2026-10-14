import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:car/core/network/status.state.dart';
import 'package:car/features/home/data/model/add_booking_permission_model.dart';
import 'package:car/features/home/data/model/add_booking_permission_response_model.dart';
import 'package:car/features/home/data/model/add_loan_application_model.dart';
import 'package:car/features/home/data/model/add_loan_application_response_model.dart';
import 'package:car/features/home/data/model/banks_data_model.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:car/features/home/data/model/cancel_reserved_car_model.dart';
import 'package:car/features/home/data/model/cancel_reserved_car_response_model.dart';
import 'package:car/features/home/data/model/cars_models_response.dart';
import 'package:car/features/home/data/model/customer_loan_application_model.dart';
import 'package:car/features/home/data/model/financing_ad_model.dart';
import 'package:car/features/home/data/model/send_otp_model.dart';
import 'package:car/features/home/data/model/send_otp_response_model.dart';
import 'package:car/features/home/data/model/send_whatsapp_model.dart';
import 'package:car/features/home/data/repository/home_repo.dart';
import 'package:car/features/notifications/data/model/notification_model.dart';
import 'package:equatable/equatable.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepo homeRepo;
  String? lastEditLoanMessage;
  bool _isRefreshingHome = false;

  HomeCubit(this.homeRepo) : super(const HomeState());

  /// Reloads every data source shown on the home screen.
  ///
  /// Keeping this in the cubit makes an initial load and an app-resume load
  /// behave identically, while preventing overlapping refresh requests.
  Future<void> refreshHomeData() async {
    if (_isRefreshingHome) return;

    _isRefreshingHome = true;
    try {
      await Future.wait([
        getCarsModels(),
        getBanks(),
        fetchAllCars(),
        getFinancingAds(),
        getNormalFinancing(),
      ]);
    } finally {
      _isRefreshingHome = false;
    }
  }

  Future<void> getCarsModels() async {
    emit(state.copyWith(carsModelsStatus: const StatusState.loading()));

    final result = await homeRepo.getCarsModels();

    await result.fold<Future<void>>(
      (failure) async {
        emit(
          state.copyWith(
            carsModelsStatus: StatusState.failure(failure.errMessage),
          ),
        );
      },
      (response) async {
        dynamic data = response.cars;

        if (data is String) {
          data = jsonDecode(data);
        }

        List<CarModel> fetchedBrands = [];

        if (data is List<CarModel>) {
          fetchedBrands = data;
        } else if (data is List) {
          fetchedBrands = data.map((e) {
            if (e is CarModel) return e;
            return CarModel.fromJson(e);
          }).toList();
        }

        emit(
          state.copyWith(
            carsModelsStatus: StatusState.success(fetchedBrands),
            brands: fetchedBrands,
          ),
        );

        if (fetchedBrands.isNotEmpty) {
          // Always start the refreshed home screen with the first brand and
          // wait for its cars, so the selected category never appears empty.
          await getBrandCars(fetchedBrands.first.groupCode.toString());
          await fetchAllBrandsCars(fetchedBrands);
        }
      },
    );
  }

  Future<void> fetchAllBrandsCars(List<CarModel> brands) async {
    if (state.allPopularCarsStatus.isLoading) return;

    emit(state.copyWith(allPopularCarsStatus: const StatusState.loading()));

    final Map<String, List<GetBrandCarsDataModel>> allCarsMap = {};

    final brandsToFetch = brands.take(12).toList();

    final results = await Future.wait(
      brandsToFetch.map((b) => homeRepo.getBrandCars(b.groupCode.toString())),
    );

    for (int i = 0; i < results.length; i++) {
      final result = results[i];
      final brandName = brandsToFetch[i].groupName;

      result.fold((_) {}, (carsList) {
        allCarsMap[brandName] = carsList;
      });
    }

    emit(state.copyWith(allPopularCarsStatus: StatusState.success(allCarsMap)));
  }

  Future<void> getBrandCars(String brandId) async {
    if (brandId == 'null' || brandId.isEmpty) {
      emit(
        state.copyWith(
          brandCarsStatus: const StatusState.success([]),
          selectedBrandId: null,
        ),
      );
      return;
    }

    final brandIdInt = int.tryParse(brandId);
    int newSelectedIndex = state.selectedIndex;
    if (state.brands.isNotEmpty && brandIdInt != null) {
      final idx = state.brands.indexWhere((b) => b.groupCode == brandIdInt);
      if (idx != -1) {
        newSelectedIndex = idx;
      }
    }

    emit(
      state.copyWith(
        brandCarsStatus: const StatusState.loading(),
        selectedBrandId: brandIdInt,
        selectedIndex: newSelectedIndex,
      ),
    );

    final result = await homeRepo.getBrandCars(brandId);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            brandCarsStatus: StatusState.failure(failure.errMessage),
          ),
        );
      },
      (response) {
        emit(state.copyWith(brandCarsStatus: StatusState.success(response)));
      },
    );
  }

  Future<void> fetchAllCars({
    int? brandId,
    String? fromMakeYear,
    String? toMakeYear,
    int? fromPrice,
    int? toPrice,
    String? fuelType,
  }) async {
    emit(
      state.copyWith(
        allCarsStatus: const StatusState.loading(),
        brandId: brandId,
        fromMakeYear: fromMakeYear,
        toMakeYear: toMakeYear,
        fromPrice: fromPrice,
        toPrice: toPrice,
        fuelType: fuelType,
      ),
    );
    final result = await homeRepo.fetchAllCars(
      brandId,
      fromMakeYear,
      toMakeYear,
      fromPrice,
      toPrice,
      fuelType,
    );
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            allCarsStatus: StatusState.failure(failure.errMessage),
          ),
        );
      },
      (response) {
        emit(state.copyWith(allCarsStatus: StatusState.success(response)));
      },
    );
  }

  void selectBrand(int index, String brandId) {
    emit(
      state.copyWith(
        selectedIndex: index,
        selectedBrandId: int.tryParse(brandId),
      ),
    );
    unawaited(getBrandCars(brandId));
  }

  List<CarModel> getFilteredBrands(List<CarModel> brands, String query) {
    if (query.isEmpty) return brands;
    return brands
        .where((b) => b.groupName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void updateSearchQuery(String value) {
    emit(state.copyWith(searchQuery: value));
  }

  Future<void> getAddBookingPermission(AddBookingPermissionModel model) async {
    emit(
      state.copyWith(
        addBookingPermissionResponseModel: const StatusState.loading(),
      ),
    );
    final result = await homeRepo.addBookingPermission(model);
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            addBookingPermissionResponseModel: StatusState.failure(
              failure.errMessage,
              statusCode: failure.statusCode,
            ),
          ),
        );
      },
      (response) {
        emit(
          state.copyWith(
            addBookingPermissionResponseModel: StatusState.success(response),
          ),
        );
      },
    );
  }

  Future<void> cancelReservedCar(CancelReservedCarModel model) async {
    emit(
      state.copyWith(
        cancelReservedCarResponseModel: const StatusState.loading(),
      ),
    );
    final result = await homeRepo.cancelreservedcar(model);
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            cancelReservedCarResponseModel: StatusState.failure(
              failure.errMessage,
            ),
          ),
        );
      },
      (response) {
        emit(
          state.copyWith(
            cancelReservedCarResponseModel: StatusState.success(response),
          ),
        );
      },
    );
  }

  Future<void> sendOtp(SendOtpModel model) async {
    emit(state.copyWith(sendOtpStatus: const StatusState.loading()));
    final result = await homeRepo.sendOtp(model);
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            sendOtpStatus: StatusState.failure(failure.errMessage),
          ),
        );
      },
      (response) {
        emit(state.copyWith(sendOtpStatus: StatusState.success(response)));
      },
    );
  }

  Future<void> getBanks({String? searchVal}) async {
    emit(state.copyWith(banksStatus: const StatusState.loading()));
    final result = await homeRepo.getBanks(searchVal);
    result.fold(
      (failure) {
        emit(
          state.copyWith(banksStatus: StatusState.failure(failure.errMessage)),
        );
      },
      (response) {
        emit(state.copyWith(banksStatus: StatusState.success(response)));
      },
    );
  }

  Future<void> getFinancingAds({String? code}) async {
    final isSpecificProgram = code != null && code.isNotEmpty;
    if (isSpecificProgram) {
      emit(state.copyWith(programCarsStatus: const StatusState.loading()));
    } else {
      emit(state.copyWith(financingAdsStatus: const StatusState.loading()));
    }

    final result = await homeRepo.getFinancingAds(code: code);

    result.fold(
      (failure) {
        if (isSpecificProgram) {
          emit(
            state.copyWith(
              programCarsStatus: StatusState.failure(failure.errMessage),
            ),
          );
        } else {
          emit(
            state.copyWith(
              financingAdsStatus: StatusState.failure(failure.errMessage),
            ),
          );
        }
      },
      (response) {
        if (isSpecificProgram) {
          emit(
            state.copyWith(programCarsStatus: StatusState.success(response)),
          );
        } else {
          emit(
            state.copyWith(financingAdsStatus: StatusState.success(response)),
          );
        }
      },
    );
  }

  Future<void> getNormalFinancing() async {
    emit(state.copyWith(normalFinancingStatus: const StatusState.loading()));
    final result = await homeRepo.getNormalFinancing();
    result.fold(
      (failure) => emit(
        state.copyWith(
          normalFinancingStatus: StatusState.failure(failure.errMessage),
        ),
      ),
      (response) => emit(
        state.copyWith(normalFinancingStatus: StatusState.success(response)),
      ),
    );
  }

  void clearProgramCarsFilter() {
    emit(state.copyWith(programCarsStatus: const StatusState.initial()));
  }

  Future<void> addLoanApplicationWithFiles({
    required AddLoanApplicationModel model,
    required List<File> files,
  }) async {
    emit(state.copyWith(addLoanApplicationStatus: const StatusState.loading()));
    final result = await homeRepo.addLoanApplicationWithFiles(
      model: model,
      files: files,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          addLoanApplicationStatus: StatusState.failure(failure.errMessage),
        ),
      ),
      (response) => emit(
        state.copyWith(addLoanApplicationStatus: StatusState.success(response)),
      ),
    );
  }

  Future<void> getCustLoanApplications(String code) async {
    emit(
      state.copyWith(custLoanApplicationsStatus: const StatusState.loading()),
    );
    final result = await homeRepo.getCustLoanApplications(code);
    result.fold(
      (failure) => emit(
        state.copyWith(
          custLoanApplicationsStatus: StatusState.failure(failure.errMessage),
        ),
      ),
      (response) => emit(
        state.copyWith(
          custLoanApplicationsStatus: StatusState.success(response),
        ),
      ),
    );
  }

  Future<void> getNotificationsData({
    required String currentUserId,
    required int userType,
  }) async {
    emit(state.copyWith(notificationsStatus: const StatusState.loading()));
    final result = await homeRepo.getNotificationsData(
      currentUserId: currentUserId,
      userType: userType,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          notificationsStatus: StatusState.failure(failure.errMessage),
        ),
      ),
      (response) => emit(
        state.copyWith(notificationsStatus: StatusState.success(response)),
      ),
    );
  }

  Future<String?> editBooking({
    required int represCode,
    required int lpoNo,
    required int customerNo,
    required int notifyId,
  }) async {
    lastEditLoanMessage = null;
    final result = await homeRepo.editBooking(
      represCode: represCode,
      lpoNo: lpoNo,
      customerNo: customerNo,
      notifyId: notifyId,
    );
    return result.fold(
      (failure) {
        lastEditLoanMessage = failure.errMessage;
        return null;
      },
      (message) {
        lastEditLoanMessage = message;
        return message;
      },
    );
  }

  Future<String?> editLoan({
    required int represCode,
    required int relatedEntityId,
    required int notifyId,
    required int isApproved,
    required int customerNo,
  }) async {
    lastEditLoanMessage = null;
    final result = await homeRepo.editLoan(
      represCode: represCode,
      relatedEntityId: relatedEntityId,
      notifyId: notifyId,
      isApproved: isApproved,
      customerNo: customerNo,
    );
    return result.fold(
      (failure) {
        lastEditLoanMessage = failure.errMessage;
        return null;
      },
      (message) {
        lastEditLoanMessage = message;
        return message;
      },
    );
  }

  Future<void> sendWhatsApp(SendWhatsAppModel model) async {
    try {
      emit(state.copyWith(sendWhatsAppStatus: const StatusState.loading()));
      final result = await homeRepo.sendWhatsApp(model);
      result.fold(
        (failure) {
          emit(
            state.copyWith(
              sendWhatsAppStatus: StatusState.failure(failure.errMessage),
            ),
          );
        },
        (response) => emit(
          state.copyWith(sendWhatsAppStatus: StatusState.success(response)),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(sendWhatsAppStatus: StatusState.failure(e.toString())),
      );
    }
  }
}
