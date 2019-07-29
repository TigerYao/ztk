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
import 'covert.dart';

class NetUtils {
  static const List weekNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  static const String baseUrl = "http://m.imomoe.io";//"http://m.yhdm.tv";

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
    print('getBody.url...' +url);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      String htmBody = gbk.decode(response.bodyBytes);
      print('getBody....' + htmBody);
      return htmBody;
    }
    return null;
  }

  static Future<HomeModel> requestData(String url) async {
    HomeModel homeModel = HomeModel();
    String htmBody = await getBody(url);
    if (htmBody != null) {
      Document document = parse(htmBody);
      print("body ==" + htmBody.toString());
      if (homeModel.headerInfos.isEmpty) {
        List<Element> sortsInfo = document.querySelectorAll('.am-offcanvas-bar > ul > li > a');//('.sort > a');
        print("...sortsInfo...." + sortsInfo.toString());
        for (var el in sortsInfo) {
          homeModel.headerInfos
              .add(TvInfo(path: el.attributes['href'], title: el.text));
        }
      }
      print("...headerInfos...." + homeModel.headerInfos.toString());
      if (homeModel.sliderInfos.isEmpty) {
        List<Element> sliderElem = document.querySelectorAll('.am-slides > li');//('.am-list > li');
        for (var sl in sliderElem) {
          Element sliderNode = sl.querySelector('a');
          Element picNode = sl.querySelector('img');
          homeModel.sliderInfos.add(TvInfo(
              path: sliderNode.attributes['href'],
              picUrl: picNode.attributes['src'],
              title: picNode.attributes['alt']));
        }
      }
      if (homeModel.tabListInfos.isEmpty) {
        homeModel.tabListInfos = getTabList(document);
      }
      List catories = getCateList(document);
      homeModel.infos = catories[0];
      homeModel.catorgreList = catories[1];
      print("...home...." + homeModel.toString());
      return homeModel;
    }
    return null;
  }

  static Map<String, List<TvInfo>> getTabList(Document document) {
    Map<String, List<TvInfo>> mTabLists = Map();
    List<Element> tListEles = document.querySelectorAll('.am-tabs-bd > div > div > ul');
//    print("==tListEles ==" +tListEles.toString());
    for (int i = 0; i < 7 && i < tListEles.length; i++) {
      String weekName = weekNames[i];
      List<Element> childNodes = tListEles[i].querySelectorAll('li');
      List<TvInfo> tListChildren = List();
      for (var tNode in childNodes) {
        Element info = tNode.querySelector('a');
        String tvNum = tNode.querySelector('span').text;
        String path = info.attributes['href'];
        String title = info.text;
          print(info.toString() + "==tListEles ==" +path + "..."+tvNum);
        tListChildren.add(TvInfo(path: path, number: tvNum, title: title));
      }
      mTabLists.putIfAbsent(weekName, () => tListChildren);
    }
    return mTabLists;
  }
  static List getCateList1(Document document) {
    Map<String, List<TvInfo>> catorgreList = Map();
    List<TvInfo> infos = List();
    List<Element> listEles = document.querySelectorAll(' div > .am-titlebar-title');
    List<Element> listElesNav = document.querySelectorAll(' div > .am-titlebar-nav > .am-icon-angle-right');
    int childIndex = 0;
    for (int i = 0; i < listEles.length; i++) {
      Element elementtitle = listEles[i];
      Element elementNav = listElesNav[i];
        String path = elementNav.attributes.containsKey('href')
            ? elementNav.attributes['href']
            : '';
        String title = elementtitle.text;
        TvInfo keyInfo =
        TvInfo(path: path, title: title);
        List<TvInfo> values = List();
        infos.add(keyInfo);
        catorgreList.putIfAbsent(keyInfo.title, () => values);
      List<Element> listItemEles = document.querySelectorAll('.list > ul');
        for (int j = childIndex;
        j < childIndex + 2 && j < listItemEles.length;
        j++) {
          catorgreList[keyInfo.title] = getListItem(listItemEles[j]);
        }
        childIndex += 2;
    }
    return [infos, catorgreList];
  }

  static List getCateList(Document document) {
    Map<String, List<TvInfo>> catorgreList = Map();
    List<TvInfo> infos = List();
    List<Element> listEles = document.querySelectorAll('.list > .listtit');
    List<Element> listItemEles = document.querySelectorAll('.list > ul');
    int childIndex = 0;
    for (int i = 0; i < listEles.length; i++) {
      Element element = listEles[i].querySelector('.listtitle');
      if (element == null) element = listEles[i];
      if (element != null) {
        String path = element.attributes.containsKey('href')
            ? element.attributes['href']
            : '';
        print(element.outerHtml + "...outhtml....");
        String title = element.querySelector('span') != null ? element.querySelector('span').text : element.text;
        TvInfo keyInfo =
            TvInfo(path: path, title: title);
        List<TvInfo> values = List();
        infos.add(keyInfo);
        catorgreList.putIfAbsent(keyInfo.title, () => values);
        for (int j = childIndex;
            j < childIndex + 2 && j < listItemEles.length;
            j++) {
          catorgreList[keyInfo.title] = getListItem(listItemEles[j]);
        }
        childIndex += 2;
      }
    }
    return [infos, catorgreList];
  }

  static Future<List> fetchDataByCategory(String url) async {
    print('*****datacategory:'+url);
    String body = await getBody(url);
    if (body == null) return null;
    Document document = parse(body);
    return getCateList(document);
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
    String videoUrl =
        document.querySelector('.player > div').attributes['data-vid'];
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
