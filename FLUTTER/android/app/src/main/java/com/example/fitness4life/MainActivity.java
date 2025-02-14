package com.example.fitness4life;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        handleDeepLink(getIntent()); // Xử lý Deep Link khi app mở lần đầu
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        handleDeepLink(intent); // Xử lý khi app đang chạy
    }

    private void handleDeepLink(Intent intent) {
        Uri data = intent.getData();
        if (data != null) {
            Log.d("DeepLink", "🎯 Received Deep Link: " + data.toString());

            getFlutterEngine().getNavigationChannel().pushRoute("/paypal_success"); // Chuyển hướng Flutter
        }
    }
}
