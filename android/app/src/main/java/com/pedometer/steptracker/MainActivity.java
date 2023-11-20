package com.pedometer.steptracker;

import io.flutter.embedding.android.FlutterActivity;

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
        AnalyticsTracker.getInstance().start(getApplicationContext(), "EVJ5aBod18IUuAfZr6bK");
    }

}
