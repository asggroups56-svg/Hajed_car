import 'package:car/core/utils/security_helper.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../theme/theme_enum.dart';

class HiveMethods {
  /// Keeps the comparison readable on a phone while allowing a useful shortlist.
  static const int maxComparisonCars = 4;
  static final _box = Hive.box('app');

  static String getLang() {
    return _box.get('lang', defaultValue: 'ar');
  }

  static void updateLang(Locale locale) {
    _box.put('lang', locale.languageCode);
  }

  static String? getToken() {
    final String? encryptedToken = _box.get('token');
    if (encryptedToken == null) return null;
    return SecurityHelper.decrypt(encryptedToken);
  }

  static void updateToken(String token) {
    final String encryptedToken = SecurityHelper.encrypt(token);
    _box.put('token', encryptedToken);
  }

  static void deleteToken() {
    _box.delete('token');
  }

  static String? getRefreshToken() {
    final String? encrypted = _box.get('refreshToken');
    if (encrypted == null) return null;
    return SecurityHelper.decrypt(encrypted);
  }

  static void updateRefreshToken(String refreshToken) {
    final String encrypted = SecurityHelper.encrypt(refreshToken);
    _box.put('refreshToken', encrypted);
  }

  static void deleteRefreshToken() {
    _box.delete('refreshToken');
  }

  static bool isFirstTime() {
    return _box.get('isFirstTime', defaultValue: true);
  }

  static void updateFirstTime() {
    _box.put('isFirstTime', false);
  }

  static ThemeEnum getTheme() {
    return _box.get('theme', defaultValue: ThemeEnum.light);
  }

  static void updateThem(ThemeEnum theme) {
    _box.put('theme', theme);
  }

  static List<dynamic> getFavorites() {
    return _box.get('favorites', defaultValue: []);
  }

  static void updateFavorites(List<dynamic> favorites) {
    _box.put('favorites', favorites);
  }

  static void removeFromFavorites(
    String carName, {
    String? itemCode,
    String? chassisNo,
    String? uniqueId,
  }) {
    final List<dynamic> list = List.from(getFavorites());
    list.removeWhere((c) {
      if (c is! Map) return false;
      if (uniqueId != null && uniqueId.isNotEmpty) {
        if (getCarUniqueId(c) == uniqueId) return true;
      }
      final nameMatch = c['name']?.toString().trim() == carName.trim();
      final chassisMatch =
          chassisNo != null &&
          chassisNo.isNotEmpty &&
          (c['chassisNo']?.toString().trim() == chassisNo.trim() ||
              c['CHASSIS_NO']?.toString().trim() == chassisNo.trim());
      return chassisMatch || nameMatch;
    });
    _box.put('favorites', list);
  }

  static bool isGuest() {
    return _box.get('isGuest', defaultValue: false);
  }

  static void updateIsGuest(bool isGuest) {
    _box.put('isGuest', isGuest);
  }

  static String getRole() {
    return _box.get('role', defaultValue: '1');
  }

  static void updateRole(String role) {
    _box.put('role', role);
  }

  static bool isUserRole() {
    final role = getRole();
    return role == '1' || role == 'user';
  }

  static bool isAgentRole() {
    final role = getRole();
    return role == '2' || role == 'agent';
  }

  static bool isAdminRole() {
    return !isUserRole() && !isAgentRole();
  }

  static String? getUserName() {
    return _box.get('userName');
  }

  static void updateUserName(String userName) {
    _box.put('userName', userName);
  }

  // ─── Comparison List ────────────────────────────────────────
  static List<dynamic> getComparisonList() {
    return _box.get('comparisonList', defaultValue: []);
  }

  static String getCarUniqueId(dynamic car) {
    if (car == null) return '';
    if (car is! Map) return car.toString().trim();

    // 1. If unique_id is already assigned and valid (not empty, not just "_" or "null")
    final key = car['unique_id']?.toString().trim();
    if (key != null &&
        key.isNotEmpty &&
        key != '_' &&
        key != 'null' &&
        key != 'null_null' &&
        key != '0') {
      return key;
    }

    // 2. Chassis No (VIN) is globally unique to cars
    final chassis =
        (car['chassisNo'] ?? car['CHASSIS_NO'])?.toString().trim() ?? '';
    if (chassis.isNotEmpty && chassis != 'null' && chassis != '0') {
      return 'chassis_$chassis';
    }

    // 3. Customs Card No
    final customs =
        (car['customsCardNo'] ?? car['CUSTOMS_CARD_NO'])?.toString().trim() ??
        '';
    if (customs.isNotEmpty && customs != 'null' && customs != '0') {
      return 'customs_$customs';
    }

    // 4. Motor No
    final motor = (car['motorNo'] ?? car['MOTOR_NO'])?.toString().trim() ?? '';
    if (motor.isNotEmpty && motor != 'null' && motor != '0') {
      return 'motor_$motor';
    }

    // 5. Board No
    final board = (car['boardNo'] ?? car['BOARD_NO'])?.toString().trim() ?? '';
    if (board.isNotEmpty && board != 'null' && board != '0') {
      return 'board_$board';
    }

    // 6. Composite fallback without itemCode: name, year, color, price, image
    final name =
        (car['name'] ?? car['itemName'] ?? car['ITEM_NAME'])
            ?.toString()
            .trim() ??
        '';
    final year =
        (car['year'] ?? car['makeYear'] ?? car['MAKE_YEAR'])
            ?.toString()
            .trim() ??
        '';
    final color =
        (car['color'] ?? car['Color'] ?? car['bodyColor'] ?? car['BODY_COLOR'])
            ?.toString()
            .trim() ??
        '';
    final price = (car['price'] ?? car['PRICE'])?.toString().trim() ?? '';
    final image =
        (car['image'] ?? car['carImage'] ?? car['carimage'])
            ?.toString()
            .trim() ??
        '';

    final composite = '${name}_${year}_${color}_${price}_$image';
    if (composite.replaceAll('_', '').isNotEmpty) {
      return composite;
    }

    return 'car_${identityHashCode(car)}';
  }

  static bool _matchesCar(dynamic existingItem, dynamic target) {
    if (existingItem == null || target == null) return false;
    final existingId = getCarUniqueId(existingItem);
    final targetId = getCarUniqueId(target);

    if (existingId.isNotEmpty && targetId.isNotEmpty) {
      return existingId == targetId;
    }

    return false;
  }

  static bool addToComparison(Map<String, dynamic> car) {
    final List<dynamic> list = List.from(getComparisonList());
    final carToSave = Map<String, dynamic>.from(car);
    carToSave['unique_id'] = getCarUniqueId(car);

    // If it's already in the list, remove it so it can be re-added to the top
    list.removeWhere((c) => _matchesCar(c, carToSave));

    if (list.length >= maxComparisonCars) {
      return false;
    }

    list.insert(0, carToSave);
    _box.put('comparisonList', list);
    return true;
  }

  static void removeFromComparison(dynamic carOrKey) {
    final List<dynamic> list = List.from(getComparisonList());
    list.removeWhere((c) => _matchesCar(c, carOrKey));
    _box.put('comparisonList', list);
  }

  static void clearComparisonList() {
    _box.put('comparisonList', []);
  }

  static bool isInComparison(dynamic carOrKey) {
    return getComparisonList().any((c) => _matchesCar(c, carOrKey));
  }

  // ─── Recently Viewed ────────────────────────────────────────
  static List<dynamic> getRecentlyViewed() {
    return _box.get('recentlyViewed', defaultValue: []);
  }

  static void addToRecentlyViewed(Map<String, dynamic> car) {
    final List<dynamic> list = List.from(getRecentlyViewed());
    // Remove if exists to move it to the top
    list.removeWhere((c) => c['name'] == car['name']);
    list.insert(0, car);

    // Limit to 10 stored cars
    if (list.length > 10) {
      list.removeLast();
    }
    _box.put('recentlyViewed', list);
  }

  static void removeFromRecentlyViewed(String carName) {
    final List<dynamic> list = List.from(getRecentlyViewed());
    list.removeWhere((c) => c['name'] == carName);
    _box.put('recentlyViewed', list);
  }

  // ─── Cart ───────────────────────────────────────────────────
  static List<dynamic> getCartItems() {
    return _box.get('cartItems', defaultValue: []);
  }

  static void updateCartItems(List<dynamic> items) {
    _box.put('cartItems', items);
  }

  // ─── Remember Me ────────────────────────────────────────────
  static bool getRememberMe() {
    return _box.get('rememberMe', defaultValue: false);
  }

  static void updateRememberMe(bool rememberMe) {
    _box.put('rememberMe', rememberMe);
  }

  static String getSavedMobile() {
    return _box.get('savedMobile', defaultValue: '');
  }

  static void updateSavedMobile(String mobile) {
    _box.put('savedMobile', mobile);
  }

  static String getSavedPassword() {
    final String? encrypted = _box.get('savedPassword');
    if (encrypted == null) return '';
    try {
      return SecurityHelper.decrypt(encrypted);
    } catch (_) {
      return '';
    }
  }

  static void updateSavedPassword(String password) {
    if (password.isEmpty) {
      _box.delete('savedPassword');
      return;
    }
    final String encrypted = SecurityHelper.encrypt(password);
    _box.put('savedPassword', encrypted);
  }

  static void clearSavedCredentials() {
    _box.delete('savedMobile');
    _box.delete('savedPassword');
  }

  static String? getUserCode() {
    return _box.get('userCode', defaultValue: '1');
  }

  static void updateUserCode(String userCode) {
    _box.put('userCode', userCode);
  }

  static String? getReservationStartedAt(String itemCode) {
    return _box.get('reservationStartedAt_$itemCode');
  }

  static void updateReservationStartedAt(String itemCode, DateTime startedAt) {
    _box.put('reservationStartedAt_$itemCode', startedAt.toIso8601String());
  }

  static void clearReservationStartedAt(String itemCode) {
    _box.delete('reservationStartedAt_$itemCode');
  }

  static void updateVatNumber(String vatNumber) {
    _box.put('VAT_SERIAL', vatNumber);
  }

  static void updatecode(String code) {
    _box.put('Code', code);
  }

  static String? getcode() {
    return _box.get('Code', defaultValue: '');
  }

  static String? getRepresentativeNo() {
    return _box.get('REPRES_NO', defaultValue: '');
  }

  static String? getVatNumber() {
    return _box.get('VAT_SERIAL', defaultValue: '');
  }

  static void updateRepresentativeNo(String representativeNo) {
    _box.put('REPRES_NO', representativeNo);
  }

  static void phone(String phone) {
    _box.put('phone', phone);
  }

  static String? getphone() {
    return _box.get('phone', defaultValue: '');
  }

  static void updateName(String name) {
    _box.put('name', name);
  }

  static String? getname() {
    return _box.get('name', defaultValue: '');
  }
}
