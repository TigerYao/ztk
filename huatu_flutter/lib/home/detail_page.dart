import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:huatu_flutter/utils/net_utils.dart';
import 'comment_webview.dart';

class ChewieDemo extends StatefulWidget {
  ChewieDemo({this.title = 'Chewie Demo', this.url});

  final String title;
  String url;

  @override
  State<StatefulWidget> createState() {
    return _ChewieDemoState();
  }
}

class _ChewieDemoState extends State<ChewieDemo> {
  String videoUrl;

  @override
  void initState() {
    super.initState();
//    _initView('');
    NetUtils.getTvDetail(NetUtils.baseUrl + widget.url).then((tvDetailModel) {
      setState(() {
        videoUrl = NetUtils.baseUrl + tvDetailModel.currentInfo.path;
        print(videoUrl + "...video..");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return
      videoUrl == null ? Center(
          child: CircularProgressIndicator(),
        ): CommonWebView(widget.title, videoUrl);


//      MaterialApp(
//      title: widget.title,
//      theme: ThemeData.light().copyWith(
//        platform: _platform ?? Theme.of(context).platform,
//      ),
//      home: Scaffold(
//        appBar: AppBar(
//          title: Text(widget.title),
//        ),
//        body: _videoPlayerController2== null ? Center(
//          child: CircularProgressIndicator(),
//        ):Column(
//          children: <Widget>[
//            Expanded(
//              child: Center(
//                child: Chewie(
//                  controller: _chewieController,
//                ),
//              ),
//            ),
//            FlatButton(
//              onPressed: () {
//                _chewieController.enterFullScreen();
//              },
//              child: Text('Fullscreen'),
//            ),
//            Row(
//              children: <Widget>[
//                Expanded(
//                  child: FlatButton(
//                    onPressed: () {
//                      setState(() {
//                        _chewieController.dispose();
//                        _videoPlayerController2.pause();
//                        _videoPlayerController2.seekTo(Duration(seconds: 0));
//                        _chewieController = ChewieController(
//                          videoPlayerController: _videoPlayerController1,
//                          aspectRatio: 3 / 2,
//                          autoPlay: true,
//                          looping: true,
//                        );
//                      });
//                    },
//                    child: Padding(
//                      child: Text("Video 1"),
//                      padding: EdgeInsets.symmetric(vertical: 16.0),
//                    ),
//                  ),
//                ),
//                Expanded(
//                  child: FlatButton(
//                    onPressed: () {
//                      setState(() {
//                        _chewieController.dispose();
//                        _videoPlayerController1.pause();
//                        _videoPlayerController1.seekTo(Duration(seconds: 0));
//                        _chewieController = ChewieController(
//                          videoPlayerController: _videoPlayerController2,
//                          aspectRatio: 3 / 2,
//                          autoPlay: true,
//                          looping: true,
//                        );
//                      });
//                    },
//                    child: Padding(
//                      padding: EdgeInsets.symmetric(vertical: 16.0),
//                      child: Text("Video 2"),
//                    ),
//                  ),
//                )
//              ],
//            ),
//            Row(
//              children: <Widget>[
//                Expanded(
//                  child: FlatButton(
//                    onPressed: () {
//                      setState(() {
//                        _platform = TargetPlatform.android;
//                      });
//                    },
//                    child: Padding(
//                      child: Text("Android controls"),
//                      padding: EdgeInsets.symmetric(vertical: 16.0),
//                    ),
//                  ),
//                ),
//                Expanded(
//                  child: FlatButton(
//                    onPressed: () {
//                      setState(() {
//                        _platform = TargetPlatform.iOS;
//                      });
//                    },
//                    child: Padding(
//                      padding: EdgeInsets.symmetric(vertical: 16.0),
//                      child: Text("iOS controls"),
//                    ),
//                  ),
//                )
//              ],
//            )
//          ],
//        ),
//      ),
//    );
  }
}

class VideoScaffold extends StatefulWidget {
  const VideoScaffold({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  State<StatefulWidget> createState() => _VideoScaffoldState();
}

class _VideoScaffoldState extends State<VideoScaffold> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    AutoOrientation.landscapeMode();
    super.initState();
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    AutoOrientation.portraitMode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
