import 'dart:async';

import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/bloc_provider.dart';
import 'package:flutter_rentaza/models/Notification/freemar_notification.dart';
import 'package:flutter_rentaza/providers/repository.dart';
import 'package:flutter_rentaza/utils/ui_data.dart';
import 'package:rxdart/rxdart.dart';

class NotificationBloc implements BlocBase {
  final _repository = Repository();

  BehaviorSubject<int> _unreadCountController = BehaviorSubject<int>();

  Stream<int> get streamUnreadCount => _unreadCountController.stream;

  Sink<int> get unreadCountSink => _unreadCountController.sink;

  int unread = 0;

  getUnreadCount(int userId) async {
    _repository.notificationProvider.getUnreadCount(userId).then((countUnread) {
      unread = _unreadCountController.value ?? 0;
      unread = unread + countUnread;
      if (!_unreadCountController.isClosed) unreadCountSink.add(unread);
    });
  }

  setUnread(String accessToken) {
    _repository.notificationProvider.setUnread({'access_token': accessToken});
    unread = 0;
    if (!_unreadCountController.isClosed) unreadCountSink.add(unread);
  }

  Future<List<FreeMarNotification>> getYourNotification(String accessToken) {
    return _repository.notificationProvider
        .getYourNotification({'access_token': accessToken});
  }

  Future<List<FreeMarNotification>> getSystemNotification() {
    return _repository.notificationProvider.getSystemNotification();
  }

  @override
  void dispose() {
    _unreadCountController.close();
  }
}
