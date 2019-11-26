import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/rank_bloc.dart';
import 'package:flutter_rentaza/blocs/search_bloc.dart';
import 'package:flutter_rentaza/models/Product/actions/product_search_template.dart';
import 'package:flutter_rentaza/models/Product/brand.dart';
import 'package:flutter_rentaza/models/Product/category.dart';
import 'package:flutter_rentaza/models/Product/rank.dart';
import 'package:flutter_rentaza/ui/pages/product/search/search_results.dart';
import 'package:flutter_rentaza/ui/widgets/list_cell.dart';

class RankListWidget extends StatefulWidget {
  final neverScrollable;
  RankListWidget({this.neverScrollable = false});

  @override
  _RankListWidget createState() => _RankListWidget();
}

class _RankListWidget extends State<RankListWidget> {
  RankBloc _bloc;
  ProductSearchTemplate productSearchTemplate;
  SearchBloc searchBloc;

  @override
  void initState() {
    super.initState();
    _bloc = RankBloc();
    _bloc.getRanks();
    productSearchTemplate = new ProductSearchTemplate();
    searchBloc = SearchBloc();
  }

  @override
  void dispose() {
    _bloc.dispose();
    searchBloc.dispose();
    super.dispose();
  }

  Widget _buildListItem(BuildContext context, Rank data, index) {
    return Column(children: <Widget>[
      ListCell(
          leading: Container(
            width: 30.0,
            height: 30.0,
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              color: index == 0
                  ? Colors.orange
                  : index == 1
                      ? Colors.grey
                      : index == 2 ? Colors.redAccent : Colors.blueGrey,
            ),
            child: Center(
                child: Text((index + 1).toString(),
                    style: new TextStyle(color: Colors.white, fontSize: 15.0))),
          ),
          trailing: SizedBox(
            width: 64,
            height: 64,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              child: Material(
                color: Colors.transparent,
                child: CachedNetworkImage(
                  imageUrl: data.image,
                ),
              ),
            ),
          ),
          title: data.brandName,
          subtitle: data.categoryName,
          onTap: () {
            productSearchTemplate.categoryObjs = [
              Category(id: data.categoryId, name: data.categoryName)
            ];
            productSearchTemplate.brandObjs = [
              Brand(id: data.brandId, name: data.brandName)
            ];
            searchBloc.inSearch.add(productSearchTemplate);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchResults(
                  searchBloc: searchBloc,
                  productSearchTemplate: productSearchTemplate,
                ),
              ),
            );
          }),
      const Divider(height: 1.0, indent: 96.0)
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _bloc.outRanks,
      builder: (context, AsyncSnapshot<List<Rank>> snapshot) {
        if (snapshot.hasData) {
          return Scrollbar(
              child: ListView.builder(
            physics: widget.neverScrollable
                ? const NeverScrollableScrollPhysics()
                : null,
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) =>
                _buildListItem(context, snapshot.data[index], index),
          ));
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
