import 'dart:async';

import 'package:global_configuration/global_configuration.dart';
import 'package:rxdart/rxdart.dart';

import '../models/Product/message.dart';
import '../providers/repository.dart';
import 'bloc_provider.dart';

class MessageBloc implements BlocBase {
  final _repository = Repository();
  GlobalConfiguration _config = new GlobalConfiguration();

  BehaviorSubject<List<Message>> messageController = BehaviorSubject<List<Message>>();
  Sink<List<Message>> get messageSink => messageController.sink;

  Stream<List<Message>> get streamMessage => messageController.stream;

  Future<List> getProductCommentMessage(int productId,int page) async {
    Map<String,String> params = Map<String,String>();
    params['product_id'] = productId.toString();
    params['page'] = page.toString();
    params['page_size'] = _config.get('product_comment_page_size').toString();
    var response = await _repository.getProductCommentMessage(params);

    return response;
  }

  Future<List> getOrderChatMessage(int orderId,int page) async {
    Map<String,String> params = Map<String,String>();
    params['order_id'] = orderId.toString();
    params['page'] = page.toString();
    params['page_size'] = _config.get('product_comment_page_size').toString();
    var response = await _repository.getOrderChatMessage(params);

    return response;
  }

  Future<Message> updateMessage(Map params) async {
    return await _repository.updateMessage(params);
  }

  void dispose() {
    messageController.close();
  }
}
