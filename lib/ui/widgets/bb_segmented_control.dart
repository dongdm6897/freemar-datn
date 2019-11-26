import 'package:flutter/material.dart';
import 'package:flutter_rentaza/models/Sale/assessment_type.dart';
import 'package:flutter_rentaza/models/Sale/detail_assessment_type.dart';
import 'package:flutter_rentaza/utils/hex_color.dart';
import 'package:flutter_rentaza/utils/icons_helper.dart';

class BbSegmentedControl extends StatefulWidget {
  final List<AssessmentType> assessmentTypes;
  final void Function(AssessmentType assessmentType,
      DetailAssessmentType detailAssessmentType) selectedChanged;
  final bool assessed;
  final DetailAssessmentType detailAssessmentType;

  BbSegmentedControl(
      {this.assessmentTypes, this.selectedChanged, this.assessed = false, this.detailAssessmentType});

  @override
  _BbSegmentedControlState createState() => _BbSegmentedControlState();
}

class _BbSegmentedControlState extends State<BbSegmentedControl> {
  AssessmentType _assessmentType;
  bool _showDetail = false;
  int _selectAssessmentType = 0;
  int _selectDetailAssessmentType = 0;

  @override
  void initState() {
    super.initState();
    _assessmentType = AssessmentType();
    if (widget.assessed)
      for (int i = 0; i < widget.assessmentTypes.length; i++) {
        if (widget.assessmentTypes[i].id ==
            widget.detailAssessmentType.assessmentTypeId) {
          _assessmentType = widget.assessmentTypes[i];
          _selectDetailAssessmentType = widget.detailAssessmentType.id;
          _selectAssessmentType = widget.detailAssessmentType.assessmentTypeId;
          break;
        }
      }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        widget.assessed
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: widget.assessmentTypes.map((ass) {
                  return Container(
                    padding: EdgeInsets.all(5.0),
                    margin: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        color: _selectAssessmentType == ass.id
                            ? HexColor(ass.color)
                            : null,
                        border:
                            Border.all(color: HexColor(ass.color), width: 1.0),
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          getFontAwesomeIcon(name: ass.icon),
                          color: _selectAssessmentType == ass.id
                              ? Colors.white
                              : HexColor(ass.color),
                        ),
                        Text(ass.name,
                            style: TextStyle(
                                color: _selectAssessmentType == ass.id
                                    ? Colors.white
                                    : HexColor(ass.color))),
                      ],
                    ),
                  );
                }).toList(),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: widget.assessmentTypes.map((ass) {
                  return InkWell(
                    onTap: () {
                      widget.selectedChanged(ass, null);
                      setState(() {
                        _assessmentType = ass;
                        _showDetail = true;
                        _selectAssessmentType = ass.id;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(5.0),
                      margin: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          color: _selectAssessmentType == ass.id
                              ? HexColor(ass.color)
                              : null,
                          border: Border.all(
                              color: HexColor(ass.color), width: 1.0),
                          borderRadius: BorderRadius.circular(20.0)),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            getFontAwesomeIcon(name: ass.icon),
                            color: _selectAssessmentType == ass.id
                                ? Colors.white
                                : HexColor(ass.color),
                          ),
                          Text(ass.name,
                              style: TextStyle(
                                  color: _selectAssessmentType == ass.id
                                      ? Colors.white
                                      : HexColor(ass.color))),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
        widget.assessed
            ? Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1)),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: _assessmentType.detailAssessmentTypes.map((detail) {
                    if (detail.name != 'Default')
                      return Container(
                        padding: EdgeInsets.all(8.0),
                        margin: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                            color: _selectDetailAssessmentType == detail.id
                                ? HexColor(_assessmentType.color)
                                : Colors.white,
                            border: Border.all(
                                color: Colors.grey.withOpacity(0.1),
                                width: 1.0),
                            borderRadius: BorderRadius.circular(20.0)),
                        child: Text(detail.name,
                            style: TextStyle(
                                color: _selectDetailAssessmentType == detail.id
                                    ? Colors.white
                                    : Colors.grey)),
                      );
                    else
                      return SizedBox();
                  }).toList(),
                ))
            : Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1)),
                child: _showDetail
                    ? Wrap(
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        children:
                            _assessmentType.detailAssessmentTypes.map((detail) {
                          if (detail.name != 'Default')
                            return InkWell(
                              onTap: () {
                                widget.selectedChanged(null, detail);
                                setState(() {
                                  _selectDetailAssessmentType = detail.id;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(8.0),
                                margin: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                    color:
                                        _selectDetailAssessmentType == detail.id
                                            ? HexColor(_assessmentType.color)
                                            : Colors.white,
                                    border: Border.all(
                                        color: Colors.grey.withOpacity(0.1),
                                        width: 1.0),
                                    borderRadius: BorderRadius.circular(20.0)),
                                child: Text(detail.name,
                                    style: TextStyle(
                                        color: _selectDetailAssessmentType ==
                                                detail.id
                                            ? Colors.white
                                            : Colors.grey)),
                              ),
                            );
                          else
                            return SizedBox();
                        }).toList(),
                      )
                    : SizedBox(),
              )
      ],
    );
  }
}
