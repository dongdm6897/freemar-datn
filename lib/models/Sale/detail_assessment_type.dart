import '../root_object.dart';

class DetailAssessmentType extends RootObject {
  int id;
  String name;
  int assessmentTypeId;

  DetailAssessmentType({this.id, this.name, this.assessmentTypeId});

  @override
  factory DetailAssessmentType.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      return DetailAssessmentType(id: json["id"], name: json["name"],assessmentTypeId: json['assessment_type_id']);
    }
    return null;
  }
}
