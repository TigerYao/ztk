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
    var header = {
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3',
      'Accept-Encoding': 'gzip, deflate',
      'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
      'user-agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1',
    };
    var response = await http.get(url);
    if (response.statusCode == 200) {
      String htmBody =  Utf8Decoder().convert(response.bodyBytes);
      Document document = parse(htmBody);
      print("body ==" + htmBody.toString());
      List<Element> sortsInfo = document.querySelectorAll('.sort > a');
      for(var el in sortsInfo){
        homeModel.headerInfos.add(TvInfo(path: el.attributes['href'], title: el.text));
      }
      print("headerInfos ==" +  homeModel.headerInfos.toString());
      List<Element> sliderElem = document.querySelectorAll('#slider > li');
      print("sliderElem ==" + sliderElem.toString());
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
      print("tabListInfos ==" +  homeModel.tabListInfos.toString());
      return homeModel;
    }
    return null;
  }
}
