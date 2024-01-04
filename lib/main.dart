import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steptracking/presentations/Back_Service.dart';
import 'package:steptracking/presentations/HomePage.dart';
import 'package:steptracking/presentations/NotificationServices.dart';
import 'SharedPrefrences/SharedPref.dart';
import 'appsflyer/appsflyerMethod.dart';
import 'firebase_options.dart';
import 'presentations/SplashScreen.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
// import 'package:background_fetch/background_fetch.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();


late AppsflyerSdk appsflyerSdk;

// import 'package:firebase_core/firebase_core.dart';
Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  appsflyerSdk = initiateAppsflyer();
  IsolateNameServer.registerPortWithName(
    port.sendPort,
    isolateName,
  );
  prefs = await SharedPreferences.getInstance();
  if (!prefs!.containsKey(countKey)) {
    await prefs!.setInt(countKey, 0);
  }
  NotificationServices().initializeNotification();
  tz.initializeTimeZones();
  final String timeZoneName = 'Asia/Kolkata';
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
          'small_logo'); // Use your own app icon here.
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // await  initializeService();
  //  await Permission.locationAlways.request();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
// Requires {stopOnTerminate: false, enableHeadless: true}
//   BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

      await AndroidAlarmManager.initialize();
  final int helloAlarmID = 200;
  await AndroidAlarmManager.periodic(
      const Duration(seconds: 3), helloAlarmID, printHello);


  runApp(const MyApp());
}
@pragma('vm:entry-point')
Future<void> printHello() async {
  bool check=await SharedPref().getischecking();
  final isServiceRunning = await FlutterBackgroundService().isRunning();
  bool start= await SharedPref().getisStart();
  if (!isServiceRunning && start) {
    print('Background service is not running. Restarting...');
    await  initializeService();
  }else{
    print('Background service is running....');
  }
  print("Helllooo From Step Tracker top1");
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

  flutterLocalNotificationsPlugin.cancelAll();
  final tz.Location local = tz.getLocation('Asia/Kolkata');
  final DateTime now = tz.TZDateTime.now(local);
  final DateTime nextInstance = DateTime(
      now.year, now.month, now.day, 8, 0); // 8:00 AM
  final DateTime nextInstance2 = DateTime(
      now.year, now.month, now.day, 20, 0); // 8:00 PM
  final DateTime nextInstance3 = DateTime(
      now.year, now.month, now.day, 12, 0); // 8:00 PM
  final DateTime nextInstance4 = DateTime(
      now.year, now.month, now.day, 16, 0); // 8:00 PM
  print("location" + tz.local.toString());
  final tz.TZDateTime scheduledDateTZ = nextInstance.isBefore(now)
      ? tz.TZDateTime.from(nextInstance.add(Duration(days: 1)),
      local) // If 8:00 AM has already passed today, schedule for tomorrow
      : tz.TZDateTime.from(
      nextInstance, local); // Otherwise, schedule for today

  final tz.TZDateTime scheduledDateTZ2 = nextInstance2.isBefore(now)
      ? tz.TZDateTime.from(nextInstance2.add(Duration(days: 1)),
      local) // If 8:00 AM has already passed today, schedule for tomorrow
      : tz.TZDateTime.from(
      nextInstance2, local); // Otherwise, schedule for today

  final tz.TZDateTime scheduledDateTZ3 = nextInstance3.isBefore(now)
      ? tz.TZDateTime.from(nextInstance3.add(Duration(days: 1)),
      local) // If 8:00 AM has already passed today, schedule for tomorrow
      : tz.TZDateTime.from(
      nextInstance3, local); // Otherwise, schedule for today

  final tz.TZDateTime scheduledDateTZ4 = nextInstance4.isBefore(now)
      ? tz.TZDateTime.from(nextInstance4.add(Duration(days: 1)),
      local) // If 8:00 AM has already passed today, schedule for tomorrow
      : tz.TZDateTime.from(
      nextInstance4, local); // Otherwise, schedule for today


  const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android:
      AndroidNotificationDetails(
        'Step Tracking',
        'Step Tracker',
        color: Colors.black,
        enableLights: true,
        enableVibration: true,
        playSound: true,
        icon: 'small_logo',
        colorized: true,
        largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
        channelDescription: "This is Notification is to give  you alert to start and check your daily steps ",
        importance: Importance.max,
      )
  );

  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Morning walk reminder',
    'Good morning! Start your day with a refreshing walk and boost your energy.',
    scheduledDateTZ,
    platformChannelSpecifics,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
        .absoluteTime,
    matchDateTimeComponents: DateTimeComponents.dateAndTime,
  ).then((value) {
    print(scheduledDateTZ);
  });

  await flutterLocalNotificationsPlugin.zonedSchedule(
    5,
    'Daily goal check',
    'Have you reached your daily step goal? A little more effort can make it happen!',
    scheduledDateTZ2,
    platformChannelSpecifics,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
        .absoluteTime,
    matchDateTimeComponents: DateTimeComponents.dateAndTime,
  ).then((value) {
    print(scheduledDateTZ2);
  });

  await flutterLocalNotificationsPlugin.zonedSchedule(
    6,
    'Steps Update',
    'Take the extra step towards your goal.Every step counts!',
    scheduledDateTZ3,
    platformChannelSpecifics,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
        .absoluteTime,
    matchDateTimeComponents: DateTimeComponents.dateAndTime,
  ).then((value) {
    print(scheduledDateTZ3);
  });
  await flutterLocalNotificationsPlugin.zonedSchedule(
    7,
    'Nearly There',
    "Keep it up! You're so close to reachingtoday's step target!",
    scheduledDateTZ4,
    platformChannelSpecifics,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
        .absoluteTime,
    matchDateTimeComponents: DateTimeComponents.dateAndTime,
  ).then((value) {
    print(scheduledDateTZ4);
  });

  // if(check){
  //   print("stoping background service");
  //   final service = FlutterBackgroundService();
  //   service.invoke('stopService');
  // }else{
  //   print("background service runing");
  // }
  print("Helllooo From Step Tracker middle");

}
// }
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(428, 926),
      builder: (_, child) => GetMaterialApp(
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)
        ],
        title: "Step Tracker",
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF2D2D2D),
        ),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SplashScreen(),
        ),
      ),
    );
  }
}
