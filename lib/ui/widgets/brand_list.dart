import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/brand_bloc.dart';
import 'package:flutter_rentaza/blocs/favorite_bloc.dart';
import 'package:flutter_rentaza/blocs/search_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/ui/widgets/list_cell.dart';

import '../../models/Product/brand.dart';

class BrandListWidget extends StatefulWidget {
  final bool isMultiselect;
  final bool isOnlyFavoriteMode;
  final List<Brand> selectedBrands;
  final User user;
  final SearchBloc searchBloc;

  BrandListWidget(
      {this.isMultiselect = false,
      this.isOnlyFavoriteMode = false,
      this.selectedBrands,
      this.user,
      this.searchBloc});

  @override
  _BrandListWidget createState() => _BrandListWidget();
}

class _BrandListWidget extends State<BrandListWidget> {
  User _user;
  FavoriteBloc _favoriteBloc;
  String _searchText = "";
  final TextEditingController _searchTextController =
      new TextEditingController();
  BrandBloc _bloc;
  List<Brand> _selectedBrands;
  bool isFavorite = false;

  @override
  void didUpdateWidget(BrandListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _favoriteBloc = FavoriteBloc();
    _bloc = new BrandBloc();
    _user = widget.user ?? AppBloc().loginUser;
    _selectedBrands = new List<Brand>.from(widget.selectedBrands ?? []);

    _searchTextController.addListener(() {
      if (this.mounted) {
        if (_searchTextController.text.isEmpty) {
          _searchText = _searchTextController.text;
        } else {
          _searchText = _searchTextController.text;
          _bloc.searchBrand(_searchText);
        }
      }
    });
    _bloc.getBrands();
    super.initState();
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    _bloc.dispose();
    _favoriteBloc.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var lang = S.of(context);

    return SimpleDialog(
      contentPadding: EdgeInsets.all(10.0),
      children: <Widget>[
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  lang.product_brand,
                  style: new TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ),
              Spacer(),
              if (widget.isMultiselect)
                IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () {
                      Navigator.pop(context, _selectedBrands);
                    })
            ]),
        Divider(),
        Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: new TextField(
                    controller: _searchTextController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: lang.message_search,
                    ),
                  )),
            )
          ],
        ),
        Container(
            height: 500,
            width: 450,
            child: StreamBuilder(
                stream: _bloc.outBrands,
                builder: (context, AsyncSnapshot<List<Brand>> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.separated(
                        separatorBuilder: (context, index) => Divider(
                              color: Colors.grey,
                            ),
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext content, int index) {
                          Brand brand = snapshot.data[index];
                          var imageWidget = SizedBox(
                            width: 48,
                            height: 48,
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              child: Material(
                                color: Colors.transparent,
                                child: CachedNetworkImage(
                                  imageUrl: brand.image,
                                  placeholder: (context, url) => Center(
                                      child: new CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      new Icon(Icons.error),
                                ),
                              ),
                            ),
                          );
                          if (widget.isMultiselect) {
                            var check =
                                _selectedBrands.any((e) => e.id == brand.id);
                            return CheckboxListTile(
                              title: Text(brand.name),
                              subtitle: Text(brand.description),
                              value: check,
                              onChanged: (bool value) async {
                                setState(() {
                                  if (check) {
                                    _selectedBrands
                                        .removeWhere((e) => e.id == brand.id);
                                  } else {
                                    _selectedBrands.add(brand);
                                  }
                                });
                              },
                              secondary: imageWidget,
                            );
                          } else {
                            isFavorite = _user != null
                                ? _user.favoriteBrandObjs.contains(brand)
                                : false;
                            return ListCell(
                              leading: imageWidget,
                              title: brand.name,
                              subtitle: brand.description,
                              trailing: _user != null
                                  ? GestureDetector(
                                      onTap: () async {
                                        addToFavorite(brand);
                                      },
                                      child: Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isFavorite ? Colors.red : null,
                                      ),
                                    )
                                  : null,
                              onTap: () {
                                if (widget.isOnlyFavoriteMode) {
                                  addToFavorite(brand);
                                } else {
                                  Navigator.pop(context, brand);
                                }
                              },
                            );
                          }
                        });
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  return Center(child: CircularProgressIndicator());
                }))
      ],
    );
  }

  void addToFavorite(Brand brand) {
    isFavorite = _user.favoriteBrandObjs.contains(brand);
    if (isFavorite) {
      setState(() {
        _user.favoriteBrandObjs.removeWhere((e) => e.id == brand.id);
      });
      _favoriteBloc.deleteFavoriteBrand(brand);
    } else {
      if (brand != null) {
        if (!_user.favoriteBrandObjs.contains(brand) &&
            _user.favoriteBrandObjs.length < 10) {
          setState(() {
            _user.favoriteBrandObjs.add(brand);
          });
          _favoriteBloc.addFavoriteBrand(brand);
        }
      }
    }
    ;
  }
}
