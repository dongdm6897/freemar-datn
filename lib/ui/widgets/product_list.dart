import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/load_more_bloc.dart';
import 'package:flutter_rentaza/blocs/products_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/Product/actions/product_search_template.dart';
import 'package:flutter_rentaza/models/Product/actions/product_tabs.dart';
import 'package:flutter_rentaza/models/Product/product.dart';
import 'package:flutter_rentaza/models/master_datas.dart';
import 'package:flutter_rentaza/ui/pages/product/create_product.dart';
import 'package:flutter_rentaza/ui/pages/product/order_detail.dart';
import 'package:flutter_rentaza/ui/pages/product/product_detail.dart';
import 'package:flutter_rentaza/ui/pages/user/profile.dart';
import 'package:flutter_rentaza/utils/custom_style.dart';
import 'package:flutter_rentaza/utils/icons_helper.dart';
import 'package:flutter_rentaza/utils/no_data.dart';
import 'package:flutter_rentaza/utils/string_utils.dart';
import 'package:intl/intl.dart';

class ProductList extends StatefulWidget {
  final ProductTabs productTabs;
  final List<Product> products;
  final bool blocUsed;
  final ProductSearchTemplate productSearchTemplate;
  final bool shrinkWrap;

  ProductList({
    this.blocUsed = true,
    this.productTabs, //load tab
    this.products,
    this.productSearchTemplate,
    this.shrinkWrap,
  });

  @override
  _ProductListWidgetState createState() {
    return _ProductListWidgetState();
  }
}

class _ProductListWidgetState extends State<ProductList> {
  static const offsetVisibleThreshold = 50;

  ProductBloc _productBloc;
  AppBloc _appBloc;
  var _selectedOption;
  bool _blocUsed = true;
  final _scrollController = ScrollController();
  final _loading = ValueNotifier(false);

  @override
  void initState() {
    _appBloc = AppBloc();
    _productBloc = new ProductBloc();

    _blocUsed = widget.blocUsed;

    if (_blocUsed) {
      _selectedOption = widget.productTabs != null
          ? widget.productTabs
          : widget.productSearchTemplate;
      _selectedOption.loadFirstPage = true;
      _productBloc.loadFirstPage.add(_selectedOption);

      if (_selectedOption.pageSize != null && _selectedOption.pageSize > 1) {
        _scrollController.addListener(_onScroll);
      }
    }

    super.initState();
  }

  @override
  void dispose() {
    if (_productBloc != null) _productBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return RefreshIndicator(
        child: StreamBuilder<ObjectListState>(
          stream: _blocUsed
              ? _productBloc?.objectsList
              : new Stream<ObjectListState>.fromIterable([
                  ObjectListState(
                      objects: List.unmodifiable(widget.products),
                      isLoading: false,
                      error: null,
                      currentPage: 0)
                ]),
          builder: (context, AsyncSnapshot<ObjectListState> snapshot) {
            if (snapshot.hasData) {
              final isLoading = snapshot.data.isLoading;
              final error = snapshot.data.error;

              if (!isLoading && snapshot.data.objects.length == 0)
                return Center(
                  child: noData(),
                );
              else
                return ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data.objects.length + 1,
                    itemBuilder: (BuildContext context, idx) {
                      if (idx < snapshot.data.objects.length) {
                        var product = snapshot.data.objects[idx];
                        return product.isSoldOut
                            ? Banner(
                                message: "SOLD OUT",
                                location: BannerLocation.topStart,
                                color: Colors.red,
                                child: _buildProductTile(context, product),
                              )
                            : _buildProductTile(context, product);
                      }

                      if (error != null) {
                        return ListTile(
                          title: Text(
                            'Error while loading data...',
                            style: Theme.of(context)
                                .textTheme
                                .body1
                                .copyWith(fontSize: 16.0),
                          ),
                          isThreeLine: false,
                          leading: CircleAvatar(
                            child: Text(':('),
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Center(
                          child: Opacity(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                            ),
                            opacity: isLoading ? 1 : 0,
                          ),
                        ),
                      );
                    });
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
        onRefresh: () async {
          _selectedOption.loadFirstPage = true;
          _productBloc?.loadFirstPage?.add(_selectedOption);
        });
  }

  void _onScroll() {
    if (_scrollController.offset + offsetVisibleThreshold >=
        _scrollController.position.maxScrollExtent) {
      _selectedOption.loadFirstPage = false;
      _productBloc?.loadMore?.add(_selectedOption);
    }
  }

  Widget _buildProductTile(BuildContext context, Product product) {
    if (_selectedOption.name == ProductTabs.ACTION_DRAFT) {
      return _buildDraftProductTile(context, product);
    } else if (_selectedOption.name == ProductTabs.ACTION_SELLING) {
      return _buildSellingProductTile(context, product);
    } else if (_selectedOption.name == ProductTabs.ACTION_ORDERING_AUTH) {
      return _buildOrderingProductTile(context, product);
    } else if (_selectedOption.name == ProductTabs.ACTION_SOLD_AUTH) {
      return _buildSoldProductTile(context, product);
    } else if (_selectedOption.name == ProductTabs.ACTION_BUYING) {
      return _buildBuyingProductTile(context, product);
    } else if (_selectedOption.name == ProductTabs.ACTION_BOUGHT) {
      return _buildBoughtProductTile(context, product);
    }
  }

  Widget _buildDraftProductTile(BuildContext context, Product product) {
    return Material(
      child: InkWell(
          child: Container(
              decoration: _containerDecoration(),
              padding: EdgeInsets.all(5.0),
              margin: EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),
              child: Row(
                children: <Widget>[
                  Container(
                      width: 100.0,
                      height: 150.0,
                      child: _thumbnailStack(product, reactInfos: false)),
                  VerticalDivider(),
                  Flexible(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _productNameStack(product),
                      Divider(),
                      _productPrice(product),
                      Divider(),
                      Wrap(
                        children: <Widget>[
                          _productEditButton(context, product),
                          const SizedBox(width: 8.0),
                          _productDeleteButton(context, product)
                        ],
                      )
                    ],
                  )),
                ],
              )),
          onTap: () {
            var route = MaterialPageRoute(
                builder: (BuildContext context) =>
                    ProductDetailPage(product: product));
            Navigator.of(context).push(route);
          }),
    );
  }

  Widget _buildSellingProductTile(BuildContext context, Product product) {
    return InkWell(
        child: Container(
            decoration: _containerDecoration(),
            padding: EdgeInsets.all(10.0),
            margin: EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),
            child: Row(children: <Widget>[
              Container(
                width: 100.0,
                height: 150.0,
                child: _thumbnailStack(product),
              ),
              VerticalDivider(),
              Flexible(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _productNameStack(product),
                  Divider(),
                  _productPrice(product),
                  Divider(),
                  Wrap(
                    children: <Widget>[
                      _productPutBackStoreButton(context, product),
                    ],
                  )
                ],
              ))
            ])),
        onTap: () {
          var route = MaterialPageRoute(
              builder: (BuildContext context) =>
                  ProductDetailPage(product: product));
          Navigator.of(context).push(route);
        });
  }

  Widget _buildOrderingProductTile(BuildContext context, Product product) {
    return InkWell(
        child: Container(
            decoration: _containerDecoration(),
            padding: EdgeInsets.all(10.0),
            margin: EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),
            child: Row(children: <Widget>[
              Container(
                width: 100.0,
                height: 150.0,
                child: _thumbnailStack(product),
              ),
              VerticalDivider(),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _productNameStack(product),
                    Divider(),
                    _productPrice(product),
                    Divider(),
                    _productOrderStatus(product),
                  ],
                ),
              )
            ])),
        onTap: () {
          var route = MaterialPageRoute(
              builder: (BuildContext context) =>
                  OrderDetailPage(order: product.inOrderObj));
          Navigator.of(context).push(route);
        });
  }

  Widget _buildSoldProductTile(BuildContext context, Product product) {
    return InkWell(
        child: Container(
            decoration: _containerDecoration(),
            padding: EdgeInsets.all(10.0),
            margin: EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),
            child: Row(children: <Widget>[
              Container(
                width: 100.0,
                height: 150.0,
                child: _thumbnailStack(product),
              ),
              VerticalDivider(),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _productNameStack(product),
                    Divider(),
                    _productPrice(product),
                    Divider(),
                    _productOrderStatus(product)
                  ],
                ),
              )
            ])),
        onTap: () {
          var route = MaterialPageRoute(
              builder: (BuildContext context) =>
                  OrderDetailPage(order: product.inOrderObj));
          Navigator.of(context).push(route);
        });
  }

  Widget _buildBuyingProductTile(BuildContext context, Product product) {
    return InkWell(
        child: Container(
            decoration: _containerDecoration(),
            padding: EdgeInsets.all(10.0),
            margin: EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),
            child: Row(children: <Widget>[
              Container(
                width: 100.0,
                height: 150.0,
                child: _thumbnailStack(product),
              ),
              VerticalDivider(),
              Flexible(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _productNameStack(product),
                  Divider(),
                  _productPrice(product),
                  Divider(),
                  _productOrderStatus(product),
                ],
              ))
            ])),
        onTap: () {
          var route = MaterialPageRoute(
              builder: (BuildContext context) =>
                  OrderDetailPage(order: product.inOrderObj));
          Navigator.of(context).push(route);
        });
  }

  Widget _buildBoughtProductTile(BuildContext context, Product product) {
    return InkWell(
        child: Container(
            decoration: _containerDecoration(),
            padding: EdgeInsets.all(10.0),
            margin: EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),
            child: Row(children: <Widget>[
              Container(
                width: 100.0,
                height: 150.0,
                child: _thumbnailStack(product),
              ),
              VerticalDivider(),
              Flexible(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _productNameStack(product),
                  Divider(),
                  _productPrice(product),
                  Divider(),
                  _productOrderStatus(product)
                ],
              ))
            ])),
        onTap: () {
          var route = MaterialPageRoute(
              builder: (BuildContext context) =>
                  OrderDetailPage(order: product.inOrderObj));
          Navigator.of(context).push(route);
        });
  }

  // product gird 3
  Widget _imageStack(String img) => CachedNetworkImage(
      imageUrl: img,
      fit: BoxFit.cover,
      placeholder: (context, url) =>
          Center(child: new CircularProgressIndicator()),
      errorWidget: (context, url, error) => new Icon(Icons.error));

  Widget _thumbnailStack(Product product, {bool reactInfos = true}) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
      child: _imageStack(product.representImage),
    );
  }

  Widget _productNameStack(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(product.name,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: Theme.of(context).textTheme.title),
        Text(
          product.categoryObj?.name ?? "",
          style: Theme.of(context)
              .textTheme
              .subtitle
              .copyWith(color: Colors.grey.shade700, fontSize: 12.0),
        ),
        Container(height: 5.0),
        Text(
          DateFormat("yyyy-MM-dd hh:mm:ss").format(product.createdAt),
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .subtitle
              .copyWith(color: Colors.grey.shade700, fontSize: 12.0),
        ),
      ],
    );
  }

  Widget _productId(Product product) {
    var lang = S.of(context);

    return Row(
      children: <Widget>[
        Text(lang.product_id, style: CustomTextStyle.labelInformation(context)),
        Text(" : "),
        Text(
          product.id.toString(),
          style: TextStyle(fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  Widget _productPrice(Product product) {
    var lang = S.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
//        Text(lang.product_pricing,
//            style: CustomTextStyle.labelInformation(context)),
//        Text(" : "),
        Text(formatCurrency(product.price, useNatureExpression: true),
            style: CustomTextStyle.textPrice(context)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.comment,
              size: 14.0,
            ),
            Padding(
              padding: EdgeInsets.only(left: 5.0, right: 5.0),
              child: Text(product.numberOfComments?.toString() ?? "0",
                  style: CustomTextStyle.labelInformation(context)),
            ),
            Icon(
              getIconUsingPrefix(name: 'solidHeart'),
              size: 14.0,
            ),
            Padding(
              padding: EdgeInsets.only(left: 5.0, right: 10.0),
              child: Text(product.numberOfFavorites?.toString() ?? "0",
                  style: CustomTextStyle.labelInformation(context)),
            )
          ],
        )
      ],
    );
  }

  Widget _productCreatedDate(Product product) {
    var lang = S.of(context);
    return Row(
      children: <Widget>[
        Text("Created date", style: CustomTextStyle.labelInformation(context)),
        Text(" : "),
        Flexible(
          child: Text(
            DateFormat("yyyy-MM-dd hh:mm:ss").format(product.createdAt),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Widget _productOrderedDate(Product product) {
    var lang = S.of(context);

    return Row(
      children: <Widget>[
        Text("Ordered date", style: CustomTextStyle.labelInformation(context)),
        Text(": "),
        Flexible(
          child: Text(
            formatDateTimeToString(product.inOrderObj.createdAt),
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
  }

  Widget _productOrderStatus(Product product) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        margin: EdgeInsets.only(top: 5.0),
        decoration: BoxDecoration(
          color: ((product.inOrderObj?.statusObj?.id != null) &&
                  (product.inOrderObj.statusObj.id >=
                      OrderStatusEnum.TRANSACTION_FINISHED))
              ? Colors.grey.shade400
              : Colors.green,
          borderRadius: new BorderRadius.circular(10.0),
        ),
        child: Column(
          children: <Widget>[
            new Text(
              product.inOrderObj?.statusObj?.name ?? "FAIL",
              overflow: TextOverflow.ellipsis,
              style: new TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
//            Text(
//              formatDateTimeToString(product.inOrderObj?.createdAt),
//              overflow: TextOverflow.ellipsis,
//              style: Theme.of(context)
//                  .textTheme
//                  .subtitle
//                  .copyWith(color: Colors.white70, fontSize: 10.0),
//            )
          ],
        ));
  }

  Widget _productEditButton(BuildContext context, Product product) {
    var lang = S.of(context);

    return OutlineButton(
      child: Text("Edit"),
      borderSide: BorderSide(color: Colors.green),
      onPressed: () async {
        var route = MaterialPageRoute(
            builder: (BuildContext context) => CreateProduct(product: product));
        Navigator.of(context).push(route);
      },
    );
  }

  // TODO: Need process response after Put back to store
  Widget _productPutBackStoreButton(BuildContext context, Product product) {
    var lang = S.of(context);

    return OutlineButton(
      child: Text("Put back to store"),
      borderSide: BorderSide(color: Colors.amber),
      onPressed: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Put back product to store"),
                content: Text(
                    "Do you want to put product to draft status for editting?"),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
                  FlatButton(
                    child: Text("No"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text("Yes"),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) {
                          _productBloc
                              .updateProduct(product..isPublic = false)
                              .then((result) async {
                            if (result != null) {
                              _selectedOption.loadFirstPage = true;
                              _productBloc?.loadFirstPage?.add(_selectedOption);
                            }
                            await Flushbar(
                              title: "Information",
                              message:
                                  'Product was ${result != null ? "successully" : "failed."} to put back to store.',
                              duration: Duration(seconds: 5),
                              backgroundColor:
                                  result != null ? Colors.green : Colors.red,
                            ).show(context);
                            Navigator.of(context).pop(true);
                          });
                          return SimpleDialog(children: <Widget>[
                            Center(child: CircularProgressIndicator())
                          ]);
                        },
                      );
                    },
                  ),
                ],
              );
            });
      },
    );
  }

  Widget _productDeleteButton(BuildContext context, Product product) {
    var lang = S.of(context);
    var isNeedRefresh = false;

    return OutlineButton(
      child: Text("Delete"),
      borderSide: BorderSide(color: Colors.red),
      onPressed: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return ValueListenableBuilder(
                  valueListenable: _loading,
                  builder: (context, value, _) {
                    if (!value)
                      return AlertDialog(
                        title: Text("Delete product"),
                        content: Text("Do you want to delete this product?"),
                        actions: <Widget>[
                          // usually buttons at the bottom of the dialog
                          FlatButton(
                            child: Text("No"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          FlatButton(
                            child: Text("Yes"),
                            onPressed: () async {
                              _loading.value = true;
                              var result =
                                  await _productBloc.deleteProduct(product.id);
                              isNeedRefresh = result;
                              _loading.value = false;
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    return AlertDialog(
                      title: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  });
            }).then((value) {
          if (isNeedRefresh) {
            _selectedOption.loadFirstPage = true;
            _productBloc?.loadFirstPage?.add(_selectedOption);
          }
        });
      },
    );
  }

  Widget _productBuyerStack(Product product) {
    var lang = S.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          var route = new MaterialPageRoute(
              builder: (BuildContext context) =>
                  ProfilePage(user: product.inOrderObj?.buyerObj));
          Navigator.of(context).push(route);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            CircleAvatar(
                backgroundImage: (product.inOrderObj?.buyerObj?.avatar != null)
                    ? NetworkImage(product.inOrderObj?.buyerObj?.avatar)
                    : AssetImage("assets/images/default_avatar.png"),
                radius: 20.0),
//            Padding(
//                padding: EdgeInsets.only(top: 5.0),
//                child: Text(product.inOrderObj?.buyerObj?.name ?? "buyer",
//                    style: CustomTextStyle.labelInformation(context)))
          ],
        ),
      ),
    );
  }

  Widget _productSellerStack(Product product) {
    var lang = S.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          var route = new MaterialPageRoute(
              builder: (BuildContext context) =>
                  ProfilePage(user: product.ownerObj));
          Navigator.of(context).push(route);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            CircleAvatar(
                backgroundImage: (product.ownerObj?.avatar != null)
                    ? NetworkImage(product.ownerObj.avatar)
                    : AssetImage("assets/images/default_avatar.png"),
                radius: 20.0),
//            Padding(
//                padding: EdgeInsets.only(top: 5.0),
//                child: Text(product.ownerObj?.name ?? "seller",
//                    style: CustomTextStyle.labelInformation(context)))
          ],
        ),
      ),
    );
  }

  BoxDecoration _containerDecoration() {
    return BoxDecoration(color: Colors.white, boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 20.0,
      ),
    ]);
  }
}
