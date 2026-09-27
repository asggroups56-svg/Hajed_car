import 'package:car/core/utils/security_helper.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../theme/theme_enum.dart';

class HiveMethods {
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

  static void removeFromFavorites(String carName, {String? itemCode, String? chassisNo}) {
    final List<dynamic> list = List.from(getFavorites());
    list.removeWhere((c) {
      if (c is! Map) return false;
      final nameMatch = c['name']?.toString().trim() == carName.trim();
      final itemCodeMatch = itemCode != null &&
          itemCode.isNotEmpty &&
          c['itemCode']?.toString().trim() == itemCode.trim();
      final chassisMatch = chassisNo != null &&
          chassisNo.isNotEmpty &&
          (c['chassisNo']?.toString().trim() == chassisNo.trim() ||
              c['CHASSIS_NO']?.toString().trim() == chassisNo.trim());
      return nameMatch || itemCodeMatch || chassisMatch;
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

  static bool addToComparison(Map<String, dynamic> car) {
    final List<dynamic> list = List.from(getComparisonList());

    // If it's already in the list, remove it so it can be added to the top
    list.removeWhere((c) => c['name'] == car['name']);

    if (list.length >= 2) {
      return false;
    }

    list.insert(0, car);
    _box.put('comparisonList', list);
    return true;
  }

  static void removeFromComparison(String carName) {
    final List<dynamic> list = List.from(getComparisonList());
    list.removeWhere((c) => c['name'] == carName);
    _box.put('comparisonList', list);
  }

  static void clearComparisonList() {
    _box.put('comparisonList', []);
  }

  static bool isInComparison(String carName) {
    return getComparisonList().any((c) => c['name'] == carName);
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
