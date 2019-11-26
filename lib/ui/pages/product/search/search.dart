import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/app_bloc.dart';
import 'package:flutter_rentaza/blocs/search_bloc.dart';
import 'package:flutter_rentaza/models/User/user.dart';
import 'package:flutter_rentaza/ui/pages/product/search/favorite_search.dart';
import 'package:flutter_rentaza/ui/pages/product/search/search_all.dart';
import 'package:flutter_rentaza/ui/widgets/custom_float.dart';
import 'package:flutter_rentaza/ui/widgets/required_login.dart';
import 'package:flutter_rentaza/ui/widgets/search_bar.dart';
import 'package:flutter_rentaza/ui/widgets/brand_list.dart';
import 'package:flutter_rentaza/ui/widgets/category_list.dart';
import 'package:flutter_rentaza/ui/widgets/rank_list.dart';
import 'package:flutter_rentaza/ui/widgets/common_drawer.dart';
import 'package:flutter_rentaza/utils/ui_data.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class Search extends StatefulWidget {
  @override
  _Search createState() => _Search();
}

class _Search extends State<Search> with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  SearchBloc _searchBloc;
  User _user;

  final _searching = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _searchBloc = new SearchBloc();
    _user = AppBloc().loginUser;
  }

  @override
  void dispose() {
    _searchBloc.dispose();
    super.dispose();
  }

  Widget buttonRow(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          width: width / 3,
          child: RaisedButton.icon(
            onPressed: () async {
              try {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return BrandListWidget();
                  },
                );
                setState(() {});
              } catch (FormatException) {}
            },
            elevation: 2.0,
//            shape: new RoundedRectangleBorder(
//              borderRadius: new BorderRadius.circular(5.0),
//            ),
            icon: Icon(Icons.branding_watermark, color: Colors.white70),
            label: Text(
              "Brand",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        Container(
          width: width / 3,
          child: RaisedButton.icon(
            onPressed: () async {
              try {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CategoryListWidget();
                  },
                );
                setState(() {});
              } catch (FormatException) {}
            },
            elevation: 2.0,
//            shape: new RoundedRectangleBorder(
//              borderRadius: new BorderRadius.circular(5.0),
//            ),
            icon: Icon(Icons.category, color: Colors.white70),
            label: Flexible(
              child: Text(
                "Category",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget ranking() {
    return Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20.0,
          ),
        ]),
        padding: EdgeInsets.all(12.0),
        margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
        height: 600.0,
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                "Ranking",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Divider(),
            Expanded(
                child: RankListWidget(
              neverScrollable: true,
            )),
            Divider(),
            Container(
              padding: EdgeInsets.all(10.0),
              child: GestureDetector(
                child: Row(children: <Widget>[
                  Icon(Icons.arrow_forward, color: Colors.red),
                  Padding(padding: EdgeInsets.all(5.0)),
                  Text("More...", style: TextStyle(color: Colors.red))
                ]),
                onTap: () {
                  Navigator.pushNamed(context, UIData.RANK_PAGE);
                },
              ),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CommonDrawer(user: _user),
      appBar: AppBar(
        title: SearchBar(
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchAll(),
              ),
            );
          },
        ),
      ),
      floatingActionButton: CustomFloat(
        icon: Icons.camera_alt,
        qrCallback: () {
          if (_user == null)
            requiredLogin(context);
          else
            Navigator.pushNamed(context, UIData.CREATE_PRODUCT);
        },
      ),
      body: ValueListenableBuilder(
          valueListenable: _searching,
          builder: (context, value, _) {
            return ModalProgressHUD(
              inAsyncCall: value,
              child: Container(
                margin: const EdgeInsets.all(5.0),
                padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.white70)),
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverList(
                      delegate: SliverChildListDelegate([
                        _user != null
                            ? FavoriteSearch(
                                user: _user, searchBloc: _searchBloc)
                            : Container(),
                        ranking(),
                      ]),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
