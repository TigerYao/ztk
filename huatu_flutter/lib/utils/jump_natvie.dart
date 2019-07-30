//获取到插件与原生的交互通道
import 'dart:async';

import 'package:flutter/services.dart';

 class JumpNativie{
  static const jumpPlugin = const MethodChannel('com.huatu.jump/plugin');

  Future<Null> _jumpToNative(String methodName) async {
    String result = await jumpPlugin.invokeMethod(methodName);

    print(result);
  }

  Future<String> jumpToNativeWithValue(String methodName, String key, String value) async {

    Map<String, String> map = {key: value};

    String result = await jumpPlugin.invokeMethod(methodName, map);

    return result;
  }

  static const counterPlugin = const EventChannel('com.huatu.counter/plugin');

  StreamSubscription _subscription = null;
  void initListener(){
    if(_subscription == null){
      _subscription =  counterPlugin.receiveBroadcastStream().listen(onEvent,onError: _onError);
    }
  }

  void cancle(){
    if (_subscription != null)
      _subscription.cancel();
  }

   void onEvent(Object event){
    
  }

  void _onError(Object error) {
      print(error);
  }
}
