package com.rollbar.flutter;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.UiThread;
import com.rollbar.android.Rollbar;
import com.rollbar.notifier.config.Config;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodCodec;

/**
 * <p>
 * A flutter {@link MethodChannel} implementation that, when an invocation
 * throws an exception, will capture and embed additional occurrence details
 * to be used by the Dart notifier.
 * </p>
 */
public class RollbarMethodChannel extends MethodChannel {
  public RollbarMethodChannel(BinaryMessenger messenger, String name) {
    super(messenger, name);
  }

  public RollbarMethodChannel(BinaryMessenger messenger, String name, MethodCodec codec) {
    super(messenger, name, codec);
  }

  @Override
  public void setMethodCallHandler(@Nullable MethodChannel.MethodCallHandler handler) {
    if (handler != null) {
      handler = new RollbarMethodCallHandler(handler);
    }

    super.setMethodCallHandler(handler);
  }

  static class RollbarMethodCallHandler implements MethodCallHandler {
    private final MethodCallHandler delegate;

    public RollbarMethodCallHandler(@NonNull MethodCallHandler handler) {
      delegate = handler;
    }

    @UiThread
    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
      try {
        delegate.onMethodCall(call, result);
      } catch (Throwable t) {
        Config config = RollbarFlutterPlugin.getConfig();
        throw new RollbarTracePayload(t, config);
      }
    }
  }
}
