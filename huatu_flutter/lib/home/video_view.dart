import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:huatu_flutter/model/home_model.dart';
import 'package:huatu_flutter/movie/video_controler.dart';
import 'package:huatu_flutter/utils/jump_natvie.dart';
import 'package:huatu_flutter/utils/net_utils.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/src/chewie_player.dart';

class VideoScaffold extends StatefulWidget {
  String title;
  List<TvInfo> playLists;
  String currentPath = '';
  String baseUrl = '';

  VideoScaffold({this.title, this.playLists, this.currentPath, this.baseUrl});

  @override
  State<StatefulWidget> createState() => _VideoScaffoldState();
}

class _VideoScaffoldState extends State<VideoScaffold> {
  String url;
  bool isSucces;
  VideoPlayerController _controller;
  ChewieController _chewieController;
  bool _isPlaying = false;
  bool _hasErro = false;
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
    if (_controller != null) _controller.dispose();
    if (_chewieController != null) _chewieController.dispose();
  }

  void onEvent(Object event) {
    if (url == event) return;
    url = event;
    isSucces = true;
    print("==onEvent==" + url);
    initVideo();
  }

  void initVideo() {
    _controller = VideoPlayerController.network(this.url)
      // 播放状态
      ..addListener(() {
        _hasErro = _controller.value.hasError;
        final bool isPlaying = _controller.value.isPlaying;
        if (isPlaying != _isPlaying) {
          setState(() {
            _isPlaying = isPlaying;
          });
        }
      })
      // 在初始化完成后必须更新界面
      ..initialize().then((_) {
        _chewieController = ChewieController(
          videoPlayerController: _controller,
          aspectRatio: _controller.value.aspectRatio,
          customControls: MaterialControls(
            title: widget.title,
          ),
          showControls: true,
        );
        setState(() {});
      });
  }

  void _onError(Object error) {
    PlatformException exception = error;
    url = exception.message != null && exception.message.isNotEmpty
        ? exception.message
        : exception.details;
    print("_onError == " + url);
    if (url.contains('playdata')) {
      NetUtils.getVideoUrl(url).then((value) {
        onEvent(value);
      });
    } else
      setState(() {
        isSucces = true;
        _hasErro = true;
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[100],
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.black),
        ),
      ),
      backgroundColor: Colors.white,
      body: (widget.playLists == null || widget.playLists.isEmpty)
          ? Center(
              child: CircularProgressIndicator(
              backgroundColor: Colors.pink,
            ))
          : ListView(
              children: <Widget>[
                createBody(),
                createTvNum(widget.playLists),
              ],
            ),
    );
  }

  Widget createBody() {
    return Container(
      color: Colors.grey,
      child: (url == null || url.isEmpty || !isSucces)
          ? Center(
              child: CircularProgressIndicator(
              backgroundColor: Colors.pink,
            ))
          : _hasErro
              ? new WebviewScaffold(
                  url: url,
                  withZoom: false,
                  withLocalStorage: true,
                )
              : Chewie(
                  controller: _chewieController,
                ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width * 9 / 16,
      alignment: Alignment.topCenter,
    );
  }

  createTvNum(List<TvInfo> playLists) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      itemCount: playLists.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          //单个子Widget的水平最大宽度
          maxCrossAxisExtent: 80,
          //水平单个子Widget之间间距
          mainAxisSpacing: 10.0,
          //垂直单个子Widget之间间距
          crossAxisSpacing: 2.0,
          childAspectRatio: 4 / 3),
      itemBuilder: (context, index) {
        TvInfo f = playLists[index];
        String videoPath = f.path;
        if (!videoPath.startsWith("http")) {
          videoPath = widget.baseUrl + f.path;
        }
        return Padding(
          padding: EdgeInsets.all(2.0),
          child: ChoiceChip(
              label: Text(f.number),
              labelStyle: TextStyle(
                fontSize: 12,
              ),
              //未选定的时候背景
              backgroundColor: Colors.pink[500],
              selectedColor: Colors.pink[200],
              //被禁用得时候背景
              disabledColor: Colors.pink[100],
              materialTapTargetSize: MaterialTapTargetSize.padded,
              onSelected: (bool sel) {
                if (sel) {
                  isSucces = false;
                  JumpNativie().jumpToNativeWithValue(
                      "webview_video", "getVideo", videoPath);
                  setState(() {
                    widget.currentPath = f.path;
                  });
                }
              },
              selected: widget.currentPath == f.path),
        );
//        return RaisedButton(
//          onPressed: () {
//            JumpNativie()
//                .jumpToNativeWithValue("webview_video", "getVideo", f.path);
//          },
//          child:
//          Text(
//            f.number,
//            style: TextStyle(fontSize: 8),
//          ),
//          color: Colors.pink[200],
//          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//        );
      },
    );
  }
}
