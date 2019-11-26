import '../root_object.dart';
import 'detail_assessment_type.dart';

class Assessment extends RootObject {
  int id;
  int orderId;
  int userId;
  DetailAssessmentType detailAssessmentType;
  String description;
  List<String> imageLinks;

  Assessment({
    this.id,
    this.orderId,
    this.userId,
    this.description,
    this.imageLinks,
    this.detailAssessmentType,
    DateTime createdAt,
    DateTime updatedAt,
  }):super(createdAt: createdAt, updatedAt: updatedAt);

  @override
  factory Assessment.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      return new Assessment(
          id: json["id"],
          orderId: json["order_id"],
          userId: json["user_id"],
          description: json["description"],
          imageLinks: (json["image_links"] as String)?.split(","),
          detailAssessmentType:
              DetailAssessmentType.fromJSON(json["detail_assessment_type"]),
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']));
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id ?? null,
        'order_id': orderId,
        'user_id': userId,
        'description': description,
        'image_links': imageLinks?.join(",") ?? null,
        'detail_assessment_type_id': detailAssessmentType.id,
        'assessment_type_id': detailAssessmentType.assessmentTypeId
      };
}
