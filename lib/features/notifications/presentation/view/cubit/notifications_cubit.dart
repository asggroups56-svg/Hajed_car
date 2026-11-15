import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(NotificationsInitial()) {
    loadNotifications();
  }

  /// Notifications created locally (reservation created/cancelled) are kept
  /// here so that a server refresh does not immediately remove them from the
  /// list while the backend has not stored the matching record yet.
  final List<Map<String, dynamic>> _localNotifications = [];

  void loadNotifications() {
    emit(NotificationsLoading());
    // Real data is loaded via HomeCubit.getNotificationsData
    // and then fed in via loadFromApi(). This initial call is a
    // placeholder that shows a loading state until data arrives.
  }

  /// Called externally (e.g., from a BlocListener) once HomeCubit
  /// returns the real notifications from the server.
  void loadFromApi(List<Map<String, dynamic>> notifications) {
    final serverList = notifications
        .where((notification) => notification['isRead'] != true)
        .toList();
    final serverKeys = serverList.map(_dedupeKey).toSet();

    // Drop local copies that are already on the server or that the user has
    // read, then show the remaining local ones before the server list.
    _localNotifications.removeWhere(
      (notification) =>
          notification['isRead'] == true ||
          serverKeys.contains(_dedupeKey(notification)),
    );

    _emitLoaded([..._localNotifications, ...serverList]);
  }

  void addReservationNotification({required String title, required String body}) {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'body': body,
      'time': 'الآن',
      'isRead': false,
      'type': 'reservation',
    };

    _localNotifications.insert(0, notification);

    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      _emitLoaded([notification, ...currentState.notifications]);
    } else {
      _emitLoaded([notification]);
    }
  }

  void markAsRead(String id) {
    for (var i = 0; i < _localNotifications.length; i++) {
      if (_localNotifications[i]['id'] == id) {
        _localNotifications[i] = {..._localNotifications[i], 'isRead': true};
      }
    }
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      final updatedList = currentState.notifications.map((n) {
        if (n['id'] == id) return {...n, 'isRead': true};
        return n;
      }).toList();
      _emitLoaded(updatedList);
    }
  }

  void markAllAsRead() {
    for (var i = 0; i < _localNotifications.length; i++) {
      _localNotifications[i] = {..._localNotifications[i], 'isRead': true};
    }
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      final updatedList = currentState.notifications.map((n) => {...n, 'isRead': true}).toList();
      _emitLoaded(updatedList);
    }
  }

  void clearAll() {
    _localNotifications.clear();
    _emitLoaded([]);
  }

  void _emitLoaded(List<Map<String, dynamic>> list) {
    final unreadCount = list.where((n) => n['isRead'] == false).length;
    emit(NotificationsLoaded(notifications: list, unreadCount: unreadCount));
  }

  static String _dedupeKey(Map<String, dynamic> notification) =>
      '${notification['title']}|${notification['body']}';

  /// Convenience: triggers HomeCubit to fetch and then feeds data here.
  static void fetchAndLoad(HomeCubit homeCubit) {
    final code = HiveMethods.getcode() ?? '';
    final isAgent = HiveMethods.isAgentRole();
    homeCubit.getNotificationsData(currentUserId: code, userType: isAgent ? 2 : 1);
  }
}
