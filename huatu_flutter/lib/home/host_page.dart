import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:huatu_flutter/model/home_model.dart';
import 'package:huatu_flutter/utils/net_utils.dart';

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
    if (mHomeModel == null) return Text('动漫画');
    List<TvInfo> infos = mHomeModel.headerInfos;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: infos.map((tvInfo) {
        return Container(
          padding: EdgeInsets.all(5),
          child: Text(tvInfo.title, style: TextStyle(fontSize: 12, color:Colors.black),),
        );
      }).toList(),
    );
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
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[headerView()],
              ),
            ),
    );
  }
}
