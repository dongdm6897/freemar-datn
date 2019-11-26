import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rentaza/generated/i18n.dart';

class ContactAddressPage extends StatefulWidget {
  @override
  State createState() => _ContactAddressPage();
}

class _ContactAddressPage extends State<ContactAddressPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var lang = S.of(context);
    Widget buildTextFormField(String labelText, String hintText) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            decoration:
                InputDecoration(labelText: labelText, hintText: hintText),
            keyboardType: TextInputType.number,
            enabled: true,
          ),
        );
    return Scaffold(
        appBar: AppBar(
          title: Text("Contact - Address"),
        ),
        body: Builder(
            builder: (context) =>
                Stack(fit: StackFit.expand, children: <Widget>[
                  SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          child: Form(
                            child: Column(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text("Contact Address"),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Flexible(
                                        child: buildTextFormField(
                                            "Last name", "Name")),
                                    Flexible(
                                        child: buildTextFormField(
                                            "First name", "Name"))
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Flexible(
                                      child: buildTextFormField("Say", ''),
                                    ),
                                    Flexible(
                                      child:
                                          buildTextFormField("Description", ''),
                                    )
                                  ],
                                ),
                                buildTextFormField("Phone number", ''),
                                buildTextFormField("Birthday", ''),
                                buildTextFormField("Postal code", ''),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Flexible(
                                        child: buildTextFormField(
                                            "Prefectures", '')),
                                    Flexible(
                                        child: buildTextFormField("City", ''))
                                  ],
                                ),
                                buildTextFormField("Street", ''),
                                buildTextFormField("Company", ''),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: RaisedButton(
                                        child: Text(
                                          lang.cancel,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subhead
                                              .copyWith(color: Colors.red),
                                        ),
                                        color: Colors.white,
                                        onPressed: () {},
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: RaisedButton(
                                        child: Text(
                                          lang.save,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subhead
                                              .copyWith(color: Colors.white),
                                        ),
                                        color: Colors.red,
                                        onPressed: () {},
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ])));
  }
}
