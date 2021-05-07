package com.rollbar.flutter;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.hasItem;

import com.google.gson.Gson;
import java.util.Map;


/**
 * Helper methods to deal with untyped Json deserialization.
 */
public class MapHelper {
  @SuppressWarnings("unchecked")
  public static Map<String, Object> jsonToMap(String json) {
    return new Gson().fromJson(json, Map.class);
  }

  public static <T> T getValue(Class<T> ignored, Map<String, Object> source, String... path) {
    return getValue(source, path);
  }

  @SuppressWarnings("unchecked")
  public static <T> T getValue(Map<String, Object> source, String... path) {
    Map<String, Object> currMap = source;

    for (int j = 0; j < path.length; ) {
      String key = path[j];
      assertThat(currMap.keySet(), hasItem(key));
      Object result = currMap.get(key);

      ++j;
      if (j == path.length) {
        return (T) result;
      } else {
        currMap = (Map<String, Object>) result;
      }
    }

    throw new IllegalStateException("No path provided");
  }
}
