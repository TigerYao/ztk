import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:huatu_flutter/model/home_model.dart';
import 'package:huatu_flutter/utils/net_utils.dart';
import 'detail_page.dart';
import 'search_page.dart';

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
  int _currentHeadIndex = 0;
  Map<String, Map<String, List<TvInfo>>> _mCataList;
  Map<String, List<TvInfo>> _mCatogryTypeList;
  Map<String, List<TvInfo>> _currentCatogrList;
  List<TvInfo> _currentTypes;

  @override
  void initState() {
    super.initState();
    NetUtils.requestData(NetUtils.baseUrl).then((value) => setState(() {
          if (_mCataList == null) _mCataList = Map();
          if (_mCatogryTypeList == null) _mCatogryTypeList = Map();
          mHomeModel = value;
          mHomeModel.headerInfos.insert(0, TvInfo(path: '/', title: '推荐'));
          mHomeModel.headerInfos.insert(1, TvInfo(path: '//', title: '最新'));
          _currentTypes = mHomeModel.infos;
          _currentCatogrList = mHomeModel.catorgreList;
          _mCataList.putIfAbsent(NetUtils.baseUrl, () {
            return _currentCatogrList;
          });
          _mCatogryTypeList.putIfAbsent(NetUtils.baseUrl, () => _currentTypes);
        }));
  }

  fetchDatas(String url) {
    if (_mCatogryTypeList.containsKey(url))
      _currentTypes = _mCatogryTypeList[url];
    if (_mCataList.containsKey(url)) _currentCatogrList = _mCataList[url];
    if (!_mCatogryTypeList.containsKey(url) || !_mCataList.containsKey(url)) {
      NetUtils.fetchDataByCategory(url).then((value) {
        setState(() {
          _currentTypes = value[0];
          _currentCatogrList = value[1];
          _mCataList.putIfAbsent(url, () => value[1]);
          _mCatogryTypeList.putIfAbsent(url, () => value[0]);
        });
      });
    }
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
          TvInfo f = sliders[index];
          Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) =>
                    new ChewieDemo(title: f.title, url: f.path)),
          );
        },
        viewportFraction: 0.9,
        scale: 0.9,
      ),
    );
  }

  tvCataogryView() {
    if (mHomeModel == null) return Text('动漫画');
    List<TvInfo> infos = mHomeModel.headerInfos;
    return ListView.builder(
        itemCount: infos.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          TvInfo tvInfo = infos[index];
          return InkWell(
            onTap: () {
              if (_currentHeadIndex == index) return;
              _currentHeadIndex = index;
              String url = NetUtils.baseUrl;
              _currentCatogrList = Map();
              _currentTypes = List();
              if (index == 0)
                fetchDatas(url);
              else if (index > 1) fetchDatas(url + tvInfo.path);
              setState(() {});
            },
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(5),
              child: Text(
                tvInfo.title,
                style: TextStyle(
                    fontSize: 18,
                    color:
                        _currentHeadIndex == index ? Colors.red : Colors.black),
              ),
            ),
          );
        });

//      Row(
//      mainAxisAlignment: MainAxisAlignment.spaceAround,
//      children: infos.map((tvInfo) {
//        return InkWell(
//          onTap: (){
//            setState(() {
//              _currentHeadIndex = infos.indexOf(tvInfo);
//              _currentHeadTitle = tvInfo.title;
//            });
//          },
//          child: Container(
//            padding: EdgeInsets.all(5),
//            child: Text(
//              tvInfo.title,
//              style: TextStyle(fontSize: 12, color: _currentHeadTitle == tvInfo.title ? Colors.red  : Colors.black),
//            ),
//          ),
//        );
//      }).toList(),
//    );
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
    print('****[infos:' +
        _currentTypes.toString() +
        "****[catogr]:" +
        _currentCatogrList.toString());
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.all(10),
      child: Column(
        children: _currentTypes.map((tvInfo) {
          String title = tvInfo.title;
          List<TvInfo> tvList = _currentCatogrList[title];
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
          '||',
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
          onTap: () {
            Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) =>
                      new ChewieDemo(title: f.title, url: f.path)),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Image.network(
                f.picUrl,
                fit: BoxFit.fitHeight,
                height: 150,
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
  }

  @override
  Widget build(BuildContext context) {
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
              children: getChildren(),
            ),
    );
  }

  creatSearchView() {
    return InkWell(
      child: Container(
        alignment: Alignment.centerLeft,
        height: 40,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.only(right: 10.0, top: 3.0, left: 10.0),
              child: new Icon(Icons.search,
                  size: 24.0, color: Theme.of(context).accentColor),
            ),
            new Expanded(
              child: Text('一拳超人'),
            )
          ],
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => SearchPage(
                    placeholder: "进击的巨人全季", path: '/search/',
                  )),
        );
      },
    );
  }

  List<Widget> getChildren() {
    if (_currentHeadIndex == 1) {
      return [
        creatSearchView(),
        headerView(),
        weekItemHeader(),
        weekItemView(mHomeModel.tabListInfos[_currentValue]),
      ];
    } else {
      return [creatSearchView(), headerView(), tvContentView()];
    }
  }
}
