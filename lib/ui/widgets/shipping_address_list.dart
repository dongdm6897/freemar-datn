import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/user_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/Address/district.dart';
import 'package:flutter_rentaza/models/Address/province.dart';
import 'package:flutter_rentaza/models/Address/street.dart';
import 'package:flutter_rentaza/models/Address/ward.dart';
import 'package:flutter_rentaza/models/User/shipping_address.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/ui/widgets/address.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ShippingAddressListWidget extends StatefulWidget {
  final User user;

  ShippingAddressListWidget({@required this.user});

  @override
  _ShippingAddressListWidget createState() => _ShippingAddressListWidget();
}

class _ShippingAddressListWidget extends State<ShippingAddressListWidget> {
  User _user;
  List<ShippingAddress> _shippingAddress;
  UserBloc _userBloc;

  @override
  void initState() {
    _userBloc = UserBloc();
    _user = widget.user;
    _shippingAddress = _user.shippingAddressObjs ?? [];
    super.initState();
  }

  @override
  void dispose() {
    _userBloc.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ShippingAddressListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var lang = S.of(context);
    return SimpleDialog(contentPadding: EdgeInsets.all(10.0), children: <
        Widget>[
      new Row(
        children: <Widget>[
          new Flexible(
              child: Column(
            children: <Widget>[
              Text(
                lang.shipping_address,
                style: new TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              Divider(),
              Container(
                  width: 450,
                  height: _shippingAddress.length * 80.0,
                  constraints: BoxConstraints(minHeight: 100, maxHeight: 500),
                  child: _shippingAddress.length > 0
                      ? ListView.builder(
                          itemCount: _shippingAddress.length,
                          itemBuilder: (BuildContext content, int index) {
                            ShippingAddress item = _shippingAddress[index];
                            return ListTile(
                              title: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(item.name),
                                  Text(
                                    "${item.address} "
                                    "${item.ward != null ? (" - " + item.ward.prefix + " " + item.ward.name) : ""}"
                                    "${item.district != null ? (" - " + item.district.prefix + " " + item.district.name) : ""} - "
                                    "${item.province != null ? (item.province.name) : ""}",
                                    style:
                                        TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      GestureDetector(
                                        child: Icon(Icons.edit, size: 14.0),
                                        onTap: () async {
                                          var shippingAddress =
                                              await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          Scaffold(
                                                              appBar: AppBar(
                                                                  title: Text(
                                                                      'Add new address')),
                                                              body:
                                                                  AddShippingFields(
                                                                user: _user,
                                                                shippingAddress:
                                                                    item,
                                                              ))));
                                          if (shippingAddress != null)
                                            Navigator.pop(
                                                context, shippingAddress);
                                        },
                                      ),
                                      SizedBox(
                                        width: 5.0,
                                      ),
                                      GestureDetector(
                                        child: Icon(Icons.delete, size: 14.0),
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text("Are you sure?"),
                                                  actions: <Widget>[
                                                    FlatButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(false),
                                                      child: new Text('No'),
                                                    ),
                                                    FlatButton(
                                                      onPressed: () {
                                                        _userBloc
                                                            .deleteShippingAddress(
                                                                _user, item.id);
                                                        setState(() {
                                                          _shippingAddress
                                                              .removeAt(index);
                                                        });
                                                      },
                                                      child: new Text('Yes'),
                                                    ),
                                                  ],
                                                );
                                              });
                                        },
                                      ),
                                    ],
                                  ),
                                  Divider()
                                ],
                              ),
                              trailing: (item.id ==
                                      _user?.currentShippingAddressObj?.id)
                                  ? Icon(Icons.check)
                                  : null,
                              onTap: () async {
                                Navigator.pop(context, item);
                              },
                            );
                          })
                      : null),
              Divider(),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: RaisedButton.icon(
                      color: Colors.white,
                      onPressed: () async {
                        var shippingAddress = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => Scaffold(
                                    appBar:
                                        AppBar(title: Text('Add new address')),
                                    body: AddShippingFields(
                                      user: _user,
                                    ))));
                        if (shippingAddress != null)
                          Navigator.pop(context, shippingAddress);
                      },
                      icon: Icon(Icons.add),
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(5.0)),
                      label: Flexible(
                          child: Text(
                        lang.shipping_address_add,
                        overflow: TextOverflow.ellipsis,
                      ))))
            ],
          ))
        ],
      )
    ]);
  }
}

class AddShippingFields extends StatefulWidget {
  final User user;
  final ShippingAddress shippingAddress;

  const AddShippingFields({Key key, this.user, this.shippingAddress})
      : super(key: key);

  @override
  _AddShippingFieldsState createState() => _AddShippingFieldsState();
}

class _AddShippingFieldsState extends State<AddShippingFields> {
  UserBloc _userBloc;
  User _user;
  final _formKey = GlobalKey<FormState>();
  String _fullName, _phoneNumber, _address;
  Province _province;

  District _district;

  Ward _ward;

//  Street _street = Street();
  bool _saving = false;

  @override
  void initState() {
    _userBloc = UserBloc();
    _user = widget.user;
    if (widget.shippingAddress != null) {
      _fullName = widget.shippingAddress.name;
      _phoneNumber = widget.shippingAddress.phoneNumber;
      _address = widget.shippingAddress.address;
      _province = widget.shippingAddress.province;
      _district = widget.shippingAddress.district;
      _ward = widget.shippingAddress.ward;
    }
    super.initState();
  }

  @override
  void dispose() {
    _userBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _submit() async {
      final form = _formKey.currentState;
      if (form.validate()) {
        setState(() {
          _saving = true;
        });
        form.save();
        String fullName = _fullName.trim();
        String phoneNumber = _phoneNumber.trim();
        String address = _address.trim();

        if (this._province != null &&
            this._district != null &&
            this._ward != null) {
          // Create new shipping address
          var addr = ShippingAddress(
            id: widget.shippingAddress?.id ?? null,
            name: fullName,
            phoneNumber: phoneNumber,
            address: address,
            province: this._province,
            district: this._district,
            ward: this._ward,
//          street: this._street,
          );
          var ret = await _userBloc.setNewShippingAddress(_user, addr);
          if (ret != null) {
            ShippingAddress _shipAd;
            if (_user.shippingAddressObjs.length > 0 &&
                widget.shippingAddress != null) {
              _shipAd = _user.shippingAddressObjs.firstWhere(
                  (s) => s.id == widget.shippingAddress?.id,
                  orElse: null);
            }
            if (_shipAd != null) {
              _shipAd.id = ret.id;
              _shipAd.name = ret.name;
              _shipAd.province = ret.province;
              _shipAd.district = ret.district;
              _shipAd.ward = ret.ward;
              _shipAd.phoneNumber = ret.phoneNumber;
              _shipAd.address = ret.address;
            } else {
              _user.shippingAddressObjs.add(ret);
            }
            Fluttertoast.showToast(
                msg: "New shipping address was created.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIos: 2,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
            setState(() {
              _saving = false;
              Navigator.pop(context, ret);
            });
          }
        } else {
          Fluttertoast.showToast(
              msg: "Loading.......",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 2,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
          setState(() {
            _saving = false;
          });
        }
      }
    }

    Widget addShippingFields(context) {
      var lang = S.of(context);
      return Material(
        child: Scaffold(
          body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(labelText: "Full Name"),
                          initialValue: _fullName,
                          validator: (value) {
                            if (value.isEmpty)
                              return "You can't leave this empty";
                            else if (value.length < 2)
                              return "The name length should be 2 - 50 characters";
                            else
                              _fullName = value;
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration:
                              InputDecoration(labelText: "Phone Number"),
                          initialValue: _phoneNumber,
                          validator: (value) {
                            if (value.isEmpty)
                              return "You can't leave this empty";
                            else if (value.length > 11 || value.length < 10)
                              return "Please enter a valid phone number";
                            else
                              _phoneNumber = value;
                            return null;
                          },
                        ),
                      ),
                      Address(
                        callBack: (String address, Province province,
                            District district, Ward ward, Street street) {
                          this._address = address;
                          this._province = province;
                          this._district = district;
                          this._ward = ward;
//                          this._street = street;
                        },
                        province: this._province,
                        district: this._district,
                        ward: this._ward,
                        address: this._address,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 30.0),
                        width: double.infinity,
                        child: RaisedButton(
                          padding: EdgeInsets.all(10.0),
//                          shape: StadiumBorder(),
                          child: Text(
                            lang.save,
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.red,
                          onPressed: () {
                            _submit();
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ModalProgressHUD(
      child: addShippingFields(context),
      inAsyncCall: _saving,
    );
  }
}
