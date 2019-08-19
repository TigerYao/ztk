import 'package:flutter/material.dart';

import 'package:huatu_flutter/home/host_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  static List tabData = [
    {'text': '动漫', 'icon': Icon(Icons.music_video)},
    {'text': '剧集', 'icon': Icon(Icons.queue_music)},
    {'text': '收藏', 'icon': Icon(Icons.favorite)},
    {'text': '我的', 'icon': Icon(Icons.person)},
  ];
  List<BottomNavigationBarItem> _bottomTabs = [];
  int _currentIndex = 0;
  List<Widget> _listPages = List();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < tabData.length; i++) {
      _bottomTabs.add(BottomNavigationBarItem(
          icon: tabData[i]['icon'], title: Text(tabData[i]['text'])));
    }

    _listPages
      ..add(HostPage(0))
      ..add(HostPage(1))
      ..add(Text('ds'))
      ..add(Text('dd'));
  }

  @override
  Widget build(BuildContext context) {
    return

//      Scaffold(
//      body: HostPage(0),
//    );
//
 Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _listPages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _bottomTabs,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        fixedColor: Color(0xFFC91B3A),
        onTap: (index) {
          if (index != _currentIndex)
            setState(() {
              _currentIndex = index;
            });
        },
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
