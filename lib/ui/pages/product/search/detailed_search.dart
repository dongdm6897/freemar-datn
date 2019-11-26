import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/search_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/Product/actions/product_search_template.dart';
import 'package:flutter_rentaza/models/Product/attribute.dart';
import 'package:flutter_rentaza/models/Product/brand.dart';
import 'package:flutter_rentaza/models/Product/category.dart';
import 'package:flutter_rentaza/models/Product/product_status.dart';
import 'package:flutter_rentaza/models/master_datas.dart';
import 'package:flutter_rentaza/ui/pages/product/search/search_results.dart';
import 'package:flutter_rentaza/ui/widgets/attribute_size.dart';
import 'package:flutter_rentaza/ui/widgets/attribute_widget.dart';
import 'package:flutter_rentaza/ui/widgets/brand_list.dart';
import 'package:flutter_rentaza/ui/widgets/category_list.dart';
import 'package:flutter_rentaza/utils/currency_input_formatter.dart';
import 'package:flutter_rentaza/utils/string_utils.dart';

class DetailedSearch extends StatefulWidget {
  final bool drawer;
  final SearchBloc searchBloc;
  final ProductSearchTemplate productSearchTemplate;

  DetailedSearch(
      {this.drawer = false, this.searchBloc, this.productSearchTemplate});

  @override
  DetailedSearchState createState() {
    return DetailedSearchState();
  }
}

class DetailedSearchState extends State<DetailedSearch> {
  final _formKey = GlobalKey<FormState>();
  bool isSwitch = false;
  List<Attribute> _statuses;
  List<Attribute> _statusOptions = [];
  TextEditingController _minPriceTC = new TextEditingController();
  TextEditingController _maxPriceTC = new TextEditingController();
  TextEditingController _keywordController = TextEditingController();
  ProductSearchTemplate _productSearchTemplate = ProductSearchTemplate();

  @override
  void initState() {
    _productSearchTemplate = widget.productSearchTemplate;

    _statuses = _productSearchTemplate.productStatusObjs
        ?.map((s) => Attribute(name: s.name, value: s.name, metadata: s.id))
        ?.toList();

    isSwitch = _productSearchTemplate.soldOut ?? false;

    _statusOptions = AppBloc()
            .productStatuses
            ?.map((s) => Attribute(name: s.name, value: s.name, metadata: s.id))
            ?.toList() ??
        [];

    if (_productSearchTemplate.priceTo != null)
      _minPriceTC.text = _productSearchTemplate.priceFrom.toString();
    if (_productSearchTemplate.priceFrom != null)
      _maxPriceTC.text = _productSearchTemplate.priceTo.toString();

    _keywordController.text = _productSearchTemplate.keyword;

    super.initState();
  }

  @override
  void dispose() {
    _keywordController.clear();
    _maxPriceTC.clear();
    _minPriceTC.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var lang = S.of(context);
    var size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: widget.drawer
            ? null
            : AppBar(
                title: Text(S.of(context).detail_search),
              ),
        body: Builder(
            builder: (context) =>
                new Stack(fit: StackFit.expand, children: <Widget>[
                  new SingleChildScrollView(
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Container(
                          padding: const EdgeInsets.all(20.0),
                          child: new Form(
                            key: _formKey,
                            autovalidate: true,
                            child: ListView(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              children: <Widget>[
                                TextFormField(
                                  controller: _keywordController,
                                  maxLength: 40,
                                  decoration: InputDecoration(
                                      labelText: 'Keyword',
                                      fillColor: Colors.white),
                                  keyboardType: TextInputType.text,
                                  onSaved: (String value) {
                                    if (value != "")
                                      _productSearchTemplate.keyword = value;
                                  },
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Divider(),
                                ),
                                GestureDetector(
                                  onTap: () => _handleSelectCategory(context),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 12.0),
                                    child: Row(
                                      children: <Widget>[
                                        Text(lang.product_category),
                                        Spacer(),
                                        Flexible(
                                          child: SizedBox(
                                            width: size.width / 2,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                  (_productSearchTemplate !=
                                                              null &&
                                                          _productSearchTemplate
                                                                  .categoryObjs !=
                                                              null &&
                                                          _productSearchTemplate
                                                                  .categoryObjs
                                                                  .length >
                                                              0)
                                                      ? _productSearchTemplate
                                                          .categoryObjs
                                                          .map((c) =>
                                                              c.toString())
                                                          .join(' / ')
                                                      : S.of(context).unspecified,
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontStyle:
                                                          FontStyle.italic)),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _handleSelectBrand(context),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 12.0),
                                    child: Row(
                                      children: <Widget>[
                                        Text(lang.product_brand),
                                        Spacer(),
                                        Flexible(
                                          child: SizedBox(
                                            width: size.width / 2,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                  (_productSearchTemplate !=
                                                              null &&
                                                          _productSearchTemplate
                                                                  .brandObjs !=
                                                              null &&
                                                          _productSearchTemplate
                                                                  .brandObjs
                                                                  .length >
                                                              0)
                                                      ? _productSearchTemplate
                                                          .brandObjs
                                                          .map((b) => b.name)
                                                          .join(' / ')
                                                      : S.of(context).unspecified,
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontStyle:
                                                          FontStyle.italic)),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                ListTile(
                                  contentPadding: EdgeInsets.all(0.0),
                                  leading: Text('Size'),
                                  trailing: (_productSearchTemplate != null &&
                                          _productSearchTemplate
                                                  .sizeAttributeObjs !=
                                              null &&
                                          _productSearchTemplate
                                                  .sizeAttributeObjs.length >
                                              0)
                                      ? Text(_productSearchTemplate
                                          .sizeAttributeObjs
                                          .map((e) => e.value)
                                          .join(', '))
                                      : Text(S.of(context).unspecified,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontStyle: FontStyle.italic)),
                                  onTap: () {
                                    _handleSelectSize(context);
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: AttributeWidget(
                                      new Attribute(
                                          name: 'Color',
                                          attributeTypeId:
                                              AttributeTypeEnum.COLOR),
                                      isEditMode: true,
                                      isMultiSelect: true,
                                      multiSelectAttributes:
                                          _productSearchTemplate
                                              .colorAttributeObjs,
                                      onChanged: (List<Attribute> newObjs) {
                                    if (newObjs != null) {
                                      setState(() {
                                        _productSearchTemplate
                                            .colorAttributeObjs = newObjs;
                                      });
                                    }
                                  }),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Divider(),
                                ),
                                ListTile(
                                  contentPadding: EdgeInsets.all(0.0),
                                  leading: Text(S.of(context).price),
                                  title: Wrap(
                                    children: <Widget>[
                                      TextField(
                                          controller: _minPriceTC,
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                              hintText: "0.000",
                                              helperText: "From"),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            WhitelistingTextInputFormatter
                                                .digitsOnly,
                                            CurrencyInputFormatter()
                                          ]),
                                      TextField(
                                        controller: _maxPriceTC,
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                            hintText: "20.000.000",
                                            helperText: "To"),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          WhitelistingTextInputFormatter
                                              .digitsOnly,
                                          CurrencyInputFormatter()
                                        ],
                                      )
                                    ],
                                  ),
                                  trailing: Text(getCurrencyString()),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20.0),
                                  child: AttributeWidget(
                                      new Attribute(
                                          name: lang.product_status,
                                          value: (_statuses != null &&
                                                  _statuses.length > 0)
                                              ? _statuses
                                                  .map((s) => s.name)
                                                  .join(', ')
                                              : S.of(context).unspecified),
                                      isMultiSelect: true,
                                      isEditMode: true,
                                      multiSelectAttributes: _statuses,
                                      options: _statusOptions,
                                      onChanged: (List<Attribute> newObjs) {
                                    if (newObjs != null) {
                                      setState(() {
                                        _statuses = newObjs;
                                      });
                                    }
                                  }),
                                ),
                                ListTile(
                                    contentPadding: EdgeInsets.all(0.0),
                                    leading: Text(S.of(context).sold_out),
                                    trailing: Switch(
                                      value: isSwitch,
                                      onChanged: (value) {
                                        setState(() {
                                          isSwitch = value;
                                        });
                                      },
                                      activeTrackColor: Colors.redAccent[300],
                                      activeColor: Colors.red,
                                    ),
                                    onTap: () {}),
                                Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Divider(),
                                ),
//                                ListTile(
//                                  contentPadding: EdgeInsets.only(bottom: 5.0),
//                                  leading: Text(
//                                    "shipping fee inclued",
//                                  ),
//                                  trailing: Switch(
//                                    value: isSwitch,
//                                    onChanged: (value) {
//                                      setState(() {
//                                        isSwitch = value;
//                                      });
//                                    },
//                                    activeTrackColor: Colors.redAccent[300],
//                                    activeColor: Colors.red,
//                                  ),
//                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: RaisedButton(
                                        child: new Text(
                                          S.of(context).clear,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subhead
                                              .copyWith(color: Colors.red),
                                        ),
                                        color: Colors.white,
                                        onPressed: () {
                                          _productSearchTemplate.keyword = "";
                                          _keywordController.text = "";
                                          _productSearchTemplate.categoryObjs =
                                              null;
                                          _productSearchTemplate.brandObjs =
                                              null;
                                          _productSearchTemplate
                                              .sizeAttributeObjs = null;
                                          _productSearchTemplate
                                              .colorAttributeObjs = null;
                                          _productSearchTemplate.priceTo = 0;
                                          _minPriceTC.text = "0";
                                          _maxPriceTC.text = "0";
                                          _productSearchTemplate.priceFrom = 0;
                                          _productSearchTemplate.soldOut =
                                              false;
                                          isSwitch = false;
                                          _productSearchTemplate
                                              .productStatusObjs = null;
                                          _statuses = null;
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: RaisedButton(
                                        child: new Text(
                                          S.of(context).search,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subhead
                                              .copyWith(color: Colors.white),
                                        ),
                                        color: Colors.red,
                                        onPressed: () =>
                                            _handleSaveButton(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ])));
  }

  _handleSaveButton(BuildContext context) {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save(); // Save our form now.

      _productSearchTemplate.productStatusObjs = _statuses
          ?.map((s) => ProductStatus(name: s.name, id: s.id))
          ?.toList();
      _productSearchTemplate.soldOut = isSwitch;
      _productSearchTemplate.priceFrom = double.tryParse(_minPriceTC.text);
      _productSearchTemplate.priceTo = double.tryParse(_maxPriceTC.text);

      widget.searchBloc.inSearch.add(_productSearchTemplate);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResults(
            searchBloc: widget.searchBloc,
            productSearchTemplate: _productSearchTemplate,
          ),
        ),
      );
    }
  }

  _handleSelectCategory(BuildContext context) async {
    try {
      List<Category> categories = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return CategoryListWidget(
              isMultiselect: true,
              selectedCategories: _productSearchTemplate.categoryObjs);
        },
      );

      setState(() {
        _productSearchTemplate.categoryObjs = categories;
      });
    } catch (FormatException) {}
  }

  _handleSelectBrand(BuildContext context) async {
    try {
      List<Brand> brands = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return BrandListWidget(
              isMultiselect: true,
              selectedBrands: _productSearchTemplate.brandObjs);
        },
      );

      setState(() {
        _productSearchTemplate.brandObjs = brands;
      });
    } catch (FormatException) {}
  }

  _handleSelectSize(BuildContext context) async {
    var sizes = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AttributeSizeWidget(
              selectedSizes: _productSearchTemplate.sizeAttributeObjs);
        });
    if (sizes != null) {
      setState(() {
        _productSearchTemplate.sizeAttributeObjs = sizes;
      });
    }
  }
}
