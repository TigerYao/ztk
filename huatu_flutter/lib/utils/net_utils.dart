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
import 'urlencode.dart';

class NetUtils {
  static const List weekNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  static const List navNames = ['最近连载', '2019新剧推荐', '即将开播'];
  static const String baseUrl = "http://m.imomoe.io"; //"http://m.yhdm.tv";
  static const String meiju_base = "http://m.meijutt.com";

//  static Future<RecommendInfo> getRecommendList() async {
//    Dio _dio = DioFactory.getInstance().getDio();
//    try {
//      Response infos = await _dio.get(Api.RECOMMEND_URL);
//      RecommendInfo baseMode = RecommendInfo.fromJson(infos.data);
//      return baseMode;
//    } on DioError catch (e) {
//      if (e.response != null) {
//        print(e.response.data);
//        print(e.response.headers);
//        print(e.response.request);
//      } else {
//        // Something happened in setting up or sending the request that triggered an Error
//        print(e.request);
//        print(e.message);
//      }
//    }
//    return null;
//  }

//  static Future<TopInfoModel> getTopList() async {
//    Dio _dio = DioFactory.getInstance().getDio();
//    try {
//      Response infos = await _dio.get(Api.TOP_LIST_URL);
//      print(".....info....." + infos.data.toString());
//      TopInfoModel baseMode = TopInfoModel.fromJson(infos.data);
//      return baseMode;
//    } on DioError catch (e) {
//      if (e.response != null) {
//        print(e.response.data);
//        print(e.response.headers);
//        print(e.response.request);
//      } else {
//        // Something happened in setting up or sending the request that triggered an Error
//        print(e.request);
//        print(e.message);
//      }
//    }
//    return null;
//  }

  static Future<String> getBody(String url) async {
    print('getBody.url...' + url);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      String htmBody = gbk.decode(response.bodyBytes);
//      print('getBody....' + htmBody);
      return htmBody;
    }
    return null;
  }

  static Future<String> postBody(String url, String keywork) async {
    print('postBody.url...' + url + '.....' + keywork);
    url = url + "?searchword=" + keywork;
    var client = new http.Client();
    var request = new http.Request('POST', Uri.parse(url));
    var body = {'searchword': keywork};
    request.bodyFields = body;
    var response = await client.send(request);
    if (response.statusCode == 200) {
      String htmBody = gbk.decode(await response.stream
          .toBytes()); //gbk.decode(response.stream.toString());
      print('postBody....' + htmBody);
      return htmBody;
    }
    return null;
  }

  static Future<HomeModel> requestDataMJ(String url) async {
    HomeModel homeModel = HomeModel();
    String htmBody = await getBody(url);
    if (htmBody == null) return null;
    Document document = parse(htmBody);
    homeModel.headerInfos = List();
    List<Element> headerEle = document.querySelectorAll(
        '#guide > div > div > a');
    List<Element> headerNavls = document.querySelectorAll('.guide > div > nav > a');
    List<Element> navEles = document.getElementsByClassName('list_4');
    List<Element> contentNav = document.getElementsByClassName('box_3');
    print("contentNav.... " + contentNav.toString());
    for (Element el in headerNavls) {
      String title = el
          .querySelector('p')
          .text;
      String path = el.attributes['href'];
      homeModel.headerInfos.add(TvInfo(title: title, path: path));

    }

    for (Element el in headerEle) {
      String title = el.text;
      String path = el.attributes['href'];
      homeModel.headerInfos.add(TvInfo(title: title, path: path));
    }
    for (int i = 0;i< navEles.length ;i++) {
      Element el = navEles[i];
      List<Element> navEleLis = el.querySelectorAll('li');
      List<TvInfo> infos = List();
      for (Element navLi in navEleLis) {
        String path = navLi
            .querySelector('a')
            .attributes['href'];
        String title = navLi
            .querySelector('h5')
            .text;
        String picPath = '';
        if (navLi.querySelector('img') != null) picPath = navLi
            .querySelector('img')
            .attributes['src'];
        List<Element> pTags = navLi.querySelectorAll(" p > font");
        String num = '';
        if(pTags != null && pTags.isNotEmpty) num = pTags[pTags.length - 1].text;
        infos.add(
            TvInfo(path: path, title: title, picUrl: picPath, number: num));
      }
      String title = navNames[i];
      homeModel.tabListInfos.putIfAbsent(title, () {
        return infos;
      });
    }
    
    for(Element el in contentNav){
      Element titlInfo = el.querySelector("div");
      String cateTitle = titlInfo.querySelector('h4').text;
      String path = titlInfo.querySelector("a").attributes['href'];
      homeModel.infos.add(TvInfo(path: path, title: cateTitle));
      List<Element> contentEle = el.querySelectorAll('li');
      homeModel.catorgreList.putIfAbsent(cateTitle, (){
        return List();
      });
      for(Element element in contentEle){
        Element aTag = element.querySelector('a');
        String title = aTag.attributes['title'];
        String path = aTag.attributes['href'];
        String picPath = aTag.querySelector('span > img').attributes['src'];
        String num = aTag.querySelector('i').text;
        homeModel.catorgreList[cateTitle].add(TvInfo(path: path, title: title, picUrl: picPath, number: num));
      }
    }
    return homeModel;
  }

  static Future<HomeModel> requestData(String url) async {
    HomeModel homeModel = HomeModel();
    String htmBody = await getBody(url);
    if (htmBody != null) {
      Document document = parse(htmBody);
//      print("body ==" + htmBody.toString());
      if (homeModel.headerInfos.isEmpty) {
        List<Element> sortsInfo = document.querySelectorAll(
            '.am-offcanvas-bar > ul > li > a'); //('.sort > a');
//        print("...sortsInfo...." + sortsInfo.toString());
        for (var el in sortsInfo) {
          homeModel.headerInfos
              .add(TvInfo(path: el.attributes['href'], title: el.text));
        }
      }
//      print("...headerInfos...." + homeModel.headerInfos.toString());
      if (homeModel.sliderInfos.isEmpty) {
        List<Element> sliderElem =
        document.querySelectorAll('.am-slides > li'); //('.am-list > li');
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
      List catories = getCateList1(document);
      homeModel.infos = catories[0];
      homeModel.catorgreList = catories[1];
//      print("...home...." + homeModel.toString());
      return homeModel;
    }
    return null;
  }

  static Map<String, List<TvInfo>> getTabList(Document document) {
    Map<String, List<TvInfo>> mTabLists = Map();
    List<Element> tListEles =
    document.querySelectorAll('.am-tabs-bd > div > div > ul');
//    print("==tListEles ==" +tListEles.toString());
    for (int i = 0; i < 7 && i < tListEles.length; i++) {
      String weekName = weekNames[i];
      List<Element> childNodes = tListEles[i].querySelectorAll('li');
      List<TvInfo> tListChildren = List();
      for (var tNode in childNodes) {
        Element info = tNode.querySelector('a');
        String tvNum = tNode
            .querySelector('span')
            .text;
        String path = info.attributes['href'];
        String title = info.text;
        tListChildren.add(TvInfo(path: path, number: tvNum, title: title));
      }
      mTabLists.putIfAbsent(weekName, () => tListChildren);
    }
//    print("==tListEles。。 ==" + mTabLists.toString());
    return mTabLists;
  }

  static List getCateList1(Document document) {
    Map<String, List<TvInfo>> catorgreList = Map();
    List<TvInfo> infos = List();

    List<Element> listEles =
    document.getElementsByClassName("am-titlebar-title ");
    List<Element> listElesNav = document
        .querySelectorAll(' div > .am-titlebar-nav > .am-icon-angle-right');
    List<Element> listCategoriesElem = document.querySelectorAll('.am-gallery');
//    print(listEles.toString() + "......nav....");
    if (listEles == null || listEles.isEmpty) {
      List<TvInfo> values = List();
      infos.add(TvInfo(title: '最新'));
      catorgreList.putIfAbsent('最新', () => values);
      catorgreList['最新'] = getListItem1(document);
    } else {
      for (int i = 0; i < listEles.length; i++) {
        Element elementtitle = listEles[i];
        Element elementNav = listElesNav[i];
        String path = elementNav.attributes.containsKey('href')
            ? elementNav.attributes['href']
            : '';
        String title = elementtitle.text;
        TvInfo keyInfo = TvInfo(path: path, title: title);
        List<TvInfo> values = List();
        infos.add(keyInfo);
        catorgreList.putIfAbsent(keyInfo.title, () => values);
        List<Element> cateEls = listCategoriesElem[i].querySelectorAll("li");
        for (Element category in cateEls) {
          String title = category
              .querySelector('.am-gallery-title')
              .text;
          String tvNum = category
              .querySelector('.am-gallery-desc')
              .text;
          String path =
          category
              .querySelector('.am-gallery-item > a')
              .attributes['href'];
          String imgPathStr = category
              .querySelector('.lazy')
              .outerHtml;
          String imgPath = imgPathStr.substring(
              imgPathStr.indexOf("http"), imgPathStr.indexOf('.jpg')) +
              '.jpg';
//          print("imgPaht...." + imgPath);
          catorgreList[keyInfo.title].add(
              TvInfo(title: title, number: tvNum, path: path, picUrl: imgPath));
        }
      }
    }
    return [infos, catorgreList];
  }


  static Future<List> fetchDataByCategory(String url) async {
    String body = await getBody(url);
    if (body == null) return null;
    Document document = parse(body);
    return getCateList1(document);
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
  
  static Future<TvDetailModel> getIntroMj(String url) async{
    String body = await getBody(url);
    if (body == null) return null;
    TvDetailModel detailModel = TvDetailModel();
    Document document = parse(body);
    Element headerTitle = document.getElementById('piccon');
    String title = headerTitle.querySelector('h1').text;
    String picPath = headerTitle.querySelector('#pic > img').attributes['src'];
    List<Element> tagEls = headerTitle.getElementsByClassName('sDes');
    for(Element tagelt in tagEls){

    }
  }

  static Future<TvDetailModel> getIntro(String url) async {
    String body = await getBody(url);
    if (body == null) return null;
    TvDetailModel detailModel = TvDetailModel();
    Document document = parse(body);
    String title = document
        .querySelector('.am-header-title')
        .text;
    Element element = document.querySelector('.am-intro-left > img');
    String picPath = element.attributes['src'];
    List<Element> infoElement = document.querySelectorAll('#p-info > p');
    List<String> tags = List();
    for (Element ele in infoElement) {
      if (ele.querySelector('a') != null) {
        List<Element> aTags = ele.querySelectorAll('a');
        StringBuffer sb = StringBuffer();
        for (Element atag in aTags) {
          sb.write(atag.text + "      ");
        }
        tags.add(sb.toString());
      } else
        tags.add(ele.text);
    }
//    print('tags == ' + tags.toString());
    Element elementA = document.querySelector('#p-info > a');
    String currentPath = elementA.attributes['href'];
    String description = document
        .querySelector('.txtDesc')
        .text;
    detailModel.currentInfo = TvInfo(
        path: currentPath,
        tvDescription: description,
        title: title,
        picUrl: picPath);
    detailModel.currentInfo.tags = tags;
    detailModel.playLists = List();
    List<Element> videoEles = document.querySelectorAll('.mvlist > li');
    for (Element videoEl in videoEles) {
      Element videoAEl = videoEl.querySelector('a');
      String videoPath = videoAEl.attributes['href'];
      String titleNum = videoAEl.attributes['title'];
//      print('____list。。。。' + videoPath + "...." + titleNum);
      detailModel.playLists
          .add(TvInfo(path: videoPath, title: title, number: titleNum));
    }

    return detailModel;
  }

  static Future<List<TvInfo>> getSearchResult(String url,
      String keywrods) async {
    String postB = UrlEncode().encode(keywrods);
    String body = await postBody(url, postB);
    if (body == null) return null;
    Document document = parse(body);
    return getListItem1(document);
  }

  static List<TvInfo> getListItem1(Document document) {
    List<TvInfo> infos = List();
    List<Element> listCategoriesElem = document.querySelectorAll(
        'li > .am-gallery-item');
    for (Element category in listCategoriesElem) {
      String title = category
          .querySelector('.am-gallery-title')
          .text;
      String tvNum = category
          .querySelector('.am-gallery-desc')
          .text;
      String path = category
          .querySelector('a')
          .attributes['href'];
      String imgPathStr = category
          .querySelector('.lazy')
          .outerHtml;
      String imgPath = imgPathStr.substring(
          imgPathStr.indexOf("http"), imgPathStr.indexOf('.jpg')) +
          '.jpg';
//        print("imgPaht...." + imgPath);
      infos.add(
          TvInfo(title: title, number: tvNum, path: path, picUrl: imgPath));
    }
    return infos;
  }

  static Future<String> getVideoUrl(String url)async{
    Dio _dio = DioFactory.getInstance().getDio();
    Response infos = await _dio.get(url);
    print("videoURl == " +infos.data.toString());
    Map<String, dynamic> datas = infos.data;
    List<dynamic> videData = datas['stream'];
    String videoM3 = videData[0]['m3u8_url'];
    return videoM3;
  }
}
