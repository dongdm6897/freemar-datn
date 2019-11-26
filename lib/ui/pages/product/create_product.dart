import 'dart:async';
import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/products_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/Product/attribute.dart';
import 'package:flutter_rentaza/models/Product/attribute_type.dart';
import 'package:flutter_rentaza/models/Product/brand.dart';
import 'package:flutter_rentaza/models/Product/category.dart';
import 'package:flutter_rentaza/models/Product/product.dart';
import 'package:flutter_rentaza/models/Product/product_status.dart';
import 'package:flutter_rentaza/models/Product/ship_pay_method.dart';
import 'package:flutter_rentaza/models/Product/ship_time_estimation.dart';
import 'package:flutter_rentaza/models/User/shipping_address.dart';
import 'package:flutter_rentaza/models/master_datas.dart';
import 'package:flutter_rentaza/ui/pages/image/crop_multi_image.dart';
import 'package:flutter_rentaza/ui/pages/product/search/storage/file_storage.dart';
import 'package:flutter_rentaza/ui/pages/utils/help_screen.dart';
import 'package:flutter_rentaza/ui/widgets/attribute_widget.dart';
import 'package:flutter_rentaza/ui/widgets/brand_list.dart';
import 'package:flutter_rentaza/ui/widgets/category_list.dart';
import 'package:flutter_rentaza/ui/widgets/guide_alert.dart';
import 'package:flutter_rentaza/ui/widgets/required_login.dart';
import 'package:flutter_rentaza/ui/widgets/ship_provider_list.dart';
import 'package:flutter_rentaza/ui/widgets/shipping_address_list.dart';
import 'package:flutter_rentaza/utils/currency_input_formatter.dart';
import 'package:flutter_rentaza/utils/custom_style.dart';
import 'package:flutter_rentaza/utils/string_utils.dart';
import 'package:flutter_rentaza/utils/ui_data.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shipping_plugin/shipping_plugin.dart';
import 'package:simple_logger/simple_logger.dart';

int kMaxImageNumber = 4;

class CreateProduct extends StatefulWidget {
  final Product product;

  CreateProduct({this.product});

  @override
  State createState() => new _CreateProductState();
}

class _CreateProductState extends State<CreateProduct>
    with AfterLayoutMixin<CreateProduct> {
  ProductBloc _productBloc;
  Product _product;
  bool _inputMode = true;
  bool _editMode = false;
  final _textPriceController = TextEditingController();
  final _appBloc = AppBloc();
  final _logger = SimpleLogger()..mode = LoggerMode.print;

  // List<File> _images = new List<File>();
  Map<int, String> _images = new Map<int, String>();

  // Master data used inside this screen
  List<ProductStatus> _productStatusList = new List<ProductStatus>();
  List<ShipPayMethod> _shipPayMethods = new List<ShipPayMethod>();
  List<ShipTimeEstimation> _shipTimeEstimations =
      new List<ShipTimeEstimation>();

  final FileStorage fileStorage = FileStorage();
  bool _saving = false;

  final _formKey = GlobalKey<FormState>();

  //FocusNode
  FocusNode _productNameFocus = FocusNode();
  FocusNode _productDescriptionFocus = FocusNode();
  FocusNode _priceFocus = FocusNode();
  FocusNode _weightFocus = FocusNode();

  //AttributeType
  List<AttributeType> _attributeTypes = List<AttributeType>();

  List<double> _weights = [0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4];

  @override
  void initState() {
    _productBloc = new ProductBloc();
    _product = widget.product;
    if (_product == null) {
      _product = new Product()..ownerObj = _appBloc.loginUser;
      _product.attributeObjs = [];
      _product.statusId = 1;
      _product.weight = 0.5;

      if ((_appBloc.loginUser?.shippingAddressObjs?.length ?? 0) > 0) {
        _appBloc.loginUser?.currentShippingAddressObj ??=
            _appBloc.loginUser?.shippingAddressObjs?.first;
        _product.shippingFrom = _appBloc.loginUser?.currentShippingAddressObj;
        _product.shipProviderObj = _appBloc.loginUser?.currentShipProvider;
      }
    } else {
      if (_product.referenceImageLinks != null) {
        for (int i = 0; i < _product.referenceImageLinks.length; i++) {
          _images[i] = _product.referenceImageLinks[i];
        }
      }

      if (!_weights.contains(_product.weight)) {
        _product.weight = 0.5;
      }
    }
    _editMode = true;
    _textPriceController.text = _product.originalPrice?.toString() ?? '0';
    if (this.mounted) {
      setState(() {
        _productStatusList = _appBloc.productStatuses;
        _shipPayMethods = _appBloc.shipPayMethods;
        _shipTimeEstimations = _appBloc.shipTimeEstimation;
        if (_product.shipTimeEstimationId == null) {
          _product.shipTimeEstimationId = _shipTimeEstimations[0].id;
        }
        if (_product.shippingPaymentMethodObj == null) {
          _product.shippingPaymentMethodObj = _shipPayMethods[0];
        }
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _productBloc.dispose();
    _textPriceController.dispose();
    _productNameFocus.dispose();
    _productDescriptionFocus.dispose();
    _priceFocus.dispose();
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // Show capture dialog with new product only
    if (_product.id == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) => GuideAlert(
            buttonText: "Chụp ngay",
            title: "Nào, 1-2-3, chụp đẹp nhé!",
            description:
                "Chỉ với 2 bước đơn giản, bạn đã có thể chụp những bức ảnh thật đẹp về sản phẩm bạn định bán, và đăng lên chợ baibai.vn.",
            image: Image.asset("assets/images/bg-summer.jpg")),
      ).then((value) {
        if (value == true) _handleMultiImagesSelectButton(context, 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var lang = S.of(context);
    var size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text(_getPageTitle(lang)),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () {
                var route = MaterialPageRoute(
                    builder: (BuildContext context) => new HelpScreen(
                        title: 'HELP: How to create a product on BaiBai',
                        url: _appBloc.links["help2"]));
                Navigator.of(context).push(route);
              },
            )
          ],
        ),
        body: ModalProgressHUD(
            inAsyncCall: _saving,
            child: Builder(
                builder: (context) =>
                    new Stack(fit: StackFit.expand, children: <Widget>[
                      new SingleChildScrollView(
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Container(
                              color: Colors.grey.shade200,
                              child: new Form(
                                key: _formKey,
                                autovalidate: true,
                                child: new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    _buildImageList(context),
                                    _buildProductInfomation(context),
                                    _buildProductShippingInfomation(context),
                                    _buildPriceInformation(context),
                                    _buildOrderInformation(context)
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ]))),
        bottomNavigationBar: _buildBottomAppBar(context));
  }

  String _getPageTitle(S lang) {
    if (_product.id != null) {
      return 'Update product'; //TODO:
    } else {
      return _inputMode ? lang.create_product : lang.product_confirm_title;
    }
  }

  Widget _buildImageList(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(12.0),
      margin: EdgeInsets.only(bottom: 10.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
                children: List<Expanded>.generate(
                    kMaxImageNumber,
                    (int idx) => Expanded(
                          child: InkWell(
                              child: Container(
                                child: _getImage(_images[idx]),
                                padding: EdgeInsets.all(5.0),
                              ),
                              onTap: () {
                                if (_editMode) {
                                  setState(() {
                                    _saving = true;
                                  });
                                  _handleMultiImagesSelectButton(context, idx);
                                }
                              }),
                        ))),
            Text("Gợi ý: Ảnh chụp càng đẹp, hàng bán càng nhanh nhé bạn!",
                style: CustomTextStyle.textExplainNormal(context)),
          ]),
    );
  }

  Widget _buildProductInfomation(BuildContext context) {
    var lang = S.of(context);
    var size = MediaQuery.of(context).size;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(12.0),
      margin: EdgeInsets.only(bottom: 10.0),
      child: Column(children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 5.0),
          child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                lang.product_informations,
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
        ),
        Divider(),
        TextFormField(
          focusNode: _productNameFocus,
          maxLength: 40,
          initialValue: _product.name ?? "",
          decoration: InputDecoration(
            labelText: lang.product_name,
            helperText: lang.product_hint,
          ),
          keyboardType: TextInputType.text,
          enabled: _inputMode,
          validator: (value) {
            if (value.isEmpty) {
              return "Please input product name";
            }
            return null;
          },
          onSaved: (value) {
            _product.name = value;
          },
        ),
        TextFormField(
          focusNode: _productDescriptionFocus,
          maxLength: 255,
          maxLines: 5,
          initialValue: _product.description ?? "",
          decoration: new InputDecoration(
            labelText: lang.product_description,
            helperText: lang.product_description_hint,
          ),
          keyboardType: TextInputType.multiline,
          enabled: _inputMode,
          validator: (value) {
            if (value.isEmpty) {
              return "Please input product description";
            }
            return null;
          },
          onSaved: (value) {
            _product.description = value;
          },
        ),
        Padding(
          padding: EdgeInsets.only(top: 5.0),
          child: Divider(),
        ),
//      Padding(
//        padding: EdgeInsets.only(bottom: 5.0),
//        child: Align(
//            alignment: Alignment.bottomLeft,
//            child: Text(
//              lang.product_informations,
//              style: TextStyle(fontWeight: FontWeight.bold),
//            )),
//      ),
        ListTile(
            contentPadding: EdgeInsets.all(0.0),
            leading: Text(lang.product_category),
            trailing: SizedBox(
                width: size.width / 2,
                child: Container(
                    alignment: Alignment.centerRight,
                    child: Text(
                        _product.categoryObj == null
                            ? lang.type_required
                            : _product.categoryObj.toString(),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: Colors.red,
                            fontStyle: FontStyle.italic,
                            decoration: TextDecoration.underline)))),
            onTap: () {
              if (_inputMode) _handleSelectCategory(context);
            }),
        ListTile(
          contentPadding: EdgeInsets.all(0.0),
          leading: Text(lang.product_brand),
          trailing: Text(
              _product.brandObj == null
                  ? lang.type_optional
                  : _product.brandObj.name,
              style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                  decoration: TextDecoration.underline)),
          onTap: () {
            if (_inputMode) _handleSelectBrand(context);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: AttributeWidget(
              new Attribute(
                name: lang.product_status,
                value: _productStatusList
                    .firstWhere((e) => e.id == _product.statusId,
                        orElse: () => null)
                    ?.name,
              ),
              options: _productStatusList
                  .map((s) =>
                      Attribute(name: s.name, value: s.name, metadata: s.id))
                  .toList(), onChanged: (List<Attribute> newObjs) {
            if (newObjs != null && newObjs.length > 0) {
              setState(() {
                _product.statusId = _productStatusList
                    .firstWhere((e) => e.id == newObjs[0].metadata,
                        orElse: () => null)
                    ?.id;
              });
            }
          }),
        ),
        ..._attributeTypes.map((a) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: AttributeWidget(
              Attribute(
                  name: a.title,
                  value: _product.attributeObjs.length > 0
                      ? _product.attributeObjs
                          .firstWhere((attr) => attr.attributeTypeId == a.id)
                          .value
                      : "00000",
                  attributeTypeId: a.id),
              options: a.attributes
                  .map((s) => Attribute(
                      id: s.id,
                      name: s.name,
                      value: s.value,
                      attributeTypeId: s.attributeTypeId,
                      metadata: s.id))
                  .toList(),
              onChanged: (List<Attribute> newObjs) {
                if (newObjs != null && newObjs.length > 0) {
                  _product.attributeObjs
                      .removeWhere((attr) => attr.attributeTypeId == a.id);
                  setState(() {
                    _product.attributeObjs.addAll(newObjs);
                  });
                }
              },
            ),
          );
        }),
      ]),
    );
  }

  Widget _buildProductShippingInfomation(BuildContext context) {
    var lang = S.of(context);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(12.0),
      margin: EdgeInsets.only(bottom: 10.0),
      child: Column(children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 5.0),
          child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                lang.product_shipping,
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: AttributeWidget(
              new Attribute(
                name: lang.product_shipping_fee_pay_method,
                value: _product.shippingPaymentMethodObj?.name ??
                    _shipPayMethods[0]?.name,
              ),
              options: _shipPayMethods
                  .map((s) =>
                      Attribute(name: s.name, value: s.name, metadata: s.id))
                  .toList(), onChanged: (List<Attribute> newObjs) {
            if (newObjs != null && newObjs.length > 0) {
              setState(() {
                _product.shippingPaymentMethodObj = _shipPayMethods.firstWhere(
                    (e) => e.id == newObjs[0].metadata,
                    orElse: () => null);
              });
            }
          }),
        ),
        ListTile(
            contentPadding: EdgeInsets.all(0.0),
            leading: Text(lang.product_ship_provider),
            trailing: Text(
              _product.shipProviderObj?.name ?? lang.type_required,
              style: TextStyle(
                  color: Colors.red, decoration: TextDecoration.underline),
            ),
            onTap: () {
              _handleSelectShipProvider(context);
            }),
        _product.shipProviderObj != null
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Wrap(
                  runAlignment: WrapAlignment.spaceEvenly,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(lang.product_shipping_from),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        child: Container(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            _product.shippingFrom?.toString() ??
                                lang.type_required,
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.red),
                          ),
                        ),
                        onTap: () {
                          _handleSelectShippingAddress(context);
                        },
                      ),
                    ),
                  ],
                ),
              )
            : SizedBox(),
        ListTile(
          contentPadding: EdgeInsets.all(0.0),
          leading: Text(lang.weight),
          trailing: DropdownButtonHideUnderline(
              child: DropdownButton<double>(
                  value: _product.weight,
                  items: _weights
                      .map((i) => DropdownMenuItem<double>(
                          value: i,
                          child: Text(
                            "~ $i Kg",
                          )))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _product.weight = value;
                    });
                  })),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: AttributeWidget(
              new Attribute(
                name: lang.ship_time_estimation,
                value: _shipTimeEstimations
                    .firstWhere((e) => e.id == _product.shipTimeEstimationId,
                        orElse: () => null)
                    ?.name,
              ),
              options: _shipTimeEstimations
                  .map((s) =>
                      Attribute(name: s.name, value: s.name, metadata: s.id))
                  .toList(), onChanged: (List<Attribute> newObjs) {
            if (newObjs != null && newObjs.length > 0) {
              setState(() {
                _product.shipTimeEstimationId = _shipTimeEstimations
                    .firstWhere((e) => e.id == newObjs[0].metadata,
                        orElse: () => null)
                    ?.id;
              });
            }
          }),
        ),
      ]),
    );
  }

  Widget _buildPriceInformation(BuildContext context) {
    var lang = S.of(context);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(12.0),
      margin: EdgeInsets.only(bottom: 10.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 5.0),
            child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  lang.product_pricing_informations,
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
          ),
          Divider(),
          ListTile(
            contentPadding: EdgeInsets.all(0.0),
            leading: Text(lang.product_pricing),
            title: TextFormField(
              focusNode: _priceFocus,
              controller: _textPriceController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(hintText: "0"),
              keyboardType: TextInputType.number,
              style: CustomTextStyle.textPrice(context),
              enabled: _inputMode,
              validator: (value) {
                if (value.isEmpty) {
                  return "Please input value.";
                }
                return null;
              },
              onSaved: (value) {
                _product.originalPrice =
                    double.tryParse(value.replaceAll(',', ''));
                _product.price = _product.originalPrice;
                _product.commerceFee =
                    _product.originalPrice * _appBloc.defaultCommerceFee;
              },
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly,
                CurrencyInputFormatter()
              ],
            ),
            subtitle: Text(
                "You can give free product to community by set price is 0" +
                    getCurrencyString()),
            trailing: Text(getCurrencyString()),
          ),
          ListTile(
            contentPadding: EdgeInsets.all(0.0),
            leading: Text(lang.product_fee),
            trailing: Text(formatCurrency((double.tryParse(
                        _textPriceController.text.replaceAll(',', '')) ??
                    0.0) *
                _appBloc.defaultCommerceFee)),
          ),
          ListTile(
            contentPadding: EdgeInsets.all(0.0),
            leading: Text(lang.product_income_pricing),
            trailing: Text(formatCurrency((double.tryParse(
                        _textPriceController.text.replaceAll(',', '')) ??
                    0.0) *
                (1.0 - _appBloc.defaultCommerceFee))),
          )
        ],
      ),
    );
  }

  Widget _buildOrderInformation(BuildContext context) {
    var lang = S.of(context);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(12.0),
      margin: EdgeInsets.only(bottom: 10.0),
      child: Column(children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 5.0),
          child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                "Order",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
        ),
        Divider(),
        ListTile(
            contentPadding: EdgeInsets.all(0.0),
            leading: Text("Confirm order"),
            trailing: Switch(
              value: _product.isConfirmRequired,
              onChanged: (value) {
                setState(() {
                  _product.isConfirmRequired = value;
                });
              },
              activeTrackColor: Colors.redAccent[300],
              activeColor: Colors.red,
            ),
            onTap: () {}),
      ]),
    );
  }

  Widget _buildBottomAppBar(BuildContext context) {
    var lang = S.of(context);

    return BottomAppBar(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          new FlatButton(
              child: new Text(
                _inputMode ? lang.product_save : lang.product_back,
                style: Theme.of(context)
                    .textTheme
                    .subhead
                    .copyWith(color: Colors.black),
              ),
              onPressed: () {
                if (_validateInputData(context) &&
                    _formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  _handleSaveButton(context);
                }
              }),
          new FlatButton(
              child: new Text(
                _inputMode ? lang.product_confirm : lang.product_post,
                style: Theme.of(context)
                    .textTheme
                    .subhead
                    .copyWith(color: Colors.red),
              ),
              onPressed: () {
                if (_validateInputData(context) &&
                    _formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  _handleConfirmButton(context);
                }
              }),
        ],
      ),
    );
  }

  // https://sh1d0w.github.io/multi_image_picker/#/theming
  _handleMultiImagesSelectButton(BuildContext context, int idx) async {
    var lang = S.of(context);
    try {
      // Get images from picker
      MultiImagePicker.pickImages(
              maxImages: (_images[idx] != null)
                  ? 1
                  : (kMaxImageNumber - _images.length),
              enableCamera: true,
              cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
              materialOptions: MaterialOptions(
                  lightStatusBar: false,
                  startInAllView: true,
                  actionBarTitle: "Baibai app",
                  allViewTitle: "All Photos"))
          .then((assets) {
        if (assets != null && assets.length > 0) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => CropMultiImagePage(
                        assets: assets,
                      ))).then((results) {
            if (results != null) {
              setState(() {
                if (_images.length > idx)
                  _images[idx] = (results[0] as File).path;
                else {
                  var currentIdx = _images.length;
                  var imgs = results as List<File>;
                  for (int i = 0; i < imgs.length; i++) {
                    _images[currentIdx + i] = imgs[i].path;
                  }
                }
              });
            }
          });
        }
      });
    } on PlatformException catch (e) {
      print(e.message);
    } on Exception catch (e) {
      print(e.toString());
    } finally {
      if (this.mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  _handleSaveButton(BuildContext context) async {
    var lang = S.of(context);
    try {
      if (_inputMode) {
        setState(() {
          _saving = true;
        });

        Product ret =
            await _updateProduct(_product..isPublic = false, images: _images);
        _logger.info("[_handleSaveButton] updateProduct $ret");

        setState(() {
          _saving = false;
        });

        Navigator.of(context).pushReplacementNamed(UIData.SELL_MANAGER);

//        var flushbar = Flushbar(
//          title: "Information",
//          message:
//              "Product was saved in draft successully. (image: ${ret?.representImage ?? ""})",
//          duration: Duration(seconds: 5),
//          backgroundColor: Colors.red,
//        );
//        await flushbar.show(context);

      } else {
        // Back to edit mode
        setState(() {
          _inputMode = true;
        });
      }
    } catch (FormatException) {}
  }

  _handleConfirmButton(BuildContext context) async {
    var lang = S.of(context);

    try {
      if (_inputMode) {
        setState(() {
          _inputMode = false;
        });
      } else {
        // flutter defined function
        var ret = await showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: Text(lang.product_post_confirm_title),
              content: Text(lang.product_post_confirm_message),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                new FlatButton(
                    child: new Text(lang.title_close),
                    onPressed: () => Navigator.of(context).pop(false)),
                new FlatButton(
                    child: new Text(lang.product_post),
                    onPressed: () => Navigator.of(context).pop(true))
              ],
            );
          },
        );

        // Process update
        if (ret) {
          setState(() {
            _saving = true;
          });

          Product ret =
              await _updateProduct(_product..isPublic = true, images: _images);
          _logger.info("[_handleConfirmButton] updateProduct $ret");

          setState(() {
            _saving = false;
            Navigator.of(context).pushReplacementNamed(UIData.HOMEPAGE);
          });

//          var flushbar = Flushbar(
//            title: "Information",
//            message:
//                "Product was updated successully. (image: ${ret?.representImage ?? ""})",
//            duration: Duration(seconds: 5),
//            backgroundColor: Colors.red,
//          );
//          await flushbar.show(context);
        }
      }
    } catch (FormatException) {}
  }

  _handleSelectCategory(BuildContext context) async {
    unFocusNode();
    try {
      Category category = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return CategoryListWidget();
        },
      );

      if (category != null) {
        // Update related attribute
        if (category.attributeTypes != null) {
          setState(() {
            _product.categoryObj = category;
            _attributeTypes = category.attributeTypes;
          });
        } else
          setState(() {
            _product.categoryObj = category;
          });
      }
    } catch (FormatException) {}
  }

  _handleSelectBrand(BuildContext context) async {
    unFocusNode();
    try {
      Brand brand = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return BrandListWidget();
        },
      );

      if (brand != null) {
        setState(() {
          _product.brandObj = brand;
        });
      }
    } catch (FormatException) {}
  }

  _handleSelectShipProvider(BuildContext context) async {
    unFocusNode();
    var ret = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ShipProviderListWidget();
//          return ShippingProviderList();
      },
    );

    if (ret != null) {
      setState(() {
        _product.shipProviderObj = ret;
      });
    }
  }

  ///
  /// Save new product to server
  ///
  Future<Product> _updateProduct(Product product,
      {Map<int, String> images}) async {
    return await _productBloc.updateProduct(product, images: images);
  }

  Image _getImage(String uri) {
    String url = uri ?? "assets/images/no_image.png";

    if (url.startsWith("http") ?? false) {
      return Image.network(uri, width: 100.0, height: 100.0, fit: BoxFit.cover);
    } else if (url.startsWith("assets") ?? false) {
      return Image.asset(url, width: 100.0, height: 100.0, fit: BoxFit.cover);
    } else {
      return Image.file(File(url),
          width: 100.0, height: 100.0, fit: BoxFit.cover);
    }
  }

  bool _validateInputData(BuildContext context) {
    // Check image
    bool retVal = true;
    String message = "";

    if (_images.length == 0) {
      message = "Please input product image (at least 1 image).";
      retVal = false;
    } else if (_product.categoryObj == null) {
      message = "Please select product category";
      retVal = false;
    } else if (_product.shippingFrom == null) {
      message = "Please select ship from";
      retVal = false;
    } else if (_product.shipProviderObj == null) {
      message = "Please select ship provider";
      retVal = false;
    }

    if (message?.isNotEmpty ?? false) {
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    return retVal;
  }

  unFocusNode() {
    _productNameFocus.unfocus();
    _productDescriptionFocus.unfocus();
    _priceFocus.unfocus();
    _weightFocus.unfocus();
  }

  _handleSelectShippingAddress(BuildContext context) async {
    ShippingAddress ret = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ShippingAddressListWidget(user: _appBloc.loginUser);
      },
    );

    if (_appBloc.loginUser.shippingAddressObjs.length == 0) {
      ret = null;
    }

    if (ret != null) {
      ShippingPlugin shippingPlugin = ShippingPlugin();
      bool res = true;
      if (_product.shipProviderObj.id != ShipProviderEnum.GIAO_TAN_NOI ||
          _product.shipProviderObj.id != ShipProviderEnum.TU_DEN_LAY) {
        res = await shippingPlugin.checkSupportedAddress(
            ret.province.name, ret.district.name, ret.ward.name);
      }
      if (!res) {
        Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(
                "Quận/Huyện này chưa hỗ trợ giao hàng. Xin chọn địa chỉ khác")));
        ret = null;
      } else
        _appBloc.loginUser.currentShippingAddressObj = ret;
    }

    setState(() {
      _product.shippingFrom = ret;
    });
  }
}
