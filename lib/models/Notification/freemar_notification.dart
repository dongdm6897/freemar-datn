import '../root_object.dart';

class FreeMarNotification extends RootObject {

  final int id;
  final String title;
  final String body;
  final String image;
  final bool isUnread;
  final int typeId;

  FreeMarNotification({
    this.id,
    this.title,
    this.body,
    this.image,
    this.isUnread,
    this.typeId
  });

  @override
  factory FreeMarNotification.fromJson(Map<String, dynamic> json) {
    return FreeMarNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      image:json['image'],
      isUnread:json['isUnread'],
      typeId: json['type_id']
    );
  }
}
