import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/collection_bloc.dart';
import 'package:flutter_rentaza/models/Product/collection.dart';
import 'package:flutter_rentaza/ui/pages/product/collection_product.dart';
import 'package:flutter_rentaza/utils/no_data.dart';

class CollectionListWidget extends StatefulWidget {
  @override
  _CollectionListWidget createState() => _CollectionListWidget();
}

class _CollectionListWidget extends State<CollectionListWidget> {
  CollectionBloc _bloc;

  @override
  void initState() {
    _bloc = new CollectionBloc();
    _bloc.getCollections();

    super.initState();
  }

  @override
  void dispose() {
//    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Collection>>(
      stream: _bloc.outCollections,
      builder: (context, AsyncSnapshot<List<Collection>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length == 0)
            return Center(
                child: noData());
          else
            return Card(
              elevation: 5.0,
              child: GridView.count(
                crossAxisCount: 2,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: MediaQuery.of(context).size.width /
                    (MediaQuery.of(context).size.height / 4),
                children:
                    List<Container>.generate(snapshot.data.length, (int index) {
                  return Container(
                    child: menuStack(context, snapshot.data[index]),
                  );
                }),
              ),
            );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

//menuStack
  Widget menuStack(BuildContext context, Collection collection) => InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => CollectionProductPage(
                        collection: collection,
                      )));
        },
        splashColor: Colors.orange,
        child: Padding(
          padding: const EdgeInsets.all(2.5),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              menuImage(collection),
              menuColor(),
              menuData(collection),
            ],
          ),
        ),
      );

  //stack 1/3
  Widget menuImage(Collection collection) => Image.network(
        collection.image,
        fit: BoxFit.cover,
      );

  //stack 2/3
  Widget menuColor() => Container(
        decoration: BoxDecoration(boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.orangeAccent.withOpacity(0.4),
            blurRadius: 5.0,
          ),
        ]),
      );

  //stack 3/3
  Widget menuData(Collection collection) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 10.0,
          ),
          Text(
            collection.name,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )
        ],
      );
}
