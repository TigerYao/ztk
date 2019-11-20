package com.huatu.yao.tiger.huatu_flutter;

import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public interface FlutterAndroidListener {
    void onFlutterToAct(String method, Map<String, String> args, MethodChannel.Result result);
    void onActToFlutterResult(boolean isSuccess);
}
