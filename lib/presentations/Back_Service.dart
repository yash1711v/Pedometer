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
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steptracking/main.dart';

import '../Firebasefunctionalities/AuthServices.dart';
import '../LocalDataBaseForSteps/Model.dart';
import '../LocalDataBaseForSteps/ObjectBox.dart';
import '../SharedPrefrences/SharedPref.dart';
import '../firebase_options.dart';
import '../objectbox.g.dart';
import 'SignUpScreen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:home_widget/home_widget.dart';

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
 Future<void> stopBackgroundService() async {
final service = FlutterBackgroundService();
service.invoke('stopService');
}
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async{
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  String Uid=await SharedPref().getUid();
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('users').child(Uid).child('Device_ID');
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
    // print("invoked the stop service");
    service.stopSelf();
  });
  bool Indeterminate = false;
  int Target=await SharedPref().getStepsTarget();

Timer.periodic(Duration(seconds: 1), (timer) async {
  int StepsTarget=await SharedPref().getStepsTarget();
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
    int StepsComing=await SharedPref().getStepsComingFromFirebase();
    // print("Print Steps Coming"+StepsComing.toString());
    // print("Last Day Steps"+LastdaysSteps.toString());


    _getLastResetDay().then((value) {
      newday=value;
    });
    // print("Last reset Day"+_lastResetDay.toString());

    if(DateTime.now().day!=_lastResetDay){
      // print("in not equals to last day");
      _resetStepCount(event.steps);
    }else {
      // print("steps " + Steps.toString() + "Last Day Steps " +
      //     (LastdaysSteps).toString());
      Steps = total - LastdaysSteps;
      if (Steps < 0) {
        // print("less zero");
        newlast = await SharedPref().getfSwitchoffThenvalue();
        // print("newLast"+newlast.toString());

        Steps = newlast + event.steps;
        // print("Steps Newwww--------------------->"+Steps.toString());
        Future.delayed(Duration(seconds: 2),()
        async {
          await SharedPref().setTodaysSteps(Steps);
          // print("Steps After All calculations" + Steps.toString());
          // print("laste Day steps"+LastdaysSteps.toString());
       //   sendStepsToFirebase(Steps);
          DateTime now = DateTime.now();
          String formattedDate = DateFormat('yyyy-MM-dd').format(now);
          String formattedDatee = DateTime.parse(formattedDate).toIso8601String(); // Convert date to a string
          stepCounts[formattedDatee] = Steps;
          SharedPref().saveStepsData(stepCounts);
        });

      } else {
        if(StepsComing>0) {
          Steps = Steps + StepsComing;
          // print("More zero");
          await SharedPref().setTodaysSteps(Steps);
          // print("Steps After All calculations" + Steps.toString());
        //  sendStepsToFirebase(Steps);
          DateTime now = DateTime.now();
          String formattedDate = DateFormat('yyyy-MM-dd').format(now);
          String formattedDatee = DateTime.parse(formattedDate)
              .toIso8601String(); // Convert date to a string
          stepCounts[formattedDatee] = Steps;
          SharedPref().saveStepsData(stepCounts);
          SharedPref().setifSwitchoffThenvalue(Steps);
          // print("Steps Coming back from Set Switchoff" +
          //     await SharedPref().getfSwitchoffThenvalue().toString());
        }else{

          // print("More zero");
          await SharedPref().setTodaysSteps(Steps);
          // print("Steps After All calculations" + Steps.toString());
         // sendStepsToFirebase(Steps);
          DateTime now = DateTime.now();
          String formattedDate = DateFormat('yyyy-MM-dd').format(now);
          String formattedDatee = DateTime.parse(formattedDate)
              .toIso8601String(); // Convert date to a string
          stepCounts[formattedDatee] = Steps;
          SharedPref().saveStepsData(stepCounts);
          SharedPref().setifSwitchoffThenvalue(Steps);
          // print("Steps Coming back from Set Switchoff" +
          //     await SharedPref().getfSwitchoffThenvalue().toString());
        }
      }
    }
  });


  DatabaseReference databaseReference2 = FirebaseDatabase.instance.reference().child('users').child(Uid).child("defaultsteps");
  int maxprogress=6000;


  try {
    databaseReference2.onValue.listen((event) {
      print(event.snapshot.value.toString());
      if(event.snapshot.value!=null){
   maxprogress=int.parse(event.snapshot.value.toString());}else{
        maxprogress=6000;
      }
      flutterLocalNotificationsPlugin.show(
          888,
          "Step Tracking",
          "Steps Completed:- ${Steps}  |  Steps Target:-  ${maxprogress}",
          NotificationDetails(android:
          AndroidNotificationDetails(
              'Step Tracking',
              'Steps Completed:- ${Steps}  |  Steps Target:-  ${Target}',
              showProgress:true,
              channelShowBadge: false,
              color: Colors.black,
              maxProgress: maxprogress,
              enableLights: false,
              enableVibration: false,
              playSound: false,
              icon: 'small_logo',
              colorized: true,
              onlyAlertOnce : true,
              largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
              channelDescription: "This is Notification is to give  you alert to start and check your daily steps ",
              importance: Importance.max,
              ongoing: true,
              indeterminate: Indeterminate,
              progress: Steps
          )
          )
        // After the first run, set this to false
      );
    });
  } catch (e) {
    print('Error: $e');
  }
    await  HomeWidget.saveWidgetData("_Steps", Steps);
    await  HomeWidget.updateWidget(name: "HomeScreenWidgetProvider",iOSName: "HomeScreenWidgetProvider");
// await  ObjectBoxClass.instance.storeSteps(Steps);
 await  SharedPref().setStepsData(Steps);

  flutterLocalNotificationsPlugin.show(
      888,
      "Step Tracking",
      "Steps Completed:- ${Steps}  |  Steps Target:-  ${maxprogress}",
      NotificationDetails(android:
      AndroidNotificationDetails(
        'Step Tracking',
        'Steps Completed:- ${Steps}  |  Steps Target:-  ${Target}',
        showProgress:true,
        channelShowBadge: false,
        color: Colors.black,
        maxProgress: maxprogress,
        enableLights: false,
        enableVibration: false,
        playSound: false,
        icon: 'small_logo',
        colorized: true,
          onlyAlertOnce : true,
        largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
        channelDescription: "This is Notification is to give  you alert to start and check your daily steps ",
        importance: Importance.max,
        ongoing: true,
        indeterminate: Indeterminate,
        progress: Steps
      )
      )
    // After the first run, set this to false
  );
});


Timer.periodic(Duration(minutes: 5), (timer) async {
  String Uid=await SharedPref().getUid();
  String deviceid=await SharedPref().getDeviceid();
  print("Uid:  "+  Uid);
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('users').child(Uid).child('Device_ID');
  try {
    databaseReference.onValue.listen((event) async {

      // print("Device is stored in shared pre"+deviceid);
      // print("Device is stored in firebase"+event.snapshot.value.toString());
      if(deviceid!=event.snapshot.value.toString() && event.snapshot.value.toString().isNotEmpty &&  event.snapshot.value.toString()!=null){
        // print("Id is diffrent from current device");
        // print("on value change");
        service.stopSelf();
        await SharedPref().clearAllPreferences();
      await SharedPref().setIntroScreenInfo(false);
      SharedPref().setStepsComingFromFirebase(0);
      SharedPref().setEmail("");
      SharedPref().setPassword("");
      SharedPref().setUsername("");
      SharedPref().setisguest(true);
      await SharedPref().setisStart(false);
      await SharedPref().setTodaysSteps(0);
      await SharedPref().setisMiles(false);
      await SharedPref().setStepsTarget(6000);
      }else{
        // print("Id is same ");
      }
    });
  } catch (e) {
    print('Error: $e');
  }
});


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
  SharedPref().setStepsComingFromFirebase(0);
  // print("new Day in _reset last day------------------->"+ DateTime.now().day.toString());
  // startListening();
}


void sendStepsToFirebase(int steps) async {
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference(); // Replace with your user ID
  String _uid = await SharedPref().getUid();
  DateTime now = DateTime.now();
  Map<String,Object> newtimedatw={};
  String formattedDate = DateFormat('yyyy-MM-dd').format(now);
  String FormattedTime = DateFormat('hh a').format(now);
  String previoustime=await SharedPref().getPreviousTime()??"00 Am";
  String pre = DateFormat('hh a').format(now.subtract(Duration(hours: 1)));
  int lasttimesteps=0;
  DateTime startTime = DateTime(now.year, now.month, now.day, 0, 0);
  DateTime endTime = now.subtract(Duration(hours: 1));

  int intervalInMinutes = 60; // Adjust as needed

  // Run the loop
  for (DateTime loopTime = startTime; loopTime.isBefore(endTime); loopTime = loopTime.add(Duration(minutes: intervalInMinutes))) {
    // Format the current time in the desired format
    String formattedTime = DateFormat('hh a').format(loopTime);
    print(formattedTime);
    databaseReference
        .child('users')
        .child(_uid)
        .child('steps')
        .child(formattedDate)
        .child(formattedTime)
        .once().then((value) {
      var dataSnapshot =value;
      if(dataSnapshot.snapshot.value!=null){
        lasttimesteps=lasttimesteps+int.parse(dataSnapshot.snapshot.value.toString());
        int Stepstobeset=steps-lasttimesteps;
        databaseReference
            .child('users')
            .child(_uid)
            .child('steps')
            .child(formattedDate).update({FormattedTime:Stepstobeset});
        // print("Lasttimestepsp in if condition--------------------->"+lasttimesteps.toString());
      }else{

        // print("Lasttimestepsp in else condition--------------------->"+lasttimesteps.toString());
        databaseReference
            .child('users')
            .child(_uid)
            .child('steps')
            .child(formattedDate)
            .child(formattedTime).set(0);
      }

    });
    // Print or use the formatted time as needed

  }

  databaseReference
      .child('users')
      .child(_uid)
      .child('steps')
      .child(formattedDate).update({"TotalSteps" : steps});


}




bool isNewHour(String newFormattedTime) {
  DateTime now = DateTime.now();
  String currentFormattedTime = DateFormat('hh a').format(now);
  return newFormattedTime != currentFormattedTime;
}














  firstTimeInstalled(int steps) async {
    print(" firstTimeInstalled");
    await SharedPref().setLastDaySteps(steps);
    await SharedPref().setIntroScreenInfo(true);
   bool isGuest=await SharedPref().getisguest();
   int StepsTarget= await SharedPref().getStepsTarget();
    if(isGuest){
      // print("first Time Called Guest");
      SharedPref().setStepsTarget(StepsTarget);
      SharedPref().setisStart(true);
    }else{
      // print("first Time Called login");
     // sendStepsToFirebase(steps);
      SharedPref().setStepsTarget(StepsTarget);
    }
  }
Future<int>  Switchoffmethod() async {
  int Switch =await SharedPref().getfSwitchoffThenvalue()??0;
 return Switch;
}

Future<bool>  _getLastResetDay() async {
  // print("--------------------------->getlast reset Day");
  SharedPreferences prefs = await SharedPreferences.getInstance();

  int?  _lastResetDay = prefs.getInt('lastResetDay');

  // print("--------------------------->last reset Day"+_lastResetDay.toString());
  // print("--------------------------->Today Day"+DateTime.now().day.toString());
  if (_lastResetDay != DateTime.now().day){
    // print("--------------------------->in no equals to of last reset day");
      return true;


  }else{
    return false;
  }
}

Future<bool> checkisSingleDeviceloggedIn() async{
  // print("checkSingleDeviceLoggededIn calling after 1 sec");
  AuthServices authServices2=AuthServices();
  String Firebaseid="";
  String deviceid=await SharedPref().getDeviceid();
  bool isGuest=await SharedPref().getisguest();
  String Uid=await SharedPref().getUid();
  // print("Uid:  "+  Uid);
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('users').child(Uid).child('Device_ID');
  try {
    databaseReference.onValue.listen((event) async {
      Firebaseid=event.snapshot.value.toString();
      // print("Firebase Devide Idddddddddd"+event.snapshot.value.toString());
      // print("Firebase Deviceid"+Firebaseid);
      // print("SharedPref Device ID:"+deviceid);
    });
  } catch (e) {
    print('Error: $e');
  }
  Future.delayed(Duration(milliseconds: 15),() async {
    if(isGuest){}else{
      if(deviceid!=Firebaseid && Firebaseid!=null ){
        // print("------------------------------------------------------------------------------>in notEquals");

        SharedPref().setischecking(true);

        return true;
      }
      else{
        // print("in Equals");
        SharedPref().setischecking(false);
        return false;
      }
    }
  });
  return false;
}
void _storeSteps(int Steps) async {

  ObjectBoxClass.instance.storeSteps(Steps).then((value) {
    _getTotalYearlySteps();
  });

  // Optionally, you can add code here to update the UI or show a success message.

}


Future<void> _getTotalYearlySteps() async {
  final Map<String, dynamic> stepsData = await ObjectBoxClass.instance.getStepsData();
  print(stepsData.toString());
  final now = DateTime.now();
  final year = (now.year).toString();
  final month = now.month<10?"0"+now.month.toString():now.month.toString(); // Use month number directly
  final date = (now.day).toString();
  final time = (DateFormat('h a').format(now)).toString();
  print(year);
  print(month);
  print(date);
  print(time);
  print(now);
  print('Steps Target is----------> ${stepsData['${year}']['${month}']['${date}']['${time}']}');
}