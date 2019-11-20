package com.huatu.yao.tiger.huatu_flutter;

import android.os.Bundle;
import android.util.Log;

import com.umeng.message.inapp.IUmengInAppMsgCloseCallback;
import com.umeng.message.inapp.InAppMessageManager;

import io.flutter.app.FlutterActivity;

public class BaseActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        InAppMessageManager.getInstance(this.getApplicationContext()).showCardMessage(this, "base", new IUmengInAppMsgCloseCallback() {
            @Override
            public void onClose() {
                Log.i("BaseActivity", "card message close");
            }
        });
    }
}
