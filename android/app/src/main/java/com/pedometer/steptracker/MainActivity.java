package com.pedometer.steptracker;

import io.flutter.embedding.android.FlutterActivity;
import android.util.Log;
import androidx.annotation.NonNull;
import android.os.Bundle;

import com.own.sdk.analyticstracker.AnalyticsTracker;


public class MainActivity extends FlutterActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        funToBeCalledFromFlutterSDK();
    }

    private void funToBeCalledFromFlutterSDK() {
        Log.d("New Sdk nasir","BEfore");
        AnalyticsTracker.getInstance().start(getApplicationContext(), "EVJ5aBod18IUuAfZr6bK");
//        AnalyticsTracker.getInstance().setDebugLog(true);
        Log.d("New Sdk nasir","After");
    }

}
