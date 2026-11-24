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
  int _brandCarsRequestId = 0;
  Future<void>? _normalFinancingRequest;
  Future<void>? _financingAdsListRequest;
  Future<void>? _promoCarOffersRequest;
  bool _promoCarOffersLoaded = false;
  final Map<int, List<FinancingAdModel>> _programCarsCache =
      <int, List<FinancingAdModel>>{};
  final Set<String> _locallyReservedCarCodes = <String>{};

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
          // Keep the initial home view on "All". If the user had already
          // selected a brand before a refresh, reload only that selection.
          final selectedBrandId = state.selectedBrandId;
          if (selectedBrandId != null) {
            await getBrandCars(selectedBrandId.toString());
          }
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
          clearSelectedBrandId: true,
        ),
      );
      return;
    }

    // A user can select brands faster than the API responds. Keep an id for
    // the most recent request so a slower, older response cannot replace the
    // cars of the brand currently selected on screen.
    final requestId = ++_brandCarsRequestId;
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

    if (requestId != _brandCarsRequestId ||
        state.selectedBrandId != brandIdInt) {
      return;
    }

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
    int? colorCode,
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
      colorCode,
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

  /// Removes a newly reserved car from the currently displayed inventory
  /// immediately. This keeps it hidden while the server refresh is in flight.
  void hideReservedCar(String itemCode) {
    if (itemCode.isEmpty) return;

    _locallyReservedCarCodes.add(itemCode);
    final cars = state.allCarsStatus.data;
    if (cars == null) return;

    emit(
      state.copyWith(
        allCarsStatus: StatusState.success(
          cars.where((car) => car.itemCode != itemCode).toList(),
        ),
      ),
    );
  }

  bool isCarLocallyReserved(String itemCode) =>
      _locallyReservedCarCodes.contains(itemCode);

  /// Refreshes the same inventory query after a successful reservation.
  /// The local exclusion is applied again in case the inventory API has not
  /// reflected the new status yet.
  Future<void> refreshCarsAfterReservation(String itemCode) async {
    final currentState = state;
    hideReservedCar(itemCode);
    await fetchAllCars(
      brandId: currentState.brandId,
      fromMakeYear: currentState.fromMakeYear,
      toMakeYear: currentState.toMakeYear,
      fromPrice: currentState.fromPrice,
      toPrice: currentState.toPrice,
      fuelType: currentState.fuelType,
    );
    hideReservedCar(itemCode);
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

  void selectAllBrands() {
    unawaited(getBrandCars(''));
  }

  /// Drops the brand (or model type) picked from the brands section without
  /// issuing a new brand-cars request. Used when another inventory filter takes
  /// over, so the cars tab shows those results instead of the old brand.
  void clearBrandSelection() {
    if (state.selectedBrandId == null) return;
    // Cancel any in-flight brand request so its response cannot restore the
    // selection after the filter was applied.
    _brandCarsRequestId++;
    emit(
      state.copyWith(clearSelectedBrandId: true, selectedIndex: 0),
    );
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
        // Vehicle offers often carry the bank only as an id. Register the full
        // directory so those offers can show the bank name and select the
        // non-transferred (`*Other`) terms. A filtered search must not replace
        // the full directory with a subset.
        if (searchVal == null || searchVal.trim().isEmpty) {
          FinancingAdModel.registerBankDirectory(response);
        }
        emit(state.copyWith(banksStatus: StatusState.success(response)));
      },
    );
  }

  Future<void> getFinancingAds({String? code}) async {
    final isSpecificProgram = code != null && code.isNotEmpty;
    if (isSpecificProgram) {
      await _loadProgramCars(code);
      return;
    }

    // The program list is also requested when the cars list is enriched with
    // promotional offers. Share the in-flight request so opening both surfaces
    // does not issue it twice.
    final inFlightRequest = _financingAdsListRequest;
    if (inFlightRequest != null) {
      await inFlightRequest;
      return;
    }

    final request = _loadFinancingAdsList();
    _financingAdsListRequest = request;
    try {
      await request;
    } finally {
      _financingAdsListRequest = null;
    }
  }

  Future<void> _loadFinancingAdsList() async {
    emit(state.copyWith(financingAdsStatus: const StatusState.loading()));

    final result = await homeRepo.getFinancingAds();

    result.fold(
      (failure) => emit(
        state.copyWith(
          financingAdsStatus: StatusState.failure(failure.errMessage),
        ),
      ),
      (response) => emit(
        state.copyWith(financingAdsStatus: StatusState.success(response)),
      ),
    );
  }

  Future<void> _loadProgramCars(String code) async {
    emit(state.copyWith(programCarsStatus: const StatusState.loading()));

    final result = await homeRepo.getFinancingAds(code: code);

    result.fold(
      (failure) => emit(
        state.copyWith(
          programCarsStatus: StatusState.failure(failure.errMessage),
        ),
      ),
      (response) {
        final programId = int.tryParse(code);
        // The offers endpoint can return the same vehicle more than once (for
        // example once per bank row). Each car must still get a single card,
        // otherwise its picture and details appear twice in the listing.
        final rowsWithPid = programId != null
            ? response
                .map((r) => r.programId == null ? r.copyWith(programId: programId) : r)
                .toList()
            : response;
        final uniqueRows = _dedupeProgramCars(rowsWithPid);
        if (programId != null) {
          // Keep the program's cars so the regular inventory list can attach
          // their offer terms to the matching cars later.
          _programCarsCache[programId] = uniqueRows;
        }
        emit(
          state.copyWith(programCarsStatus: StatusState.success(uniqueRows)),
        );
        _emitPromoCarOffers();
      },
    );
  }

  /// Removes repeated vehicle rows from one program's response.
  ///
  /// Identity follows the same priority used to match an offer with its
  /// inventory row: item code, then chassis number, then name, model year and
  /// plate. The last fallback also includes the plate so two genuinely
  /// different cars of the same model are both kept.
  static List<FinancingAdModel> _dedupeProgramCars(
    List<FinancingAdModel> rows,
  ) {
    if (rows.length < 2) return rows;

    final seen = <String>{};
    final unique = <FinancingAdModel>[];
    for (final row in rows) {
      final itemCode = row.itemCode?.trim() ?? '';
      final chassis = row.chassisNo?.trim().toLowerCase() ?? '';
      final String key;
      if (itemCode.isNotEmpty) {
        key = 'item:$itemCode';
      } else if (chassis.isNotEmpty && chassis != 'null') {
        key = 'chassis:$chassis';
      } else {
        final name = row.itemName?.trim().toLowerCase() ?? '';
        if (name.isEmpty) {
          unique.add(row);
          continue;
        }
        final year = row.makeYear ?? row.modelYear ?? 0;
        final color = (row.bodyColor ?? row.color ?? '').trim().toLowerCase();
        final plate = (row.boardNo ?? '').trim().toLowerCase();
        key = 'name:$name|year:$year|color:$color|plate:$plate';
      }
      if (seen.add(key)) unique.add(row);
    }
    return unique;
  }

  /// Loads the standard financing offers once and shares the in-flight request
  /// between every car card. A car list can create many financing banners at
  /// the same time, so letting each banner issue its own request can overwhelm
  /// the app and the API.
  Future<void> getNormalFinancing({bool force = false}) {
    final inFlightRequest = _normalFinancingRequest;
    if (inFlightRequest != null) return inFlightRequest;

    // A successful response may validly contain no offers. It is still a
    // completed request and must not cause every visible card to retry it.
    if (!force && state.normalFinancingStatus.isSuccess) {
      return Future.value();
    }

    return _normalFinancingRequest ??= _loadNormalFinancing().whenComplete(() {
      _normalFinancingRequest = null;
    });
  }

  Future<void> _loadNormalFinancing() async {
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

  /// Loads the cars of every active financing program so the regular inventory
  /// list can show the promotional terms of the vehicles that are part of an
  /// offer while still listing them among the standard cars.
  ///
  /// Programs are cached per id, so repeated visits to the cars tab (and a
  /// program opened from the offers slider) do not issue the requests again.
  Future<void> loadPromoCarOffers({bool force = false}) {
    final inFlightRequest = _promoCarOffersRequest;
    if (inFlightRequest != null) return inFlightRequest;

    if (!force && _promoCarOffersLoaded) return Future.value();

    return _promoCarOffersRequest = _loadPromoCarOffers(force: force)
        .whenComplete(() {
          _promoCarOffersRequest = null;
        });
  }

  Future<void> _loadPromoCarOffers({required bool force}) async {
    if (force) {
      _programCarsCache.clear();
      _promoCarOffersLoaded = false;
    }

    if (!state.financingAdsStatus.isSuccess) {
      await getFinancingAds();
    }

    final programs =
        state.financingAdsStatus.data ?? const <FinancingAdModel>[];
    final programIds = <int>{
      for (final program in programs)
        if (program.programId != null) program.programId!,
    };

    // A program whose cars were already opened from the offers slider is
    // served from the cache.
    final missingProgramIds = programIds
        .where((programId) => !_programCarsCache.containsKey(programId))
        .toList();

    if (missingProgramIds.isNotEmpty) {
      final results = await Future.wait(
        missingProgramIds.map((programId) async {
          final result = await homeRepo.getFinancingAds(
            code: programId.toString(),
          );
          return result.fold(
            (_) => const <FinancingAdModel>[],
            (rows) => rows,
          );
        }),
      );

      for (var i = 0; i < missingProgramIds.length; i++) {
        final pid = missingProgramIds[i];
        final rowsWithPid = results[i]
            .map((r) => r.programId == null ? r.copyWith(programId: pid) : r)
            .toList();
        _programCarsCache[pid] = _dedupeProgramCars(rowsWithPid);
      }
    }

    _promoCarOffersLoaded = true;
    _emitPromoCarOffers();
  }

  /// Publishes the cached program cars as the source of promotional terms for
  /// the regular car list.
  void _emitPromoCarOffers() {
    final programs =
        state.financingAdsStatus.data ?? const <FinancingAdModel>[];
    final offers = <FinancingAdModel>[
      // Some deployments return the vehicle rows together with the program
      // list instead of one advertisement row per program.
      ...programs.where(_isPromoVehicleRow),
      for (final rows in _programCarsCache.values)
        ...rows.where(_isPromoVehicleRow),
    ];
    emit(state.copyWith(promoCarOffers: offers));
  }

  /// True for offer rows that describe a vehicle, as opposed to the program
  /// advertisement rows returned by the program list endpoint.
  static bool _isPromoVehicleRow(FinancingAdModel row) {
    final itemCode = row.itemCode?.trim() ?? '';
    final chassisNo = row.chassisNo?.trim() ?? '';
    final itemName = row.itemName?.trim() ?? '';
    return itemCode.isNotEmpty ||
        (chassisNo.isNotEmpty && chassisNo.toLowerCase() != 'null') ||
        itemName.isNotEmpty;
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

  Future<void> sendWhatsAppPdf(SendWhatsAppPdfModel model) async {
    try {
      emit(state.copyWith(sendWhatsAppPdfStatus: const StatusState.loading()));
      final result = await homeRepo.sendWhatsAppPdf(model);
      result.fold(
        (failure) {
          emit(
            state.copyWith(
              sendWhatsAppPdfStatus: StatusState.failure(failure.errMessage),
            ),
          );
        },
        (response) => emit(
          state.copyWith(sendWhatsAppPdfStatus: StatusState.success(response)),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          sendWhatsAppPdfStatus: StatusState.failure(e.toString()),
        ),
      );
    }
  }

  Future<void> sendWhatsAppWithPdf({
    required SendWhatsAppModel textModel,
    required SendWhatsAppPdfModel pdfModel,
  }) async {
    await sendWhatsApp(textModel);
    await sendWhatsAppPdf(pdfModel);
  }
}
