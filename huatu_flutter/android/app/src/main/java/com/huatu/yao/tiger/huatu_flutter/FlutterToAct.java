package com.huatu.yao.tiger.huatu_flutter;

import android.app.Activity;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class FlutterToAct implements MethodChannel.MethodCallHandler {

    public static String CHANNEL = "com.huatu.jump/plugin";

    static MethodChannel channel;

    private Activity activity;
    private FlutterAndroidListener mListener;

    public FlutterToAct() {
    }

    private FlutterToAct(Activity activity, FlutterAndroidListener listener) {
        this.activity = activity;
        mListener = listener;
    }

    public static void registerWith(PluginRegistry.Registrar registrar, FlutterAndroidListener listener) {
        channel = new MethodChannel(registrar.messenger(), CHANNEL);
        FlutterToAct instance = new FlutterToAct(registrar.activity(), listener);
        //setMethodCallHandler在此通道上接收方法调用的回调
        channel.setMethodCallHandler(instance);
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        String callMethod = methodCall.method;
        mListener.onFlutterToAct(callMethod, methodCall.arguments(), result);
    }
}
