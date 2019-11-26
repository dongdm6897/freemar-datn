import 'package:flutter/material.dart';
import 'package:flutter_rentaza/generated/i18n.dart';

class AttributeColorWidget extends StatefulWidget {
  @override
  _AttributeColorWidget createState() => _AttributeColorWidget();
}

class _AttributeColorWidget extends State<AttributeColorWidget> {
  // List<AttributeColor> _listColors;
  List<bool> _colorSelection;

  @override
  void initState() {
    if (this.mounted) {
      setState(() {
        // _listColors = AppBloc().attributeColors;
        // _colorSelection = new List<bool>.filled(_listColors.length, false);
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget colorStack(BuildContext context, double width, double height,
      Orientation orientation, int index) {
//     var listColors = AppBloc().attributeColors;
//     return GestureDetector(
//         onTap: () {
//           if (_colorSelection[index] == true) {
//             setState(() {
//               _colorSelection[index] = false;
//             });
//           } else {
//             setState(() {
//               _colorSelection[index] = true;
//             });
//           }
//         },
//         child: Stack(
//           alignment: AlignmentDirectional.center,
//           children: <Widget>[
//             Container(
//               width:
//                   orientation == Orientation.portrait ? width / 3 : width / 2,
//               height: orientation == Orientation.portrait
//                   ? height / 12
//                   : height / 6,
//               decoration: new BoxDecoration(
//                   color: HexColor(listColors[index].value),
//                   shape: BoxShape.circle,
//                   border: new Border.all(color: Colors.grey)),
//             ),
//             //        Positioned(
// //          child: Text(listColors[index].name,
// //              style: TextStyle(
// //                fontWeight: FontWeight.bold,
// //                fontSize: 12.0,
// //              )),
// //          top: 30.0,
// //          left: orientation == Orientation.portrait ? 28.0 : 38.0,
// //        ),
//             _colorSelection[index]
//                 ? Container(
//                     child: listColors[index].name == 'White'
//                         ? Icon(Icons.done, color: Colors.grey)
//                         : Icon(Icons.done, color: Colors.white),
//                   )
//                 : Container(),
//           ],
//         ));
  }

  @override
  Widget build(BuildContext context) {
    var lang = S.of(context);

    // final width = MediaQuery.of(context).size.width * .7;
    // final height = MediaQuery.of(context).size.height * .5;
    // return AlertDialog(
    //   contentPadding: const EdgeInsets.all(10.0),
    //   title: Text(
    //     lang.product_color,
    //     style: TextStyle(
    //         fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15.0),
    //   ),
    //   content: Container(
    //     width: width * .9,
    //     height: height * .9,
    //     child: _listColors.length > 0
    //         ? OrientationBuilder(builder: (context, orientation) {
    //             return GridView.count(
    //               crossAxisCount: orientation == Orientation.portrait ? 3 : 4,
    //               childAspectRatio: 1.0,
    //               padding: const EdgeInsets.all(4.0),
    //               mainAxisSpacing: 4.0,
    //               crossAxisSpacing: 4.0,
    //               children: List.generate(_listColors.length, (index) {
    //                 return colorStack(
    //                     context, width, height, orientation, index);
    //               }),
    //             );
    //           })
    //         : Center(
    //             child: CircularProgressIndicator(),
    //           ),
    //   ),
    //   actions: <Widget>[
    //     IconButton(
    //         splashColor: Colors.green,
    //         icon: new Icon(
    //           Icons.clear,
    //           color: Colors.blue,
    //         ),
    //         onPressed: () {
    //           if (_colorSelection.contains(true)) {
    //             setState(() {
    //               for (int i = 0; i < _listColors.length; i++) {
    //                 _colorSelection[i] = false;
    //               }
    //             });
    //           } else
    //             Navigator.pop(context);
    //         }),
    //     IconButton(
    //         splashColor: Colors.green,
    //         icon: new Icon(
    //           Icons.done,
    //           color: Colors.blue,
    //         ),
    //         onPressed: () {
    //           var resultColors = [];
    //           for (int i = 0; i < _listColors.length; i++) {
    //             if (_colorSelection[i]) {
    //               resultColors.add(_listColors[i]);
    //             }
    //           }
    //           Navigator.pop(context, resultColors);
    //         })
    //   ],
    // );
  }
}
