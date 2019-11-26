import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/address_bloc.dart';
import 'package:flutter_rentaza/models/Address/district.dart';
import 'package:flutter_rentaza/models/Address/province.dart';
import 'package:flutter_rentaza/models/Address/street.dart';
import 'package:flutter_rentaza/models/Address/ward.dart';
import 'package:flutter_rentaza/ui/widgets/dropdown.dart' as CustomDropdown;

class Address extends StatefulWidget {
  final Function callBack;
  final Province province;
  final District district;
  final Ward ward;
  final String address;

  const Address(
      {Key key,
      this.callBack,
      this.province,
      this.district,
      this.ward,
      this.address})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddressState();
  }
}

class AddressState extends State<Address> {
  AddressBloc _addressBloc;
  Province _province;
  District _district;
  Street _street;
  Ward _ward;
  bool _loadedProvice = false, _loadedDistrict = false;

  @override
  void initState() {
    _addressBloc = AddressBloc();
    _province = widget.province;
    _district = widget.district;
    _ward = widget.ward;
    if (_province != null) {
      _loadedProvice = true;
      _addressBloc.loadDistrict(_province.id).then((value) {
        if (value) {
          _addressBloc.loadWard(_district.id, _province.id);
          _loadedDistrict = true;
        }
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _addressBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder(
        initialData: true,
        stream: _addressBloc.streamLoad,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            return Column(
                children: <Widget>[
              StreamBuilder(
                  stream: _addressBloc.streamProvince,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Province>> snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomDropdown.DropdownButtonHideUnderline(
                          child:
                              CustomDropdown.DropdownButtonFormField<Province>(
                            decoration: InputDecoration(labelText: "Province"),
                            value: _province,
                            validator: (value) {
                              if (value == null)
                                return "You can't leave this empty";
                              return null;
                            },
                            items: snapshot.data
                                .map((val) =>
                                    CustomDropdown.DropdownMenuItem<Province>(
                                      value: val,
                                      child: Text(val.name),
                                    ))
                                .toList(),
                            onChanged: (value) async {
                              setState(() {
                                _province = value;
                                _district = null;
                                _ward = null;
                                _street = null;
                                _loadedProvice = false;
                              });
                              bool res =
                                  await _addressBloc.loadDistrict(value.id);
                              setState(() {
                                _loadedProvice = res;
                              });
                            },
                          ),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    );
                  }),
              _province != null
                  ? StreamBuilder(
                      stream: _addressBloc.streamDistrict,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<District>> snapshot) {
                        if (snapshot.hasData &&
                            snapshot.data != null &&
                            _loadedProvice) {
//                          if (widget.district != null) {
//                            _district = snapshot.data.firstWhere(
//                                (d) => d.id == widget.district.id,
//                                orElse: () => null);
//                          }
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CustomDropdown.DropdownButtonHideUnderline(
                              child: CustomDropdown.DropdownButtonFormField<
                                  District>(
                                decoration:
                                    InputDecoration(labelText: "District"),
                                validator: (value) {
                                  if (value == null)
                                    return "You can't leave this empty";
                                  return null;
                                },
                                value: _district,
                                items: snapshot.data
                                    .map((val) => CustomDropdown
                                            .DropdownMenuItem<District>(
                                          value: val,
                                          child:
                                              Text(val.prefix + " " + val.name),
                                        ))
                                    .toList(),
                                onChanged: (value) async {
                                  setState(() {
                                    _district = value;
                                    _ward = null;
                                    _street = null;
                                    _loadedDistrict = false;
//                                    _addressBloc.loadStreet(
//                                        _district.id, _district.provinceId);
                                  });
                                  bool res = await _addressBloc.loadWard(
                                      _district.id, _district.provinceId);
                                  setState(() {
                                    _loadedDistrict = res;
                                  });
                                },
                              ),
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        );
                      })
                  : null,
              _district != null
                  ? StreamBuilder(
                      stream: _addressBloc.streamWard,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Ward>> snapshot) {
                        if (snapshot.hasData &&
                            snapshot.data != null &&
                            _loadedDistrict) {
//                          if (widget.ward != null) {
//                            _ward = snapshot.data.firstWhere(
//                                (w) => w.id == widget.ward.id,
//                                orElse: () => null);
//                          }
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CustomDropdown.DropdownButtonHideUnderline(
                              child:
                                  CustomDropdown.DropdownButtonFormField<Ward>(
                                decoration: InputDecoration(labelText: "Ward"),
                                value: _ward,
                                validator: (value) {
                                  if (value == null)
                                    return "You can't leave this empty";
                                  return null;
                                },
                                items: snapshot.data
                                    .map((val) =>
                                        CustomDropdown.DropdownMenuItem<Ward>(
                                          value: val,
                                          child:
                                              Text(val.prefix + " " + val.name),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _ward = value;
                                  });
                                },
                              ),
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        );
                      })
                  : null,
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                      labelText: "Address Details",
                      helperText:
                          "Eg. Sảnh T1-Khu đô thị TimeCity - Minh Khai"),
                  initialValue: widget.address,
                  validator: (value) {
                    if (value.isEmpty)
                      return "You can't leave this empty";
                    else if (value.length < 5)
                      return "The address length should be 5 - 350 characters";
                    return null;
                  },
                  onSaved: (value) {
                    widget.callBack(
                        value, _province, _district, _ward, _street);
                  },
                ),
              ),
            ]..removeWhere((widget) => widget == null));
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }

  Widget _buildDefault(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        decoration: InputDecoration(labelText: text),
        validator: (value) {
          if (value.isEmpty) return "You can't leave this empty";
          return null;
        },
      ),
    );
  }
}
