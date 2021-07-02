package com.rollbar.flutter.compatibility;

import org.mockito.ArgumentCaptor;
import org.mockito.ArgumentMatchers;
import org.mockito.verification.VerificationMode;

import java.nio.ByteBuffer;

import io.flutter.plugin.common.MethodCodec;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class CodecAdapter {
  public static void whenCodecInvoked(MethodCodec codec, ByteBuffer result) {
    when(codec.encodeErrorEnvelope(
            ArgumentMatchers.anyString(),
            ArgumentMatchers.anyString(),
            any())).thenReturn(result);
  }

  public static void verifyCall(MethodCodec codec, VerificationMode times,
                                ArgumentCaptor<String> message,
                                ArgumentCaptor<String> ignoredStackTrace) {
    verify(codec, times).encodeErrorEnvelope(
            anyString(),
            message.capture(),
            any()
    );
  }

  public static boolean canCaptureStackTrace() {
    // This is the Flutter 1 implementation, `encodeErrorEnvelope` doesn't accept a stack trace
    return false;
  }
}
