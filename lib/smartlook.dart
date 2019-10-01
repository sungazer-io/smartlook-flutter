import 'dart:async';
import 'package:flutter/services.dart';

enum SmartlookNavigationEventType { enter, exit }

class Smartlook {
	static const MethodChannel _channel =
		const MethodChannel('smartlook');

	static Future<String> get platformVersion async {
		final String version = await _channel.invokeMethod('getPlatformVersion');
    	return version;
	}

// SETUP
	static void setup(String key, [int fps = 2]) async{
    await _channel. invokeMethod('setup',{"key":key, "fps":fps});
  }

	static Future<void> setupAndStartRecording(String key, [int fps = 2]) async{
    await _channel. invokeMethod('setupAndStartRecording',{"key":key, "fps":fps});
  }

  static Future<void> setUserIdentifier(String key, [Object map = null]) async{
    await _channel. invokeMethod('setUserIdentifier',{"key":key, "map":map});
  }

// START & STOP
  static Future<void> startRecording() async{
    await _channel. invokeMethod('startRecording');
  }

  static Future<void> stopRecording() async{
    await _channel. invokeMethod('stopRecording');
  }

  static Future<bool> isRecording() async{
    bool isRecording = await _channel.invokeMethod('isRecording');
    return isRecording;
  }

// EVENTS
  static Future<void> startTimedCustomEvent(String key) async{
    await _channel. invokeMethod('startTimedCustomEvent',{"key":key});
  }

  static Future<void> trackCustomEvent(String key, [Object map = null]) async{
  	await _channel. invokeMethod('trackCustomEvent',{"key":key, "map":map});
  }
 
  static Future<void> trackNavigationEvent(String key, SmartlookNavigationEventType type) async {
    await _channel. invokeListMethod("trackNavigationEvent", { "key": key, "type" : type.index } );
  }

// SENSITIVE 
  static Future<void> startFullscreenSensitiveMode() async{
    await _channel. invokeMethod('startFullscreenSensitiveMode');
  }

  static Future<void> stopFullscreenSensitiveMode() async{
    await _channel. invokeMethod('stopFullscreenSensitiveMode');
  }

  static Future<bool> isFullscreenSensitiveModeActive() async{
    bool isFullscreenSesitiveMode = await _channel. invokeMethod('isFullscreenSensitiveModeActive');
    return isFullscreenSesitiveMode;
  }

  static Future<void> enableWebviewRecording(bool enabled) async{
  	await _channel. invokeMethod('enableWebviewRecording',{"enabled":enabled});
  }

// GLOBAL EVENT PROPERTIES
  static Future<void> setGlobalEventProperty(String key, String value, bool immutable) async{
    await _channel. invokeMethod('setGlobalEventProperty',{ "key":key, "value": value, "immutable":immutable});
  }

  static Future<void> setGlobalEventProperties(Object map, bool immutable) async{
    await _channel. invokeMethod('setGlobalEventProperties',{"map":map, "immutable":immutable});
  }

  static Future<void> removeGlobalEventProperty(String key) async{
  	await _channel. invokeMethod('removeGlobalEventProperty',{"key":key});
  }

  static Future<void> removeAllGlobalEventProperties() async{
  	await _channel. invokeMethod('removeAllGlobalEventProperties');
  }

// OTHERS
	static Future<void> setReferrer(String referrer, String source) async{
   	await _channel. invokeMethod('setReferrer',{"referrer":referrer, "source":source});
	}

	static Future<String> getDashboardSessionUrl() async{
   	String url = await _channel.invokeMethod('getDashboardSessionUrl');
  	return url;
	}

  static Future<void> enableCrashlytics(bool enabled) async{
    await _channel. invokeMethod('enableCrashlytics',{"enabled":enabled});
  }

}
