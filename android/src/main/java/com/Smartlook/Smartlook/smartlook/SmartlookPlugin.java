package com.Smartlook.Smartlook.smartlook;

import android.webkit.WebView;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import org.json.JSONObject;
import com.smartlook.sdk.smartlook.Smartlook;
import java.util.HashMap;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import java.lang.reflect.Type;

/** SmartlookPlugin */
public class SmartlookPlugin implements MethodCallHandler {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "smartlook");
    channel.setMethodCallHandler(new SmartlookPlugin());
  }

  private Gson gson = null;

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("setupAndStartRecording")) {
      String apiKey = call.argument("key");
      int fps = call.argument("fps");
      Smartlook.setupAndStartRecording(apiKey, true, fps);
    } else if (call.method.equals("setup")) {
      String apiKey = call.argument("key");
      int fps = call.argument("fps");
      Smartlook.setup(apiKey, true, fps);
    } else if (call.method.equals("isRecording")) {
      result.success(Smartlook.isRecording());
    } else if (call.method.equals("startFullscreenSensitiveMode")) {
      Smartlook.startFullscreenSensitiveMode();
    } else if (call.method.equals("stopFullscreenSensitiveMode")) {
      Smartlook.stopFullscreenSensitiveMode();
    } else if (call.method.equals("isFullscreenSensitiveModeActive")) {
      result.success(Smartlook.isFullscreenSensitiveModeActive());
    } else if (call.method.equals("setReferrer")) {
      String referrer = call.argument("referrer");
      String source = call.argument("source");
      Smartlook.setReferrer(referrer, source);
    } else if (call.method.equals("trackNavigationEvent")) {
      String navKey = call.argument("key");
      int direction = call.argument("type");
      String viewDirection = "start";
      if (direction == 0) viewDirection = "start"; else viewDirection = "stop";
      Smartlook.trackNavigationEvent(navKey, "activity", viewDirection);
    } else if (call.method.equals("getDashboardSessionUrl")) {
      result.success(Smartlook.getDashboardSessionUrl());
    } else if (call.method.equals("startRecording")) {
      Smartlook.startRecording();
    } else if (call.method.equals("stopRecording")) {
      Smartlook.stopRecording();
    } else if (call.method.equals("flush")) {
      //Smartlook.flush();
    } else if (call.method.equals("removeAllGlobalEventProperties")) {
      Smartlook.removeAllGlobalEventProperties();
    } else if (call.method.equals("removeGlobalEventProperty")) {
      String propertyKey = call.argument("key");
      Smartlook.removeGlobalEventProperty(propertyKey);
    } else if (call.method.equals("setGlobalEventProperties")) {
      HashMap globalImmutableProperties = call.argument("map");
      boolean immutable = call.argument("immutable");

      if (globalImmutableProperties != null) {
        if (gson == null) {
          gson = new Gson();
        }
        Type gsonType = new TypeToken<HashMap>(){}.getType();
        String gsonString = gson.toJson(globalImmutableProperties,gsonType);
        Smartlook.setGlobalEventProperties(gsonString, immutable);
      }
    } else if (call.method.equals("startTimedCustomEvent")) {
      String eventKey = call.argument("key");
      Smartlook.startTimedCustomEvent(eventKey);
    } else if (call.method.equals("enableCrashlytics")) {
      boolean enabled = call.argument("enabled");
      Smartlook.enableCrashlytics(enabled);
    } else if (call.method.equals("enableWebviewRecording")) {
      boolean enabled = call.argument("enabled");
      if (enabled) {
        Smartlook.unregisterBlacklistedClass(WebView.class);
      } else {
        Smartlook.registerBlacklistedClass(WebView.class);
      }
    } else if (call.method.equals("trackCustomEvent")) {
      String eventKey = call.argument("key");
      HashMap eventMap = call.argument("map");

      if (eventKey != null && eventMap != null) {
        if (gson == null) {
          gson = new Gson();
        }
        Type gsonType = new TypeToken<HashMap>(){}.getType();
        String gsonString = gson.toJson(eventMap,gsonType);
        Smartlook.trackCustomEvent(eventKey, gsonString);
      } else if (eventKey != null) {
        Smartlook.trackCustomEvent(eventKey);
      }
    } else if (call.method.equals("setUserIdentifier")) {
      String identifyKey = call.argument("key");
      HashMap identifyMap = call.argument("map");

      if (identifyKey != null && identifyMap != null) {
        if (gson == null) {
          gson = new Gson();
        }
        Type gsonType = new TypeToken<HashMap>(){}.getType();
        String gsonString = gson.toJson(identifyMap,gsonType);
        Smartlook.setUserIdentifier(identifyKey, gsonString);
      } else if (identifyKey != null) {
        Smartlook.setUserIdentifier(identifyKey);
      }
    } else {
            result.notImplemented();
    }
  }
}
