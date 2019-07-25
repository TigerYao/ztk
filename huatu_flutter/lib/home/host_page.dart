import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:huatu_flutter/model/home_model.dart';
import 'package:huatu_flutter/utils/net_utils.dart';
import 'detail_page.dart';

class HostPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HostPageState();
  }
}

class _HostPageState extends State<HostPage> {
//  RecommendInfo mRecommendInfo;
//  TopInfoModel mTopModel;
  HomeModel mHomeModel;
  String _currentValue = '周一';

  @override
  void initState() {
    super.initState();
    NetUtils.requestData().then((value) => setState(() {
          mHomeModel = value;
        }));
  }

  headerView() {
    List<TvInfo> sliders = mHomeModel.sliderInfos;
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width / 2 - 10,
      child: Swiper(
        itemCount: sliders.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: <Widget>[
                Image.network(
                  sliders[index].picUrl,
                  fit: BoxFit.fill,
                  width: MediaQuery.of(context).size.width,
                ),
                Container(
                  padding: EdgeInsets.only(left: 10),
                  height: 30,
                  alignment: Alignment.centerLeft,
                  width: MediaQuery.of(context).size.width,
                  color: Color(0xaF757575),
                  child: Text(
                    sliders[index].title,
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          );
        },
        scrollDirection: Axis.horizontal,
        autoplay: true,
        onTap: (index) {
          print('');
        },
        viewportFraction: 0.9,
        scale: 0.9,
      ),
    );
  }

  tvCataogryView() {
    if (mHomeModel == null) return Text('动漫画');
    List<TvInfo> infos = mHomeModel.headerInfos;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: infos.map((tvInfo) {
        return Container(
          padding: EdgeInsets.all(5),
          child: Text(
            tvInfo.title,
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
        );
      }).toList(),
    );
  }

//  weekView() {
//    return IndexedStack(
//      index: _currentIndex,
//      children: weekItemView(),
//    );
//  }

  weekItemHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: mHomeModel.tabListInfos.keys.map((f) {
        return GestureDetector(
          onTapDown: (tabDowDetail) {
            setState(() {
              _currentValue = f;
            });
          },
          child: Container(
            padding: EdgeInsets.only(top: 5, bottom: 5),
            child: Text(
              f,
              style: TextStyle(
                  color: _currentValue == f ? Colors.red : Colors.black),
            ),
          ),
        );
      }).toList(),
    );
  }

  weekItemView(List<TvInfo> tvInfoList) {
    return Container(
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: tvInfoList.map((f) {
            return Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width - 100,
                      padding: EdgeInsets.only(right: 50, left: 10),
                      child: Text(
                        f.title,
                        style: TextStyle(),
                        softWrap: true,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(f.number),
                    ),
                  ],
                ),
                Divider(
                  height: 2,
                )
              ],
            );
          }).toList(),
        ));
  }

  tvContentView() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.all(10),
      child: Column(
        children: mHomeModel.infos.map((tvInfo) {
          String title = tvInfo.title;
          List<TvInfo> tvList = mHomeModel.catorgreList[title];
          return Column(
            children: <Widget>[
              tvContentHeaderView(title),
              tvContentItemListView(tvList),
            ],
          );
        }).toList(),
      ),
    );
  }

  tvContentHeaderView(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(fontSize: 16, color: Colors.red),
        ),
        Text(
          '更多',
          style: TextStyle(fontSize: 16, color: Colors.black),
        )
      ],
    );
  }

  tvContentItemListView(List<TvInfo> tvInfoList) {
    return GridView.custom(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 2.0,
          crossAxisSpacing: 2.0,
          childAspectRatio: 9 / 16),
      childrenDelegate: SliverChildBuilderDelegate((context, index) {
        TvInfo f = tvInfoList[index];
        return InkWell(
//          padding: EdgeInsets.all(5),
          onTap: (){
            Navigator.push(
              context,
              new MaterialPageRoute(builder: (context) => new ChewieDemo(title: f.title ,url: f.path)),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Image.network(
                f.picUrl,
                fit: BoxFit.cover,
              ),
              Container(
                child: Text(
                  f.title,
                  softWrap: false,
                  style: TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        );
      }, childCount: tvInfoList.length),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
    );
//      GridView.builder(
//        itemCount: tvInfoList.length,
//        itemBuilder: (BuildContext context, int index) {
//          TvInfo f = tvInfoList[index];
//          return Container(
//          padding: EdgeInsets.all(10),
//          child: Column(
//            children: <Widget>[
//              Image.network(
//                f.picUrl,
//                fit: BoxFit.cover,
//              ),
//              Text(f.title, softWrap: true)
//            ],
//          ),
//        );
//        },
//        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
//          //单个子Widget的水平最大宽度
//            maxCrossAxisExtent: MediaQuery.of(context).size.width/3,
//            //水平单个子Widget之间间距
//            mainAxisSpacing: 20.0,
//            //垂直单个子Widget之间间距
//            crossAxisSpacing: 10.0,
//        ),
//        shrinkWrap: true,
//        physics: NeverScrollableScrollPhysics(),
//      );

//      GridView.count(
//      shrinkWrap: true,
//      //水平子Widget之间间距
//      crossAxisSpacing: 10.0,
//      //垂直子Widget之间间距
//      mainAxisSpacing: 30.0,
//      //GridView内边距
//      padding: EdgeInsets.all(10.0),
//      //一行的Widget数量
//      crossAxisCount: 2,
//      //子Widget宽高比例
//      childAspectRatio: 2.0,
//      //子Widget列表
//      children: tvInfoList.map((f) {
//        return Container(
//          padding: EdgeInsets.all(10),
//          width: MediaQuery.of(context).size.width / 2 - 20,
//          child: Column(
//            children: <Widget>[
//              Image.network(
//                f.picUrl,
//                fit: BoxFit.cover,
//                height: 80,
//              ),
//              Text(f.title, softWrap: true)
//            ],
//          ),
//        );
//      }).toList(),
//      physics: NeverScrollableScrollPhysics(),
//    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: tvCataogryView(),
      ),
      body: mHomeModel == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              shrinkWrap: true,
              children: <Widget>[
                headerView(),
//            weekItemHeader(),
//            weekItemView(mHomeModel.tabListInfos[_currentValue]),
                tvContentView()
              ],
            ),
    );
  }
}
