import 'dart:async';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:huatu_flutter/utils/net_utils.dart';

class VideoScaffold extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _VideoScaffoldState();
}

class _VideoScaffoldState extends State<VideoScaffold> {
  String url;
  bool isSucces;

  static const counterPlugin = const EventChannel('com.huatu.counter/plugin');

  StreamSubscription _subscription = null;

  void initListener() {
    if (_subscription == null) {
      _subscription = counterPlugin
          .receiveBroadcastStream()
          .listen(onEvent, onError: _onError);
    }
  }

  void cancle() {
    if (_subscription != null) _subscription.cancel();
  }

  void onEvent(Object event) {
    url = event;
    isSucces = true;
    if (url.contains("get.json")) {
      NetUtils.getVideoUrl(event).then((val) {
        setState(() {
          url = val;
          print("url....jjj  " + url);
        });
      });
    } else {
      setState(() {});
    }
  }

  void _onError(Object error) {
    setState(() {
      isSucces = false;
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    initListener();

//    SystemChrome.setPreferredOrientations([
//      DeviceOrientation.landscapeRight,
//      DeviceOrientation.landscapeLeft,
//    ]);
//    AutoOrientation.landscapeMode();

    super.initState();
  }

  @override
  dispose() {
    cancle();
//    SystemChrome.setPreferredOrientations([
//      DeviceOrientation.portraitUp,
//      DeviceOrientation.portraitDown,
//    ]);
//    AutoOrientation.portraitMode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (url == null || url.isEmpty || !isSucces)
        ? Center(
            child: CircularProgressIndicator(backgroundColor: Colors.yellow,))
        : Container(
            color: Colors.white,
            child: new WebviewScaffold(
              url: url,
              withZoom: false,
              withLocalStorage: true,
            ),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
          );
  }
}
