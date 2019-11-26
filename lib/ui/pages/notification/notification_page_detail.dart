import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rentaza/models/Notification/freemar_notification.dart';

class NotificationDetailPage extends StatefulWidget {
  final FreeMarNotification data;

  const NotificationDetailPage({Key key, this.data}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NotificationDetailPage();
  }
}

class _NotificationDetailPage extends State<NotificationDetailPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var data = widget.data;
    return Scaffold(
      appBar: AppBar(
        title: Text(data.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Html(data: data.body),
        ),
      ),
    );
  }
}
