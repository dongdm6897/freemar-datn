import 'package:flutter/material.dart';

class PhoneAuthPage extends StatefulWidget {
  @override
  State createState() => _PhoneAuthPage();
}

class _PhoneAuthPage extends State<PhoneAuthPage> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Authentication"),
      ),
      body: Builder(
          builder: (context) => SingleChildScrollView(
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
                              child: Text("Phone number"),
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Flexible(
                                    child: Icon(
                                  Icons.phone_android,
                                  size: 35.0,
                                )),
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                          labelText: "Phone number"),
                                      keyboardType: TextInputType.number,
                                      enabled: true,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Container(
                              width: MediaQuery.of(context).size.height,
                              child: FlatButton(
                                color: Colors.red,
                                child: Text(
                                  "SMS",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {},
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )),
    );
  }
}
