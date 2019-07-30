import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class CommonWebView extends StatefulWidget {
  final String title;

  final String url;

  CommonWebView(this.title, this.url);

  @override
  State<StatefulWidget> createState() {
    return new _CommonWebViewPageState();
  }
}

class _CommonWebViewPageState extends State<CommonWebView> {
  FlutterWebviewPlugin flutterWebviewPlugin = FlutterWebviewPlugin();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  webListener() {
    /**
     * 监听web页加载状态
     */
    flutterWebviewPlugin.onStateChanged
        .listen((WebViewStateChanged webViewState) async {
      switch (webViewState.type) {
        case WebViewState.finishLoad:
          break;
        case WebViewState.shouldStart:
          break;
        case WebViewState.startLoad:
          break;
        case WebViewState.abortLoad:
          break;
      }
      print("webview..state..." + webViewState.type.toString());
    });
    flutterWebviewPlugin.onUrlChanged.listen((String url) {
      print("webview..." + url);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    flutterWebviewPlugin.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new WebviewScaffold(
      url: widget.url,
      withJavascript:true,
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      withZoom: false,
      withLocalStorage: true,
    );
  }
}
