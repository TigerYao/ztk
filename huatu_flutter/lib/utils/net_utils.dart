import 'package:huatu_flutter/api/api.dart';
import 'package:huatu_flutter/api/dio_factory.dart';
import 'package:huatu_flutter/model/recommend_info.dart';
import 'package:huatu_flutter/model/home_model.dart';
import 'package:dio/dio.dart';
import 'package:huatu_flutter/model/top_info.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'dart:convert';

class NetUtils {
  static const List weekNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  static const String baseUrl = "http://m.yhdm.tv";

  static Future<RecommendInfo> getRecommendList() async {
    Dio _dio = DioFactory.getInstance().getDio();
    try {
      Response infos = await _dio.get(Api.RECOMMEND_URL);
      RecommendInfo baseMode = RecommendInfo.fromJson(infos.data);
      return baseMode;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.request);
        print(e.message);
      }
    }
    return null;
  }

  static Future<TopInfoModel> getTopList() async {
    Dio _dio = DioFactory.getInstance().getDio();
    try {
      Response infos = await _dio.get(Api.TOP_LIST_URL);
      print(".....info....." + infos.data.toString());
      TopInfoModel baseMode = TopInfoModel.fromJson(infos.data);
      return baseMode;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.request);
        print(e.message);
      }
    }
    return null;
  }

  static Future<String> getBody(String url) async {
    print('getBody....' + url);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      String htmBody = Utf8Decoder().convert(response.bodyBytes);
      return htmBody;
    }
    return null;
  }

  static Future<HomeModel> requestData() async {
    HomeModel homeModel = HomeModel();
    String htmBody = await getBody(baseUrl);
    if (htmBody != null) {
      Document document = parse(htmBody);
//      print("body ==" + htmBody.toString());
      List<Element> sortsInfo = document.querySelectorAll('.sort > a');
      for (var el in sortsInfo) {
        homeModel.headerInfos
            .add(TvInfo(path: el.attributes['href'], title: el.text));
      }
//      print("headerInfos ==" +  homeModel.headerInfos.toString());
      List<Element> sliderElem = document.querySelectorAll('#slider > li');
//      print("sliderElem ==" + sliderElem.toString());
      for (var sl in sliderElem) {
        Element sliderNode = sl.querySelector('a');
        Element picNode = sl.querySelector('img');
        homeModel.sliderInfos.add(TvInfo(
            path: sliderNode.attributes['href'],
            picUrl: picNode.attributes['src'],
            title: picNode.attributes['alt']));
      }
      List<Element> tListEles = document.querySelectorAll('.tlist > ul');
      for (int i = 0; i < 7; i++) {
        String weekName = weekNames[i];
        List<Element> childNodes = tListEles[i].querySelectorAll('li');
        List<TvInfo> tListChildren = List();
        for (var tNode in childNodes) {
          List<Element> info = tNode.querySelectorAll('a');
          String tvNum = info[0].text;
          String path = info[1].attributes['href'];
          String title = info[1].text;
//          print(info.toString() + "==tListEles ==" +path + "..."+tvNum);
          tListChildren.add(TvInfo(path: path, number: tvNum, title: title));
        }
        homeModel.tabListInfos.putIfAbsent(weekName, () => tListChildren);
      }
      List<Element> listEles = document.querySelectorAll('.listtit');
      List<Element> listItemEles = document.querySelectorAll('.list > ul');
      int childIndex = 0;
      for (int i = 0; i < listEles.length; i++) {
        Element element = listEles[i].querySelector('.listtitle');
        TvInfo keyInfo = TvInfo(
            path: element.attributes['href'],
            title: element.querySelector('span').text);
        List<TvInfo> values = List();
        homeModel.infos.add(keyInfo);
        homeModel.catorgreList.putIfAbsent(keyInfo.title, () => values);
        for (int j = childIndex;
            j < childIndex + 2 && j < listItemEles.length;
            j++) {
          homeModel.catorgreList[keyInfo.title] = getListItem(listItemEles[j]);
        }
        childIndex += 2;
      }
//      print("catorgreList ==" + homeModel.catorgreList.toString());
//      print("tabListInfos ==" +  homeModel.tabListInfos.toString());
      return homeModel;
    }
    return null;
  }

  ///**
  /// <div class = "list">
  ///   <div class == listtit>
  ///     <ul>
  ///       <li class = item>这一层解析
  ///
  static List<TvInfo> getListItem(Element itemParent) {
    List<TvInfo> tListChildren = List();
    List<Element> itemEls = itemParent.querySelectorAll('.item');
    for (var ite in itemEls) {
      Element itemEle = ite.querySelector('.itemtext');
      String path = itemEle.attributes['href'];
      String title = itemEle.text;
      String pic = ite.querySelector('.imgblock').attributes['style'];
      pic = pic.substring(pic.indexOf('http'), pic.lastIndexOf('\')'));
      print("pic ==" + pic);
      tListChildren.add(TvInfo(path: path, title: title, picUrl: pic));
    }
    return tListChildren;
  }

  static List<TvInfo> getPlayList(Document document) {
    List<TvInfo> infoList = List();
    List<Element> playListEle =
        document.querySelectorAll('#playlists > ul > li');
    for (var itemEl in playListEle) {
      Element itemL = itemEl.querySelector('a');
      String path = itemL.attributes['href'];
      String title = itemL.text;
      infoList.add(TvInfo(path: path, title: title));
    }
    return infoList;
  }

  static Future<TvDetailModel> getTvDetail(String url) async {
    TvDetailModel tvDetailModel = TvDetailModel();
    String body = await getBody(url);
    if (body == null) return null;
    Document document = parse(body);
    Element showElement = document.querySelector('.list > .show');
    String picUrl = showElement.querySelector('img').attributes['src'];
    String title = showElement.querySelector('h1').text;
    List<Element> pEls = showElement.querySelectorAll('p');
    String num = pEls[1].text;
    String createTime = pEls[2].text;
    String path = pEls[4].querySelector('a').attributes['href'];
    List<Element> typeInfos = pEls[3].querySelectorAll('a');
    List<TvInfo> tvTypes = List();
    for (var eltype in typeInfos) {
      String typePath = eltype.attributes['href'];
      String typeTitle = eltype.text;
      tvTypes.add(TvInfo(path: typePath, title: typeTitle));
    }
    tvDetailModel.currentInfo = TvInfo(
        path: path,
        createTime: createTime,
        number: num,
        title: title,
        picUrl: picUrl);
    tvDetailModel.tvTypes = tvTypes;
    tvDetailModel.currentInfo.tvDescription =
        document.querySelector('.info').text;
    tvDetailModel.playLists = getPlayList(document);
    tvDetailModel.recommendList = getListItem(document.querySelector('.list'));
    print('detailInfo....' + tvDetailModel.currentInfo.path);
    tvDetailModel.currentInfo.videoUrl = await getVideoUrl(baseUrl + path);
    return tvDetailModel;
  }

  static Future<String> getVideoUrl(String url) async {
    String body = await getBody(url);
    if (body == null) return null;
    Document document = parse(body);
    String videoUrl = document.querySelector('.player > div').attributes['data-vid'];
//    if (videoUrl == null || videoUrl.endsWith('mp4') || videoUrl.endsWith('m3u8'))
      return videoUrl.replaceAll('\$', '.');
//    else{
//      String videoBody = await getBody(videoUrl);
//      Document document = parse(videoBody);
//      String element = document.body.querySelectorAll('script')[2].text;
//      print('video_elem....' + element);
//      element = element.substring(element.indexOf('url:')+5, element.indexOf('m3u8') + 4);
//      return element;
//    }
  }
}
