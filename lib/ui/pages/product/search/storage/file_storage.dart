import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class FileStorage {
  Future<String> localPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> localPathTemporary() async{
    final temporary = await getTemporaryDirectory();
    return temporary.path;
  }

  Future<File> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  deleteToFile(String path) {
    return File(path).deleteSync(recursive: true);
  }
}
