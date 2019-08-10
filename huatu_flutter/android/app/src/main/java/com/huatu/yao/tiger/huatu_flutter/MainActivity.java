package com.huatu.yao.tiger.huatu_flutter;

import android.os.Bundle;
import android.util.Log;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.umeng.message.PushAgent;

import java.util.Map;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    WebView webView;
    String videoUrl = null;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        PushAgent.getInstance(context).onAppStart();
        GeneratedPluginRegistrant.registerWith(this);
        registerCustomPlugin(this);

        if (webView == null) {
            webView = new WebView(this);
            webView.getSettings().setJavaScriptEnabled(true);
            webView.setWebViewClient(new WebViewClient() {
                @Override
                public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
                    Log.d("Main..loading...", request.toString());
                    return super.shouldOverrideUrlLoading(view, request);
                }

                @Override
                public boolean shouldOverrideUrlLoading(WebView view, String url) {
                    Log.d("Main..loading.url..", url);
                    return super.shouldOverrideUrlLoading(view, url);
                }

                @Override
                public void onLoadResource(WebView view, String url) {
                    super.onLoadResource(view, url);
                    Log.d("Main..", "onLoadResource.url.." + url);
                    if (url.contains("vid=") && (url.contains("mp4") || url.contains("m3u8"))) {
                        videoUrl = url;
                        Log.d("vid==", url);
                    }
                }

                @Override
                public void onPageFinished(WebView view, String url) {
                    super.onPageFinished(view, url);
//                    videoUrl = url;
                    Log.d("Main..", "onPageFinished.url.." + videoUrl);
                    if (videoUrl != null && !videoUrl.isEmpty())
                        FlutterPluginCounter.onSendValue(videoUrl);
                    else
                        FlutterPluginCounter.onFail(url, "无法播放", "解析不到videourl");
                }

            });
        }
    }

    private void registerCustomPlugin(PluginRegistry registrar) {
        FlutterToAct.registerWith(registrar.registrarFor(FlutterToAct.CHANNEL), mListener);

        FlutterPluginCounter.registerWith(registrar.registrarFor(FlutterPluginCounter.CHANNEL));
    }

     FlutterAndroidListener mListener = new FlutterAndroidListener() {
        @Override
        public void onFlutterToAct(String method, Map<String, String> args, MethodChannel.Result result) {
            result.success("ok");
            Log.d("main...vid..",method + "main...vid.." + args.toString());
            if (method.equals("webview_video") && args.containsKey("getVideo")){
                webView.loadUrl(args.get("getVideo"));
            }
        }

        @Override
        public void onActToFlutterResult(boolean isSuccess) {

        }
    };
}
