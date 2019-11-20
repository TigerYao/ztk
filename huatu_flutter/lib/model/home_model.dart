class HomeModel{
  List<TvInfo> headerInfos = List();//头部分类
  List<TvInfo> sliderInfos = List();//轮播图
  Map<String, List<TvInfo>> tabListInfos = Map();//最近更新，每天更新的 ，周一，周二
  List<TvInfo> infos = List();
  Map<String, List<TvInfo>> catorgreList = Map();//分类
@override
  String toString() {
    // TODO: implement toString
    return '[headerInfos]:'+headerInfos.toString()+"*****[sliderInfos]:"+sliderInfos.toString()+"*****[tabListInfos]:"+tabListInfos.toString()+"*****[infos]:"+infos.toString()+"******[categoryInfos]:"+catorgreList.toString();
  }
}

class TvDetailModel{
  TvInfo currentInfo;
  List<TvInfo> playLists;
  List<TvInfo> recommendList;
  List<TvInfo> tvTypes;
}

class TvInfo{
  String path;
  String title;
  String picUrl;
  String number;
  String videoUrl;
  String tvDescription;
  String createTime;
  List<String> tags;

  TvInfo({this.path, this.title, this.picUrl, this.number, this.videoUrl, this.tvDescription, this.createTime});

  @override
  String toString() {
    // TODO: implement toString
    return "...[TvInfo]."+title;
  }

}