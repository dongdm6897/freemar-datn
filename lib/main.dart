import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/ui/pages/notification/notification_page.dart';
import 'package:flutter_rentaza/ui/pages/payment/account_manager.dart';
import 'package:flutter_rentaza/ui/pages/product/buy_manager.dart';
import 'package:flutter_rentaza/ui/pages/product/create_product.dart';
import 'package:flutter_rentaza/ui/pages/product/home.dart';
import 'package:flutter_rentaza/ui/pages/product/interest_products.dart';
import 'package:flutter_rentaza/ui/pages/product/product_detail.dart';
import 'package:flutter_rentaza/ui/pages/product/search/detailed_search.dart';
import 'package:flutter_rentaza/ui/pages/product/search/ranking.dart';
import 'package:flutter_rentaza/ui/pages/product/search/search.dart';
import 'package:flutter_rentaza/ui/pages/product/sell_manager.dart';
import 'package:flutter_rentaza/ui/pages/product/shopping.dart';
import 'package:flutter_rentaza/ui/pages/setting/contact_address.dart';
import 'package:flutter_rentaza/ui/pages/setting/phone_number_auth.dart';
import 'package:flutter_rentaza/ui/pages/setting/push_notifications.dart';
import 'package:flutter_rentaza/ui/pages/setting/settings.dart';
import 'package:flutter_rentaza/ui/pages/splash_screen.dart';
import 'package:flutter_rentaza/ui/pages/user/edit_profile.dart';
import 'package:flutter_rentaza/ui/pages/user/forget_password.dart';
import 'package:flutter_rentaza/ui/pages/user/login.dart';
import 'package:flutter_rentaza/ui/pages/user/profile.dart';
import 'package:flutter_rentaza/ui/pages/user/sign_up.dart';
import 'package:flutter_rentaza/utils/custom_style.dart';
import 'package:flutter_rentaza/utils/navigation_service.dart';
import 'package:flutter_rentaza/utils/ui_data.dart';

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      navigatorKey: NavigationService.navKey,
      theme: ThemeData(
          primaryColor: Colors.white,
          accentColor: Colors.red,
          inputDecorationTheme: const InputDecorationTheme(
            focusedBorder:
                UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            labelStyle: TextStyle(color: Colors.black),
          ),
          primaryIconTheme: const IconThemeData(color: Colors.black),
          //color drawer
          accentIconTheme: const IconThemeData(color: Colors.white),
          //color icon floatButton,..
          iconTheme: IconThemeData(color: CustomStyle.iconInterest),
          buttonColor: Colors.red[600]),
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: SplashScreen(),
      routes: <String, WidgetBuilder>{
        UIData.HOMEPAGE: (BuildContext context) => HomePage(),
        UIData.SHOPPING: (BuildContext context) => ShoppingPage(),
        UIData.SEARCH: (BuildContext context) => Search(),
        UIData.SETTINGS: (BuildContext context) => SettingsPage(),
        UIData.CONTACT_ADDRESS: (BuildContext context) => ContactAddressPage(),
        UIData.SET_UP_NOTIFICATIONS: (BuildContext context) =>
            SetPushNotificationPage(),
        UIData.PHONE_AUTH: (BuildContext context) => PhoneAuthPage(),
        UIData.CREATE_PRODUCT: (BuildContext context) => CreateProduct(),
        UIData.PRODUCT_DETAIL: (BuildContext context) => ProductDetailPage(),
        UIData.SELL_MANAGER: (BuildContext context) => SellManagerPage(),
        UIData.BUY_MANAGER: (BuildContext context) => BuyManagerPage(),
        UIData.INTEREST_PRODUCTS: (BuildContext context) =>
            InterestProductPage(),
        UIData.ACCOUNT_MANAGER: (BuildContext context) => AccountManagerPage(),
        UIData.NOTIFICATION: (BuildContext context) => NotificationPage(),
        UIData.LOGIN: (BuildContext context) => LoginPage(),
        UIData.PROFILE: (BuildContext context) => ProfilePage(),
        UIData.EDIT_PROFILE: (BuildContext context) => EditProfile(),
        UIData.RANK_PAGE: (BuildContext context) => RankPage(),
        UIData.DETAILED_SEARCH: (BuildContext context) => DetailedSearch(),
        UIData.SIGN_UP: (BuildContext context) => SignupPage(),
        UIData.FORGET_PASSWORD: (BuildContext context) => ForgetPassword(),
      },
    );
  }
}
