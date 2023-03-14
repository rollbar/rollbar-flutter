package com.rollbar.flutter;

import static com.rollbar.flutter.RollbarTracePayload.TRACE_PAYLOAD_PREFIX;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.greaterThanOrEqualTo;
import static org.hamcrest.Matchers.startsWith;
import static org.junit.Assert.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import androidx.annotation.NonNull;

import com.rollbar.flutter.compatibility.CodecAdapter;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodCodec;
import java.nio.ByteBuffer;
import java.util.List;
import java.util.Map;
import org.junit.Before;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.ArgumentMatchers;
import org.mockito.MockedStatic;

public class RollbarMethodChannelTest {

  private BinaryMessenger messenger;
  private MethodCodec codec;

  @Before
  public void setUp() {
    mockStatic(android.util.Log.class).when(new MockedStatic.Verification() {
      @Override
      public void apply() {
        android.util.Log.i(null, null);
      }
    }).thenReturn(0);

    messenger = mock(BinaryMessenger.class);
    codec = mock(MethodCodec.class);

    ByteBuffer errorBytes = ByteBuffer.wrap(new byte[]{3, 2, 0});

    CodecAdapter.whenCodecInvoked(codec, errorBytes);

    when(codec.decodeMethodCall(ArgumentMatchers.<ByteBuffer>any()))
            .thenReturn(new MethodCall("simpleMethod", 1));
  }

  @Test
  public void ifHandlerThrowsItShouldWrapTheException() {
    RollbarMethodChannel channel = new RollbarMethodChannel(messenger, "testing_ch", codec);
    channel.setMethodCallHandler(getBadMethodHandler());

    ArgumentCaptor<BinaryMessenger.BinaryMessageHandler> handler =
            ArgumentCaptor.forClass(BinaryMessenger.BinaryMessageHandler.class);
    verify(messenger, times(1)).setMessageHandler(anyString(), handler.capture());

    BinaryMessenger.BinaryReply reply = mock(BinaryMessenger.BinaryReply.class);

    handler.getValue().onMessage(null, reply);

    ArgumentCaptor<String> stackTrace = ArgumentCaptor.forClass(String.class);
    ArgumentCaptor<String> message = ArgumentCaptor.forClass(String.class);

    CodecAdapter.verifyCall(codec, times(1),
            message,
            stackTrace);

    if (CodecAdapter.canCaptureStackTrace()) {
      String stackTraceString = stackTrace.getValue();
      if (stackTraceString != null) {
        assertThat(stackTraceString, startsWith(TRACE_PAYLOAD_PREFIX));
      }
    }

    String messageString = message.getValue();
    assertNotNull(messageString);
    assertThat(messageString, startsWith(TRACE_PAYLOAD_PREFIX));
    messageString = messageString.substring(TRACE_PAYLOAD_PREFIX.length());

    Map<String, Object> result = MapHelper.jsonToMap(messageString);
    assertNotNull(result);

    List<Map<String, Object>> frames =
            MapHelper.getValue(result, "data", "body", "trace", "frames");

    assertThat(frames.size(), greaterThanOrEqualTo(1));

    assertThat(MapHelper.getValue(String.class, frames.get(0), "method"),
            equalTo("badMethod"));
  }

  private MethodChannel.MethodCallHandler getBadMethodHandler() {
    return new MethodChannel.MethodCallHandler() {
      @Override
      public void onMethodCall(@NonNull MethodCall methodCall,
                               @NonNull MethodChannel.Result result) {
        if (methodCall.method.equals("simpleMethod")) {
          badMethod();
        } else {
          result.success(null);
        }
      }
    };
  }

  private void badMethod() {
    throw new IllegalStateException("Don't call us, we'll call you");
  }
}
