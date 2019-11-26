import 'package:flutter/material.dart';
import 'package:flutter_rentaza/blocs/search_bloc.dart';
import 'package:flutter_rentaza/models/Product/actions/product_search_template.dart';
import 'package:flutter_rentaza/ui/pages/product/search/detailed_search.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SearchBar extends StatelessWidget {
  final Function onTap;
  final Function onChange;
  final Function onSubmitted;
  final bool autoFocus;

  const SearchBar({Key key, this.onTap, this.onChange, this.autoFocus = false, this.onSubmitted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: Container(
              decoration: BoxDecoration(boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5.0,
                ),
              ]),
              child: TextField(
                onTap: onTap,
                onChanged: onChange,
                onSubmitted: onSubmitted,
                autofocus: autoFocus,
                decoration: InputDecoration(
                  hintText: 'Search',
                  filled: true,
                  fillColor: Colors.white54,
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.black54),
                ),
                textInputAction: TextInputAction.search,
              ),
            ),
          ),
          Container(
            width: 50,
            padding: EdgeInsets.all(0.0),
            child: FlatButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DetailedSearch(
                                searchBloc: new SearchBloc(),
                                productSearchTemplate:
                                    new ProductSearchTemplate(),
                              )));
                },
                child: Icon(MdiIcons.fileDocumentBoxSearchOutline)),
          )
        ],
      ),
    );
  }
}
