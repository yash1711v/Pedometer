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
        notificationChannelId: "Step Tracker",
        initialNotificationTitle: "Counting Steps Continously",
        foregroundServiceNotificationId: 888
      ));
  service.startService();
}
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async{
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  bool isFirstRun = true;
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
  Timer.periodic(Duration(seconds: 50), (timer) async {
    int?  _lastResetDay = prefs.getInt('lastResetDay')??DateTime.now().day;
    int TodaysSteps=await SharedPref().getTodaysSteps()??0;
    int Switchoff=0;
    int newsteps=0;
    bool isGuest=await SharedPref().getisguest();
    bool introdone=await SharedPref().getIntroScreenInfo();
    int LastDaySteps=await SharedPref().getLastDaySteps();
    int ExtraSteps=await SharedPref().getextraSteps()??0;
    double walkingSpeedThreshold = 14;// this is for man
    double currentSpeed=0;
    print("--------------------------->last reset Day"+_lastResetDay.toString());
    print("--------------------------->Today Day"+DateTime.now().day.toString());
    if (_lastResetDay != DateTime.now().day){
      print("--------------------------->in no equals to of last reset day");
      SharedPref().setTodaysSteps(0);
      SharedPref().saveDuration(Duration.zero);
      // newday=true;
      print("in if condition");

    }else{
      print("in else condition");
    }
    Pedometer.stepCountStream.listen((StepCount event) async {
      print("in ForeGround Service------------------------------------->"+event.steps.toString());
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Calculate speed in m/s
      double speed = position.speed ?? 0.0;

      // Convert speed to km/h
      speed *= 3.6;
      currentSpeed = speed;
      print(
          "this Speed is In get Speed Method------------------------------------------>" +
              currentSpeed.toString());
      print(
          "current Speed--------------------------------------------->" +
              currentSpeed.toString());
      print(
          "Walking Threshold------------------------------------------>" +
              walkingSpeedThreshold.toString());
      print("Helllooo From Step Tracker in function of strem");
      if (event.steps == 0) {
        SharedPref().setifSwitchoffThenvalue(TodaysSteps);
      }
      if (event.steps < TodaysSteps && _lastResetDay == DateTime
          .now()
          .day) {
        int Switch = await SharedPref().getfSwitchoffThenvalue() ?? 0;

        Switchoff = Switch;
        print("old Steps:----------------------------------------->" +
            Switchoff.toString());
        print("new  steps: ------------->" + event.steps.toString());
        int newSteps = Switchoff + event.steps;
        newsteps = newSteps;
        if (newsteps > TodaysSteps) {
          TodaysSteps = newsteps;
          if (isGuest) {
            SharedPref().setTodaysSteps(TodaysSteps);
          } else {
            DatabaseReference databaseReference = FirebaseDatabase
                .instance.reference(); // Replace with your user ID
            String _uidd = await SharedPref().getUid();
            DateTime now = DateTime.now();
            String formattedDate = DateFormat('yyyy-MM-dd').format(now);

            databaseReference
                .child('users')
                .child(_uidd)
                .child('steps')
                .child(formattedDate)
                .set(TodaysSteps);
            SharedPref().setTodaysSteps(TodaysSteps);
          }
        }
        print(
            "newStep Variable Data------------------------------------------------------------>" +
                newSteps.toString());
        print(
            "old Steps:------------------------------------------------------------------------>" +
                TodaysSteps.toString());
      }
      else if (_lastResetDay != DateTime
          .now()
          .day) {
        print("in Streamn");
        SharedPref().setextraSteps(0);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('lastResetDay', DateTime
            .now()
            .day);
        await SharedPref().setLastDaySteps(event.steps);
        SharedPref().setTodaysSteps(0);
        SharedPref().saveDuration(Duration.zero);
        print("in stream2");
      }
      else {
        if (currentSpeed >= walkingSpeedThreshold) {
          print("inside if speef is greater than walking threshHold");
          int newWithwalkingandcar = event.steps - LastDaySteps;
          ExtraSteps = newWithwalkingandcar - TodaysSteps;
          SharedPref().setextraSteps(ExtraSteps);
        } else {
          print(
              "inside else speed is smaller  than walking threshHold");
          TodaysSteps = event.steps - (LastDaySteps + ExtraSteps);
        }
        if (isGuest) {
          SharedPref().setTodaysSteps(TodaysSteps);
          print("s " + TodaysSteps.toString() + "Last Day Steps " +
              (LastDaySteps).toString());
          DateTime now = DateTime.now();
          String formattedDate = DateFormat('yyyy-MM-dd').format(now);
          DatabaseReference databaseReference = FirebaseDatabase
              .instance.reference(); // Replace with your user ID
          String _uidd = await SharedPref().getUid();
          DateTime now2 = DateTime.now();
          String formattedDatee = DateFormat('yyyy-MM-dd').format(now2);

          databaseReference
              .child('users')
              .child(_uidd)
              .child('steps')
              .child(formattedDatee)
              .set(TodaysSteps);
          SharedPref().setTodaysSteps(TodaysSteps);
          print(
              "Map is ---------------------------------------------------->" +
                  stepCounts.toString());
          SharedPref().saveStepsData(stepCounts);
        }
        else {
          DatabaseReference databaseReference = FirebaseDatabase
              .instance.reference(); // Replace with your user ID
          String _uidd = await SharedPref().getUid();
          DateTime now = DateTime.now();
          String formattedDate = DateFormat('yyyy-MM-dd').format(now);

          databaseReference
              .child('users')
              .child(_uidd)
              .child('steps')
              .child(formattedDate)
              .set(TodaysSteps);
          SharedPref().setTodaysSteps(TodaysSteps);
          SharedPref().setTodaysSteps(TodaysSteps);
          print("s " + TodaysSteps.toString() + "Last Day Steps " +
              (LastDaySteps).toString());
          DateTime now3 = DateTime.now();
          String formattedDate3 = DateFormat('yyyy-MM-dd').format(now3);
          String formattedDate4 = DateTime.parse(formattedDate3)
              .toIso8601String(); // Convert date to a string
          stepCounts[formattedDate4] = TodaysSteps;
          print(
              "Map is ---------------------------------------------------->" +
                  stepCounts.toString());
          SharedPref().saveStepsData(stepCounts);
        }
      }
    });
    if(isFirstRun && service is AndroidServiceInstance){
      if(await service.isForegroundService()){
        flutterLocalNotificationsPlugin.show(
            888,
            "Step Tracking",
            "Be Relax We are Tracking your steps",
            NotificationDetails(android:
            AndroidNotificationDetails(
              'Step Tracking',
              'Step Tracker',
              color: Colors.black,
              enableLights: false,
              enableVibration: false,
              playSound: false,
              icon: 'small_logo',
              colorized: true,
              largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
              channelDescription: "This is Notification is to give  you alert to start and check your daily steps ",
              importance: Importance.max,
              ongoing: true
              )
            )
            // After the first run, set this to false
        );
        // service.setForegroundNotificationInfo(
        //   title: "Step Tracker",
        //     content: 'This is Runing in background'
        //
        // );
        isFirstRun = false;
      }

    }
    //persome some operation which is not  notificable  to user
    print("background  service running");
    service.invoke('update');
  });
}
@pragma('vm:entry-point')
Future<bool>  onBackGround(ServiceInstance service) async{
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}
 void PPrint(){
  print("Hello From Background Services");
 }