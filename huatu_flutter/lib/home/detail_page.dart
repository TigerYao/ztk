import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:huatu_flutter/utils/net_utils.dart';
import 'package:huatu_flutter/model/home_model.dart';
import 'package:huatu_flutter/utils/jump_natvie.dart';
import 'video_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChewieDemo extends StatefulWidget {
  ChewieDemo({this.title = '播放中', this.url, this.baseUrl});

  final String title;
  String url;
  String baseUrl;

  @override
  State<StatefulWidget> createState() {
    return _ChewieDemoState();
  }
}

class _ChewieDemoState extends State<ChewieDemo> {
  String videoUrl;
  TvDetailModel _detailModel;
  JumpNativie _jumpNativie;
  bool _isCanPlay = false;

  @override
  void initState() {
    super.initState();
    _jumpNativie = JumpNativie();
    String url = (widget.url.contains("http"))
        ? widget.url
        : widget.baseUrl + widget.url;
    NetUtils.getIntro(url).then((tvDetailModel) {
      setState(() {
        _detailModel = tvDetailModel;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  createTagView() {
    if (_detailModel.currentInfo.tags == null)
      return Text(_detailModel.currentInfo.title);
    List<Widget> childrens = _detailModel.currentInfo.tags.map((info) {
      return Container(
        width: 200,
        padding: EdgeInsets.only(right: 5),
        child: Text(
          info,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
          textAlign: TextAlign.left,
        ),
      );
    }).toList();
//    Widget btn = RaisedButton(
//      onPressed: () {
//        _jumpVideo(_detailModel.currentInfo.path);
//      },
//      child: Text('立即播放'),
//      color: Colors.lightGreenAccent,
//      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//    );
    return Column(
      children: <Widget>[Column(children: childrens)],
    );
//    return ListView.builder(
//      itemCount: _detailModel.currentInfo.tags.length,
//      itemBuilder: (context, index) {
//        String data = _detailModel.currentInfo.tags[index];
//        return
//          Row(
//            mainAxisAlignment: MainAxisAlignment.start,
//            children: <Widget>[
//              ClipOval(
//                child: Container(
////                margin: EdgeInsets.all(5),
////                padding: EdgeInsets.all(5),
//                  alignment: Alignment.center,
//                  width: 5,
//                  height: 5,
//                  color: Colors.black,
//                ),
//              ),
//            Padding(
////              padding: EdgeInsets.all(5),
//              child: Text(
//                data,
//                style: TextStyle(color: Colors.white, fontSize: 12),
//              ),
//            )
//          ],
//        );
//      },
//      shrinkWrap: true,
//      physics: NeverScrollableScrollPhysics(),
//    );
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
          childAspectRatio: 4/3),
      itemBuilder: (context, index) {
        TvInfo f = _detailModel.playLists[index];
        return RaisedButton(
          onPressed: () {
            _jumpVideo(f.path, f.title);
          },
          child: Text(
            f.number,
            style: TextStyle(fontSize: 8),
          ),
          color: Colors.pink[200],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        );
      },
    );
  }

  createBodyTop() {
    return Container(
      alignment: Alignment.centerLeft,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: <Widget>[
          new CachedNetworkImage(
            imageUrl: _detailModel.currentInfo.picUrl,
            placeholder: (context, url) => Center(child: new CircularProgressIndicator(),),
            errorWidget: (context, url, error) => new SizedBox.fromSize(),
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
          Positioned(
            left: 10,
            width: 120,
            child: new CachedNetworkImage(
              imageUrl: _detailModel.currentInfo.picUrl,
              placeholder: (context, url) => Center(child: new CircularProgressIndicator(),),
              errorWidget: (context, url, error) => new Icon(Icons.landscape),
              fit: BoxFit.cover,
//              height: MediaQuery.of(context).size.width * 9 / 16,
//              width: MediaQuery.of(context).size.width,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: createTagView(),
          )
//          Container(
//            child: Row(
//              children: <Widget>[
//                Image.network(
//                  _detailModel.currentInfo.picUrl,
//                  fit: BoxFit.fill,
//                  height: MediaQuery.of(context).size.width * 9 / 16,
//                  width: MediaQuery.of(context).size.width,
//                ),
//                createTagView()
//              ],
//            ),
//          )
//          Column(
//            mainAxisAlignment: MainAxisAlignment.center,
//            children: <Widget>[
//              RaisedButton(
//                onPressed: () {
//                  _jumpVideo(widget.baseUrl + _detailModel.currentInfo.path);
//                },
//                child: Text('立即播放'),
//                color: Colors.lightGreenAccent,
//                shape: RoundedRectangleBorder(
//                    borderRadius: BorderRadius.circular(5)),
//              ),
//              Text(
//                _detailModel
//                    .currentInfo.tags[_detailModel.currentInfo.tags.length - 1],
//                style: TextStyle(
//                    backgroundColor: Color(0x55000000), color: Colors.white),
//              )
//            ],
//          ),
//          Row(
//            children: <Widget>[
//              Image.network(
//                _detailModel.currentInfo.picUrl,
//                fit: BoxFit.fill,
//                height: MediaQuery.of(context).size.width * 9 / 16,
//                width: MediaQuery.of(context).size.width,
//              ),
//              createTagView()
//            ],
//          ),
        ],
      ),
    );
  }

  _jumpVideo(String url, String title) {
    if (!url.startsWith('http')) url = widget.baseUrl + url;
    _jumpNativie
        .jumpToNativeWithValue("webview_video", "getVideo", url)
        .then((value) {
      print("videoUrl == " + value);
      setState(() {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => VideoScaffold(title: widget.title, playLists: _detailModel.playLists)));
      });
    });
  }

  createBody() {
    List<Widget> children = List();
    children.add(createBodyTop());
    if (_detailModel.playLists != null && _detailModel.playLists.isNotEmpty)
      children.add(createTvNum());
    if (_detailModel.currentInfo.tvDescription != null &&
        _detailModel.currentInfo.tvDescription.isNotEmpty)
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
      theme: ThemeData.light().copyWith(),
      home: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
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
