import 'base_mode.dart';

class RecommendInfo extends BaseModel {
  List<String> slider;
  List<RadioInfo> radioList;

  RecommendInfo({announce, errno, msg, this.slider, this.radioList});

  @override
  factory RecommendInfo.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey("data")) return null;
    Map<String, dynamic> data = json['data'];
    List<String> sliders = List();
    for (String item in data['slider']) {
      sliders.add(item);
    }
    List<RadioInfo> radionInfos = List();
    for (var radio in data['radioList']) {
      radionInfos.add(RadioInfo.fromJson(radio));
    }
    return RecommendInfo(
        announce: json['announce'],
        errno: json['errno'],
        msg: json['msg'],
        slider: sliders,
        radioList: radionInfos);
  }
}

class RadioInfo {
  String picUrl;
  String title;
  int id;

  RadioInfo({this.picUrl, this.title, this.id});

  factory RadioInfo.fromJson(Map<String, dynamic> json) {
    return RadioInfo(
        picUrl: json['picUrl'], title: json['title'], id: json['id']);
  }
}
