import 'package:flutter/foundation.dart';

class FilterBy {
  final String filter;
  bool loadFirstPage = true;
  int pageSize;

  FilterBy({@required this.filter, this.loadFirstPage, this.pageSize})
      : assert(filter != null);
}

const List<String> presetTags = const [
  'Low Price',
];
