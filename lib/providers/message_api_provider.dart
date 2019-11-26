import 'dart:async';

import 'package:flutter/foundation.dart' show compute;

import '../models/Product/message.dart';
import 'api_list.dart';
import 'api_provider.dart';

class MessageApiProvider extends ApiProvider {
  MessageApiProvider() : super() {
//    mockupDataPath = 'assets/json/messages.json';
//    apiBaseUrl = 'http://139.162.25.146/api/V1/message';
    apiUrlSuffix = "/message";
  }

  Future<List> getProductCommentMessage(Map params) async {
    var jsonData = await this.getData(ApiList.API_GET_MESSAGE, params);

    // Extract items from json data
    return compute(parseMessages, {"json": jsonData});
  }

  Future<List> getOrderChatMessage(Map params) async {
    var jsonData = await this.getData(ApiList.API_GET_MESSAGE, params);

    // Extract items from json data
    return compute(parseMessages, {"json": jsonData});
  }

  Future<Message> updateMessage(params) async {
    var result = await this.postData(ApiList.API_SET_MESSAGE, params);
    return result != null ? Message.fromJSON(result) : null;
  }

  // Isolate implementations
  static List parseMessages(dynamic params) {
    final json = params["json"];
    final data = json["data"];
    final pagination = {
      'current_page': json["current_page"],
      'page_size': json["per_page"],
      'to': json["to"],
      'total': json['total']
    };

    if (json != null) {
      return [
        new List<Message>.from(data.map((e) => Message.fromJSON(e))),
        pagination
      ];
    }

    return null;
  }
}
