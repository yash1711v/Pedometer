// import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:steptracking/appsflyer/appsflyerMethod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../SharedPrefrences/SharedPref.dart';
import '../main.dart';
import 'HomePage.dart';
import 'IntroScreen.dart';
import 'SignUpScreen.dart';
// import 'package:toast/toast.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final auth = FirebaseAuth.instance;
  bool islogin = false;
  bool isOnboarding = false;
  bool isGuest=false;
  // FirebaseAnalytics analytics =FirebaseAnalytics.instance;
  checkifLoginAndIntro() async {
    auth.authStateChanges().listen((User? user) {
      if (user != null && mounted) {
        setState(() {
          islogin = true;
        });
      }
    });
    bool _isonboarding = await SharedPref().getisOnboardingt();
    bool _isguest = await SharedPref().getisguest();
    setState(() {
      isOnboarding = _isonboarding ;
      isGuest=_isguest;
    });
  }

//   Future<void> initPlatformState() async {
// // Configure BackgroundFetch.
//     var status = await BackgroundFetch.configure(BackgroundFetchConfig(
//       minimumFetchInterval: 15,
//       forceAlarmManager: false,
//       stopOnTerminate: false,
//       startOnBoot: true,
//       enableHeadless: true,
//       requiresBatteryNotLow: false,
//       requiresCharging: false,
//       requiresStorageNotLow: false,
//       requiresDeviceIdle: false,
//       requiredNetworkType: NetworkType.NONE,
//     ), _onBackgroundFetch, _onBackgroundFetchTimeout);
//     print("BackgroundFetch] configure success: $status");
// // Schedule backgroundfetch for the 1st time it will execute with 1000ms delay.
// // where device must be powered (and delay will be throttled by the OS).
//     BackgroundFetch.scheduleTask(
//         TaskConfig(
//         taskId: "6",
//         delay: 1000,
//         periodic: true,
//         stopOnTerminate: false,
//         enableHeadless: true,
//         startOnBoot: true
//     ));
//   }
//   void _onBackgroundFetchTimeout(String taskId) {
//     print("[BackgroundFetch] TIMEOUT: $taskId");
//     BackgroundFetch.finish(taskId);
//   }

  void _onBackgroundFetch(String taskId) async {
    if(taskId == "6") {
      print("[BackgroundFetch] Event received");
      scheduleNotification();
//TODO: perform your task like : call the API’s, call the DB and local notification.
    }
  }
  void scheduleNotification() async {
    flutterLocalNotificationsPlugin.cancelAll();
    final tz.Location local = tz.getLocation('Asia/Kolkata');
    final DateTime now = tz.TZDateTime.now(local);
    final DateTime nextInstance = DateTime(now.year, now.month, now.day, 8, 0); // 8:00 AM
    final DateTime nextInstance2 = DateTime(now.year, now.month, now.day, 20, 0);
    final DateTime nextInstance3 = DateTime(now.year, now.month, now.day, 12, 0); // 8:00 PM
    final DateTime nextInstance4 = DateTime(now.year, now.month, now.day, 16, 0);// 8:00 PM
    print("location"+tz.local.toString());
    final tz.TZDateTime scheduledDateTZ = nextInstance.isBefore(now)
        ? tz.TZDateTime.from(nextInstance.add(Duration(days: 1)), local)  // If 8:00 AM has already passed today, schedule for tomorrow
        : tz.TZDateTime.from(nextInstance, local);  // Otherwise, schedule for today

    final tz.TZDateTime scheduledDateTZ2 = nextInstance2.isBefore(now)
        ? tz.TZDateTime.from(nextInstance2.add(Duration(days: 1)), local)  // If 8:00 AM has already passed today, schedule for tomorrow
        : tz.TZDateTime.from(nextInstance2, local); // Otherwise, schedule for today

    final tz.TZDateTime scheduledDateTZ3 = nextInstance3.isBefore(now)
        ? tz.TZDateTime.from(nextInstance3.add(Duration(days: 1)), local)  // If 8:00 AM has already passed today, schedule for tomorrow
        : tz.TZDateTime.from(nextInstance3, local);  // Otherwise, schedule for today

    final tz.TZDateTime scheduledDateTZ4 = nextInstance4.isBefore(now)
        ? tz.TZDateTime.from(nextInstance4.add(Duration(days: 1)), local)  // If 8:00 AM has already passed today, schedule for tomorrow
        : tz.TZDateTime.from(nextInstance4, local);


    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'Step Tracker', 'Step Tracker',
        importance: Importance.max,
        color: Colors.black,
        icon: "small_logo",
        largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
        priority: Priority.max,
        showWhen: true
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Morning walk reminder',
        'Good morning! Start your day with a refreshing walk and boost your energy.',
        scheduledDateTZ,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    ).then((value) { print(scheduledDateTZ);


    });


    await flutterLocalNotificationsPlugin.zonedSchedule(
        5,
        'Daily goal check',
        'Have you reached your daily step goal? A little more effort can make it happen!',
        scheduledDateTZ2,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    ).then((value) { print(scheduledDateTZ2);});

    await flutterLocalNotificationsPlugin.zonedSchedule(
      6,
      'Steps Update',
      'Take the extra step towards your goal.Every step counts!',
      scheduledDateTZ3,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    ).then((value) { print(scheduledDateTZ3);});

    await flutterLocalNotificationsPlugin.zonedSchedule(
      7,
      'Nearly There',
      "Keep it up! You're so close to reachingtoday's step target!",
      scheduledDateTZ4,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    ).then((value) { print(scheduledDateTZ4);});

  }


  void requestExactAlarmPermission() async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.manageExternalStorage,
      ].request();
      print(statuses[Permission.manageExternalStorage]);
    }
  }
  void initState() {
    super.initState();
    // initPlatformState();
    requestExactAlarmPermission();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    scheduleNotification();
    final Map<String, String> values = {
      "time_stamp": DateTime.timestamp().toString(),
      "time_zone": DateTime.timestamp().timeZoneName,
      "package_name":"com.pedometer.steptracker",
    };

    afLogEvent(appsflyerSdk, "application_opened",values);
    // analytics.setAnalyticsCollectionEnabled(true);
  checkifLoginAndIntro();
  Future.delayed(
      const Duration(seconds: 3),
      () async => {
      // await FirebaseAnalytics.instance
      //     .logBeginCheckout(
      // value: 10.0,
      // currency: 'USD',
      // items: [
      // AnalyticsEventItem(
      // itemName: 'Socks',
      // itemId: 'xjw73ndnw',
      // price: 10.0      ),
      // ],
      // coupon: '10PERCENTOFF'
      // ),
        if( isOnboarding ){
      if(islogin || isGuest)
            {
              Get.to(() =>  HomePage(),
                  duration: const Duration(
                      milliseconds:
                          350),)
            } //duration of transitions, default 1 sec
                  // transition: Transition.fade)
              else {
              Get.to(() =>  SignUpScreen(),
                  duration: const Duration(
                      milliseconds:
                      500), //duration of transitions, default 1 sec
                  // transition: Transition.fade
              )
             }}
        else{
            Get.to(() =>  IntroScreen(),
                duration: const Duration(
                    milliseconds:
                        350), //duration of transitions, default 1 sec
                // transition: Transition.fade
            )
              }

          });

  }


  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Padding(

        padding: EdgeInsets.symmetric(horizontal: 67.w, vertical: 300.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image(
                image: AssetImage('lib/assests/Images/SplashScreen.png'),),
            )
          ],
        ),
      ),
    );
  }
}
