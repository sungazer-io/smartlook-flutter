import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:smartlook/smartlook.dart';
import 'dart:collection';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  String _timeString;

  @override
  void initState() {
    super.initState();

    initPlatformState();
    
    _timeString = "${DateTime.now().hour} : ${DateTime.now().minute} :${DateTime.now().second}";
    Timer.periodic(Duration(seconds:1), (Timer t)=>_getCurrentTime());
    
    Smartlook.setupAndStartRecording('API_KEY');

    // calling all functions to make sure nothing crashes
    Smartlook.setUserIdentifier('FlutterLul', { "flutter-usr-prop" : "valueX"});
    Smartlook.setGlobalEventProperty("key_", "value_", true);
    Smartlook.setGlobalEventProperties( { "A" : "B"}, false);
    Smartlook.removeGlobalEventProperty("A");
    Smartlook.removeAllGlobalEventProperties();
    Smartlook.setGlobalEventProperty("flutter_global", "value_", true);
    Smartlook.enableWebviewRecording(true);
    Smartlook.enableWebviewRecording(false);
    Smartlook.enableCrashlytics(true);
    Smartlook.setReferrer("referer", "source");
    Smartlook.getDashboardSessionUrl();
  }

  void _getCurrentTime()  {
    setState(() {
    _timeString = "${DateTime.now().hour} : ${DateTime.now().minute} :${DateTime.now().second}";
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await Smartlook.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          //child: Text('Running on: $_platformVersion\n'),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[

            Image.asset("lib/Smartlook.png"),

            Text(_timeString, style: TextStyle(fontSize: 18),),

            const SizedBox(height: 15),
            RaisedButton(
              onPressed: () {
                Smartlook.stopRecording();
              },
              child: Text('Stop recording'),
            ),
            RaisedButton(
              onPressed: () {
                Smartlook.startRecording();
              },
              child: Text('Start recording'),
            ),

            const SizedBox(height: 15),
            RaisedButton(
              onPressed: () {
                Smartlook.startTimedCustomEvent("timed-event");
              },
              child: Text('Start timed event'),
            ),
            RaisedButton(
              onPressed: () {
                Smartlook.trackCustomEvent("timed-event", { "property1" : "value1" });
              },
              child: Text('Track event'),
            ),

            const SizedBox(height: 15),
            RaisedButton(
              onPressed: () {
                Smartlook.startFullscreenSensitiveMode();
              },
              child: Text('Start Sensitive Mode'),
            ),
            RaisedButton(
              onPressed: () {
                Smartlook.stopFullscreenSensitiveMode();
              },
              child: Text('Stop Sensitive Mode'),
            ),

            const SizedBox(height: 15),
            RaisedButton(
              onPressed: () {
                Smartlook.trackNavigationEvent("nav-event", SmartlookNavigationEventType.enter);
              },
              child: Text('Enter Navigation Event'),
            ),
            RaisedButton(
              onPressed: () {
                Smartlook.trackNavigationEvent("nav-event", SmartlookNavigationEventType.exit);
              },
              child: Text('Exit Navigation Event'),
            ),
              
            ],
          ),
        ),      
      ),
    );
  }
}
