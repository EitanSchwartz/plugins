import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class TestWebView extends StatelessWidget {
  GlobalKey _key = GlobalKey();
  final double _WEBVIEW_HEIGHT = 800;
  WebViewController webViewController;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: _key,
      constraints: BoxConstraints(maxHeight: _WEBVIEW_HEIGHT),
      child: WebView(
        initialUrl: "https://news.google.com",
        debuggingEnabled: true,
      ),
    );
  }

}
