
class BaseModel{
  String announce;
  int errno;
  String msg;

  BaseModel({this.announce, this.errno, this.msg});

  factory BaseModel.fromJson(Map<String, dynamic> json){
    return BaseModel(
      announce: json['announce'],
      errno: json['errno'],
      msg: json['msg'],
    );
  }

}