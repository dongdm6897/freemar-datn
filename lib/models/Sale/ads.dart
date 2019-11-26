import '../root_object.dart';

class Ads extends RootObject {
  int id;
  String imageLink;
  String url;
  String title;
  int adsTypeId;

  Ads({this.id, this.imageLink, this.title, this.url, this.adsTypeId});

  @override
  factory Ads.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      return Ads(
          id: json['id'],
          imageLink: json['image_link'],
          title: json['title'],
          url: json['url'],
          adsTypeId: json['ads_type_id']);
    }
    return null;
  }
}
