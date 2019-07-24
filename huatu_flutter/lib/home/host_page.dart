import 'package:flutter/material.dart';

import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:huatu_flutter/model/recommend_info.dart';
import 'package:huatu_flutter/utils/net_utils.dart';
import 'package:huatu_flutter/model/top_info.dart';
import 'package:huatu_flutter/model/home_model.dart';

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

  @override
  void initState() {
    super.initState();
//    if (mRecommendInfo == null)
//      NetUtils.getRecommendList().then((value) {
//        if (value != null)
//          setState(() {
//            mRecommendInfo = value;
//          });
//      });
//    if (mTopModel == null)
//      NetUtils.getTopList().then((value) {
//        if (value != null)
//          setState(() {
//            mTopModel = value;
//          });
//      });
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
    List<TvInfo> infos = mHomeModel.headerInfos;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: infos.map((tvInfo) {
        return Text(tvInfo.title);
      }).toList(),
    );
  }

//  radioView() {
//    List<RadioInfo> radioInfos = mRecommendInfo.radioList;
//    List<Widget> radioViews = List();
//    for (RadioInfo info in radioInfos) {
//      radioViews
//        ..add(Container(
//            margin: EdgeInsets.only(bottom: 20),
//            padding: EdgeInsets.only(top: 10, bottom: 10, left: 5),
//            width: MediaQuery.of(context).size.width / radioInfos.length - 10,
//            child: Row(
//              children: <Widget>[
//                ClipRRect(
//                  borderRadius: BorderRadius.circular(20),
//                  child: Image.network(
//                    info.picUrl,
//                    fit: BoxFit.fill,
//                    width: 40,
//                  ),
//                ),
//                Padding(
//                  padding: EdgeInsets.only(left: 5),
//                  child: Text(
//                    info.title,
//                    style: TextStyle(color: Colors.white),
//                  ),
//                )
//              ],
//            ),
//            decoration: BoxDecoration(
//              borderRadius: BorderRadius.circular(10),
//              gradient: const LinearGradient(
//                  colors: [Color(0xFFC5E1A5), Color(0xFFAED581)]),
//            )));
//    }
//    return Row(
//      mainAxisAlignment: MainAxisAlignment.spaceAround,
//      children: radioViews,
//    );
//  }

//  contentView() {
//    if (mTopModel == null || mTopModel.data == null || mTopModel.data.isEmpty)
//      return Center(
//        child: LinearProgressIndicator(),
//      );
//    else
//      return ExpansionPanelList(
//        animationDuration: Duration(milliseconds: 500),
//        expansionCallback: (index, bol) {
//          setState(() {
//            mTopModel.data[index].isOpen = !bol;
//          });
//        },
//        children: mTopModel.data.map((topInfo) {
//          return ExpansionPanel(
//              // 上下文 是否是打开的
//              headerBuilder: (context, isExpanded) {
//                return Container(
//                  height: 40,
//                  child: Row(
//                    children: <Widget>[
//                      Image.network(
//                        topInfo.picUrl,
//                        fit: BoxFit.cover,
//                      ),
//                      Text(topInfo.title)
//                    ],
//                  ),
//                );
//
//                ListTile(title: Text(topInfo.title));
//
////                  Image.network(
////                  topInfo.picUrl,
////                  fit: BoxFit.cover,
////                );
//              },
//              body: Container(
//                    child: ListView.builder(
//                        shrinkWrap: true,
//                        physics: NeverScrollableScrollPhysics(),
//                        itemCount: topInfo.songList.length,
//                        itemBuilder: (context, index) {
//                          return ListTile(
//                              title: Text(topInfo.songList[index].singName));
//                        }),
//                  ),
//              // 判断是否打开
//              isExpanded: topInfo.isOpen);
//        }).toList(),
//      );
////    return ListView.builder(
////    itemCount: mTopModel.data.length,
////    itemBuilder: (context, index){
////    return
////    })
//  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return mHomeModel == null
        ? Center(
            child: CircularProgressIndicator(),
          )
        : SingleChildScrollView(
            child: Column(
              children: <Widget>[headerView(), tvCataogryView()],
            ),
          );
  }
}
