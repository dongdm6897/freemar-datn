import 'dart:async';

import 'package:flutter_rentaza/models/Notification/freemar_notification.dart';
import 'package:flutter_rentaza/providers/api_list.dart';

import 'api_provider.dart';

class NotificationApiProvider extends ApiProvider {
  NotificationApiProvider() : super() {
    apiUrlSuffix = "/notification";
  }

  Future<bool> sendNotification(Map<String, dynamic> params) async {
    var response = await this.postData(null, params);
    if (response != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<FreeMarNotification>> getYourNotification(
      Map<String, String> params) async {
    var jsonData =
        await this.getData(ApiList.API_GET_YOUR_NOTIFICATION, params);
    if (jsonData != null) {
      return List<FreeMarNotification>.from(
          jsonData.map((e) => FreeMarNotification.fromJson(e)));
    }
    return null;
  }

  Future<List<FreeMarNotification>> getSystemNotification() async {
    var jsonData = await this.getData(ApiList.API_GET_SYSTEM_NOTIFICATION, {});
    if (jsonData != null) {
      return List<FreeMarNotification>.from(
          jsonData.map((e) => FreeMarNotification.fromJson(e)));
    }
    return null;
  }

  Future<int> getUnreadCount(int userId) async {
    var jsonData =
        await this.getData(ApiList.API_GET_UNREAD_COUNT, {"user_id": userId});
    if (jsonData != null) {
      return jsonData['count_unread'];
    }
    return null;
  }

  setUnread(Map param) {
    this.postData(ApiList.API_SET_UNREAD, param);
  }
}
