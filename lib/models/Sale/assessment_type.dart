import 'package:flutter_rentaza/models/Sale/detail_assessment_type.dart';

import '../root_object.dart';

class AssessmentType extends RootObject {
  int id;
  String name;
  String icon;
  String color;
  List<DetailAssessmentType> detailAssessmentTypes;

  AssessmentType({this.id, this.name, this.icon,this.color, this.detailAssessmentTypes});

  @override
  factory AssessmentType.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      return AssessmentType(
          id: json["id"],
          name: json["name"],
          icon: json["icon"],
          color: json['color'],
          detailAssessmentTypes: json['detail_assessment_types'] != null
              ? List<DetailAssessmentType>.from(json['detail_assessment_types']
                  .map((e) => DetailAssessmentType.fromJSON(e)))
              : null);
    }
    return null;
  }
}
