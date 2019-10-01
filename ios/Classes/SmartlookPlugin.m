#import "SmartlookPlugin.h"
#import <Smartlook/Smartlook.h>

#ifdef DEBUG
//#   define DLog(fmt, ...) NSLog((@"👀Smartlook: [Line %d] " fmt), __LINE__, ##__VA_ARGS__);
#   define DLog(...)
#else
#   define DLog(...)
#endif

#define IS_STRING_WITH_VALUE(string) ([string isKindOfClass:[NSString class]] && string > 0)
#define BOOL_VALUE_OR_DEFAULT(value,dft) ([value respondsToSelector:@selector(boolValue)] ? [value boolValue] : dft)
#define INT_VALUE_OR_DEFAULT(value,dft) ([value respondsToSelector:@selector(integerValue)] ? [value integerValue] : dft)

@implementation SmartlookPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"smartlook"
            binaryMessenger:[registrar messenger]];
  SmartlookPlugin* instance = [[SmartlookPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _internal_handleMethodCall:call result:result];
    });
}

- (void)_internal_handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
	
    DLog(@"Smartlook: flutter log:\nmethod: %@,\nstart args: %@", call.method, [call.arguments description]);

    if ([@"getPlatformVersion" isEqualToString:call.method]) {
		result([@"iOS lul" stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
        return;
    };

    // MARK: - API 1.1.0
    
    // MARK: Setup
    if ([@"setup" isEqualToString:call.method] || [@"setupAndStartRecording" isEqualToString:call.method]) {
        DLog(@"-> %@", call.method);
        NSString *key = call.arguments[@"key"];
        if (IS_STRING_WITH_VALUE(key)) {
            NSMutableDictionary *options = [NSMutableDictionary new];
            options[@"_forceRegularFramerate"] = @YES;
            NSNumber *fps = call.arguments[@"fps"];
            if ([fps isKindOfClass:[NSNumber class]]) {
                options[@"fps"] = fps;
            }
            [Smartlook setupWithKey:key options:options];
            if ([@"setupAndStartRecording" isEqualToString:call.method]) {
                [Smartlook startRecording];
            }
            [Smartlook setSessionPropertyValue:@"flutter" forName:@"sdk_build_flavor" withOptions:SLPropertyOptionImmutable];
        } else {
            DLog(@"Smartlook API key missing in %@ call", call.method);
        }
        return;
    }
    
    if ([@"setUserIdentifier" isEqualToString:call.method]) {
        DLog(@"-> %@", call.method);
        NSString *userIdentifier = call.arguments[@"key"];
        if (IS_STRING_WITH_VALUE(userIdentifier)) {
            [Smartlook setUserIdentifier:userIdentifier];
        }
        NSDictionary *map = call.arguments[@"map"];
        if ([map respondsToSelector:@selector(enumerateKeysAndObjectsUsingBlock:)]) {
            [map enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull name, id _Nonnull value, BOOL * _Nonnull stop) {
                [Smartlook setSessionPropertyValue:value forName:name];
            }];
        }
        return;
    }
    
    // MARK: Recording
    if ([@"startRecording" isEqualToString:call.method]) {
        DLog(@"-> %@", call.method);
        [Smartlook startRecording];
        return;
    }
    if ([@"stopRecording" isEqualToString:call.method]) {
        DLog(@"-> %@", call.method);
        [Smartlook startRecording];
        return;
    }
    if ([@"isRecording" isEqualToString:call.method]) {
        DLog(@"-> %@", call.method);
        result([NSNumber numberWithBool:[Smartlook isRecording]]);
        return;
    }
    
    
    // MARK: Custom Events
    if ([@"startTimedCustomEvent" isEqualToString:call.method]) {
        DLog(@"-> %@", call.method);
        NSString *key = call.arguments[@"key"];
        if (IS_STRING_WITH_VALUE(key)) {
            [Smartlook startTimedCustomEventWithName:key props:@{}];
        }
        return;
    }
    if ([@"trackCustomEvent" isEqualToString:call.method]) {
        DLog(@"-> %@", call.method);
        NSString *key = call.arguments[@"key"];
        if (IS_STRING_WITH_VALUE(key)) {
            NSDictionary *map = [call.arguments[@"map"] respondsToSelector:@selector(enumerateKeysAndObjectsUsingBlock:)] ? call.arguments[@"map"] : @{};
            [Smartlook trackCustomEventWithName:key props:map];
        }
        return;
    }

    if ([@"trackNavigationEvent" isEqualToString:call.method]) {
        DLog(@"-> %@", call.method);
        NSString *key = call.arguments[@"key"];
        if (IS_STRING_WITH_VALUE(key)) {
            SLNavigationType navType = INT_VALUE_OR_DEFAULT(call.arguments[@"type"], 0) == 1 ? SLNavigationTypeExit : SLNavigationTypeEnter;
            [Smartlook tractNavigationEventWithControllerId:key type:navType];
        }
        return;
    }

    
    // MARK: Sensitive
    if ([@"startFullscreenSensitiveMode" isEqualToString:call.method]) {
        DLog(@"-> %@", call.method);
        [Smartlook beginFullscreenSensitiveMode];
        return;
    }
    if ([@"stopFullscreenSensitiveMode" isEqualToString:call.method]) {
        DLog(@"-> %@", call.method);
        [Smartlook endFullscreenSensitiveMode];
        return;
    }
    if ([@"isFullscreenSensitiveModeActive" isEqualToString:call.method]) {
        DLog(@"-> %@", call.method);
        result([NSNumber numberWithBool:[Smartlook isFullscreenSensitiveModeActive]]);
        return;
    }
    if ([@"enableWebviewRecording" isEqualToString:call.method]) {
        DLog(@"-> %@", call.method);
        BOOL enabled = BOOL_VALUE_OR_DEFAULT(call.arguments[@"enabled"], 0);
        if (enabled) {
            [Smartlook registerWhitelistedObject:[UIWebView class]];
            [Smartlook registerWhitelistedObject:[WKWebView class]];
        } else {
            [Smartlook registerBlacklistedObject:[UIWebView class]];
            [Smartlook registerBlacklistedObject:[WKWebView class]];
        }
        return;
    }
    
    
    // MARK: Global Properties
    if ([@"setGlobalEventProperty" isEqualToString:call.method]) {
        DLog(@"-> %@", call.method);
        NSString *name = call.arguments[@"key"];
        NSString *value = call.arguments[@"value"];
        if (!IS_STRING_WITH_VALUE(name) || !IS_STRING_WITH_VALUE(value)) {
            return;
        }
        SLPropertyOption option = BOOL_VALUE_OR_DEFAULT(call.arguments[@"immutable"], NO) ? SLPropertyOptionImmutable : SLPropertyOptionDefaults;
        [Smartlook setGlobalEventPropertyValue:value forName:name withOptions:option];
        return;
    }
    if ([@"setGlobalEventProperties" isEqualToString:call.method]) {
        DLog(@"-> %@", call.method);
        NSDictionary *map = call.arguments[@"map"];
        if ([map respondsToSelector:@selector(enumerateKeysAndObjectsUsingBlock:)]) {
            SLPropertyOption option = BOOL_VALUE_OR_DEFAULT(call.arguments[@"immutable"], NO) ? SLPropertyOptionImmutable : SLPropertyOptionDefaults;
            [map enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull name, id _Nonnull value, BOOL * _Nonnull stop) {
               [Smartlook setGlobalEventPropertyValue:value forName:name withOptions:option];
            }];
        };
        return;
    }
    if ([@"removeGlobalEventProperty" isEqualToString:call.method]) {
        DLog(@"-> %@", call.method);
        NSString *key = call.arguments[@"key"];
        if (IS_STRING_WITH_VALUE(key)) {
            [Smartlook removeGlobalEventPropertyForName:key];
        }
        return;
    }
    if ([@"removeAllGlobalEventProperties" isEqualToString:call.method]) {
        DLog(@"-> %@", call.method);
        [Smartlook clearGlobalEventProperties];
        return;
    }
    
    
    // MARK: Others
    if ([@"getDashboardSessionUrl" isEqualToString:call.method]) {
        DLog(@"-> %@", call.method);
        result([Smartlook getDashboardSessionURL].absoluteString);
        return;
    }
    
    // MARK: Not available on iOS
    if ([@"setReferrer" isEqualToString:call.method]) {
        // not available on iOS
        DLog(@"-> %@", call.method);
        return;
    }
    if ([@"flush" isEqualToString:call.method]) {
        // not available on iOS
        DLog(@"-> %@", call.method);
        return;
    }
    if ([@"enableCrashlytics" isEqualToString:call.method]) {
        // not available on iOS
        DLog(@"-> %@", call.method);
        return;
    }


    
//
//
//
//
    //MARK:- Legacy code (to be removed later)
    
    // Start
    if ([@"start" isEqualToString:call.method]) {
        DLog(@"-> %@", call.method);
        DLog(@"flutter log: start args: %@, class: %@", [call.arguments description], [call.arguments class]);
        NSArray* args = call.arguments;
        if (args && args.count > 0) {
            NSString* key = [args objectAtIndex:0];
            if (key && [key isKindOfClass:[NSString class]] && key.length > 0) {
                [Smartlook setupWithKey:key options:@{ @"_forceRegularFramerate" : @YES}];
                [Smartlook startRecording];
            } else {
                DLog(@"Smartlook - missing API key");
            }
        } else {
            DLog(@"Smartlook - missing API key");
        }
        return;
    }
    if ([@"recordEvent" isEqualToString:call.method]) {
        DLog(@"-> %@", call.method);
        NSArray* args = call.arguments;
        if (args && args.count > 0) {
            NSString* eventName = [args objectAtIndex:0];
            
            if (eventName && [eventName isKindOfClass:[NSString class]] && eventName.length > 0) {
                [Smartlook recordCustomEventWithEventName:eventName propertiesDictionary:nil];
            } else {
                DLog(@"Smartlook - missing event name");
            }
        } else {
            DLog(@"Smartlook - missing event name");
        }
        return;
    }
    
    // MARK: Default
    DLog(@"Smartlook: method not found -> %@", call.method);
    result(FlutterMethodNotImplemented);
        
}

@end
