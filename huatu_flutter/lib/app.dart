import 'package:flutter/material.dart';

import 'home/home_page.dart';

const int ThemeColor = 0xFFC91B3A;
class HTApp extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HTAppState();
  }
}

class _HTAppState extends State<HTApp>{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: '超级影漫',
      debugShowCheckedModeBanner:false,
      theme: new ThemeData(
        primaryColor: Color(ThemeColor),
        backgroundColor: Color(0xFFEFEFEF),
        accentColor: Color(0xFF888888),
        textTheme: TextTheme(
          //设置Material的默认字体样式
          body1: TextStyle(color: Color(0xFF888888), fontSize: 16.0),
        ),
        iconTheme: IconThemeData(
          color: Color(ThemeColor),
          size: 35.0,
        ),
      ),
      home: Scaffold(body: HomePage()),
    );
  }
}