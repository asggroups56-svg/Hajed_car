import 'dart:async';

import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/services/notification_service.dart';
import 'package:car/features/admin/data/model/cars_response_model.dart' as admin;
import 'package:car/features/admin/data/repo/admin_repo.dart';
import 'package:car/features/cart/presentation/view/cubit/cart_reservation_service.dart';
import 'package:car/features/home/data/model/cancel_reserved_car_model.dart';
import 'package:car/features/home/data/repository/home_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final AdminRepo adminRepo;
  final HomeRepo homeRepo;
  late final CartReservationService _reservationService;
  bool _isAgentBookings = false;

  CartCubit({required this.adminRepo, required this.homeRepo}) : super(CartState.initial()) {
    _reservationService = CartReservationService(homeRepo: homeRepo);
    loadReservedCars();
  }

  // ─── Load reserved cars from API (carstatus=2, CUSTOMER_NO=userCode) ────

  Future<void> loadReservedCars({bool isAgent = false}) async {
    _isAgentBookings = isAgent;
    if (HiveMethods.isGuest()) {
      emit(state.copyWith(isLoading: false, reservedCars: []));
      return;
    }

    final String? userCode = HiveMethods.getcode();
    final int? customerNo = isAgent ? null : int.tryParse(userCode ?? '');
    final int? represCode = isAgent ? int.tryParse(HiveMethods.getRepresentativeNo() ?? '') : null;

    if (!isAgent && customerNo == null) {
      emit(state.copyWith(isLoading: false, reservedCars: []));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await adminRepo.getCars(2, customerNo, represCode: represCode);

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, errorMessage: failure.errMessage));
      },
      (carsModel) {
        final cars = carsModel.data;
        _scheduleAllTimers(cars);
        emit(state.copyWith(isLoading: false, reservedCars: cars));
      },
    );
  }

  // ─── Cancel reservation: calls endpoint then removes locally ────────────
  // All required fields (lpoNo, storeCode) are taken directly from the CarModel.
  // No Hive map lookups needed.

  Future<void> cancelReservation(admin.CarModel car) async {
    final String lpoNo = car.lpoNo ?? '';
    final int storeCode = int.tryParse(car.storeCode?.toString() ?? '') ?? 0;
    final int customerNo = HiveMethods.getUserCode() != null
        ? int.tryParse(HiveMethods.getUserCode()!) ?? 0
        : 0;
    final int represCode = HiveMethods.getRepresentativeNo() != null
        ? int.tryParse(HiveMethods.getRepresentativeNo()!) ?? 0
        : 0;
    final model = CancelReservedCarModel(
      lpoNo: lpoNo,
      itemCode: car.itemCode ?? '',
      storeCode: storeCode,
      notes: 'Cancelled by user',
      customerNo: customerNo,
      represCode: represCode,
    );

    if (kDebugMode) {
      debugPrint(
        '[CartCubit] Calling cancelReservedCar for ${car.itemCode} '
        '| lpoNo=$lpoNo | storeCode=$storeCode',
      );
    }

    final result = await homeRepo.cancelreservedcar(model);

    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('[CartCubit] cancelReservation failed: ${failure.errMessage}');
        }
        emit(state.copyWith(errorMessage: failure.errMessage));
      },
      (response) {
        if (kDebugMode) {
          debugPrint('[CartCubit] cancelReservation success: ${response.msg}');
        }
        final msg = response.msg.isNotEmpty ? response.msg : 'تم إلغاء الحجز بنجاح';
        emit(state.copyWith(cancellationMessage: msg));
        unawaited(
          NotificationService.showReservationCancelledNotification(
            carName: car.itemName ?? 'السيارة',
          ),
        );
      },
    );

    // Stop the auto-cancel timer for this car.
    _reservationService.cancelTimer({'itemCode': car.itemCode});

    // Refresh from API (clear the cancellationMessage so it fires only once).
    if (!isClosed) unawaited(loadReservedCars(isAgent: _isAgentBookings));
  }

  // ─── Remove locally only (no endpoint – e.g., after auto-cancel) ─────────

  void removeFromCart(admin.CarModel car) {
    _reservationService.cancelTimer({'itemCode': car.itemCode, 'name': car.itemName});

    // Refresh the reserved-cars list from API.
    unawaited(loadReservedCars(isAgent: _isAgentBookings));
  }

  // ─── Clear all ───────────────────────────────────────────────────────────

  void clearCart() {
    _reservationService.disposeAll();
    emit(CartState.initial());
  }

  void rememberReservationStart(admin.CarModel car, {DateTime? reservedAt}) {
    _reservationService.rememberReservationStart(car, reservedAt: reservedAt);
  }

  // ─── Restore timers after app restart ────────────────────────────────────
  // Now uses the API data (reservedCars) as the source of truth instead of Hive maps.

  void restoreTimers() {
    _scheduleAllTimers(state.reservedCars);
  }

  // ─── Called when timer fires after the reservation window ends ──────────

  void _onItemExpired(admin.CarModel car) {
    if (kDebugMode) {
      debugPrint('[CartCubit] Item expired, removing from cart: ${car.itemCode}');
    }

    // Refresh the reserved-cars list from API.
    if (!isClosed) {
      unawaited(loadReservedCars(isAgent: _isAgentBookings));
    }
  }

  // ─── Schedule timers for all currently loaded cars ────────────────────────

  void _scheduleAllTimers(List<admin.CarModel> cars) {
    for (final car in cars) {
      _reservationService.scheduleExpiryForModel(car: car, onExpired: () => _onItemExpired(car));
    }
  }

  /// Exposes the expiry [DateTime] for a given [itemCode] so the UI can
  /// render a live countdown. Returns null if there's no active timer
  /// for this item (e.g. state was just loaded and timers haven't been
  /// (re)scheduled yet).
  DateTime? expiryTimeFor(String? itemCode) {
    if (itemCode == null) return null;
    return _reservationService.expiryTimeFor(itemCode);
  }

  @override
  Future<void> close() {
    _reservationService.disposeAll();
    return super.close();
  }

  // ─── Helper ──────────────────────────────────────────────────────────────

  bool isInCart(String itemCode) {
    return state.reservedCars.any((c) => c.itemCode == itemCode);
  }
}
