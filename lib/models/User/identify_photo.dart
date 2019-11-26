import '../root_object.dart';

class IdentifyPhoto extends RootObject {
  int id;
  String frontImageLink;
  String backImageLink;
  String comment;
  int typeId;
  int isConfirm;
  DateTime createdAt;
  DateTime updatedAt;

  IdentifyPhoto(
      {this.id,
      this.frontImageLink,
      this.backImageLink,
      this.comment,
      this.typeId,
      this.isConfirm,
      this.createdAt,
      this.updatedAt});

  @override
  factory IdentifyPhoto.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      return new IdentifyPhoto(
        id: json["id"],
        frontImageLink: json["font_image_link"],
        backImageLink: json["back_image_link"],
        comment: json["comment"],
        typeId: json["type_id"],
        isConfirm: json["is_confirm"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );
    }
    return null;
  }
}
