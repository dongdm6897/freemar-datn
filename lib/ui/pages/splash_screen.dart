import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/login_bloc.dart';
import 'package:flutter_rentaza/models/Product/message.dart' as FreeMar;
import 'package:flutter_rentaza/models/Product/product.dart';
import 'package:flutter_rentaza/models/Sale/order.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/models/master_datas.dart';
import 'package:flutter_rentaza/providers/repository.dart';
import 'package:flutter_rentaza/ui/pages/product/order_detail.dart';
import 'package:flutter_rentaza/ui/pages/product/product_detail.dart';
import 'package:flutter_rentaza/utils/navigation_service.dart';
import 'package:flutter_rentaza/utils/ui_data.dart';
import 'package:global_configuration/global_configuration.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  bool notification = false;
  Product product;
  Order order;
  Map<String, dynamic> messageFlag;

  void firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iOS_Permission();
    _firebaseMessaging.getToken().then((token) {
      AppBloc().fcmToken = token;
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        int notificationType = int.tryParse(message['data']['type']);
        Map<String, dynamic> data = jsonDecode(message['data']['data_type']);
        User _currentUser = AppBloc().loginUser;
        if (_currentUser != null) {
          switch (notificationType) {
            case NotificationTypeEnum.PRODUCT_COMMENT:
              FreeMar.Message mess = FreeMar.Message.fromJSON(data['message']);
              product = await Repository().getProduct({
                'access_token': _currentUser.accessToken,
                'product_id': data['product_id']
              }, false);
              if (mess.senderObj.id != _currentUser.id) {
                AppBloc().eventSink.add({
                  'type': NotificationTypeEnum.PRODUCT_COMMENT,
                  'message': mess
                });
              }
              break;
            case NotificationTypeEnum.ORDER_CHAT:
              FreeMar.Message mess = FreeMar.Message.fromJSON(data['message']);
              product = await Repository().getProduct({
                'access_token': _currentUser.accessToken,
                'product_id': data['product_id']
              }, true);
              order = product.inOrderObj;
              if (mess.senderObj.id != AppBloc().loginUser.id) {
                AppBloc().eventSink.add(
                    {'type': NotificationTypeEnum.ORDER_CHAT, 'message': mess});
              }
              break;
            case NotificationTypeEnum.ORDER:
              int shippingStatusId = data['shipping_status_id'];
              AppBloc().eventSink.add({
                'type': NotificationTypeEnum.ORDER,
                'shipping_status_id': shippingStatusId
              });
              break;
            default:
              break;
          }
        }
        showNotification(message['notification']['title'],
            message['notification']['body'], message['data']['type']);
      },
      onResume: (Map<String, dynamic> message) async {
        //App in Background
        print('on resume $message');
        handleNavigatorFCM(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        //App Terminated
        print('on launch $message');
        notification = true;
        messageFlag = message;
      },
    );
  }

  Future handleNavigatorFCM(message) async {
    int notificationType = int.tryParse(message['data']['type']);
    Map<String, dynamic> data = jsonDecode(message['data']['data_type']);
    User _currentUser = AppBloc().loginUser;
    if (_currentUser != null) {
      switch (notificationType) {
        case NotificationTypeEnum.PRODUCT_COMMENT:
          product = await Repository().getProduct({
            'access_token': _currentUser.accessToken,
            'product_id': data['product_id']
          }, false);
          NavigationService.navKey.currentState.push(MaterialPageRoute(
              builder: (BuildContext context) => ProductDetailPage(
                    product: product,
                    isJumpToComment: true,
                  )));
          break;
        case NotificationTypeEnum.ORDER_CHAT:
          Product p = await Repository().getProduct({
            'access_token': _currentUser.accessToken,
            'product_id': data['product_id']
          }, false);
          order = product.inOrderObj;
          NavigationService.navKey.currentState.push(MaterialPageRoute(
              builder: (BuildContext context) => OrderDetailPage(
                    order: order,
                  )));
          break;
        default:
          NavigationService.navKey.currentState.pushNamed(UIData.NOTIFICATION);
          break;
      }
    } else {
      NavigationService.navKey.currentState.pushNamed(UIData.LOGIN);
    }
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});
  }

  loadConfigurations() async {
    // Load resources
    await GlobalConfiguration().loadFromAsset("app_settings");
    await AppBloc().getMasterDatas();
    await setData();

    // Navigate to main page
    if (!notification) {
      Navigator.of(context).pushReplacementNamed(UIData.HOMEPAGE);
    } else {
      handleNavigatorFCM(messageFlag);
    }
  }

  setData() async {
    LoginBloc _loginBloc = LoginBloc();
    var res = await _loginBloc.getLogged();
    if (res != null) {
      //save app bloc
      User userTemp = AppBloc().loginUser;
      if (userTemp == null) {
        //not save app bloc
        var results = await _loginBloc.getProfile(res);
        await AppBloc().setLoginUser(results);
        _loginBloc.dispose();
      }
    }
  }

  Future onSelectNotification(String payload) {
    switch (int.parse(payload)) {
      case NotificationTypeEnum.PRODUCT_COMMENT:
        NavigationService.navKey.currentState.push(MaterialPageRoute(
            builder: (BuildContext context) => ProductDetailPage(
                  product: product,
                  isJumpToComment: true,
                )));
        break;
      case NotificationTypeEnum.ORDER_CHAT:
        NavigationService.navKey.currentState.push(MaterialPageRoute(
            builder: (BuildContext context) => OrderDetailPage(
                  order: order,
                )));
        break;
      default:
        NavigationService.navKey.currentState.pushNamed(UIData.NOTIFICATION);
        break;
    }
  }

  showNotification(String title, String body, String type) async {
    var android = new AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
        priority: Priority.High, importance: Importance.Max);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(0, title, body, platform,
        payload: type);
  }

  @override
  void initState() {
    super.initState();
    // Load configs & master data
    loadConfigurations();

    //FCM
    firebaseCloudMessagingListeners();

    //Local Notification
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSetttings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
          child: Image.asset('assets/images/logo_b2.png', fit: BoxFit.cover)),
    );
  }
}
