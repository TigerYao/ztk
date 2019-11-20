package com.huatu.yao.tiger.huatu_flutter;

import android.app.Activity;
import android.util.Log;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.PluginRegistry;

public class FlutterPluginCounter implements EventChannel.StreamHandler {

    public static String CHANNEL = "com.huatu.counter/plugin";

    static EventChannel channel;
    private static Object mObj;

    private Activity activity;
    private static EventChannel.EventSink mEventSink;

    private FlutterPluginCounter(Activity activity) {
        this.activity = activity;
    }

    public static void registerWith(PluginRegistry.Registrar registrar) {
        channel = new EventChannel(registrar.messenger(), CHANNEL);
        FlutterPluginCounter instance = new FlutterPluginCounter(registrar.activity());
        channel.setStreamHandler(instance);
    }

    @Override
    public void onListen(Object o, final EventChannel.EventSink eventSink) {
        mEventSink = eventSink;
        if (eventSink!= null && mObj != null) {
            eventSink.success(mObj);
        }
        Log.d("main..." , mEventSink.toString() + "......");
    }

    public static void onSendValue(Object obj) {
        if (mEventSink != null)
            mEventSink.success(obj);
        else {
            mObj = obj;
        }
    }

    public static void onFail(String obj, String e1, String e2) {
        if (mEventSink != null)
            mEventSink.error(e1, e2, obj);
    }

    @Override
    public void onCancel(Object o) {
        Log.i("FlutterPluginCounter", "FlutterPluginCounter:onCancel");
    }

}