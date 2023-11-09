import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
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
import 'firebase_options.dart';
import 'presentations/SplashScreen.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
// import 'package:background_fetch/background_fetch.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// import 'package:firebase_core/firebase_core.dart';
Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
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
      const Duration(seconds: 1), helloAlarmID, printHello);
  await initializeService();
  runApp(const MyApp());
}
@pragma('vm:entry-point')
Future<void> printHello() async {
  print("Helllooo From Step Tracker top1");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  StreamSubscription<StepCount>? _subscription;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusSubscription;
  print("Helllooo From Step Tracker top2");
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

 int?  _lastResetDay = prefs.getInt('lastResetDay')??DateTime.now().day;
  print("--------------------------->last reset Day"+_lastResetDay.toString());
  print("--------------------------->Today Day"+DateTime.now().day.toString());
  if (_lastResetDay != DateTime.now().day){
    print("--------------------------->in no equals to of last reset day");
      SharedPref().setTodaysSteps(0);
      SharedPref().saveDuration(Duration.zero);
      // newday=true;
    print("in else condition");

  }else{
   print("in else condition");
  }
  _subscription = Pedometer.stepCountStream.listen(
          (StepCount event) async {
            if(event.steps==0){
              SharedPref().setifSwitchoffThenvalue( await SharedPref().getTodaysSteps());
            }
            print("in Strem"+event.steps.toString());
              if(_lastResetDay != DateTime.now().day){
                print("in Streamn");
                SharedPref().setextraSteps(0);
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setInt('lastResetDay', DateTime.now().day);
                await SharedPref().setLastDaySteps(event.steps);
                SharedPref().setTodaysSteps(0);
                SharedPref().saveDuration(Duration.zero);
                print("in stream2");
              }

          }
  );



  print("out stream2");






  flutterLocalNotificationsPlugin.cancelAll();
  final tz.Location local = tz.getLocation('Asia/Kolkata');
  final DateTime now = tz.TZDateTime.now(local);
  final DateTime nextInstance = DateTime(now.year, now.month, now.day, 8, 0); // 8:00 AM
  final DateTime nextInstance2 = DateTime(now.year, now.month, now.day, 20, 0); // 8:00 PM
  final DateTime nextInstance3 = DateTime(now.year, now.month, now.day, 12, 0); // 8:00 PM
  final DateTime nextInstance4 = DateTime(now.year, now.month, now.day, 16, 0); // 8:00 PM
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
      : tz.TZDateTime.from(nextInstance4, local);  // Otherwise, schedule for today


  const NotificationDetails platformChannelSpecifics = NotificationDetails(android:
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


  print("Helllooo From Step Tracker middle");


  //
  // double currentSpeed=0;
  // bool IntroDone=await SharedPref().getIntroScreenInfo();
  // bool isstart=await SharedPref().getisStart();
  // int TodaysSteps=await SharedPref().getTodaysSteps()??0;
  // bool isguest=await SharedPref().getisguest();
  // String _uid = await SharedPref().getUid();
  // int target=await SharedPref().getStepsTarget();
  // double walkingSpeedThreshold = 14;
  // int StepsCompleted = 0;
  // StreamSubscription<StepCount>? _subscription;
  // StreamSubscription<PedestrianStatus>? _pedestrianStatusSubscription;
  // bool newday=false;
  // print("Target From shared Pref-------------------------->"+target.toString());
  // // DateTime StartTi=await SharedPref().getStartTime()??DateTime.now();
  // Duration? Activity = await SharedPref().getSavedDuration();
  // Duration totalDuration = Duration.zero;
  //
  // bool isMiles=await SharedPref().getisMiles();
  // print("intro done: "+IntroDone.toString());
  // print("Guest: before setting"+isguest.toString());
  // // print(StartTi);
  // int lastDayStep=await SharedPref().getLastDaySteps();
  // int extra=await SharedPref().getextraSteps()??0;
  // int? _lastResetDay = 0;
  // int newsteps=0;
  // Map<String, int> stepCounts = {};
  // print("--------------------------->getlast reset Day");
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //   _lastResetDay = prefs.getInt('lastResetDay');
  //
  // print("--------------------------->last reset Day"+_lastResetDay.toString());
  // print("--------------------------->Today Day"+DateTime.now().day.toString());
  // if (_lastResetDay != DateTime.now().day){
  //   print("--------------------------->in no equals to of last reset day");
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //     totalDuration=Duration.zero;
  //     StepsCompleted=0;
  //     SharedPref().setTodaysSteps(0);
  //     SharedPref().saveDuration(Duration.zero);
  //     newday=true;
  //   await prefs.setInt('lastResetDay', DateTime.now().day);
  //
  //
  //
  //
  // }else{
  //     newday=false;
  //
  // }
  //
  // print("startListening()");
  //   int Switchoff=0;
  //   Future<void> Switchoffmethod() async {
  //     int Switch =await SharedPref().getfSwitchoffThenvalue()??0;
  //       Switchoff=Switch;}
  //
  //      Pedometer.stepCountStream.listen(
  //             (StepCount event) async {
  //               Position position = await Geolocator.getCurrentPosition(
  //                   desiredAccuracy: LocationAccuracy.high);
  //
  //               // Calculate speed in m/s
  //               double speed = position.speed ?? 0.0;
  //
  //               // Convert speed to km/h
  //               speed *= 3.6;
  //               currentSpeed=speed;
  //               print("this Speed is In get Speed Method------------------------------------------>"+currentSpeed.toString());
  //
  //
  //
  //
  //               print("current Speed--------------------------------------------->"+currentSpeed.toString());
  //               print("Walking Threshold------------------------------------------>"+walkingSpeedThreshold.toString());
  //               if(event.steps==0){
  //                 SharedPref().setifSwitchoffThenvalue(StepsCompleted);
  //               }
  //               Future.delayed(Duration(seconds: 2),() async {
  //                 if(event.steps<StepsCompleted  && _lastResetDay  == DateTime.now().day){
  //                   print("in isSwitchoff if");
  //                   Switchoffmethod();
  //                   Future.delayed(Duration(seconds: 2),() async {
  //                     print("old Steps:----------------------------------------->"+Switchoff.toString());
  //                     print("new  steps: ------------->"+event.steps.toString());
  //                     int newSteps=Switchoff+event.steps;
  //                       newsteps=newSteps;
  //                       if(newsteps>StepsCompleted){
  //                         StepsCompleted=newsteps;
  //                         if(isguest){
  //                           SharedPref().setTodaysSteps(StepsCompleted);
  //                         }else{
  //                           DatabaseReference databaseReference = FirebaseDatabase.instance.reference(); // Replace with your user ID
  //                           String _uid = await SharedPref().getUid();
  //                           DateTime now = DateTime.now();
  //                           String formattedDate = DateFormat('yyyy-MM-dd').format(now);
  //
  //                           databaseReference
  //                               .child('users')
  //                               .child( _uid)
  //                               .child('steps')
  //                               .child(formattedDate)
  //                               .set(StepsCompleted);
  //                           SharedPref().setTodaysSteps(StepsCompleted);}
  //                       }
  //
  //                     print("newStep Variable Data------------------------------------------------------------>"+newSteps.toString());
  //                     print("old Steps:------------------------------------------------------------------------>"+ StepsCompleted.toString());
  //                   });
  //                 }
  //                 else
  //                 if(IntroDone==false){
  //                   print(" firstTimeInstalled");
  //                   await SharedPref().setLastDaySteps(event.steps);
  //                   await SharedPref().setIntroScreenInfo(true);
  //                      IntroDone=true;
  //                    lastDayStep=event.steps;
  //                     StepsCompleted=event.steps-lastDayStep;
  //                     extra=0;
  //                    isstart=true;
  //                   if(isguest){
  //                     print("first Time Called Guest");
  //                     SharedPref().setStepsTarget(target);
  //                     SharedPref().setisStart(true);
  //                   }else{
  //                     print("first Time Called login");
  //                     DatabaseReference databaseReference = FirebaseDatabase.instance.reference(); // Replace with your user ID
  //                     String _uid = await SharedPref().getUid();
  //                     DateTime now = DateTime.now();
  //                     String formattedDate = DateFormat('yyyy-MM-dd').format(now);
  //                     databaseReference
  //                         .child('users')
  //                         .child( _uid)
  //                         .child('steps')
  //                         .child(formattedDate)
  //                         .set(StepsCompleted);
  //                     SharedPref().setTodaysSteps(StepsCompleted);
  //                     SharedPref().setStepsTarget(target);
  //                   }
  //                   SharedPref().setextraSteps(0);
  //                 }
  //                 else  if ( newday
  //                 ) {
  //                   SharedPref().setextraSteps(0);
  //                   print("in 2nd if of start listening");
  //                     _subscription?.cancel();
  //                     _pedestrianStatusSubscription?.cancel();
  //                     SharedPreferences prefs = await SharedPreferences.getInstance();
  //                     await prefs.setInt('lastResetDay', DateTime.now().day);
  //                     await SharedPref().setLastDaySteps(event.steps);
  //                     SharedPref().setTodaysSteps(0);
  //                     // SharedPref().setisStart(false);
  //                     // SharedPref().setStartTime(DateTime.now().toString());
  //                     SharedPref().saveDuration(Duration.zero);
  //
  //                       _lastResetDay=DateTime.now().day;
  //                       lastDayStep=event.steps;
  //                       StepsCompleted =0;
  //                       newday=false;
  //                       extra=0;
  //
  //                     print("new Day in _reset last day------------------->"+newday.toString());
  //                     // startListening();
  //                 }else{
  //                     print("s " + StepsCompleted.toString() + "Last Day Steps "+(lastDayStep).toString());
  //                     print("inside more");
  //                     if(currentSpeed>=walkingSpeedThreshold){
  //                       print("inside if speef is greater than walking threshHold");
  //                       int newWithwalkingandcar =event.steps-lastDayStep;
  //                       extra=newWithwalkingandcar-StepsCompleted;
  //                       SharedPref().setextraSteps(extra);
  //
  //                     }else{
  //                       print("inside else speed is smaller  than walking threshHold");
  //                       StepsCompleted = event.steps - (lastDayStep + extra);
  //                       if(StepsCompleted==target){
  //                         await flutterLocalNotificationsPlugin.show(
  //                           0, // A unique ID for the notification
  //                           'Step Goal Completed',
  //                           'Voila! You have achieved your today’s goal of 6000 steps.',
  //                           platformChannelSpecifics,
  //                           payload: 'item x',
  //                         );
  //
  //
  //                         // checkStepsUpdated(context);
  //                       }
  //                     }
  //
  //                   // StepsCompleted = event.steps ;
  //                   if(isguest){
  //                     SharedPref().setTodaysSteps(StepsCompleted);
  //                     print("s " + StepsCompleted.toString() + "Last Day Steps " + (lastDayStep).toString());
  //                     DateTime now = DateTime.now();
  //                     String formattedDate = DateFormat('yyyy-MM-dd').format(now);
  //                     DateTime date=DateTime.parse(formattedDate);
  //                     updateStepCount(StepsCompleted){
  //                       String formattedDate = date.toIso8601String(); // Convert date to a string
  //                       stepCounts[formattedDate] = StepsCompleted;
  //                         }
  //                     print("Map is ---------------------------------------------------->" + stepCounts.toString());
  //                     SharedPref().saveStepsData(stepCounts);}
  //                   else {
  //                     DatabaseReference databaseReference = FirebaseDatabase.instance.reference(); // Replace with your user ID
  //                     String _uid = await SharedPref().getUid();
  //                     DateTime now = DateTime.now();
  //                     String formattedDate = DateFormat('yyyy-MM-dd').format(now);
  //
  //                     databaseReference
  //                         .child('users')
  //                         .child( _uid)
  //                         .child('steps')
  //                         .child(formattedDate)
  //                         .set(StepsCompleted);
  //                     SharedPref().setTodaysSteps(StepsCompleted);
  //                     SharedPref().setStepsTarget(target);
  //                     SharedPref().setTodaysSteps(StepsCompleted);
  //                     print("s " + StepsCompleted.toString() + "Last Day Steps " +
  //                         (lastDayStep).toString());
  //                     DateTime now3 = DateTime.now();
  //                     String formattedDate2 = DateFormat('yyyy-MM-dd').format(now3);
  //                     DateTime date2=DateTime.parse(formattedDate2);
  //                       String formattedDate3 = date2.toIso8601String(); // Convert date to a string
  //                       stepCounts[formattedDate3] = StepsCompleted;
  //
  //                     }
  //                     print("Map is ---------------------------------------------------->" + stepCounts.toString());
  //                     SharedPref().saveStepsData(stepCounts);
  //                   }
  //
  //               });
  //               print("Helllooo From Step Tracker in function of strem");
  //                 });
           print("Helllooo From Step Tracker in function of strem");}






















  // final DateTime now2 = DateTime.now();
  // final int isolateId = Isolate.current.hashCode;
  // tz.initializeTimeZones();
  // tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  // flutterLocalNotificationsPlugin.cancelAll();
  // tz.initializeTimeZones();
  // tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  // // final tz.Location local = tz.getLocation('Asia/Kolkata');
  // final DateTime now = tz.TZDateTime.now(tz.local);
  // final DateTime nextInstance =
  // DateTime(now.year, now.month, now.day, 8, 0); // 8:00 AM
  // final DateTime nextInstance2 =
  // DateTime(now.year, now.month, now.day, 20, 0); // 8:00 PM
  // print("location" + tz.local.toString());
  // final tz.TZDateTime scheduledDateTZ = nextInstance.isBefore(now)
  //     ? tz.TZDateTime.from(nextInstance.add(Duration(days: 1)),
  //     tz.local) // If 8:00 AM has already passed today, schedule for tomorrow
  //     : tz.TZDateTime.from(
  //     nextInstance, tz.local); // Otherwise, schedule for today
  //
  // final tz.TZDateTime scheduledDateTZ2 = nextInstance2.isBefore(now)
  //     ? tz.TZDateTime.from(nextInstance2.add(Duration(days: 1)),
  //     tz.local) // If 8:00 AM has already passed today, schedule for tomorrow
  //     : tz.TZDateTime.from(
  //     nextInstance2, tz.local); // Otherwise, schedule for today
  //
  // const AndroidNotificationDetails androidPlatformChannelSpecifics =
  // AndroidNotificationDetails('Step Tracker', 'Step Tracker',
  //     importance: Importance.max,
  //     color: Colors.black,
  //     icon: "small_logo",
  //     priority: Priority.max,
  //     showWhen: true);
  //
  // const NotificationDetails platformChannelSpecifics =
  // NotificationDetails(android: androidPlatformChannelSpecifics);
  //
  // await flutterLocalNotificationsPlugin
  //     .zonedSchedule(
  //   0,
  //   'Morning walk reminder',
  //   'Good morning! Start your day with a refreshing walk and boost your energy.',
  //   scheduledDateTZ,
  //   platformChannelSpecifics,
  //   androidAllowWhileIdle: true,
  //   uiLocalNotificationDateInterpretation:
  //   UILocalNotificationDateInterpretation.absoluteTime,
  //   matchDateTimeComponents: DateTimeComponents.dateAndTime,
  // )
  //     .then((value) {
  //   print(scheduledDateTZ);
  // });
  //
  // await flutterLocalNotificationsPlugin
  //     .zonedSchedule(
  //   5,
  //   'Daily goal check',
  //   'Have you reached your daily step goal? A little more effort can make it happen!',
  //   scheduledDateTZ2,
  //   platformChannelSpecifics,
  //   androidAllowWhileIdle: true,
  //   uiLocalNotificationDateInterpretation:
  //   UILocalNotificationDateInterpretation.absoluteTime,
  //   matchDateTimeComponents: DateTimeComponents.dateAndTime,
  // )
  //     .then((value) {
  //   print(scheduledDateTZ2);
  // });


//
// void requestExactAlarmPermission() async {
//   var status = await Permission.manageExternalStorage.status;
//   if (!status.isGranted) {
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.manageExternalStorage,
//     ].request();
//     print(statuses[Permission.manageExternalStorage]);
//   }
// }
//
// void scheduleNotification() async {
//   flutterLocalNotificationsPlugin.cancelAll();
//   tz.initializeTimeZones();
//   tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
//   // final tz.Location local = tz.getLocation('Asia/Kolkata');
//   final DateTime now = tz.TZDateTime.now(tz.local);
//   final DateTime nextInstance =
//       DateTime(now.year, now.month, now.day, 8, 0); // 8:00 AM
//   final DateTime nextInstance2 =
//       DateTime(now.year, now.month, now.day, 20, 0); // 8:00 PM
//   print("location" + tz.local.toString());
//   final tz.TZDateTime scheduledDateTZ = nextInstance.isBefore(now)
//       ? tz.TZDateTime.from(nextInstance.add(Duration(days: 1)),
//           tz.local) // If 8:00 AM has already passed today, schedule for tomorrow
//       : tz.TZDateTime.from(
//           nextInstance, tz.local); // Otherwise, schedule for today
//
//   final tz.TZDateTime scheduledDateTZ2 = nextInstance2.isBefore(now)
//       ? tz.TZDateTime.from(nextInstance2.add(Duration(days: 1)),
//           tz.local) // If 8:00 AM has already passed today, schedule for tomorrow
//       : tz.TZDateTime.from(
//           nextInstance2, tz.local); // Otherwise, schedule for today
//
//   const AndroidNotificationDetails androidPlatformChannelSpecifics =
//       AndroidNotificationDetails('Step Tracker', 'Step Tracker',
//           importance: Importance.max,
//           color: Colors.black,
//           icon: "small_logo",
//           priority: Priority.max,
//           showWhen: true);
//
//   const NotificationDetails platformChannelSpecifics =
//       NotificationDetails(android: androidPlatformChannelSpecifics);
//
//   await flutterLocalNotificationsPlugin
//       .zonedSchedule(
//     0,
//     'Morning walk reminder',
//     'Good morning! Start your day with a refreshing walk and boost your energy.',
//     scheduledDateTZ,
//     platformChannelSpecifics,
//     androidAllowWhileIdle: true,
//     uiLocalNotificationDateInterpretation:
//         UILocalNotificationDateInterpretation.absoluteTime,
//     matchDateTimeComponents: DateTimeComponents.dateAndTime,
//   )
//       .then((value) {
//     print(scheduledDateTZ);
//   });
//
//   await flutterLocalNotificationsPlugin
//       .zonedSchedule(
//     5,
//     'Daily goal check',
//     'Have you reached your daily step goal? A little more effort can make it happen!',
//     scheduledDateTZ2,
//     platformChannelSpecifics,
//     androidAllowWhileIdle: true,
//     uiLocalNotificationDateInterpretation:
//         UILocalNotificationDateInterpretation.absoluteTime,
//     matchDateTimeComponents: DateTimeComponents.dateAndTime,
//   )
//       .then((value) {
//     print(scheduledDateTZ2);
//   });
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
