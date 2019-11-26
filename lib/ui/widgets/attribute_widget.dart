import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/Product/attribute.dart';
import 'package:flutter_rentaza/models/master_datas.dart';
import 'package:flutter_rentaza/utils/hex_color.dart';
import 'package:flutter_rentaza/utils/icons_helper.dart';
import 'package:simple_logger/simple_logger.dart';

class AttributeWidget extends StatefulWidget {
  final Attribute attribute;
  final bool isEditMode;
  final bool isRequired;
  final bool isShowIcon;
  final bool isMultiSelect;
  final bool isShowCloseButton;
  final List<Attribute> multiSelectAttributes;
  final List<Attribute> options;
  final TextStyle nameTextStyle;
  final TextStyle valueTextStyle;

  final void Function(List<Attribute> newObjs)
      onChanged; // Callback event will be called when attribute changed

  AttributeWidget(this.attribute,
      {this.options,
      this.isEditMode = true,
      this.isRequired = false,
      this.isShowIcon = false,
      this.isMultiSelect = false,
      this.isShowCloseButton = false,
      this.multiSelectAttributes,
      this.onChanged,
      this.nameTextStyle,
      this.valueTextStyle});

  @override
  _AttributeWidgetState createState() => _AttributeWidgetState();
}

class _AttributeWidgetState extends State<AttributeWidget> {
  final _logger = SimpleLogger()..mode = LoggerMode.print;
  AppBloc _appBloc;
  double _iconSize = 20.0;

  List<Attribute> _options;

  @override
  void initState() {
    _appBloc = AppBloc();
    _options = widget.options ??
        (widget.attribute.attributeTypeId != null
            ? _appBloc.attributeTypes
                .where((attr) => attr.id == widget.attribute.attributeTypeId)
                .first
                .attributes
            : []);
//    _options = widget.options ?? [];

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var lang = S.of(context);
    var size = MediaQuery.of(context).size;
    var attribute = widget.attribute;
    var textColor = widget.isRequired ? Colors.red : Colors.grey;
    var hintText = widget.attribute.value;
    if (hintText == null) {
      if (widget.isMultiSelect) {
        hintText = "Unspecified";
      } else if (widget.isEditMode) {
        hintText = widget.isRequired ? lang.type_required : lang.type_optional;
      }
    }

    return InkWell(
      onTap: widget.isEditMode
          ? (() async {
              var results = await _handleSelectOptionValues(context);

              if (results != null) {
//                for (var result in results) {
//                  result.name = attribute.name;
////                  result.typeObj = attribute.typeObj;
//
//                }
                widget.onChanged(results);
              }
            })
          : null,
      child: Row(children: <Widget>[
        (widget.isShowIcon)
            ? Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: Icon(getIconUsingPrefix(name: attribute.iconName),
                    size: _iconSize),
              )
            : const SizedBox(),
        Text(
          attribute.name,
        ),
        Spacer(),
        Flexible(
          child: SizedBox(
              width: size.width / 2,
              child: _buildValueText(context, textColor, hintText)),
        )
      ]),
    );
  }

  Widget _buildValueText(
      BuildContext context, Color textColor, String hintText) {
    _logger.info("Attribute's value: ${widget.attribute.value}");

    var valueWidget = (Attribute attribute) {
      return widget.isEditMode
          ? Text(attribute.value ?? hintText,
              style: TextStyle(
                  color: textColor,
                  fontStyle: FontStyle.italic,
                  decoration: TextDecoration.underline))
          : Text(attribute.value ?? '',
              style: TextStyle(color: textColor, fontStyle: FontStyle.italic));
    };

    var colorWidget = (Attribute attribute) {
      if (attribute.attributeTypeId == AttributeTypeEnum.COLOR &&
          attribute.value != null)
        return Container(
          margin: EdgeInsets.only(right: 3.0),
          width: 20,
          height: 20,
          decoration: new BoxDecoration(
              color: HexColor(attribute.value),
              shape: BoxShape.circle,
              border: new Border.all(color: Colors.grey)),
        );
      return SizedBox();
    };

    if (!widget.isMultiSelect ||
        (widget.multiSelectAttributes?.length ?? 0) == 0) {
      var c = colorWidget(widget.attribute);
      var v = valueWidget(widget.attribute);
      var list = <Widget>[];
      if (c != null) list.add(c);
      if (v != null) list.add(v);

      return Wrap(alignment: WrapAlignment.end, children: list);
    } else {
      var list = <Widget>[];
      if (widget.multiSelectAttributes != null) {
        for (var attribute in widget.multiSelectAttributes) {
          var c = colorWidget(attribute);
          var v = valueWidget(attribute);
          if (c != null) list.add(c);
          if (v != null) list.add(v);
          list.add(Text(', '));
        }
      }
      return Wrap(alignment: WrapAlignment.end, children: list);
    }
  }

  _handleSelectOptionValues(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AttributeOptionList(
              attribute: widget.attribute,
              isMultiSelect: widget.isMultiSelect,
              isShowCloseButton: widget.isShowCloseButton,
              options: _options,
              selectedOptions: widget.multiSelectAttributes);
        });
  }
}

class AttributeOptionList extends StatefulWidget {
  final Attribute attribute;
  final List<Attribute> options;
  final List<Attribute> selectedOptions;
  final bool isMultiSelect;
  final bool isShowCloseButton;

  AttributeOptionList(
      {this.attribute,
      this.options,
      this.selectedOptions,
      this.isMultiSelect,
      this.isShowCloseButton});

  @override
  _AttributeOptionListState createState() => _AttributeOptionListState();
}

class _AttributeOptionListState extends State<AttributeOptionList> {
  List<Attribute> _selectedValues;

  // TODO: Implement searching attribute
  final TextEditingController _searchTextController =
      new TextEditingController();

  @override
  void initState() {
    _selectedValues = new List<Attribute>.from(widget.selectedOptions ?? []);
    super.initState();
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.all(2.0),
      title: widget.isMultiSelect
          ? Row(
              children: <Widget>[
                Text('Select options'),
                Spacer(),
                IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () {
                      Navigator.pop(context, _selectedValues);
                    }),
                (widget.isShowCloseButton ?? false)
                    ? IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        })
                    : const SizedBox(),
              ],
            )
          : null,
      children: <Widget>[
        if (widget.options.length > 20)
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: new TextField(
                        controller: _searchTextController,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search keyword.'))),
              )
            ],
          ),
        Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            height: widget.options.length * 70.0,
            width: 450,
            child: ListView.separated(
                separatorBuilder: (context, index) => Divider(
                      color: Colors.grey,
                    ),
                itemCount: widget.options.length,
                itemBuilder: (BuildContext content, int index) {
                  Attribute a = widget.options[index];
                  var row = Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (widget.attribute.attributeTypeId ==
                            AttributeTypeEnum.COLOR)
                          Container(
                            margin: EdgeInsets.only(right: 3.0),
                            width: 20,
                            height: 20,
                            decoration: new BoxDecoration(
                                color: HexColor(a.value),
                                shape: BoxShape.circle,
                                border: new Border.all(color: Colors.grey)),
                          ),
                        Flexible(
                          child: Text(a.value,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic)),
                        )
                      ]);

                  var check = _selectedValues.any((e) => e.value == a.value);
                  return widget.isMultiSelect
                      ? CheckboxListTile(
                          title: row,
                          value: check,
                          onChanged: (bool value) {
                            setState(() {
                              if (check)
                                _selectedValues
                                    .removeWhere((e) => e.value == a.value);
                              else
                                _selectedValues.add(a);
                            });
                          })
                      : ListTile(
                          title: row,
                          onTap: () {
                            Navigator.pop(context, [a]);
                          });
                })),
      ],
    );
  }
}
