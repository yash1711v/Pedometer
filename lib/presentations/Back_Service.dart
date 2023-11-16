import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steptracking/main.dart';

import '../SharedPrefrences/SharedPref.dart';
import '../firebase_options.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
 AndroidNotificationChannel channel=AndroidNotificationChannel(
      'Step Tracker',
      'Step Tracker',
      importance: Importance.max,
   showBadge: false,
  );
 await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  await service.configure(
      iosConfiguration: IosConfiguration(
    autoStart: true,
    onForeground: onStart,
    onBackground: onBackGround
  ),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStartOnBoot: true,
        autoStart: true,
        foregroundServiceNotificationId: 888
      ));
  service.startService();
}
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async{
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  bool isFirstRun = await SharedPref().getFirstrun();
  int maxSteps = await SharedPref().getStepsTarget();
  var Steps=0;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Map<String, int> stepCounts = {};
  DartPluginRegistrant.ensureInitialized();
  if(service is AndroidServiceInstance){
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
  bool Indeterminate = false;

  Pedometer.stepCountStream.listen((StepCount event) async {
    bool isGuest=await SharedPref().getisguest();
    bool newday=false;
    int total=event.steps;
    int? _lastResetDay=prefs.getInt('lastResetDay');
    int LastdaysSteps=await SharedPref().getLastDaySteps();
    int extra=await SharedPref().getextraSteps()??0;
    String _uid = await SharedPref().getUid();
    bool IntroDone=await SharedPref().getIntroScreenInfo();
    int newlast=await SharedPref().getfSwitchoffThenvalue();
    print("Last Day Steps"+LastdaysSteps.toString());
    _getLastResetDay().then((value) {
      newday=value;
    });
    print("Last reset Day"+_lastResetDay.toString());
    // if(event.steps==0){
    //   SharedPref().setifSwitchoffThenvalue(Steps);
    // }
    //if Phone Got Switched Off or Restarted

         if(DateTime.now().day!=_lastResetDay){
           print("in not equals to last day");
           _resetStepCount(event.steps);
         }else {
           print("steps " + Steps.toString() + "Last Day Steps " +
               (LastdaysSteps).toString());
           Steps = total - LastdaysSteps;
           if (Steps < 0) {
             print("less zero");
              newlast = await SharedPref().getfSwitchoffThenvalue();
            print("newLast"+newlast.toString());

            Steps = newlast + event.steps;
            print("Steps Newwww--------------------->"+Steps.toString());
          Future.delayed(Duration(seconds: 2),()
          async {
            await SharedPref().setTodaysSteps(Steps);
            print("Steps After All calculations" + Steps.toString());
            print("laste Day steps"+LastdaysSteps.toString());
             sendStepsToFirebase(Steps);
             DateTime now = DateTime.now();
             String formattedDate = DateFormat('yyyy-MM-dd').format(now);
             String formattedDatee = DateTime.parse(formattedDate).toIso8601String(); // Convert date to a string
             stepCounts[formattedDatee] = Steps;
             SharedPref().saveStepsData(stepCounts);
          });

           } else {
             print("More zero");
             await SharedPref().setTodaysSteps(Steps);
             print("Steps After All calculations" + Steps.toString());
             sendStepsToFirebase(Steps);
             DateTime now = DateTime.now();
             String formattedDate = DateFormat('yyyy-MM-dd').format(now);
             String formattedDatee = DateTime.parse(formattedDate).toIso8601String(); // Convert date to a string
             stepCounts[formattedDatee] = Steps;
             SharedPref().saveStepsData(stepCounts);
             SharedPref().setifSwitchoffThenvalue(Steps);
             print("Steps Coming back from Set Switchoff"+await SharedPref().getfSwitchoffThenvalue().toString());

           }
         }

  });
  // int Progress=0;
  // Timer.periodic(Duration(seconds: 2), (timer) async {
  //   Progress= await SharedPref().getTodaysSteps();
  //   isFirstRun==false?
  //   flutterLocalNotificationsPlugin.show(
  //       888,
  //       "Step Tracking",
  //       "Be Relax We are Tracking your steps",
  //       NotificationDetails(android:
  //       AndroidNotificationDetails(
  //         'Step Tracking',
  //         'Step Tracker',
  //         channelShowBadge: false,
  //         color: Colors.black,
  //         enableLights: false,
  //         enableVibration: false,
  //         playSound: false,
  //         icon: 'small_logo',
  //         colorized: true,
  //         showProgress: false,
  //         largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
  //         channelDescription: "This is Notification is to give  you alert to start and check your daily steps ",
  //         importance: Importance.low,
  //         ongoing: true,
  //         indeterminate: Indeterminate,
  //         maxProgress: await SharedPref().getStepsTarget(),
  //         progress: Progress,
  //       )
  //       )
  //     // After the first run, set this to false
  //   ):null;
  //   await SharedPref().setFirstrun(true);
  // });
  flutterLocalNotificationsPlugin.show(
      888,
      "Step Tracking",
      "Be Relax We are Tracking your steps",
      NotificationDetails(android:
      AndroidNotificationDetails(
        'Step Tracking',
        'Step Tracker',
        channelShowBadge: false,
        color: Colors.black,
        enableLights: false,
        enableVibration: false,
        playSound: false,
        icon: 'small_logo',
        colorized: true,
        showProgress: false,
        largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
        channelDescription: "This is Notification is to give  you alert to start and check your daily steps ",
        importance: Importance.low,
        ongoing: true,
        indeterminate: Indeterminate,
        maxProgress: await SharedPref().getStepsTarget(),
        progress: await SharedPref().getTodaysSteps(),
      )
      )
    // After the first run, set this to false
  );
}
@pragma('vm:entry-point')
Future<bool>  onBackGround(ServiceInstance service) async{
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}
 void _resetStepCount(int steps) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('lastResetDay', DateTime.now().day);
  await SharedPref().setLastDaySteps(steps);
  SharedPref().setTodaysSteps(0);

  SharedPref().saveDuration(Duration.zero);
  print("new Day in _reset last day------------------->"+ DateTime.now().day.toString());
  // startListening();
}
void sendStepsToFirebase(int steps) async {
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference(); // Replace with your user ID
  String _uid = await SharedPref().getUid();
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(now);

  databaseReference
      .child('users')
      .child( _uid)
      .child('steps')
      .child(formattedDate)
      .set(steps);
}
  firstTimeInstalled(int steps) async {
    print(" firstTimeInstalled");
    await SharedPref().setLastDaySteps(steps);
    await SharedPref().setIntroScreenInfo(true);
   bool isGuest=await SharedPref().getisguest();
   int StepsTarget= await SharedPref().getStepsTarget();
    if(isGuest){
      print("first Time Called Guest");
      SharedPref().setStepsTarget(StepsTarget);
      SharedPref().setisStart(true);
    }else{
      print("first Time Called login");
      sendStepsToFirebase(steps);
      SharedPref().setStepsTarget(StepsTarget);
    }
  }
Future<int>  Switchoffmethod() async {
  int Switch =await SharedPref().getfSwitchoffThenvalue()??0;
 return Switch;
}

Future<bool>  _getLastResetDay() async {
  print("--------------------------->getlast reset Day");
  SharedPreferences prefs = await SharedPreferences.getInstance();

  int?  _lastResetDay = prefs.getInt('lastResetDay');

  print("--------------------------->last reset Day"+_lastResetDay.toString());
  print("--------------------------->Today Day"+DateTime.now().day.toString());
  if (_lastResetDay != DateTime.now().day){
    print("--------------------------->in no equals to of last reset day");
      return true;


  }else{
    return false;
  }
}