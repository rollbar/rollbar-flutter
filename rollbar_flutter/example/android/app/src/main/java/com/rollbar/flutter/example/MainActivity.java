package com.rollbar.flutter.example;

import android.content.Context;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build;

import androidx.annotation.NonNull;

import com.rollbar.flutter.RollbarMethodChannel;

import java.util.concurrent.atomic.AtomicInteger;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity implements MethodChannel.MethodCallHandler {
    private static final String CHANNEL = "com.rollbar.flutter.example/activity";
    private AtomicInteger counter;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        counter = new AtomicInteger(0);
        new RollbarMethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                CHANNEL).setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("getBatteryLevel")) {
            try {
                int batteryLevel = getBatteryLevel();
                result.success(batteryLevel);
            } catch (IllegalStateException e) {
                throw new IllegalArgumentException("Method cannot be invoked", e);
            }
        } else if (call.method.equals("faultyMethod")) {
            result.success(faultyMethod());
        } else {
            result.notImplemented();
        }
    }

    private String faultyMethod() {
        throw new IllegalStateException("You called a method called 'faultyMethod', what did you expect?");
    }

    private int getBatteryLevel() {
        int counterValue = counter.incrementAndGet();
        if (counterValue % 2 == 1) {
            throw new IllegalStateException("Invalid counter state: " + counterValue);
        }

        int batteryLevel;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            BatteryManager batteryManager = (BatteryManager)getSystemService(Context.BATTERY_SERVICE);
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
        } else {
            Intent intent = new ContextWrapper(getApplicationContext())
                    .registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
            batteryLevel = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 /
                    intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        }
        
        return batteryLevel;
    }
}
