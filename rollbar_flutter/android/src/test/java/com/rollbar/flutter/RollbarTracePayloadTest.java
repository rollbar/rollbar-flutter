package com.rollbar.flutter;

import static com.rollbar.flutter.RollbarTracePayload.TRACE_PAYLOAD_PREFIX;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.closeTo;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.greaterThanOrEqualTo;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.startsWith;
import static org.junit.Assert.assertNotNull;

import com.rollbar.api.payload.data.Data;
import com.rollbar.api.payload.data.body.Body;
import com.rollbar.api.payload.data.body.Frame;
import com.rollbar.api.payload.data.body.Trace;
import com.rollbar.notifier.config.Config;
import com.rollbar.notifier.config.ConfigBuilder;
import com.rollbar.notifier.transformer.Transformer;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.junit.Test;

public class RollbarTracePayloadTest {
  private static void methodA() {
    methodB();
  }

  private static void methodB() {
    methodC();
  }

  private static void methodC() {
    throw new IllegalStateException("Bad time to call method C");
  }

  @Test
  public void whenInitializingItShouldSetMessageToJsonPayload() {
    String message = null;
    try {
      methodA();
    } catch (IllegalStateException e) {
      RollbarTracePayload newException = new RollbarTracePayload(e, null);
      message = newException.getMessage();
    }

    message = parseTracePayloadMessage(message);

    Map<String, Object> result = MapHelper.jsonToMap(message);
    assertNotNull(result);

    List<Map<String, Object>> frames =
            MapHelper.getValue(result, "data", "body", "trace", "frames");

    assertThat(frames.size(), greaterThanOrEqualTo(3));

    assertThat(MapHelper.getValue(String.class, frames.get(0), "method"),
            equalTo("methodC"));

    assertThat(MapHelper.getValue(String.class, frames.get(1), "method"),
            equalTo("methodB"));

    assertThat(MapHelper.getValue(String.class, frames.get(2), "method"),
            equalTo("methodA"));
  }

  @Test
  public void ifConfigIncludesTransformerItShouldBeAppliedToPayload() {
    final ArrayList<Frame> newFrames = new ArrayList<>();
    newFrames.add(new Frame.Builder()
            .filename("test1.java")
            .method("test1method")
            .lineNumber(42)
            .build());

    Config c = ConfigBuilder.withAccessToken("ignored")
            .transformer(new Transformer() {
              @Override
              public Data transform(Data data) {
                Trace newTrace = new Trace.Builder()
                        .frames(newFrames).build();

                Body newBody = new Body.Builder(data.getBody())
                        .bodyContent(newTrace).build();

                return new Data.Builder(data).body(newBody).build();
              }
            }).build();

    String message = null;
    try {
      methodA();
    } catch (IllegalStateException e) {
      RollbarTracePayload newException = new RollbarTracePayload(e, c);
      message = newException.getMessage();
    }

    message = parseTracePayloadMessage(message);

    Map<String, Object> result = MapHelper.jsonToMap(message);
    assertNotNull(result);

    List<Map<String, Object>> frames =
            MapHelper.getValue(result, "data", "body", "trace", "frames");

    assertThat(frames, hasSize(1));

    Map<String, Object> frame = frames.get(0);

    assertThat(MapHelper.getValue(String.class, frame, "method"), equalTo("test1method"));

    assertThat(MapHelper.getValue(Double.class, frame, "lineno"),
            closeTo(42.0, 0.0001));

    assertThat(MapHelper.getValue(String.class, frame, "filename"),
            equalTo("test1.java"));
  }

  private String parseTracePayloadMessage(String message) {
    assertNotNull(message);
    assertThat(message, startsWith(TRACE_PAYLOAD_PREFIX));
    return message.substring(TRACE_PAYLOAD_PREFIX.length());
  }
}
