import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FavoritesState {}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<Map<String, dynamic>> favorites;
  FavoritesLoaded(this.favorites);
}

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(FavoritesInitial()) {
    loadFavorites();
  }

  void loadFavorites() {
    final favoritesData = HiveMethods.getFavorites();
    final List<Map<String, dynamic>> favorites = favoritesData
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    emit(FavoritesLoaded(favorites));
  }

  /// Toggle favorite using unique ID (itemCode_chassisNo or itemCode or chassisNo)
  void toggleFavorite(Map<String, dynamic> car) {
    final currentState = state;
    if (currentState is FavoritesLoaded) {
      final List<Map<String, dynamic>> currentFavorites =
          List.from(currentState.favorites);

      final index = currentFavorites
          .indexWhere((element) => HiveMethods.getCarUniqueId(element) ==
              HiveMethods.getCarUniqueId(car));

      if (index != -1) {
        currentFavorites.removeAt(index);
      } else {
        currentFavorites.add(car);
      }

      HiveMethods.updateFavorites(currentFavorites);
      emit(FavoritesLoaded(currentFavorites));
    }
  }

  void removeFromFavorites(String carName, {String? itemCode, String? chassisNo}) {
    HiveMethods.removeFromFavorites(carName,
        itemCode: itemCode, chassisNo: chassisNo);
    loadFavorites();
  }

  /// Check if a car is favorite by unique ID.
  /// [carIdentifier] can be a Map (car data) or a String (itemCode or name).
  bool isFavorite(dynamic carIdentifier) {
    final currentState = state;
    if (currentState is! FavoritesLoaded) return false;

    if (carIdentifier is Map) {
      final targetId = HiveMethods.getCarUniqueId(carIdentifier);
      if (targetId.isEmpty) return false;
      return currentState.favorites.any(
        (element) => HiveMethods.getCarUniqueId(element) == targetId,
      );
    } else if (carIdentifier is String) {
      if (carIdentifier.trim().isEmpty) return false;
      // Try to match by ID first, then by name as last resort
      return currentState.favorites.any((element) {
        final elementId = HiveMethods.getCarUniqueId(element);
        if (elementId == carIdentifier.trim()) return true;
        // fallback to name only when no unique id available
        final elementCode =
            (element['itemCode'] ?? element['ITEM_CODE'])?.toString().trim() ?? '';
        final elementChassis =
            (element['chassisNo'] ?? element['CHASSIS_NO'])?.toString().trim() ?? '';
        if (elementCode.isNotEmpty || elementChassis.isNotEmpty) return false;
        return element['name']?.toString().trim() == carIdentifier.trim();
      });
    }

    return false;
  }
}
