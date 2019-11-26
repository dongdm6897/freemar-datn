import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/favorite_bloc.dart';
import 'package:flutter_rentaza/generated/i18n.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/ui/widgets/required_login.dart';
import 'package:flutter_rentaza/utils/icons_helper.dart';

import '../../blocs/category_bloc.dart';
import '../../models/Product/category.dart';

class CategoryListWidget extends StatefulWidget {
  final bool isMultiselect;
  final bool isOnlyFavoriteMode;
  final List<Category> selectedCategories;
  final User user;

  CategoryListWidget(
      {this.isMultiselect = false,
      this.isOnlyFavoriteMode = false,
      this.selectedCategories,
      this.user});

  @override
  _CategoryListWidget createState() => _CategoryListWidget();
}

class _CategoryListWidget extends State<CategoryListWidget> {
  User _user;
  final TextEditingController _searchTextController =
      new TextEditingController();
  CategoryBloc _bloc;
  List<Category> _selectedCategories;
  FavoriteBloc _favoriteBloc;
  bool isFavorite = false;

  @override
  void initState() {
    _favoriteBloc = FavoriteBloc();
    _bloc = new CategoryBloc();
    _user = widget.user ?? AppBloc().loginUser;
    _selectedCategories =
        new List<Category>.from(widget.selectedCategories ?? []);

    _searchTextController.addListener(() {
      if (this.mounted) {
        if (_searchTextController.text.isEmpty) {
          _bloc.searchCategories("");
        } else {
          _bloc.searchCategories(_searchTextController.text);
        }
      }
    });

    // Get all categories level 1 (parent = 0)
    _bloc.getCategories();

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
  void didUpdateWidget(CategoryListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var lang = S.of(context);

    _makeCategoryList(
        List<Category> items, CategoryBloc bloc, StateSetter stateUpdater) {
      return ListView.separated(
          separatorBuilder: (context, index) => Divider(
                color: Colors.grey,
              ),
          itemCount: items.length,
          itemBuilder: (BuildContext content, int index) {
            Category category = items[index];
            bool isContainSubCategory =
                category.childrenObj != null && category.childrenObj.length > 0;
            var listItemOnTapHandler = () async {
              var subCategories = category.childrenObj;
              if (subCategories.length == 0) {
                if (widget.isMultiselect) {
                  stateUpdater(() {
                    _selectedCategories.add(category);
                  });
                } else if (widget.isOnlyFavoriteMode) {
                  addToFavorite(category, stateUpdater);
                } else {
                  if (category.parentId != 0)
                    category.getPath(_bloc.getCategoriesFromCache());
                  Navigator.pop(context, category);
                }
              } else {
                var subCategory = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                        builder: (context, stateUpdater) {
                          return SimpleDialog(
                            children: <Widget>[
                              new Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  SizedBox(
                                    height: 18.0,
                                    width: 38.0,
                                    child: IconButton(
                                        padding: EdgeInsets.only(
                                            left: 10.0, right: 10.0),
                                        icon: Icon(
                                          Icons.arrow_back,
                                          color: Colors.black,
                                          size: 18.0,
                                        ),
                                        onPressed: () =>
                                            Navigator.of(context).pop()),
                                  ),
                                  Flexible(
                                    child: Center(
                                      child: Text(
                                        category.toString(),
                                        style: new TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                  if (widget.isMultiselect) Spacer(),
                                  if (widget.isMultiselect)
                                    IconButton(
                                        icon: Icon(Icons.check),
                                        onPressed: () {
                                          _selectedCategories.forEach((f) {
                                            if (f.parentId != 0)
                                              f.getPath(_bloc
                                                  .getCategoriesFromCache());
                                          });
                                          Navigator.pop(
                                              context, _selectedCategories);
                                        })
                                ],
                              ),
                              Divider(),
                              Container(
                                  width: 450,
                                  height: subCategories.length * 70.0,
                                  padding: EdgeInsets.all(10.0),
                                  constraints: BoxConstraints(
                                      minHeight: 100, maxHeight: 500),
                                  child: _makeCategoryList(
                                      subCategories, bloc, stateUpdater))
                            ],
                          );
                        },
                      );
                    });
                if (subCategory != null) {
                  Navigator.pop(context, subCategory);
                }
              }
            };

            // Only show checkbox when showing leaf category
            bool check = false;
            var subcategories =
                widget.isMultiselect ? category.childrenObj : [];
            if (widget.isMultiselect && subcategories.length == 0)
              check = _selectedCategories.any((e) => e.id == category.id);
            isFavorite = _user != null
                ? _user.favoriteCategoryObjs.contains(category)
                : false;

            return ListTile(
              leading: Icon(getMdiIcon(category.icon) ?? Icons.folder_open,
                  size: 24.0),
              title: Row(
                children: <Widget>[
                  Flexible(
                      child: Text(
                    category.name,
                  )),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: (isContainSubCategory)
                        ? Icon(
                            getMdiIcon('chevronDoubleDown'),
                            size: 24.0,
                            color: Colors.orange,
                          )
                        : SizedBox(),
                  )
                ],
              ),
              trailing: (widget.isMultiselect && subcategories.length == 0)
                  ? Checkbox(
                      value: check,
                      onChanged: (bool value) async {
                        stateUpdater(() {
                          if (check) {
                            _selectedCategories
                                .removeWhere((e) => e.id == category.id);
                          } else {
                            _selectedCategories.add(category);
                          }
                        });
                      })
                  : GestureDetector(
                      onTap: () async {
                        addToFavorite(category, stateUpdater);
                      },
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : null,
                      )),
              onTap: () async {
                listItemOnTapHandler();
              },
            );
          });
    }

    return SimpleDialog(contentPadding: EdgeInsets.all(5.0), children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              lang.product_category,
              style: new TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
          Spacer(),
          if (widget.isMultiselect)
            IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  Navigator.pop(context, _selectedCategories);
                }),
        ],
      ),
      Divider(),
      Row(
        children: <Widget>[
          Expanded(
            child: Padding(
                padding: EdgeInsets.all(5.0),
                child: new TextField(
                    controller: _searchTextController,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.greenAccent)),
                        prefixIcon: Icon(Icons.search),
                        hintText: lang.message_search))),
          )
        ],
      ),
      Container(
          height: 500,
          width: 450,
          child: StreamBuilder(
              stream: _bloc.outCategories,
              builder: (context, AsyncSnapshot<List<Category>> snapshot) {
                if (snapshot.hasData) {
                  return _makeCategoryList(snapshot.data, _bloc, setState);
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }
                return Center(child: CircularProgressIndicator());
              }))
    ]);
  }

  void addToFavorite(Category category, StateSetter stateUpdater) {
    if (_user != null) {
      isFavorite = _user.favoriteCategoryObjs.contains(category);
      if (isFavorite) {
        stateUpdater(() {
          _user.favoriteCategoryObjs.removeWhere((e) => e.id == category.id);
        });
        _favoriteBloc.deleteFavoriteCategory(category);
      } else {
        if (category != null) {
          if (!_user.favoriteCategoryObjs.contains(category) &&
              _user.favoriteCategoryObjs.length < 10) {
            if(category.parentId != 0)
              category.getPath(_bloc.getCategoriesFromCache());
            stateUpdater(() {
              _user.favoriteCategoryObjs.add(category);
            });
            _favoriteBloc.addFavoriteCategory(category);
          }
        }
      }
    } else
      requiredLogin(context);
  }
}
