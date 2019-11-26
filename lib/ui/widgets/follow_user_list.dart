import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/load_more_bloc.dart';
import 'package:flutter_rentaza/blocs/user_bloc.dart';
import 'package:flutter_rentaza/models/Product/product.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/ui/pages/product/product_detail.dart';
import 'package:flutter_rentaza/ui/pages/user/profile.dart';
import 'package:flutter_rentaza/ui/widgets/user_info.dart';
import 'package:flutter_rentaza/utils/no_data.dart';
import 'package:flutter_rentaza/utils/string_utils.dart';
import 'package:transparent_image/transparent_image.dart';

class FollowUserList extends StatefulWidget {
  final bool getAllSeller;

  FollowUserList({this.getAllSeller = true});

  @override
  _FollowUserListState createState() {
    return _FollowUserListState();
  }
}

class _FollowUserListState extends State<FollowUserList> {
  User _currentUser;
  UserBloc _userBloc;
  final _scrollController = ScrollController();
  static const offsetVisibleThreshold = 50;

  @override
  void initState() {
    super.initState();
    _currentUser = AppBloc().loginUser;
    _userBloc = UserBloc();

    _scrollController.addListener(_onScroll);
    _userBloc.loadFirstPage.add({
      'loadFirstPage': true,
      'getAllSeller': widget.getAllSeller,
      'userId': _currentUser?.id ?? ""
    });
  }

  void _onScroll() {
    if (_scrollController.offset + offsetVisibleThreshold >=
        _scrollController.position.maxScrollExtent) {
      _userBloc.loadMore.add({
        'loadFirstPage': false,
        'getAllSeller': widget.getAllSeller,
        'userId': _currentUser?.id ?? ""
      });
    }
  }

  @override
  void dispose() {
    _userBloc.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: Container(
        constraints: BoxConstraints.expand(),
        child: StreamBuilder<ObjectListState>(
          stream: _userBloc.objectsList,
          builder:
              (BuildContext context, AsyncSnapshot<ObjectListState> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error ${snapshot.error}'),
              );
            }

            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (!snapshot.data.isLoading && snapshot.data.objects.length == 0)
                return Center(child: noData());
              else
                return _buildList(snapshot);
            }
          },
        ),
      ),
      onRefresh: () {},
    );
  }

  ListView _buildList(AsyncSnapshot<ObjectListState> snapshot) {
    final users = snapshot.data.objects;
    final isLoading = snapshot.data.isLoading;
    final error = snapshot.data.error;

    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      itemBuilder: (BuildContext context, int index) {
        if (index < users.length) {
          User user = users[index];
          return ((user.sellingProductObjs?.length ?? 0) > 0)
              ? _buildUserTile(context, user)
              : const SizedBox();
        }
        if (error != null) {
          return ListTile(
            title: Text(
              'Error while loading data...$error',
              style: Theme.of(context).textTheme.body1.copyWith(fontSize: 16.0),
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
      },
      itemCount: users.length + 1,
//      separatorBuilder: (BuildContext context, int index) => Divider(),
    );
  }

  Widget _buildUserTile(BuildContext context, User user) {
    var size = MediaQuery.of(context).size;

    return InkWell(
      onTap: () {
        var route = new MaterialPageRoute(
            builder: (BuildContext context) => ProfilePage(user: user));
        Navigator.of(context).push(route);
      },
      child: Card(
        elevation: 5.0,
        margin: new EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10.0)),
          child: Stack(
            children: <Widget>[
              SizedBox(
                  height: 360.0,
                  width: size.width,
                  child: user?.coverImageLink != null
                      ? Image.network(user.coverImageLink, fit: BoxFit.cover)
                      : Image.asset(
                          'assets/images/bg-summer.jpg',
                        )),
              Container(
                height: 360.0,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400.withOpacity(0.5),
                ),
              ),
              Positioned(
                  top: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                      color: Colors.white.withOpacity(0.5),
                      width: size.width,
                      child: UserInfoWidget(user: user, isSimpleMode: true))),
              Positioned(
                bottom: 5.0,
                right: 0.0,
                left: 0.0,
                child: Container(
                    color: Colors.transparent,
                    height: 195.0,
                    child: _productStack(user)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _productStack(User user) {
    return ListView(
        scrollDirection: Axis.horizontal,
        children: user.sellingProductObjs
            .map((product) => GestureDetector(
                onTap: () {
                  var route = MaterialPageRoute(
                      builder: (BuildContext context) =>
                          ProductDetailPage(product: product));
                  Navigator.of(context).push(route);
                },
                child: Stack(
                  fit: StackFit.passthrough,
                  children: <Widget>[
                    Container(
                      width: 120.0,
                      padding: EdgeInsets.all(4.0),
                      margin: EdgeInsets.only(
                          left: 12.0, right: 0.0, top: 12.0, bottom: 12.0),
//                      decoration: _containerDecoration(),
                      decoration:
                          BoxDecoration(color: Colors.white, boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20.0,
                        ),
                      ]),
                      child: Column(
                        children: <Widget>[
                          _imageStack(
                              product.representImage, product.isOrdering),
                          _descStack(product)
                        ],
                      ),
                    ),
                    _loveStack(product),
                  ],
                )))
            .toList());
  }

  Widget _imageStack(String img, bool isOrdering) {
    Widget loadImage = CachedNetworkImage(
        width: 120.0,
        height: 120.0,
        fit: BoxFit.fill,
        imageUrl: img,
        placeholder: (context, url) =>
            Center(child: new CircularProgressIndicator()),
        errorWidget: (context, url, error) => new Icon(Icons.error));
    return ClipRect(
      child: isOrdering
          ? Banner(
              message: "SOLD OUT",
              location: BannerLocation.topStart,
              color: Colors.red,
              child: loadImage,
            )
          : loadImage,
    );
  }

  Widget _descStack(Product product) {
    return Container(
        padding: EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              product.name,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.black, fontSize: 10.0),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                      fit: FlexFit.tight,
                      child: Text(
                          formatCurrency(product.price,
                              useNatureExpression: true),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold))),
                ],
              ),
            )
          ],
        ));
  }

  Widget _loveStack(Product product) {
    var isFavorite = _currentUser?.checkFavorite(product.id) ?? false;

    return Positioned(
      bottom: 10.0,
      right: 0.0,
      child: InkWell(
        onTap: () {
          if (this.mounted) {
            setState(() {
              if (!isFavorite) {
                _userBloc.setFavorite(_currentUser, product);
              } else {
                _userBloc?.clearFavorite(_currentUser, product);
              }
            });
          }
        },
        child: Container(
          padding: EdgeInsets.all(4.0),
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: Colors.red,
            size: 24.0,
          ),
        ),
      ),
    );
  }

  BoxDecoration _containerDecoration(
      {Color borderColor = null, double radius = 8.0}) {
    return BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5.0,
          ),
        ],
        borderRadius: BorderRadius.circular(radius),
        border: (borderColor != null)
            ? Border.all(
                color: borderColor,
                width: 2.0,
              )
            : null);
  }
}
