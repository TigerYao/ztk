package com.huatu.yao.tiger.huatu_flutter;

import android.app.Notification;
import android.content.Context;
import android.support.multidex.MultiDex;
import android.util.Log;

import com.umeng.analytics.MobclickAgent;
import com.umeng.commonsdk.UMConfigure;
import com.umeng.message.IUmengRegisterCallback;
import com.umeng.message.PushAgent;
import com.umeng.message.UmengMessageHandler;
import com.umeng.message.entity.UMessage;
import com.umeng.message.inapp.InAppMessageManager;

import io.flutter.app.FlutterApplication;

public class CustomApplication extends FlutterApplication {
    private static final String TAG = "CustomApplication";
    private PushAgent mPushAgent;
    private OnMessageCallback mOnMessageCallback;
    @Override
    public void onCreate() {
        super.onCreate();
        UMConfigure.init(this, "5d4ea5e24ca357255300088e", "superman", UMConfigure.DEVICE_TYPE_PHONE, "e6fec877a93344eb31aad132e32790ac");
        // 选用AUTO页面采集模式
        MobclickAgent.setPageCollectionMode(MobclickAgent.PageMode.AUTO);
//        MimoSdk.init(this, "2882303761518119108", "5891811917108", "fake_app_token", new IMimoSdkListener() {
//            @Override
//            public void onSdkInitSuccess() {
//                Log.i(TAG,"注册成功：onSdkInitSuccess：-------->  ");
//            }
//
//            @Override
//            public void onSdkInitFailed() {
//                Log.i(TAG,"注册成功：onSdkInitFailed：-------->  ");
//            }
//        });
        mPushAgent = PushAgent.getInstance(this.getApplicationContext());
        mPushAgent.register(new IUmengRegisterCallback() {
            @Override
            public void onSuccess(String deviceToken) {
                //注册成功会返回deviceToken deviceToken是推送消息的唯一标志
                Log.i(TAG,"注册成功：deviceToken：-------->  " + deviceToken);
            }

            @Override
            public void onFailure(String s, String s1) {
                Log.e(TAG,"注册失败：-------->  " + "s:" + s + ",s1:" + s1);
            }
        });
        mPushAgent.onAppStart();
        InAppMessageManager.getInstance(this.getApplicationContext()).setInAppMsgDebugMode(false);
        customNotification();
    }

    private void customNotification(){
        UmengMessageHandler messageHandler = new UmengMessageHandler() {
            @Override
            public Notification getNotification(Context context, UMessage msg) {
                Log.d(TAG, "getNotification===" + msg.getRaw().toString());
                Notification notification = super.getNotification(context, msg);
                return notification;
            }

            @Override
            public void dealWithCustomMessage(Context context, UMessage uMessage) {
                super.dealWithCustomMessage(context, uMessage);
                Log.d(TAG, "dealWithCustomMessage=="+uMessage.getRaw().toString());
            }
        };
        mPushAgent.setMessageHandler(messageHandler);
    }

    public void setOnMessageCallback(OnMessageCallback callback) {
        this.mOnMessageCallback = callback;
    }

    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        MultiDex.install(base);
    }
}
