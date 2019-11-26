import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/user_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/User/identify_photo.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/models/master_datas.dart';
import 'package:flutter_rentaza/ui/pages/image/crop_multi_image.dart';
import 'package:flutter_rentaza/ui/pages/product/search/storage/file_storage.dart';
import 'package:flutter_rentaza/ui/widgets/dropdown.dart' as CustomDropdown;
import 'package:flutter_rentaza/ui/widgets/shipping_address_list.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

const List<String> presetTags = const ['ID', 'Passport', 'Driver License'];
const int imgFront = 0;
const int imgBack = 1;
const int stepSimple = 0;
const int stepMedium = 1;
//const int stepHigh = 2;

// ignore: must_be_immutable
class UserAuthentication extends StatefulWidget {
  final User user;
  Function(File, int) callback;
  File imageFont;
  File imageBack;

  UserAuthentication(
      {Key key, this.user, this.callback, this.imageFont, this.imageBack})
      : super(key: key);

  @override
  _UserAuthentication createState() => new _UserAuthentication();
}

class _UserAuthentication extends State<UserAuthentication> {
  int currStep = stepSimple;
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _codeController = TextEditingController();
  String validationBy = presetTags[0];

  User _user;
  UserBloc _userBloc;
  final FileStorage fileStorage = FileStorage();
  IdentifyPhoto _identifyPhoto;
  bool _saving = false;

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

  Future getImageFont() async {
    var image = await _handleImagesSelectButton(context);
    if (image != null) {
      widget.callback(image[0], imgFront);
    }
  }

  Future getImageBack() async {
    var image = await _handleImagesSelectButton(context);
    if (image != null) widget.callback(image[0], imgBack);
  }

  @override
  void initState() {
    super.initState();
    _user = widget.user ?? AppBloc().loginUser;
    _userBloc = UserBloc();
    _identifyPhoto = _user.identifyPhoto;
    this.currStep = getCurrentStep();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void nextStep() {
    currStep = stepSimple;
  }

  int getCurrentStep() {
    var st = _user.status;
    var tmp = stepSimple;
    if (UserStatus.SIMPLE <= st) {
      tmp = stepMedium;
    }

    return tmp;
  }

  _handleSelectShippingAddress(BuildContext context) async {
    var ret = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ShippingAddressListWidget(user: _user);
      },
    );
    if (ret != null) {
      setState(() {
        _user.currentShippingAddressObj = ret;
      });
    }
  }

  Widget buildChangeImage(BuildContext context, File image, int getImage) =>
      Container(
        height: currStep == stepMedium ? 200.0 : 0,
        child: Ink.image(
          image: image != null
              ? AssetImage(image.path)
              : _identifyPhoto != null
                  ? getImage == imgFront
                      ? NetworkImage(_identifyPhoto.frontImageLink)
                      : NetworkImage(_identifyPhoto.backImageLink)
                  : ExactAssetImage('assets/images/bg-summer.jpg'),
          fit: BoxFit.cover,
          child: _user.status == UserStatus.SIMPLE
              ? InkWell(
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
                            if (getImage == imgFront) {
                              getImageFont();
                            } else {
                              getImageBack();
                            }
                          },
                          child: Text("Change",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ))
              : Center(),
        ),
      );

  Widget buildTextFormField(String labelText, String hintText) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          decoration: InputDecoration(labelText: labelText, hintText: hintText),
          keyboardType: TextInputType.text,
          enabled: true,
          autocorrect: false,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter $labelText';
            }
            return null;
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    final lang = S.of(context);
    return ModalProgressHUD(
        inAsyncCall: _saving,
        child: Theme(
          data: Theme.of(context).copyWith(primaryColor: Colors.green),
          child: Stepper(
            controlsBuilder: (BuildContext context,
                {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
              return Row(
//            mainAxisAlignment: MainAxisAlignment.start,
//            children: <Widget>[
//              RaisedButton(
//                color: Colors.green,
//                onPressed: onStepContinue,
//                child: const Text(
//                  "Continue",
//                  style: TextStyle(color: Colors.white),
//                ),
//              ),
//            ],
                  );
            },
            steps: [
              Step(
                  title: Text('Simple'),
                  subtitle: Text("Less than 500.000 VNĐ"),
                  isActive: true,
                  state: StepState.complete,
                  content: Row(
                    children: <Widget>[
                      Text(_user.email ?? _user.snsType),
                      Icon(
                        Icons.check,
                        color: Colors.green,
                      )
                    ],
                  )),
              Step(
                title: Text('Medium'),
                subtitle: SizedBox(
                  child: Text(
                    "Less than 5.000.000 VNĐ",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                isActive: (_user.status >= UserStatus.SIMPLE),
                state: (_user.status >= UserStatus.MEDIUM)
                    ? StepState.complete
                    : (_user.status >= UserStatus.SIMPLE)
                        ? StepState.editing
                        : StepState.indexed,
                content: (_user.status >= UserStatus.SIMPLE)
                    ? Column(
                        children: <Widget>[
                          _user.status >= UserStatus.MEDIUM
                              ? Center()
                              : Align(
                                  alignment: Alignment.bottomRight,
                                  child: _user.status ==
                                          UserStatus
                                              .MEDIUM_WAITING_FOR_VERIFICATION
                                      ? Text("Waiting for confirm",
                                          style: TextStyle(color: Colors.red))
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            Text('Validation by:'),
                                            SizedBox(width: 8.0),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  top: 5.0,
                                                  bottom: 5.0,
                                                  right: 2.0),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6.0,
                                                      vertical: 2.0),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(24.0),
                                                border: Border.all(
                                                    color: Color(0xff66543D)),
                                              ),
                                              child: CustomDropdown
                                                  .DropdownButtonHideUnderline(
                                                child: CustomDropdown
                                                    .DropdownButton<String>(
                                                  isDense: true,
                                                  value: validationBy,
                                                  items: presetTags
                                                      .map((f) => CustomDropdown
                                                              .DropdownMenuItem<
                                                                  String>(
                                                            child: Text(f),
                                                            value: f,
                                                          ))
                                                      .toList(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      validationBy = value;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                          buildChangeImage(context, widget.imageFont, imgFront),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                          ),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                          ),
                          buildChangeImage(context, widget.imageBack, imgBack),
                          _user.status == UserStatus.SIMPLE
                              ? Align(
                                  alignment: Alignment.bottomRight,
                                  child: RaisedButton(
                                      color: Colors.green,
                                      onPressed: () async {
                                        if (widget.imageFont != null &&
                                            widget.imageBack != null) {
                                          setState(() {
                                            _saving = true;
                                          });
                                          var res = await _userBloc.verifyPhoto(
                                              _user.accessToken,
                                              1,
                                              widget.imageFont,
                                              widget.imageBack);
                                          if (res) {
                                            _user.status = UserStatus
                                                .MEDIUM_WAITING_FOR_VERIFICATION;
                                          } else
                                            Scaffold.of(context).showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        "Authentication failed")));
                                          setState(() {
                                            _saving = false;
                                          });
                                        } else
                                          Scaffold.of(context).showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      "Image cannot be empty")));
                                      },
                                      child: Text(
                                        "Xác thực",
                                        style: TextStyle(color: Colors.white),
                                      )),
                                )
                              : SizedBox()
                        ],
                      )
                    : SizedBox(),
              ),
//          Step(
//              title: const Text('High'),
//              subtitle: Text("Greater than 5.000.000 VNĐ"),
//              isActive:
//              (_user.status >= UserStatus.MEDIUM) ? true : false,
//              state: (_user.status >= UserStatus.HIGH)
//                  ? StepState.complete
//                  : (_user.status >= UserStatus.MEDIUM)
//                  ? StepState.editing
//                  : StepState.indexed,
//              // state: StepState.disabled,
//              content: (_user.status >= UserStatus.HIGH)
//                  ? Column(
//                children: <Widget>[
//                  Row(
//                    children: <Widget>[
//                      Text("Ha Noi"),
//                      Icon(
//                        Icons.check,
//                        color: Colors.green,
//                      )
//                    ],
//                  ),
//                  Row(
//                    children: <Widget>[
//                      Text(_user.phone),
//                      Icon(
//                        Icons.check,
//                        color: Colors.green,
//                      )
//                    ],
//                  )
//                ],
//              )
//                  : _user.status ==
//                  UserStatus.HIGH_WAITING_FOR_VERIFICATION
//                  ? Padding(
//                padding: const EdgeInsets.all(8.0),
//                child: TextFormField(
//                  controller: _codeController,
//                  decoration:
//                  InputDecoration(labelText: "Code"),
//                  keyboardType: TextInputType.text,
//                  enabled: true,
//                  autocorrect: false,
//                  validator: (value) {
//                    if (value.isEmpty) {
//                      if (_user.status >= UserStatus.MEDIUM) {
//                        setState(() {
//                          this.currStep = stepHigh;
//                        });
//                      }
//                      return 'Please enter code';
//                    }
//                    return null;
//                  },
//                ),
//              )
//                  : _user.status == UserStatus.MEDIUM
//                  ? Container(
//                padding: EdgeInsets.all(10.0),
//                child: GestureDetector(
//                  child: Text(
//                    _user.currentShippingAddressObj
//                        ?.toString() ??
//                        lang.message_not_set,
//                    style: TextStyle(
//                        decoration:
//                        TextDecoration.underline),
//                  ),
//                  onTap: () =>
//                      _handleSelectShippingAddress(context),
//                ),
//              )
//                  : Container()),
            ],
            type: StepperType.vertical,
            currentStep: this.currStep,
            onStepContinue: () async {
              switch (_user.status) {
                case UserStatus.SIMPLE:
                  if (widget.imageFont != null && widget.imageBack != null) {
                    var res = await _userBloc.verifyPhoto(_user.accessToken, 1,
                        widget.imageFont, widget.imageBack);
                    if (res) {
                      setState(() {
                        _user.status =
                            UserStatus.MEDIUM_WAITING_FOR_VERIFICATION;
                      });
                    } else
                      Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text("Authentication failed")));
                  } else
                    Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text("Image cannot be empty")));
                  break;
                case UserStatus.MEDIUM_WAITING_FOR_VERIFICATION:
                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text("Waiting for Verification")));
                  break;
//            case UserStatus.MEDIUM:
//              setState(() {
//                _user.status = UserStatus.HIGH_WAITING_FOR_VERIFICATION;
//              });
//                    final FormState formState = _formKey.currentState;
//                    if(formState.validate()){
//                      String res = _userBloc.verifyAddress(
//                          _addressController.value.text,
//                          _phoneController.value.text,
//                          _user.id);
//                      if (res.isNotEmpty) {
//                        setState(() {
//                          _user.status = UserStatus.HIGH_WAITING_FOR_VERIFICATION;
//                        });
//                      }
//                    }
//              break;
//            case UserStatus.HIGH_WAITING_FOR_VERIFICATION:
//                    String res = _userBloc.verifyAddress(
//                        _addressController.value.text,
//                        _phoneController.value.text,
//                        _user.id);
//                    if (res == _codeController.value.text) {
//                      var result =
//                          _userBloc.updateUserStatus(UserStatus.HIGH, _user.id);
//                      if (result) {
//                        setState(() {
//                          _user.status = UserStatus.HIGH;
//                        });
//                        nextStep();
//                      }
//                    }
//              break;
//            case UserStatus.HIGH:
//              break;
                default:
                  break;
              }
            },
            onStepCancel: () {
              setState(() {
                if (currStep > stepSimple) {
                  currStep = currStep - 1;
                } else {
                  currStep = stepSimple;
                }
              });
            },
            onStepTapped: (step) {
              if ((step) > getCurrentStep()) {
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text("Complete the previous steps")));
              } else {
                setState(() {
                  currStep = step;
                });
              }
            },
          ),
        ));
  }
}
