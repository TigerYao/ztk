class HomeModel{
  List<TvInfo> headerInfos = List();//头部分类
  List<TvInfo> sliderInfos = List();//轮播图
  Map<String, List<TvInfo>> tabListInfos = Map();//最近更新，每天更新的 ，周一，周二
  Map<TvInfo, TvInfo> catorgreList = Map();//分类
}

class TvInfo{
  String path;
  String title;
  String picUrl;
  String number;

  TvInfo({this.path, this.title, this.picUrl, this.number});

  @override
  String toString() {
    // TODO: implement toString
    return "...dd.";
  }
}