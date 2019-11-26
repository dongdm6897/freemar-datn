import 'dart:io';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/user_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/ui/pages/image/crop_multi_image.dart';
import 'package:flutter_rentaza/ui/pages/product/search/storage/file_storage.dart';
import 'package:flutter_rentaza/ui/widgets/ship_provider_list.dart';
import 'package:flutter_rentaza/ui/widgets/shipping_address_list.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class EditProfile extends StatefulWidget {
  @override
  State createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  File _avatar;
  File _coverImage;
  User _user;
  final FileStorage fileStorage = FileStorage();
  final _formKey = GlobalKey<FormState>();
  UserBloc _userBloc;
  FocusNode textNameFN = FocusNode();
  FocusNode textIntroFN = FocusNode();
  FocusNode textShopNameFN = FocusNode();

  @override
  void initState() {
    _userBloc = UserBloc();
    _user = AppBloc().loginUser;
    super.initState();
  }

  @override
  void dispose() {
    _userBloc.dispose();
    textNameFN.dispose();
    textIntroFN.dispose();
    textShopNameFN.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = S.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(lang.edit_profile),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(lang.profile_settings),
                  ),
                  Row(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(5.0),
                            decoration: BoxDecoration(boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.white.withOpacity(0.1),
                                blurRadius: 5.0,
                              ),
                            ]),
                            height: 100.0,
                            width: 100.0,
                            child: CircleAvatar(
                              backgroundImage: _avatar != null
                                  ? AssetImage(_avatar.path)
                                  : _user.avatar != null
                                      ? NetworkImage(_user.avatar)
                                      : AssetImage(
                                          "assets/images/default_avatar.png"),
                            ),
                          ),
                          Positioned(
                            top: 30.0,
                            left: 10.0,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(14.0)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    getImageAvatar(context);
                                  },
                                  child: Text(lang.change,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: TextFormField(
                          focusNode: textNameFN,
                          initialValue: _user?.name,
                          maxLength: 15,
                          decoration: InputDecoration(
                            labelText: lang.nick_name,
                          ),
                          keyboardType: TextInputType.multiline,
                          enabled: true,
                          validator: (value) {
                            if (value.isEmpty) return "Name cannot be empty";
                            return null;
                          },
                          onSaved: (value) {
                            _user?.name = value;
                          },
                          enableInteractiveSelection: false,
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    focusNode: textIntroFN,
                    initialValue: _user?.introduction,
                    maxLength: 1000,
                    decoration: InputDecoration(
                      labelText: lang.self_introduction,
                    ),
                    keyboardType: TextInputType.multiline,
                    enabled: true,
                    maxLines: 5,
                    onSaved: (value) {
                      _user?.introduction = value;
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Text(
                      "Ảnh nền",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Container(
                    height: 250.0,
                    child: Ink.image(
                      image: _coverImage != null
                          ? AssetImage(_coverImage.path)
                          : _user.coverImageLink != null
                              ? NetworkImage(_user.coverImageLink)
                              : AssetImage('assets/images/bg-summer.jpg'),
                      fit: BoxFit.cover,
                      child: InkWell(
                          onTap: () {},
                          child: Center(
                            child: Container(
                              width: 200.0,
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    getImageBackground(context);
                                  },
                                  child: Text(lang.change,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          )),
                    ),
                  ),
                  Divider(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Default Shipping Address",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Container(
                        padding: EdgeInsets.all(10.0),
                        child: GestureDetector(
                          child: Text(
                            _user?.currentShippingAddressObj?.toString() ??
                                lang.message_not_set,
                            style:
                                TextStyle(decoration: TextDecoration.underline),
                          ),
                          onTap: () => _handleSelectShippingAddress(context),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Default Shipping Provider",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Container(
                        padding: EdgeInsets.all(10.0),
                        child: GestureDetector(
                          child: Text(
                            _user?.currentShipProvider?.toString() ??
                                lang.message_not_set,
                            style:
                                TextStyle(decoration: TextDecoration.underline),
                          ),
                          onTap: () => _handleSelectShipProvider(context),
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          child: Text(
                            lang.cancel,
                            style: Theme.of(context)
                                .textTheme
                                .subhead
                                .copyWith(color: Colors.red),
                          ),
                          color: Colors.white,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          child: Text(
                            lang.save,
                            style: Theme.of(context)
                                .textTheme
                                .subhead
                                .copyWith(color: Colors.white),
                          ),
                          color: Colors.red,
                          onPressed: () {
                            _handleSubmitButton();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  _handleSelectShippingAddress(BuildContext context) async {
    unFocusNode();
    var ret = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ShippingAddressListWidget(user: _user);
      },
    );

    setState(() {
      _user?.currentShippingAddressObj = ret;
    });
  }

  _handleSelectShipProvider(BuildContext context) async {
    unFocusNode();
    var ret = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ShipProviderListWidget();
      },
    );

    setState(() {
      _user?.currentShipProvider = ret;
    });
  }

  _handleSubmitButton() async {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      bool res = await _userBloc.setUserInfo(_user, _avatar, _coverImage);
      if (res)
        await Flushbar(
          title: "Update",
          message: "Success",
          duration: Duration(seconds: 3),
          backgroundColor: Colors.green,
        ).show(context);
      else
        await Flushbar(
          title: "Update",
          message: "Failure",
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ).show(context);
    }
  }

  _handleImagesSelectButton(BuildContext context) async {
    try {
      // Get images from picker
      var assets = await MultiImagePicker.pickImages(
          maxImages: 1,
          enableCamera: true,
          cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
          materialOptions: MaterialOptions(
              actionBarColor: "#abcdef",
              actionBarTitle: "Baibai app",
              allViewTitle: "All Photos"));

      if (assets != null) {
        // Call crop image page to operate
        if (this.mounted && assets.length > 0) {
          var results = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => CropMultiImagePage(
                        assets: assets,
                      )));
          return results;
        }
      }
    } on PlatformException catch (e) {
      print(e.message);
    } on Exception catch (e) {
      print(e.toString());
    } finally {
      if (this.mounted) {
        setState(() {
//          _saving = false;
        });
      }
    }
  }

  Future getImageAvatar(context) async {
    var image = await _handleImagesSelectButton(context);
    if (image != null) {
      setState(() {
        _avatar = image[0];
      });
    }
  }

  Future getImageBackground(context) async {
    var image = await _handleImagesSelectButton(context);
    if (image != null) {
      setState(() {
        _coverImage = image[0];
      });
    }
  }

  unFocusNode() {
    textNameFN.unfocus();
    textIntroFN.unfocus();
    textShopNameFN.unfocus();
  }
}
