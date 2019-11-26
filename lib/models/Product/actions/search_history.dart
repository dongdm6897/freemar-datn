import '../../root_object.dart';

class SearchHistory extends RootObject {
  int id;
  String content;

  SearchHistory({
    this.id,
    this.content,
  });

  @override
  factory SearchHistory.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      return SearchHistory(
        id: json["id"],
        content: json["content"],
      );
    }
    return null;
  }

  Map<String, dynamic> toJson() => {};
}
