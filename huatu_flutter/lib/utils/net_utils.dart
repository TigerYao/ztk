
import 'package:huatu_flutter/api/dio_factory.dart';
import 'package:huatu_flutter/model/home_model.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'covert.dart';
import 'urlencode.dart';

class NetUtils {
  static const List weekNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  static const List navNames = ['最近连载', '2019新剧推荐', '即将开播'];
  static const String baseUrl = "http://m.imomoe.jp"; //"http://m.yhdm.tv";
  static const String meiju_91base = "https://91mjw.com/";
  static const String meiju_base = meiju_91base;//"http://m.meijutt.com";
  static Future<String> getBody(String url) async {
    var response = await http.get(url);
    if (response.statusCode == 200) {
      List<Element> headerss = parse(response.body).head.querySelectorAll("meta");
      bool isUtf8 = false;
      for(Element headerEle in headerss){
        if(!headerEle.attributes.toString().contains("charset"))
          continue;
//        print(isUtf8.toString() + '....getBody.headers...' + headerEle.attributes['charset'].toString());
        isUtf8 = !(headerEle.attributes['charset'] == ('gb2312'));
      }
      if (isUtf8)
        response.headers.putIfAbsent('charset', () => 'utf-8');
      String htmBody = isUtf8 ?  response.body : gbk.decode(response.bodyBytes);
      print(isUtf8.toString() + '....getBody.htmBody...' + htmBody);
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
  static Future<HomeModel> requestData91MJ(String url) async {
    HomeModel homeModel = HomeModel();
    String htmBody = await getBody(url);
    if (htmBody == null) return null;
    Document document = parse(htmBody);
    List<Element> navEles = document.querySelectorAll(".nav > li");
    for(Element element in navEles){
      if (element.className == "navmore")
        continue;
      Element aTag = element.querySelector("a");
      String title = aTag.text;
      String path = aTag.attributes['href'];
      Element subEls = element.querySelector(".sub-menu");
      if (subEls != null) {
        List<Element> subMenuEls = subEls.querySelectorAll("li");
        for(Element subEle in subMenuEls){
          Element aTags = subEle.querySelector("a");
          String title = aTags.text;
          String path = aTags.attributes['href'];
          homeModel.headerInfos.add(TvInfo(path: path, title: title));
        }
      }else
        homeModel.headerInfos.add(TvInfo(path: path, title: title));
    }
    List<Element> slideEls = document.getElementById('slider').querySelectorAll(".item");
    for(Element slideEle in slideEls){
      Element hrefTag = slideEle.querySelector('a');
      String path = hrefTag.attributes['href'];
      if (!path.contains(meiju_91base))
        continue;
      String imgPath = hrefTag.querySelector('img').attributes['src'];
      String title = hrefTag.querySelector('span').text;
      homeModel.sliderInfos.add(TvInfo(path: path,picUrl: imgPath, title: title));
    }
    List<Element> moviesEls = document.getElementsByClassName('m-movies');
    for(Element movieEl in moviesEls){
      String topTitle = movieEl.querySelector('.title > strong > a').text;
      String topPath = movieEl.querySelector('.title > strong > a').attributes['href'];
      homeModel.catorgreList.putIfAbsent(topTitle, ()=>List<TvInfo>());
      homeModel.infos.add(TvInfo(path: topPath, title: topTitle));
      List<Element> movieList = movieEl.getElementsByClassName("u-movie");
      for(Element movie in movieList){
        Element aTagEle = movie.querySelector('a');
        String title = aTagEle.querySelector('h2').text;
        String path = aTagEle.attributes['href'];
        String imgPath = aTagEle.querySelector('div > img').attributes['data-original'];
        String numb= movie.querySelector(".zhuangtai > span").text;
        homeModel.catorgreList[topTitle].add(TvInfo(path: path, picUrl: imgPath, title: title, number: numb));
      }
    }
    return homeModel;
  }
  static Future<HomeModel> requestDataMJ(String url) async {
    HomeModel homeModel = HomeModel();
    String htmBody = await getBody(url);
    if (htmBody == null) return null;
    Document document = parse(htmBody);
    homeModel.headerInfos = List();
    List<Element> headerEle =
        document.querySelectorAll('#guide > div > div > a');
    List<Element> headerNavls =
        document.querySelectorAll('.guide > div > nav > a');
    List<Element> navEles = document.getElementsByClassName('list_4');
    List<Element> contentNav = document.getElementsByClassName('box_3');
    print("contentNav.... " + contentNav.toString());
    for (Element el in headerNavls) {
      String title = el.querySelector('p').text;
      String path = el.attributes['href'];
      homeModel.headerInfos.add(TvInfo(title: title, path: path));
    }

    for (Element el in headerEle) {
      String title = el.text;
      String path = el.attributes['href'];
      homeModel.headerInfos.add(TvInfo(title: title, path: path));
    }
    for (int i = 0; i < navEles.length; i++) {
      Element el = navEles[i];
      List<Element> navEleLis = el.querySelectorAll('li');
      List<TvInfo> infos = List();
      for (Element navLi in navEleLis) {
        String path = navLi.querySelector('a').attributes['href'];
        String title = navLi.querySelector('h5').text;
        String picPath = '';
        if (navLi.querySelector('img') != null)
          picPath = navLi.querySelector('img').attributes['src'];
        List<Element> pTags = navLi.querySelectorAll(" p > font");
        String num = '';
        if (pTags != null && pTags.isNotEmpty)
          num = pTags[pTags.length - 1].text;
        infos.add(
            TvInfo(path: path, title: title, picUrl: picPath, number: num));
      }
      String title = navNames[i];
      homeModel.tabListInfos.putIfAbsent(title, () {
        return infos;
      });
    }

    for (Element el in contentNav) {
      Element titlInfo = el.querySelector("div");
      String cateTitle = titlInfo.querySelector('h4').text;
      String path = titlInfo.querySelector("a").attributes['href'];
      homeModel.infos.add(TvInfo(path: path, title: cateTitle));
      List<Element> contentEle = el.querySelectorAll('li');
      homeModel.catorgreList.putIfAbsent(cateTitle, () {
        return List();
      });
      for (Element element in contentEle) {
        Element aTag = element.querySelector('a');
        String title = aTag.attributes['title'];
        String path = aTag.attributes['href'];
        String picPath = aTag.querySelector('span > img').attributes['src'];
        String num = aTag.querySelector('i').text;
        homeModel.catorgreList[cateTitle].add(
            TvInfo(path: path, title: title, picUrl: picPath, number: num));
      }
    }
//    getIntroMj('https://m.meijutt.com/content/meiju24211.html');
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
          if (el.text.contains("美国")) continue;
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
        String tvNum = tNode.querySelector('span').text;
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
          String title = category.querySelector('.am-gallery-title').text;
          String tvNum = category.querySelector('.am-gallery-desc').text;
          String path =
              category.querySelector('.am-gallery-item > a').attributes['href'];
          String imgPathStr = category.querySelector('.lazy').outerHtml;
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
  static Future<TvDetailModel> getIntro91Mj(String url) async {
    String body = await getBody(url);
    if (body == null) return null;
    TvDetailModel detailModel = TvDetailModel();
    Document document = parse(body);
    String picUrl = document.querySelector('.video_img > img').attributes['src'];
    String info = document.querySelector('.video_info').outerHtml;
    info = info.replaceAll('<strong>', '');
    info = info.replaceAll('</strong>', '');

    String jianjie = document.querySelector('.jianjie > span').text.replaceAll('<br>', '\n');
    String title = document.querySelector('.article-title > a').text;
    detailModel.currentInfo = TvInfo(picUrl: picUrl, title: title, tvDescription: jianjie);
    List<String> tagsSp = info.split('<br />');
    if (tagsSp.length > 4)
    tagsSp = tagsSp.getRange(3, tagsSp.length);
    detailModel.currentInfo.tags =  tagsSp.map((f) => f.replaceAll('<br>', "")).toList();
//   if(detailModel.currentInfo.tags.length > 4)
//    detailModel.currentInfo.tags =  detailModel.currentInfo.tags.sublist(3, detailModel.currentInfo.tags.length -1);
    detailModel.playLists = List();
    List<Element> numList = document.getElementById('video_list_li').querySelectorAll('a');
    for(Element numEl in numList){
      String num = numEl.text;
      String path = url + '/vplay/'+numEl.attributes['id']+'.html';
      detailModel.playLists.add(TvInfo(number: num,path: path));
    }
    return detailModel;
  }
  static Future<TvDetailModel> getIntroMj(String url) async {
    String body = await getBody(url);
    if (body == null) return null;
    TvDetailModel detailModel = TvDetailModel();
    Document document = parse(body);
    Element headerTitle = document.getElementById('piccon');
//    print("...headerTitle.."+ headerTitle.outerHtml );
    String title = headerTitle.querySelector('h1').text;
    String picPath = headerTitle
        .getElementsByClassName('pic')[0]
        .querySelector("img")
        .attributes['src'];
    List<Element> tagEls = headerTitle.getElementsByClassName('emTit');
    List<String> tags = List();
    for (Element tagelt in tagEls) {
      String tagName = tagelt.text;
      if (tagName == null || tagName.isEmpty) continue;
      tags.add(tagName);
    }
    detailModel.currentInfo = TvInfo(picUrl: picPath, title: title);
    detailModel.currentInfo.tags = tags;
    Element playListElem = document.getElementsByClassName('test')[1];

    if (playListElem != null) {
      detailModel.playLists = List();
      List<Element> playEls = playListElem.getElementsByTagName('a');
      for (Element el in playEls) {
        String title = el.attributes['title'];
        String path = el.attributes['href'];
//                      print(title + ".....playList...." + path);
        detailModel.playLists.add(TvInfo(path: path, number: title));
      }
    }

    return detailModel;
  }

  static Future<TvDetailModel> getIntro(String url) async {
    if (url.startsWith(meiju_91base)) return await getIntro91Mj(url);
    if (url.startsWith(meiju_base)) return await getIntroMj(url);
    String body = await getBody(url);
    if (body == null) return null;
    TvDetailModel detailModel = TvDetailModel();
    Document document = parse(body);
    String title = document.querySelector('.am-header-title').text;
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
    String description = document.querySelector('.txtDesc').text;
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

  static Future<List<TvInfo>> getSearchResult(
      String url, String keywrods) async {
    String postB = UrlEncode().encode(keywrods);
    String body = await postBody(url, postB);
    if (body == null) return null;
    Document document = parse(body);
    return getListItem1(document);
  }

  static List<TvInfo> getListItem1(Document document) {
    List<TvInfo> infos = List();
    List<Element> listCategoriesElem =
        document.querySelectorAll('li > .am-gallery-item');
    for (Element category in listCategoriesElem) {
      String title = category.querySelector('.am-gallery-title').text;
      String tvNum = category.querySelector('.am-gallery-desc').text;
      String path = category.querySelector('a').attributes['href'];
      String imgPathStr = category.querySelector('.lazy').outerHtml;
      String imgPath = imgPathStr.substring(
              imgPathStr.indexOf("http"), imgPathStr.indexOf('.jpg')) +
          '.jpg';
//        print("imgPaht...." + imgPath);
      infos.add(
          TvInfo(title: title, number: tvNum, path: path, picUrl: imgPath));
    }
    return infos;
  }

  static Future<String> getVideoUrl(String url) async {
    Dio _dio = DioFactory.getInstance().getDio();
    Response infos = await _dio.get(url);
    print("videoURl == " + infos.data.toString());
    Map<String, dynamic> datas = infos.data;
    List<dynamic> videData = datas['stream'];
    String videoM3 = videData[0]['m3u8_url'];
    return videoM3;
  }
}
