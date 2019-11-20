import 'base_mode.dart';

class TopInfoModel extends BaseModel {
  List<TopInfo> data;

  TopInfoModel({announce, errno, msg, this.data});

  factory TopInfoModel.fromJson(Map<String, dynamic> json) {
    print('。。。info...' + json['data'].toString());
    List<dynamic> infos = json['data'];
    List<TopInfo> topinfos = List();
    for (var info in infos) {
      topinfos..add(TopInfo.fromJson(info));
    }
    return TopInfoModel(
        announce: json['announce'],
        errno: json['errno'],
        msg: json['msg'],
        data: topinfos);
  }
}

class TopInfo {
  int id;
  String title;
  int listenCount;
  String picUrl;
  List<SongInfo> songList;
  bool isOpen = false;

  TopInfo({this.id, this.title, this.listenCount, this.picUrl, this.songList});

  factory TopInfo.fromJson(Map<String, dynamic> json) {
    List<dynamic> songs = json['songList'];
    List<SongInfo> infos = List();
    for (var song in songs) {
      infos..add(SongInfo.fromJson(song));
    }
    return TopInfo(
        id: json['id'],
        title: json['title'],
        listenCount: json['listenCount'],
        picUrl: json['picUrl'],
        songList: infos);
  }

  @override
  String toString() {
    // TODO: implement toString
    return "....." + picUrl;
  }
}

class SongInfo {
  String singerName;
  String singName;
  int number;

  SongInfo({this.singerName, this.singName, this.number});

  factory SongInfo.fromJson(Map<String, dynamic> json) {
    print('。。。song...' + json.toString());
    return SongInfo(
        singerName: json['singerName'],
        singName: json['songName'],
        number: json['number']);
  }

  @override
  String toString() {
    // TODO: implement toString
    return "....." + singName;
  }
}
