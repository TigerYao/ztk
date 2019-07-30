import 'dart:ui';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:chewie/chewie.dart';
import 'package:chewie/src/chewie_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:huatu_flutter/utils/net_utils.dart';
import 'package:huatu_flutter/model/home_model.dart';
import 'package:huatu_flutter/utils/jump_natvie.dart';

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
  TargetPlatform _platform;
  VideoPlayerController _videoPlayerController1;
  VideoPlayerController _videoPlayerController2;
  ChewieController _chewieController;
  String videoUrl;
  TvDetailModel _detailModel;
  JumpNativie _jumpNativie;

  @override
  void initState() {
    super.initState();
//    _initView('');
    _jumpNativie = JumpNativie();
    _jumpNativie.initListener();
    String url =  (widget.url.contains("http")) ? widget.url : NetUtils.baseUrl + widget.url;
    NetUtils.getIntro(url).then((tvDetailModel) {
      setState(() {
        _detailModel = tvDetailModel;
      });
    });
  }

  _initView(String videoUrl) {
    print(videoUrl + "...video..");
    _videoPlayerController1 = VideoPlayerController.network(
        'https://www3.kkzy-qq.com/hls/2019/07/24/TlY93P1Z/playlist.m3u8');
    _videoPlayerController2 = VideoPlayerController.network(
        'https://www3.kkzy-qq.com/hls/2019/07/24/TlY93P1Z/playlist.m3u8');
    _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController1,
        aspectRatio: 3 / 2,
        autoPlay: true,
        looping: true,
        routePageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondAnimation, provider) {
          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget child) {
              return VideoScaffold(
                child: Scaffold(
                  resizeToAvoidBottomPadding: false,
                  body: Container(
                    alignment: Alignment.center,
                    color: Colors.black,
                    child: provider,
                  ),
                ),
              );
            },
          );
        });
  }

  @override
  void dispose() {
    _jumpNativie.cancle();
//    _videoPlayerController1.dispose();
//    _videoPlayerController2.dispose();
//    _chewieController.dispose();
    super.dispose();
  }

  createTagView() {
    return ListView.builder(
      itemCount: _detailModel.currentInfo.tags.length,
      itemBuilder: (context, index) {
        String data = _detailModel.currentInfo.tags[index];
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ClipOval(
              child: Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                alignment: Alignment.center,
                width: 5,
                height: 5,
                color: Colors.black,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5),
              child: Text(
                data,
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
            )
          ],
        );
//          ListTile(
//          leading: ClipOval(
//            child: Container(
//              alignment: Alignment.center,
//              width: 5,
//              height: 5,
//              color: Colors.black,
//            ),
//          ),
//          title: Text(
//            data,
//            style: TextStyle(color: Colors.black, fontSize: 12),
//          ),
//        );
      },
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
    );
  }

  createTvNum() {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      itemCount: _detailModel.playLists.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          //单个子Widget的水平最大宽度
          maxCrossAxisExtent: 60,
          //水平单个子Widget之间间距
          mainAxisSpacing: 10.0,
          //垂直单个子Widget之间间距
          crossAxisSpacing: 10.0,
          childAspectRatio: 1),
      itemBuilder: (context, index) {
        TvInfo f = _detailModel.playLists[index];
        return RaisedButton(
          onPressed: () {},
          child: Text(
            f.number,
            style: TextStyle(fontSize: 8),
          ),
          color: Colors.lightGreenAccent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        );
      },
    );
  }

  createBodyTop() {
    return Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.width * 9 / 16,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.network(
            _detailModel.currentInfo.picUrl,
            fit: BoxFit.fill,
            height: MediaQuery.of(context).size.width * 9 / 16,
            width: MediaQuery.of(context).size.width,
          ),
          BackdropFilter(
            filter: new ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: new Container(
              color: Colors.white.withOpacity(0.1),
              height: MediaQuery.of(context).size.width * 9 / 16,
              width: MediaQuery.of(context).size.width,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                 _jumpNativie.jumpToNativeWithValue("webview_video", "getVideo", NetUtils.baseUrl + _detailModel.currentInfo.path).then((value){
                    print("videoUrl == "+ value);
                  });
                },
                child: Text('立即播放'),
                color: Colors.lightGreenAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
              ),
              Text(
                _detailModel
                    .currentInfo.tags[_detailModel.currentInfo.tags.length - 1],
                style: TextStyle(
                    backgroundColor: Color(0x55000000), color: Colors.white),
              )
            ],
          ),
        ],
      ),
//      decoration: new BoxDecoration(
//        border: new Border.all(width: 2.0, color: Colors.red),
//        color: Colors.grey,
//        borderRadius: new BorderRadius.all(new Radius.circular(20.0)),
//        image: new DecorationImage(
//          image: new NetworkImage(_detailModel.currentInfo.picUrl),
//          centerSlice: new Rect.fromLTRB(270.0, 180.0, 1360.0, 730.0),
//        ),
//      ),
    );
  }

  createBody() {
    List<Widget> children = List();
    children.add(createBodyTop());
    children.add(createTvNum());
    children.add(createTagView());
    children.add(ListTile(
      title: Text(
        _detailModel.currentInfo.tvDescription,
        style: TextStyle(fontSize: 16, color: Colors.redAccent),
      ),
    ));
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: widget.title,
      theme: ThemeData.light().copyWith(
        platform: _platform ?? Theme.of(context).platform,
      ),
      home: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: _detailModel == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: createBody(),
                    ),
                  ),
                )),
    );
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
