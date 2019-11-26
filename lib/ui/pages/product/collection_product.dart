import 'package:flutter/material.dart';
import 'package:flutter_rentaza/models/Product/actions/product_tabs.dart';
import 'package:flutter_rentaza/models/Product/collection.dart';
import 'package:flutter_rentaza/ui/widgets/product_gird.dart';

class CollectionProductPage extends StatefulWidget {
  final Collection collection;

  const CollectionProductPage({Key key, this.collection}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CollectionProductPage();
  }
}

class _CollectionProductPage extends State<CollectionProductPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.collection?.name),
        ),
        body: ProductGird(
            productTabs: ProductTabs(
                tabId: widget.collection?.id,
                name: ProductTabs.ACTION_COLLECTION,
                pageSize: 20)));
  }
}
