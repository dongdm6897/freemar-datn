import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HelpScreen extends StatefulWidget {
  final String title;
  final String url;

  HelpScreen({this.title, this.url});

  @override
  _HelpScreenState createState() => new _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final SimpleLogger _logger = SimpleLogger()..mode = LoggerMode.print;

  WebViewController _controller;
  bool _isLoading;

  @override
  void initState() {
    _isLoading = true;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: IndexedStack(
          index: _isLoading ? 1 : 0,
          children: <Widget>[
            WebView(
                initialUrl: widget.url,
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController wbController) {
                  _logger.info('WebView was created.');
                  _controller = wbController;
                },
                onPageFinished: (String url) {
                  setState(() {
                    _isLoading = false;
                  });
                }),
            Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
              color: Colors.white,
            )
          ],
        ));
  }
}
