import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/Product/attribute.dart';
import 'package:flutter_rentaza/models/Product/attribute_type.dart';
import 'package:flutter_rentaza/models/master_datas.dart';

import 'attribute_widget.dart';

class AttributeSizeWidget extends StatefulWidget {
  final List<Attribute> selectedSizes;

  AttributeSizeWidget({this.selectedSizes});

  @override
  _AttributeSizeWidget createState() => _AttributeSizeWidget();
}

class _AttributeSizeWidget extends State<AttributeSizeWidget> {
  List<AttributeType> _attributeSizeTypes;

  @override
  void initState() {
    if (this.mounted) {
      setState(() {
        _attributeSizeTypes =
            AppBloc().attributeTypeGroups[AttributeTypeGroupEnum.SIZE];
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(AttributeSizeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var lang = S.of(context);

    return SimpleDialog(
        contentPadding: EdgeInsets.all(10.0),
        children: <Widget>[
          Text(
            lang.product_size,
            style: new TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
          Divider(),
          Container(
              width: 450,
              height: _attributeSizeTypes.length * 60.0,
              constraints: BoxConstraints(minHeight: 100, maxHeight: 500),
              child: _attributeSizeTypes.length > 0
                  ? ListView.builder(
                      itemCount: _attributeSizeTypes.length,
                      itemBuilder: (BuildContext content, int index) {
                        var type = _attributeSizeTypes[index];
                        return ListTile(
                            title: Text(type.title),
                            onTap: () async {
                              // Display list of values
                              var values = type.attributes;
                              var retSize = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    if (values.length > 0)
                                      return AttributeOptionList(
                                          attribute: values.first,
                                          isMultiSelect: true,
                                          selectedOptions: widget.selectedSizes,
                                          options: values);
                                    return SimpleDialog();
                                  });
                              Navigator.pop(context, retSize);
                            });
                      })
                  : Center(child: CircularProgressIndicator()))
        ]);
  }
}
