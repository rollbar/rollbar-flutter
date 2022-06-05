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
    when(codec.encodeErrorEnvelopeWithStacktrace(
            ArgumentMatchers.anyString(),
            ArgumentMatchers.anyString(),
            any(),
            ArgumentMatchers.anyString()))
            .thenReturn(result);
  }

  public static void verifyCall(MethodCodec codec, VerificationMode times,
                                ArgumentCaptor<String> message,
                                ArgumentCaptor<String> stackTrace) {
    verify(codec, times).encodeErrorEnvelopeWithStacktrace(
            anyString(),
            message.capture(),
            any(),
            stackTrace.capture()
    );
  }

  public static boolean canCaptureStackTrace() {
    // This is the Flutter 2 implementation, so Flutter uses `encodeErrorEnvelopeWithStacktrace`
    // for platform exceptions.
    return true;
  }
}
