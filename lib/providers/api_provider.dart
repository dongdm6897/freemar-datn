import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart'
    show Client, MultipartFile, MultipartRequest, Response;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:simple_logger/simple_logger.dart';

class ApiProvider {
  GlobalConfiguration _config = new GlobalConfiguration();
  final SimpleLogger _logger = SimpleLogger()..mode = LoggerMode.print;

  Client _client = Client();
  String apiKey = "";
  String apiBaseUrl = "";
  String apiUrlSuffix = "";

  String apiUploadBaseUrl = "";

  String mockupDataPath = "";

  ApiProvider() {
    apiKey = _config.getString("api_key");
    apiBaseUrl = _config.getString("base_url");
    apiUrlSuffix = _config.getString("url_suffix");
  }

  String _makeRequest(String command, Map params) {
    if (params != null) {
      String data = "";
      params.forEach((key, value) => data += "$key=$value&");
      return "$apiBaseUrl$apiUrlSuffix/$command?$data";
    } else
      return "$apiBaseUrl$apiUrlSuffix/$command";
  }

  Future<dynamic> getData(String command, Map params,
      {String root = ''}) async {
    var jsonData;

    // Get json data
    if (apiBaseUrl != "") {
      var request = _makeRequest(command, params);
      final response = await _client.get(request, headers: {
        'Authorization':
            'Bearer ${params != null ? params['access_token'] : ''}'
      });
      _logger.info('Request: $request');
      _logger.info('Response: ${response.body}');

      if (response?.statusCode == 200) {
        // If the call to the server was successful, parse the JSON
        //Try to use isolate here
        //jsonData = json.decode(response.body);
        if (response.headers['content-type'].contains('json'))
          jsonData = compute(jsonDecode, response.body);
      }
    }

    // TODO: use mock data for debugging
    if (jsonData == null && mockupDataPath != "") {
      final mockData = await Future.delayed(new Duration(seconds: 1),
          () => rootBundle.loadString(mockupDataPath));

      //Try to use isolate here
      jsonData = compute(decodeMockupData, {"data": mockData, "root": root});
    }
    return jsonData;
  }

  // Try to use isolate to decode mockup data
  static dynamic decodeMockupData(dynamic params) {
    final mockData = params["data"];
    final root = params["root"];
    var jsonData = jsonDecode(mockData);
    if (root != '') {
      jsonData = jsonData[root];
    }
    return jsonData;
  }

  Future<dynamic> postData(String command, Map params) async {
    var jsonData;

    if (apiBaseUrl != "") {
      String url;
      url = "$apiBaseUrl";
      if (command != null && command.isNotEmpty) {
        url = "$apiBaseUrl$apiUrlSuffix/$command";
      }
      String accessToken = params != null ? params['access_token'] : '';
      params.remove('access_token');
      _logger.info('Params: $params');
      final response = await _client.post(
        url,
        body: json.encode(params),
        encoding: Encoding.getByName('utf-8'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
      );
      _logger.info('Request: $url');

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        _logger.info("RESPONSE ${response.body}");
        jsonData = json.decode(response.body);
      }
    }

    // FIXME: user mockup data
    if (jsonData == null && mockupDataPath != "") {
      //response local
      final mockData = await Future.delayed(new Duration(seconds: 0),
          () => rootBundle.loadString(mockupDataPath));
      return json.decode(mockData)["updated"];
    }

    return jsonData;
  }

  Future<bool> putData(String command, Map params) async {
    if (apiBaseUrl != "") {
      final response = await _client.put(apiBaseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': apiKey
          },
          body: json.encode(params));
      if (response?.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    }
    return true;
  }

  Future<bool> deleteData(String command, Map params) async {
    if (apiBaseUrl != "") {
      var request = _makeRequest(command, params);
      final response = await _client.delete(request, headers: {
        'Authorization':
            'Bearer ${params != null ? params['access_token'] : ''}'
      });

      if (response?.statusCode == 200) {
        return true;
      }
    }
    return false;
  }

  /// Function for uploading file or image to server
  /// For testing
  /// https://api.imgur.com
  /// Authorization: Client-ID YOUR_CLIENT_ID
  /// Client ID: 7f8547296f80c4c
  /// Client secret: 804ab66b6d2055aa476e7717caac94019411d1a3
  ///

  Future<String> uploadFile(File file, String token) async {
    String base64Data = base64Encode(file.readAsBytesSync());
    String fileName = file.path.split("/").last;
    _logger.info("[uploadFile] fileName=$fileName");

    if (apiBaseUrl != "") {
      print("token $token");
      var response = await http.post("$apiBaseUrl/upload/image",
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: json.encode({
            "data": base64Data,
            "name": fileName,
          }));

      try {
        var responseBody = jsonDecode(response.body);
        _logger.info("[uploadFile] responseBody=$responseBody");
        return (response.statusCode == 200)
            ? responseBody["data"]["link"]
            : null;
      } catch (e) {
        return null;
      }
    } else {
      // TODO: For testing purpose
      var response = await http.post("https://api.imgur.com/3/image",
          body: {"image": base64Data, "name": fileName},
          headers: {"Authorization": "Client-ID 7f8547296f80c4c"});

      _logger.info("[uploadFile] response=${response?.body}");
      return (response != null && response.statusCode == 200)
          ? jsonDecode(response.body)["data"]["link"]
          : null;
    }
  }

  Future<List<String>> uploadFiles(List<File> files, String token) async {
    if (apiBaseUrl != "") {
      Uri uri = Uri.parse("$apiBaseUrl/upload/files");
      MultipartRequest request = http.MultipartRequest("POST", uri);
      for (int i = 0; i < files.length; i++) {
        request.files.add(await http.MultipartFile.fromPath(
            'file$i', files[i].path,
            contentType: new MediaType('application', 'x-tar')));
      }
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      });
      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      var results = json.decode(responseString);
      if (results['success']) {
        return List<String>.from(results['data']['link']);
      }
    }
    return null;
  }

  uploadImages(List imageData, String token) async {
    if (apiBaseUrl != "") {
      Uri uri = Uri.parse("$apiBaseUrl/upload/images");

      MultipartRequest request = http.MultipartRequest("POST", uri);
      MultipartFile multipartFile;

      for (int i = 0; i < imageData.length; i++) {
        multipartFile = MultipartFile.fromBytes(
          'photo$i',
          imageData[i],
          filename: 'some-file-name.jpg',
          contentType: MediaType("image", "jpg"),
        );
        request.files.add(multipartFile);
      }

      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      });

      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      return responseString;
    }
  }
}
