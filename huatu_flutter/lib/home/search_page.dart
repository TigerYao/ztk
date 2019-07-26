import 'package:flutter/material.dart';

typedef void OnSubmit(String value);

class SearchPage extends StatefulWidget {
  final String placeholder;
  final OnSubmit onSubmit;

  SearchPage({this.placeholder, this.onSubmit});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _controller = new TextEditingController();
  bool hasValue = false;

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
              onChanged: (val) {
                hasValue = val != null && val.isNotEmpty;
              },
              controller: _controller,
            ),
          ),
        ],
      ),
    );
  }

  createBody() {
    return Text('ss');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: (){
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
              onPressed: () {}),
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
