import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/foundation.dart';

AppsflyerSdk initiateAppsflyer(){
  AppsFlyerOptions appsFlyerOptions = AppsFlyerOptions(
    afDevKey: "vEbzV4hdsUG5GpQYLeXsHS",
    appId: "com.pedometer.steptracker",
    showDebug: false,
    timeToWaitForATTUserAuthorization: 50,
    disableAdvertisingIdentifier: false,
  ); // Optional field

  AppsflyerSdk appsflyerSdk = AppsflyerSdk(appsFlyerOptions);

  appsflyerSdk.initSdk(
    registerConversionDataCallback: true,
    registerOnAppOpenAttributionCallback: true,
    registerOnDeepLinkingCallback: true,
  );

  return appsflyerSdk;
}

Future<bool?> afLogEvent(AppsflyerSdk appsflyerSdk, String eventName, Map? eventValues) async {
  bool? result;
  try {
    result = await appsflyerSdk.logEvent(eventName, eventValues);
  } on Exception catch (e) {
    if (kDebugMode) {
      print(e.toString());
    }
  }
  if (kDebugMode) {
    print("Result logEvent: $result");
  }
  return result;
}