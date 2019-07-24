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
  static const List weekNames= [
    '周一', '周二','周三','周四','周五','周六','周日'
];
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

  static Future<HomeModel> requestData() async {
    HomeModel homeModel = HomeModel();
    var url = "http://m.yhdm.tv/";
    var response = await http.get(url);
    if (response.statusCode == 200) {
      String htmBody =  Utf8Decoder().convert(response.bodyBytes);
      Document document = parse(htmBody);
//      print("body ==" + htmBody.toString());
      List<Element> sortsInfo = document.querySelectorAll('.sort > a');
      for(var el in sortsInfo){
        homeModel.headerInfos.add(TvInfo(path: el.attributes['href'], title: el.text));
      }
//      print("headerInfos ==" +  homeModel.headerInfos.toString());
      List<Element> sliderElem = document.querySelectorAll('#slider > li');
//      print("sliderElem ==" + sliderElem.toString());
      for(var sl in sliderElem){
        Element sliderNode = sl.querySelector('a');
        Element picNode = sl.querySelector('img');
        homeModel.sliderInfos.add(TvInfo(path: sliderNode.attributes['href'], picUrl: picNode.attributes['src'], title: picNode.attributes['alt']));
      }
      List<Element> tListEles = document.querySelectorAll('.tlist > ul');
      for(int i = 0;i < 7;i++){
        String weekName = weekNames[i];
        List<Element> childNodes = tListEles[i].querySelectorAll('li');
        List<TvInfo> tListChildren = List();
        for(var tNode in childNodes){
          String tvNum = tNode.querySelector('span > a').text;
          Element info = tNode.querySelector('a');
          String path = info.attributes['href'];
          String title = info.attributes['title'];
          tListChildren.add(TvInfo(path: path, number: tvNum, title: title));
        }
        homeModel.tabListInfos.putIfAbsent(weekName, () => tListChildren);
      }
      List<Element> listEles = document.querySelectorAll('.listtit');
      List<Element> listItemEles = document.querySelectorAll('.item');
      int childIndex = 0;
      for(int i = 0;i< listEles.length;i++){
        Element element = listEles[i].querySelector('.listtitle');
        TvInfo keyInfo = TvInfo(path: element.attributes['href'], title: element.querySelector('span').text);
        List<TvInfo> values = List();
        homeModel.catorgreList.putIfAbsent(keyInfo.title, () => values);
        for(int j = childIndex; j < childIndex + 2 && j < listItemEles.length;j++){
//          if (childIndex >= listItemEles.length) continue;
          Element itemEle = listItemEles[j].querySelector('.itemtext');
          String path = itemEle.attributes['href'];
          String title = itemEle.text;
          String pic = listItemEles[childIndex].querySelector('.imgblock').attributes['style'];
          pic = pic.substring(pic.indexOf('http'), pic.lastIndexOf(')'));
          TvInfo tvValue = TvInfo(path: path,title: title, picUrl: pic);
          homeModel.catorgreList[keyInfo.title].add(tvValue);
        }
        childIndex += 2;
      }
//      print("catorgreList ==" + homeModel.catorgreList.toString());
//      print("tabListInfos ==" +  homeModel.tabListInfos.toString());
      return homeModel;
    }
    return null;
  }
}
