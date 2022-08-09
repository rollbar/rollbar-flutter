package com.rollbar.flutter;

import android.content.Context;
import androidx.annotation.NonNull;

import com.rollbar.android.Rollbar;
import com.rollbar.notifier.config.Config;
import com.rollbar.notifier.config.ConfigBuilder;
import com.rollbar.notifier.config.ConfigProvider;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import java.io.File;
import java.util.HashMap;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;

/**
 * RollbarFlutterPlugin.
 */
public class RollbarFlutterPlugin implements FlutterPlugin, MethodCallHandler {
  private static volatile Rollbar globalInstance;
  private final HashMap<String, Rollbar> instances = new HashMap<>();
  private final ReadWriteLock configReadWriteLock = new ReentrantReadWriteLock();
  private final Lock configWriteLock = configReadWriteLock.writeLock();
  private MethodChannel channel;
  private Context context;

  public static Config getConfig() {
    return globalInstance == null ? null : globalInstance.config();
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    context = flutterPluginBinding.getApplicationContext();
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "com.rollbar.flutter");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    String method = call.method;
    switch (method) {
      case "initialize": {
        String instanceId = call.argument("instanceId");
        Boolean isGlobalInstance = call.argument("isGlobalInstance");
        String endpoint = call.argument("endpoint");
        String accessToken = call.argument("accessToken");
        String environment = call.argument("environment");
        String codeVersion = call.argument("codeVersion");
        Boolean handleUncaughtErrors = call.argument("handleUncaughtErrors");
        Boolean includePlatformLogs = call.argument("includePlatformLogs");

        this.initialize(
            instanceId,
            isGlobalInstance,
            endpoint,
            accessToken,
            environment,
            codeVersion,
            handleUncaughtErrors,
            includePlatformLogs);

        result.success(null);
        break;
      }
      case "persistencePath": {
        String dummyDatabaseName = "tekartik_sqflite.db";
        File file = context.getDatabasePath(dummyDatabaseName);
        String path = file.getParent();
        result.success(path);
        break;
      }
      case "close": {
        String instanceId = call.argument("instanceId");
        this.close(instanceId);
        break;
      }
      default:
        result.notImplemented();
        break;
    }
  }

  private void close(String ignored) {
    // Rollbar android doesn't support closing at the moment.
  }

  private void initialize(
      String instanceId,
      Boolean isGlobalInstance,
      final String endpoint,
      String accessToken,
      String environment,
      final String codeVersion,
      Boolean handleUncaughtErrors,
      Boolean includePlatformLogs) {
    ConfigProvider configProvider = new ConfigProvider() {
      @Override
      public Config provide(ConfigBuilder builder) {
        if (endpoint != null) {
          builder = builder.endpoint(endpoint);
        }
        if (codeVersion != null) {
          builder = builder.codeVersion(codeVersion);
        }
        return builder.build();
      }
    };

    if (context == null) {
      return;
    }

    Rollbar rollbar = new Rollbar(
        context,
        accessToken,
        environment,
        handleUncaughtErrors,
        includePlatformLogs,
        configProvider);

    configWriteLock.lock();
    try {
      if (isGlobalInstance != null && isGlobalInstance) {
        globalInstance = rollbar;
      }
      instances.put(instanceId, rollbar);
    } finally {
      configWriteLock.unlock();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
