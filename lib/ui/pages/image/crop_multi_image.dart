import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as Img;
import 'package:image_crop/image_crop.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class CropMultiImagePage extends StatefulWidget {
  final List<Asset> assets;

  const CropMultiImagePage({Key key, this.assets}) : super(key: key);

  @override
  State createState() => _CropMultiImagePage();
}

class _CropMultiImagePage extends State<CropMultiImagePage> {
  final cropKey = GlobalKey<CropState>();

  bool _crop = false;
  bool _handle = true;
  final List<File> results = <File>[];
  int index = 0;

  List<int> _lastBrightness;
  double _value = 0.0;
  bool _isBrightnessCalculating = false;

  var uuid = new Uuid();

  List<List<int>> imageData = [];

  @override
  initState() {
    flutterImageCompress().then((listImageCompress) {
      setState(() {
        imageData = listImageCompress;
        _handle = false;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit image editting?'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  onValueChanged(double value) async {
    setState(() {
      _handle = true;
    });

    _changeBrightnessValue(_value);
  }

  _changeBrightnessValue(double value) async {
    if (!_isBrightnessCalculating) {
      _isBrightnessCalculating = true;
      _brightnessImage(value).then((image) {
        _lastBrightness = image;
        setState(() {
          _handle = false;
        });
        _isBrightnessCalculating = false;
      });
    }
  }

  Future<List<int>> _brightnessImage(double value) async {
    return compute(processChangeBrightness, {
      "data": Img.decodeImage(imageData[index]),
      "brightness": value.toInt()
    });
  }

  // Isolate implementation
  static List<int> processChangeBrightness(dynamic params) {
    final data = params["data"];
    final brightness = params["brightness"];
    if (data != null) return Img.encodePng(Img.brightness(data, brightness));
    return null;
  }

  Future<List<List<int>>> flutterImageCompress() async {
    List<List<int>> imageCompress = [];
    for (var asset in widget.assets) {
      ByteData byteData = await asset.requestOriginal(quality: 100);
      List<int> imageData = byteData.buffer.asUint8List();
      List<int> result = await FlutterImageCompress.compressWithList(
        imageData,
        minWidth: 1080,
        minHeight: 720,
        quality: 100,
      );
      imageCompress.add(result);
    }
    return imageCompress ?? null;
  }

  Widget _buildListCroppingImage() {
    return Theme(
      data: new ThemeData(
          backgroundColor: Colors.black, scaffoldBackgroundColor: Colors.black),
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 25.0,
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Image ${index + 1} / ${imageData.length}',
                style: Theme.of(context)
                    .textTheme
                    .button
                    .copyWith(color: Colors.white),
              ),
            ),
            Expanded(
              child: _crop
                  ? Center(
                      child: Crop(
                        image: MemoryImage(Uint8List.fromList(
                            _lastBrightness ?? imageData[index])),
                        key: cropKey,
                      ),
                    )
                  : Center(
                      child: Image(
                          image: MemoryImage(_lastBrightness ??
                              Uint8List.fromList(imageData[index]))),
                    ),
            ),
            _buildBrightnessImage(),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FlatButton.icon(
                onPressed: () {
                  setState(() {
                    _crop = _crop ? false : true;
                  });
                },
                icon: Icon(
                  Icons.crop,
                  color: _crop ? Colors.orange : Colors.white,
                ),
                label: Text(
                  "Crop",
                  style: TextStyle(color: _crop ? Colors.orange : Colors.white),
                ),
              ),
              FlatButton.icon(
                onPressed: () => _listCropImage(),
                icon: Icon(
                  Icons.save,
                  color: Colors.white,
                ),
                label: Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _listCropImage() async {
    setState(() {
      _handle = true;
    });

    final tempDir = await getTemporaryDirectory();
    var imageTemp = uuid.v1();
    final originalFile = await File(tempDir.path + "/img_crop_$imageTemp.png")
        .writeAsBytes(_lastBrightness ?? imageData[index], flush: true);

    final crop = cropKey.currentState;
    File file;

    if (crop != null) {
//      final sampledFile = await ImageCrop.sampleImage(
//        file: originalFile,
//        preferredWidth: (1080 / crop.scale).round(),
//        preferredHeight: (720 / crop.scale).round(),
//      );

      file = await ImageCrop.cropImage(
        file: originalFile,
        area: crop.area,
      );
    }
    results.add(file ?? originalFile);

    // If all file was processed, return it. Else process next image
    if (results.length >= imageData.length) {
      Navigator.pop(context, results);
    } else {
      setState(() {
        _handle = false;
        index++;
        _lastBrightness = null;
        _value = 0;
        _crop = false;
      });
    }
  }

  Widget _buildBrightnessImage() {
    return Column(
      children: <Widget>[
        Center(
          child: Text(
            _value.toInt().toString(),
            style: TextStyle(color: Colors.white),
          ),
        ),
        Center(
          child: Slider(
            value: _value,
            onChanged: (double value) {
              setState(() {
                _value = value;
              });
            },
            onChangeEnd: onValueChanged,
            min: -50,
            max: 50,
            activeColor: Colors.white,
            inactiveColor: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: ModalProgressHUD(
            inAsyncCall: _handle,
            child: (imageData != null && imageData.length > 0)
                ? _buildListCroppingImage()
                : SizedBox()));
  }
}
