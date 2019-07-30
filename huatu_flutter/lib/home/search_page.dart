import 'package:flutter/material.dart';
import 'package:huatu_flutter/home/detail_page.dart';
import 'package:huatu_flutter/model/home_model.dart';
import 'package:huatu_flutter/utils/net_utils.dart';
import 'package:huatu_flutter/home/webview.dart';

class SearchPage extends StatefulWidget {
  final String placeholder;
  final String path;

  SearchPage({this.placeholder, this.path});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _controller = new TextEditingController();
  bool hasValue = false;
  List<TvInfo> results = null;

  fetchSearch(String url) {
    NetUtils.getSearchResult(url).then((val) {
      setState(() {
        results = val;
      });
    });
  }

  creatSearchView() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(top: 5, bottom: 5),
      height: 40.0,
      child: new Row(
        children: <Widget>[
          new Expanded(
            child: TextField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10.0),
                enabledBorder: OutlineInputBorder(
                  /*边角*/
                  borderRadius: BorderRadius.all(
                    Radius.circular(20), //边角为30
                  ),
                  borderSide: BorderSide(
                    color: Colors.grey, //边线颜色为黄色
                    width: 1, //边线宽度为2
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20), //边角为30
                    ),
                    borderSide: BorderSide(
                      color: Colors.grey, //边框颜色为绿色
                      width: 1, //宽度为5
                    )),
                hasFloatingPlaceholder: false,
                hintText: widget.placeholder,
                prefixIcon: Icon(Icons.search),
                filled: true,
              ),
              controller: _controller,
            ),
          ),
        ],
      ),
    );
  }

  createBody() {
    return hasValue
        ? (results == null || results.isEmpty)
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  TvInfo info = results[index];
                  return ListTile(
                    title: Text(info.title),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
//                                  Widget_WebView_Page()
                                  ChewieDemo(
                                    title: info.title,
                                    url: info.path,
                                  )
                          ));
                    },
                    contentPadding: EdgeInsets.all(5),
                  );
                })
        : Center(
            child: _controller.text != null && _controller.text.isNotEmpty
                ? Text('抱歉，未找到相关信息')
                : Text('输入关键字试试搜索'),
          );
  }

  @override
  void dispose() {
    _controller.clear();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            }),
        backgroundColor: Colors.white,
        title: creatSearchView(),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.send,
                color: Colors.red,
              ),
              onPressed: () {
                String val = widget.placeholder;
                if (_controller.text != null && _controller.text.isNotEmpty) {
                  val = _controller.text;
                }
                setState(() {
                  hasValue = true;
                });
                print('val...' + val);
                fetchSearch(NetUtils.baseUrl + widget.path + val);
              }),
        ],
      ),
      body: createBody(),
    );
  }
}

///搜索结果内容显示面板
class MaterialSearchResult<T> extends StatelessWidget {
  const MaterialSearchResult(
      {Key key, this.value, this.text, this.icon, this.onTap})
      : super(key: key);

  final String value;
  final VoidCallback onTap;
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return new InkWell(
      onTap: this.onTap,
      child: new Container(
        height: 64.0,
        padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
        child: new Row(
          children: <Widget>[
            new Container(
                    width: 30.0,
                    margin: EdgeInsets.only(right: 10),
                    child: new Icon(icon)) ??
                null,
            new Expanded(
                child: new Text(value,
                    style: Theme.of(context).textTheme.subhead)),
            new Text(text, style: Theme.of(context).textTheme.subhead)
          ],
        ),
      ),
    );
  }
}

class SearchInput extends StatelessWidget {
  final getResults;

  final ValueChanged<String> onSubmitted;

  final VoidCallback onSubmitPressed;

  SearchInput(this.getResults, this.onSubmitted, this.onSubmitPressed);

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 40.0,
      decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.circular(4.0)),
      child: new Row(
        children: <Widget>[
          new Padding(
            padding: new EdgeInsets.only(right: 10.0, top: 3.0, left: 10.0),
            child: new Icon(Icons.search,
                size: 24.0, color: Theme.of(context).accentColor),
          ),
          new Expanded(
            child: new SearchPage(
              placeholder: '搜索 flutter 组件',
            ),
          ),
        ],
      ),
    );
  }
}
