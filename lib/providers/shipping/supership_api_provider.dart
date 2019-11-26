import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' show Client;

class SuperShipApiProvider {
  Client _client = Client();

  Future ordersFee() async {
    var response = await _client.get(
        "https://api.mysupership.vn/v1/partner/orders/fee?sender_province=H%E1%BB%93%20Ch%C3%AD%20Minh&sender_district=B%C3%ACnh%20Ch%C3%A1nh&receiver_province=H%C3%A0%20N%E1%BB%99i&receiver_district=T%C3%A2y%20H%E1%BB%93&weight=200&value=12000000");

    if (response?.statusCode == 200) {
      var jsonData = json.decode(response.body);

      print("Orders Fee $jsonData");
    }
  }

  Future ordersAdd() async {
    Map<String, dynamic> data = Map();
    data = {
      "pickup_phone": "0989999999",
      "pickup_address": "45 Nguyễn Chí Thanh",
      "pickup_commune": "Ngọc Khánh",
      "pickup_district": "Ba Đình",
      "pickup_province": "Hà Nội",
      "name": "Trương Thế Ngọc",
      "phone": "0945900350",
      "email": null,
      "address": "35 Trương Định",
      "province": "Hồ Chí Minh",
      "district": "Quận 3",
      "commune": "Phường 6",
      "amount": "220000",
      "value": null,
      "weight": "200",
      "payer": "1",
      "service": "1",
      "config": "1",
      "soc": "KAN7453535",
      "note": "Giao giờ hành chính",
      "product_type": "2",
      "products": [
        {
          "sku": "P899234",
          "name": "Tên Sản Phẩm 1",
          "price": 200000,
          "weight": 200,
          "quantity": 1
        },
        {
          "sku": "P899789",
          "name": "Tên Sản Phẩm 2",
          "price": 250000,
          "weight": 300,
          "quantity": 2
        }
      ]
    };
    final response = await _client.post(
      "https://api.mysupership.vn/v1/partner/orders/add",
      body: json.encode(data),
      encoding: Encoding.getByName('utf-8'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ZT2PS0pmHPHDKjRu6EMIcoM8rFM8XYHZ1Ye3zRiQ'
      },
    );
    if (response?.statusCode == 200) {
      var jsonData = json.decode(response.body);

      print("Orders Add $jsonData");
    }
  }

  Future ordersInfo() async {
    var response = await _client.get(
        "https://api.mysupership.vn/v1/partner/orders/info?code=S521788SGNT.0302429");

    if (response?.statusCode == 200) {
      var jsonData = json.decode(response.body);

      print("Orders Info $jsonData");
    }
  }

  Future orderCancel() async {
    Map<String, String> data = Map();
    data = {"code": "S521788SGNT.0302429"};
    final response = await _client.post(
      "https://api.mysupership.vn/v1/partner/orders/cancel",
      body: json.encode(data),
      encoding: Encoding.getByName('utf-8'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ZT2PS0pmHPHDKjRu6EMIcoM8rFM8XYHZ1Ye3zRiQ'
      },
    );

    if (response?.statusCode == 200) {
      var jsonData = json.decode(response.body);

      print("Orders Cancel $jsonData");
    }
  }
}
