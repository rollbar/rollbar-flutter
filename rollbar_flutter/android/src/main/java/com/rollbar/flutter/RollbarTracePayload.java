package com.rollbar.flutter;

import com.rollbar.api.payload.Payload;
import com.rollbar.api.payload.data.Data;
import com.rollbar.api.payload.data.body.Body;
import com.rollbar.api.payload.data.body.BodyContent;
import com.rollbar.api.payload.data.body.Trace;
import com.rollbar.api.payload.data.body.TraceChain;
import com.rollbar.notifier.config.Config;
import com.rollbar.notifier.config.ConfigBuilder;
import com.rollbar.notifier.sender.json.JsonSerializerImpl;
import com.rollbar.notifier.util.BodyFactory;
import com.rollbar.notifier.wrapper.RollbarThrowableWrapper;
import com.rollbar.notifier.wrapper.ThrowableWrapper;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class RollbarTracePayload extends RuntimeException {
  public static final String TRACE_PAYLOAD_PREFIX = "com.rollbar.flutter.RollbarTracePayload:";

  public RollbarTracePayload(Throwable t, Config config) {
    super(TRACE_PAYLOAD_PREFIX + toJsonTracePayload(t, config), t);
  }

  public static String toJsonTracePayload(Throwable t, Config config) {
    Payload payload = new Payload.Builder().data(buildData(config, t)).build();
    JsonSerializerImpl serializer = new JsonSerializerImpl();
    return serializer.toJson(payload);
  }

  private static Data buildData(Config config, Throwable throwable) {
    if (config == null) {
      config = ConfigBuilder.withAccessToken("ignored").build();
    }

    ThrowableWrapper error = new RollbarThrowableWrapper(throwable);

    BodyFactory bodyFactory = new BodyFactory();

    Body body = reverseTraces(bodyFactory.from(error, error.getMessage()));
    Data.Builder dataBuilder = new Data.Builder()
            .environment(config.environment())
            .codeVersion(config.codeVersion())
            .platform(config.platform())
            .language(config.language())
            .framework(config.framework())
            .body(body);

    // Gather data from providers.

    // Context
    if (config.context() != null) {
      dataBuilder.context(config.context().provide());
    }

    // Request
    if (config.request() != null) {
      dataBuilder.request(config.request().provide());
    }

    // Person
    if (config.person() != null) {
      dataBuilder.person(config.person().provide());
    }

    // Server
    if (config.server() != null) {
      dataBuilder.server(config.server().provide());
    }

    // Client
    if (config.client() != null) {
      dataBuilder.client(config.client().provide());
    }

    // Custom
    Map<String, Object> tmpCustom = new HashMap<>();
    if (config.custom() != null) {
      Map<String, Object> customProvided = config.custom().provide();
      if (customProvided != null) {
        tmpCustom.putAll(customProvided);
      }
    }

    if (tmpCustom.size() > 0) {
      dataBuilder.custom(tmpCustom);
    }

    // Notifier
    if (config.notifier() != null) {
      dataBuilder.notifier(config.notifier().provide());
    }

    // Timestamp
    if (config.timestamp() != null) {
      dataBuilder.timestamp(config.timestamp().provide());
    }

    Data data = dataBuilder.build();

    if (config.transformer() != null) {
      data = config.transformer().transform(data);
    }

    return data;
  }

  // rollbar-java uses the "most recent call last" frame and trace order, but rollbar-dart uses
  // the preferred order which is "most recent call first". These traces are getting shipped to the
  // Dart side and will be included in a combined trace chain, so we must reverse them to match the
  // Dart order.
  private static Body reverseTraces(Body body) {
    BodyContent content = body.getContents();
    if (content instanceof TraceChain) {
      return new Body.Builder(body)
              .bodyContent(reverseChain((TraceChain) content))
              .build();
    } else if (content instanceof Trace) {
      return new Body.Builder(body)
              .bodyContent(reverseTrace((Trace) content))
              .build();
    } else {
      return body;
    }
  }

  private static TraceChain reverseChain(TraceChain chain) {
    List<Trace> traces = chain.getTraces();
    ArrayList<Trace> result = new ArrayList<>(traces.size());
    for (int j = traces.size() - 1; j >= 0; --j) {
      result.add(reverseTrace(traces.get(j)));
    }
    return new TraceChain.Builder(chain)
            .traces(result)
            .build();
  }

  private static Trace reverseTrace(Trace trace) {
    return new Trace.Builder(trace)
            .frames(reverse(trace.getFrames()))
            .build();
  }

  private static <T> List<T> reverse(List<T> original) {
    List<T> result = new ArrayList<>(original.size());
    for (int j = original.size() - 1; j >= 0; --j) {
      result.add(original.get(j));
    }
    return result;
  }
}
