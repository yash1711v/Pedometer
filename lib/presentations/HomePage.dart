// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;
import 'package:flutter_svg/svg.dart';
import 'package:optimize_battery/optimize_battery.dart';
import 'package:steptracking/Firebasefunctionalities/AuthServices.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:pedometer/pedometer.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../Firebasefunctionalities/DatabaseServices.dart';
import '../LocalDataBaseForSteps/DatabaseHelper.dart';
import '../LocalDataBaseForSteps/ObjectBox.dart';
import '../SharedPrefrences/SharedPref.dart';
import '../main.dart';
import '../widgets/BottomNavbar.dart';
import '../widgets/GradiantArchProgress.dart';
import 'Back_Service.dart';
import 'Linechart.dart';
import 'NotificationServices.dart';
import 'SignUpScreen.dart';
SharedPreferences? prefs;
const String countKey = 'count';

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';

/// A port used to communicate from a background isolate to the UI isolate.
ReceivePort port = ReceivePort();
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int StepsTarget = 0;
  int StepsCompleted = 0;
  late AnimationController _controller;
  late Animation<double> _animation;
  String _pedestrianStatus = 'Stopped';
  double indicatorProgress = 0.0;
  bool isPause = false;
  bool isPermissionGauranted = false;
  double Distance = 0;
  int? _lastResetDay = 0;
  late PermissionStatus status;
  NotificationServices notificationServices = NotificationServices();
  Duration totalDuration = Duration.zero;
  bool introdone=false;
  Pedometer pedometer = Pedometer();
  int LastDaySteps=0;
  bool isStart=false;
  int newsteps=0;
  double speedInHours = 4.82803;
  late StepCount mySteps;
  bool isSwitchoff=true;
  bool newday=false;
  bool isMils=false;
  double inMiles=0;
  bool isGuest=false;
  bool isWalking = false;
  int ExtraSteps = 0;
  double walkingSpeedThreshold = 14;// this is for man
  double currentSpeed=0;
  String Deviceid="";
  String Uid="";
  Timer? myTimer;
  bool ischecking=true;
bool isDone=false;
int StepscomingFromFirebase=0;
DatabaseServices _services=DatabaseServices();
  DatabaseHelper dbHelper = DatabaseHelper();
 Map<String, dynamic> stepsData ={};

  void initState() {
    super.initState();
    GetPermissions();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    notificationServices.initializeNotification() ;
    _getLastResetDay();
    getUserData();
    firebaseData();
    _services.getStepsData();
    OptimizeBattery.isIgnoringBatteryOptimizations().then((onValue) {
      setState(() {
        if (onValue) {
          // Igonring Battery Optimization
          // print("optimized");
        } else {
          // App is under battery optimization
          OptimizeBattery.openBatteryOptimizationSettings();
          OptimizeBattery.stopOptimizingBatteryUsage();

        }
      });
    });

    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.repeat(reverse: true);


  }
  Future<void> GetPermissions() async {
    PermissionStatus status1=await Permission.activityRecognition.request();
    PermissionStatus status2=await Permission.sensors.request();
    if(status1.isGranted && status2.isGranted){ startListening(context).then((value2) async {
      await initializeService().then((value) {
        // print("Steps Completed--------jjjh------------>"+value2.toString());
        // _storeSteps(value2);
        // dbHelper.insertStep(value2);
      });


    });}
  }

  // void _storeSteps(int Steps) async {
  //
  //   ObjectBoxClass.instance.storeSteps(Steps).then((value) {
  //     _getTotalYearlySteps();
  //   });
  //
  //   // Optionally, you can add code here to update the UI or show a success message.
  //
  // }
  //
  //
  // Future<void> _getTotalYearlySteps() async {
  //   final Map<String, dynamic> stepsData = await ObjectBoxClass.instance.getStepsData();
  //   print(stepsData.toString());
  //   final now = DateTime.now();
  //   final year = (now.year).toString();
  //   final month = now.month<10?"0"+now.month.toString():now.month.toString(); // Use month number directly
  //   final date = (now.day).toString();
  //   final time = (DateFormat('h a').format(now)).toString();
  //   print(year);
  //   print(month);
  //   print(date);
  //   print(time);
  //   print(now);
  //   print('Steps Target is----------> ${stepsData['${year}']['${month}']['${date}']['${time}']}');
  // }

  void checkisSingleDeviceloggedIn(String Uid,String Deviceid,bool isGuest) async{
    // print("checkSingleDeviceLoggededIn calling after 1 sec");
    AuthServices authServices2=AuthServices();
    String Firebaseid="";
    String deviceid=await SharedPref().getDeviceid();
    // print("Uid:  "+  Uid);
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('users').child(Uid).child('Device_ID');
    try {
      databaseReference.onValue.listen((event) async {
        Firebaseid=event.snapshot.value.toString();
        // print("Firebase Devide Idddddddddd"+event.snapshot.value.toString());
        // print("Firebase Deviceid"+Firebaseid);
        // print("SharedPref Device ID:"+Deviceid);
      });
    } catch (e) {
      print('Error: $e');
    }
    Future.delayed(Duration(seconds: 5),() async {
      if(isGuest){
        await initializeService();
      }else{
        // print("Firebase Deviceid"+Firebaseid);
        // print("SharedPref Device ID:"+deviceid);
        if(deviceid!=Firebaseid){
          // print("in notEquals");
          await SharedPref().clearAllPreferences();
      await SharedPref().setIntroScreenInfo(false);
      SharedPref().setStepsComingFromFirebase(0);
      SharedPref().setEmail("");
      SharedPref().setPassword("");
      SharedPref().setUsername("");
      SharedPref().setisguest(true);
      await SharedPref().setisStart(false);
      await SharedPref().setTodaysSteps(0);
      await SharedPref().setStepsTarget(6000);
      await SharedPref().setisMiles(false);
      await stopBackgroundService();
          SharedPref().setischecking(true);
          await stopBackgroundService();
          Get.to(()=>SignUpScreen());
        }
        else{
          // print("in Equals");
          SharedPref().setischecking(false);
          await initializeService();
        }
      }
    });
  }


  void listenNotification(){
   NotificationServices.onNotifications.stream.listen(onClickedNotification);

}
  void onClickedNotification(String? playload)=> Get.to(()=>HomePage());

      Future<double> getSpeed() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Calculate speed in m/s
    double speed = position.speed ?? 0.0;

    // Convert speed to km/h
    speed *= 3.6;
    setState(() {
      currentSpeed=speed;
    });
    // print("this Speed is In get Speed Method------------------------------------------>"+currentSpeed.toString());
    return speed;
  }





  Map<String, int> stepCounts = {}; // Initialize an empty map

  void updateStepCount(DateTime date, int steps) {
    String formattedDate = date.toIso8601String(); // Convert date to a string
    stepCounts[formattedDate] = steps; // Update or create entry
  }
  Future<void> firebaseData() async {
    if(isGuest==true){
      print("In fire base if Guest is ");
      SharedPref().setStepsTarget(StepsTarget);
      indicatorProgress = (StepsCompleted / StepsTarget) as double;
      if (indicatorProgress >= 1) {
        setState(() {
          indicatorProgress = 1;
          // SharedPref().setStartTime(DateTime.now().toString());
          // startTime=DateTime.now();
        });
      }
    }
    else{
       // print("infirebase data");
       // print("Print is guest in firebase "+isGuest.toString());
      String _uid = await SharedPref().getUid();
      DatabaseReference databaseReference = FirebaseDatabase.instance
          .reference()
          .child('users')
          .child(_uid)
          .child('defaultsteps');
      try {
        databaseReference.onValue.listen((event) {
          // print("sixinxs: "+event.snapshot.value.toString());
          setState(() {
            if(event.snapshot.value!=null){
              StepsTarget=int.parse(event.snapshot.value.toString());}else{
              StepsTarget=6000;
            }
            // isGuest?null:SharedPref().setStepsTarget(StepsTarget);
            indicatorProgress = (StepsCompleted / StepsTarget) as double;
            if (indicatorProgress >= 1) {
              setState(() {
                indicatorProgress = 1;
                // SharedPref().setStartTime(DateTime.now().toString());
                // startTime=DateTime.now();
              });
            }
          });

        });
      } catch (e) {
        print('Error: $e');
      }
    }
  }
  StreamSubscription<StepCount>? _subscription;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusSubscription;
  double deviceHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  String StepsToDistance(int steps, bool isMiles) {
    double stepsInKm = steps / 1312.33595801;
    double totalDistance;
    String unit;
    double totalTimeInHours = stepsInKm / speedInHours;
    DateTime dateTime = DateTime(0, 0, 0, totalTimeInHours.toInt(), (totalTimeInHours % 1 * 60).toInt());
    String formattedTime = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    List<String> timeParts = formattedTime.split(':');
    int hours = int.parse(timeParts[0]);
    int minutes = int.parse(timeParts[1]);
    setState(() {
      totalDuration= Duration(hours: hours, minutes: minutes);
    });
    SharedPref().saveDuration( totalDuration);
    if (isMiles) {
      // Convert steps to miles
      totalDistance = stepsInKm * 0.62137;
      unit = " miles";
    } else {
      // Convert steps to meters
      totalDistance = stepsInKm * 1000;
      unit = " m";
    }

    if (totalDistance >= 1000) {
      // If the total distance is 1 kilometer or more, return in kilometers
      setState(() {
        // totalDuration = Duration.zero; // or set it to the desired value
        inMiles = isMiles ? totalDistance : totalDistance / 1609.34;
      });
      // SharedPref().saveDuration(totalDuration);
      return "${isMiles ? totalDistance.toStringAsFixed(1) + unit : (totalDistance / 1000).toStringAsFixed(1)+ " Km" } ";
    } else {
      // If the total distance is less than 1 kilometer, return in meters
      setState(() {
        // totalDuration = Duration.zero; // or set it to the desired value
        inMiles = isMiles ? totalDistance * 1609.34 : totalDistance;
      });
      // SharedPref().saveDuration(totalDuration);
      return "${isMiles ? (totalDistance * 1609.34).toStringAsFixed(1) + unit : totalDistance.toStringAsFixed(1) + " m"} ";
    }
  }



  void _getLastResetDay() async {
    // print("--------------------------->getlast reset Day");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastResetDay = prefs.getInt('lastResetDay');
    });
    // print("--------------------------->last reset Day"+_lastResetDay.toString());
    // print("--------------------------->Today Day"+DateTime.now().day.toString());
    if (_lastResetDay != DateTime.now().day){
      // print("--------------------------->in no equals to of last reset day");
      setState(() {
        totalDuration=Duration.zero;
        StepsCompleted=0;
        SharedPref().setTodaysSteps(0);
        SharedPref().saveDuration(Duration.zero);
        newday=true;
      });


    }else{
      setState(() {
        newday=false;
      });
    }
  }
  firstTimeInstalled(int steps) async {
    // print(" firstTimeInstalled");
    await SharedPref().setLastDaySteps(steps);
    await SharedPref().setIntroScreenInfo(true);
    await prefs?.setInt('lastResetDay', DateTime.now().day);
    SharedPref().saveDuration(Duration.zero);
    if(StepscomingFromFirebase>0){
      setState(() {
        introdone=true;
        LastDaySteps=steps;
        _lastResetDay=DateTime.now().day;
        StepsCompleted=StepscomingFromFirebase;
        ExtraSteps=0;
        isStart=true;
      });
      if(isGuest){
        // print("first Time Called Guest");
        SharedPref().setStepsTarget(StepsTarget);
        SharedPref().setisStart(true);
      }else{
        // print("first Time Called login");
        _services.sendStepsToFirebase(StepsCompleted);
        SharedPref().setStepsTarget(StepsTarget);
      }
    }else{
      setState(() {
        introdone=true;
        LastDaySteps=steps;
        StepsCompleted=steps-LastDaySteps;
        _lastResetDay=DateTime.now().day;
        ExtraSteps=0;
        isStart=true;
      });
      if(isGuest){
        // print("first Time Called Guest");
        SharedPref().setStepsTarget(StepsTarget);
        SharedPref().setisStart(true);
      }else{
        // print("first Time Called login");
        _services.sendStepsToFirebase(StepsCompleted);
        SharedPref().setStepsTarget(StepsTarget);
      }
    }
  }
  Future<int> startListening(BuildContext context) async {

    // print("startListening()");

        if(await Permission.activityRecognition.request().isGranted)
        {
          int Switchoff=0;
        Future<void> Switchoffmethod() async {
          int Switch =await SharedPref().getfSwitchoffThenvalue()??0;
          setState(() {
            Switchoff=Switch;
          });
        }

        _subscription = Pedometer.stepCountStream.listen(
              (StepCount event) async {
                if(event.steps==0){
                  SharedPref().setifSwitchoffThenvalue(StepsCompleted);
                }
                if(introdone==false ){
                  firstTimeInstalled(event.steps);
                }
                else if(DateTime.now().day!=_lastResetDay){
                  _resetStepCount(event.steps);
                }else {
                  StepsCompleted = event.steps - LastDaySteps;
                  if (StepsCompleted < 0) {
                    Switchoff = await SharedPref().getfSwitchoffThenvalue();
                      setState(() {
                        StepsCompleted = Switchoff + event.steps;
                      });
                       if(StepscomingFromFirebase>0){
                         setState(() {
                           StepsCompleted=StepsCompleted+StepscomingFromFirebase;
                         });
                       }
                    Future.delayed(Duration(seconds: 2),()
                    async {
                      indicatorProgress = (StepsCompleted / StepsTarget) as double;
                      if (indicatorProgress >= 1) {
                        setState(() {
                          indicatorProgress = 1;
                        });
                      }
                      await SharedPref().setTodaysSteps(StepsCompleted);
                    DateTime now = DateTime.now();
                    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
                    updateStepCount(DateTime.parse(formattedDate), StepsCompleted);
                    isGuest==false?_services.sendStepsToFirebase(StepsCompleted):null;
                    // SharedPref().saveStepsData(stepCounts);
                      SharedPref().setStepsData(StepsCompleted).then((value) async {
                        Map<String, dynamic> StepsData= await SharedPref().getStepsData();
                        // print("Steps-------------------------> ${StepsData}");
                      });
                    });
                  }
                  else {
                    setState(() {
                      StepsCompleted = event.steps - LastDaySteps;
                    });
                    if(StepscomingFromFirebase>0){
                      setState(() {
                        StepsCompleted=StepsCompleted+StepscomingFromFirebase;
                      });
                      indicatorProgress = (StepsCompleted / StepsTarget) as double;
                      if (indicatorProgress >= 1) {
                        setState(() {
                          indicatorProgress = 1;
                        });
                      }
                      await SharedPref().setTodaysSteps(StepsCompleted);
                      DateTime now = DateTime.now();
                      String formattedDate = DateFormat('yyyy-MM-dd').format(now);
                      updateStepCount(DateTime.parse(formattedDate), StepsCompleted);
                      isGuest==false?_services.sendStepsToFirebase(StepsCompleted):null;
                      // SharedPref().saveStepsData(stepCounts);
                      SharedPref().setStepsData(StepsCompleted).then((value) async {
                        Map<String, dynamic> StepsData= await SharedPref().getStepsData();
                        // print("Steps-------------------------> ${StepsData}");
                      });
                      SharedPref().setifSwitchoffThenvalue(StepsCompleted);
                    }else{
                      indicatorProgress = (StepsCompleted / StepsTarget) as double;
                      if (indicatorProgress >= 1) {
                        setState(() {
                          indicatorProgress = 1;
                        });
                      }
                      await SharedPref().setTodaysSteps(StepsCompleted);
                      DateTime now = DateTime.now();
                      String formattedDate = DateFormat('yyyy-MM-dd').format(now);
                      updateStepCount(DateTime.parse(formattedDate), StepsCompleted);
                      isGuest==false?_services.sendStepsToFirebase(StepsCompleted):null;
                      // SharedPref().saveStepsData(stepCounts);
                      SharedPref().setStepsData(StepsCompleted).then((value) async {
                        Map<String, dynamic> StepsData= await SharedPref().getStepsData();
                        // print("Steps-------------------------> ${StepsData}");
                      });
                      SharedPref().setifSwitchoffThenvalue(StepsCompleted);
                    }

                  }
                }



          },

          onError: (error) => print('Error: $error'),
        );
        // Pedestrian Status Stream
        _pedestrianStatusSubscription =
            Pedometer.pedestrianStatusStream.listen((PedestrianStatus event) {
              setState(() {
                _pedestrianStatus = event.status;
              });
            });
        }else{
          // await Permission.activityRecognition.request();
          // await Permission.location.request();
          setState(() {
            isStart=false;
            SharedPref().setisStart(false);
          });
        }

    return StepsCompleted;
  }
  void _resetStepCount(int steps) async {
      stopListening();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastResetDay', DateTime.now().day);
    await SharedPref().setLastDaySteps(steps);
    SharedPref().setTodaysSteps(0);
    // SharedPref().setisStart(false);
    // SharedPref().setStartTime(DateTime.now().toString());
    SharedPref().saveDuration(Duration.zero);
    SharedPref().setStepsComingFromFirebase(0);
    setState(() {
      _lastResetDay=DateTime.now().day;
      LastDaySteps=steps;
      StepsCompleted =0;
      StepscomingFromFirebase=0;
      newday=false;
      ExtraSteps=0;
    });
    // print("new Day in _reset last day------------------->"+newday.toString());
    // startListening();
  }
  void stopListening() {
    _subscription?.cancel();
    _pedestrianStatusSubscription?.cancel();
  }
  double calculateCaloriesBurnt(int totalSteps) {
    // Constants for METs value for walking at different speeds
    const double slowWalkingMETs = 2.9;
    const double normalWalkingMETs = 3.9;
    const double fastWalkingMETs = 5.9;

    // Weight in kg (replace with actual weight)
    double weight = 60.0;

    // Convert total steps to distance (in km)
    double distanceInKm = totalSteps *
        0.000762; // Assuming an average stride length of 0.762 meters

    // Calculate time based on average walking speed (adjust as needed)
    double timeInHours =
        distanceInKm / 4.8; // Assuming normal walking speed of 4.8 km/h

    // Choose the appropriate METs value based on walking speed
    double METs;
    if (timeInHours < 1.0) {
      METs = slowWalkingMETs;
    } else if (timeInHours >= 1.0 && timeInHours < 2.0) {
      METs = normalWalkingMETs;
    } else {
      METs = fastWalkingMETs;
    }

    // Calculate calories burnt
    double caloriesBurnt = METs * weight * timeInHours;

    return caloriesBurnt;
  }
Future<bool> checkifotherloggedin() async {
    bool check=await SharedPref().getischecking();
    return check;
}
  Future<void> getUserData() async {
    bool IntroDone=await SharedPref().getIntroScreenInfo();
    bool isstart=await SharedPref().getisStart();
    int stepscmingFromfirebase= await SharedPref().getStepsComingFromFirebase();
    int TodaysSteps=await SharedPref().getTodaysSteps()??0;
    bool isguest=await SharedPref().getisguest();
    String _uid = await SharedPref().getUid();
    int target=await SharedPref().getStepsTarget();
    bool isChecking=await SharedPref().getischecking();
    final Map<String, dynamic> stepsdata = await SharedPref().getStepsData();
    // DateTime StartTi=await SharedPref().getStartTime()??DateTime.now();
    Duration? Activity = await SharedPref().getSavedDuration();
    bool isMiles=await SharedPref().getisMiles();
    int lastDayStep=await SharedPref().getLastDaySteps();
    int extra=await SharedPref().getextraSteps()??0;
    setState(() {
      Uid=_uid;
      ischecking=isChecking;
      introdone=IntroDone;
      isGuest=isguest;
      StepscomingFromFirebase=stepscmingFromfirebase;
      LastDaySteps=lastDayStep;
      StepsCompleted=TodaysSteps;
      isStart=isstart;
      StepsTarget=target;
      // startTime=StartTi;
      totalDuration=Activity??Duration.zero;
      // SharedPref().setIntroScreenInfo(true);
      isMils=isMiles;
      ExtraSteps=extra;
      stepsData=stepsdata;
    });
    checkisSingleDeviceloggedIn( Uid, Deviceid, isGuest);
     print("------------------------------------------------------/-------------------------------${stepsdata}");

  }
  void setstatecallback(){
    setState(() {

    });
  }
List<String> WhichGraoh=['Day','Week','Month'];
  int indexofwhichGraph=0;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        extendBody: true,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w,
            //70.h
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 70),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Steps',
                        style: TextStyle(
                          color: Color(0xFFF3F3F3),
                          fontSize: 54.sp,
                          fontFamily: 'Teko',
                          fontWeight: FontWeight.w600,
                          height: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width*0.6,
                        height: MediaQuery.of(context).size.width*0.6,
                        child: CustomPaint(
                          painter:  GradiantArchProgress(
                              startColor: Color(0xFFFF8900),
                              endColor: Color(0xD5CE00FF), StepsCompleted: StepsCompleted, StepsTarget: StepsTarget, width: 25.0),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Text("Move",style: TextStyle(
                  color: Color(0xFFF3F3F3),
                  fontSize: 34.sp,
                  fontFamily: 'Teko',
                  fontWeight: FontWeight.w600,
                  height: 0,
                  letterSpacing: 1
                ),),
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [
                        Color(0xFFFF8900),
                        Color(0xFFCE00FF)
                      ],  // Replace these colors with your desired gradient colors
                      begin: Alignment.center,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Text(
                    StepsCompleted.toString() +"/" +StepsTarget.toString()+" Steps",
                    style: TextStyle(
                      fontSize: 46.sp,
                      fontFamily: 'Teko',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: Colors.white,  // Set the color to white since it will be masked by the gradient
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        SvgPicture.asset("lib/assests/NewImages/Kcal.svg"),
                        SizedBox(height: 10,),
                        Text(calculateCaloriesBurnt(StepsCompleted).toStringAsFixed(0)+" Kcal",
                          style: TextStyle(
                            color: Color(0xFFF3F3F3),
                            fontSize: 24.sp,
                            fontFamily: 'Teko',
                            fontWeight: FontWeight.w300,
                            height: 0,
                          ),

                        )
                      ],
                    ),
                     Column(
                      children: [
                        SvgPicture.asset("lib/assests/NewImages/Distance.svg"),
                        SizedBox(height: 10,),
                        Text(StepsToDistance(StepsCompleted,isMils),
                          style: TextStyle(
                            color: Color(0xFFF3F3F3),
                            fontSize: 24.sp,
                            fontFamily: 'Teko',
                            fontWeight: FontWeight.w300,
                            height: 0,
                          ),

                        )
                      ],
                    ),
                     Column(
                      children: [
                        SvgPicture.asset("lib/assests/NewImages/Time.svg"),
                        SizedBox(height: 10,),
                        Text("${totalDuration.inMinutes>60?totalDuration.inHours.toString().padLeft(2, '0') + " H": totalDuration.inMinutes.toString().padLeft(2, '0') + " m"}",
                          style: TextStyle(
                            color: Color(0xFFF3F3F3),
                            fontSize: 24.sp,
                            fontFamily: 'Teko',
                            fontWeight: FontWeight.w300,
                            height: 0,
                          ),
                        )
                      ],
                    ),

                  ],
                ),
                SizedBox(height: 90,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(onPressed: (){
                      setState(() {
                        if(indexofwhichGraph!=0)
                          indexofwhichGraph=indexofwhichGraph-1;
                      });
                    }, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
                    GestureDetector(
                      onTap: (){
                        if(indexofwhichGraph==2)
                         _showCustomDialog(context,StepsTarget);
                      },
                      child: Container(
                        height: 35,
                        width: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFFF8900),
                              Color(0xD5CE00FF)], // Add your desired colors
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),

                          ],
                        ),
                        child: Center(child: Text(WhichGraoh[indexofwhichGraph],style: TextStyle(color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Teko',
                          fontWeight: FontWeight.w300,
                          height: 0,
                        ),)),),
                    ),
                    IconButton(onPressed: (){
                     setState(() {
                       if(indexofwhichGraph!=2)
                         indexofwhichGraph=indexofwhichGraph+1;
                     });
                    }, icon: Icon(Icons.arrow_forward_ios,color: Colors.white,))
                  ],
                ),
                SizedBox(height: 30,),
                LineChartSample2(WhichGraoh[indexofwhichGraph]),
                SizedBox(height: 90,),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _showCustomDialog(BuildContext context,int stepstarget) {
     PageController _pageController= PageController(initialPage: DateTime.now().month - 1);


    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Custom(stepstarget: stepstarget,),
        );
      },
    );
  }
}
class Custom extends StatefulWidget {
  final int stepstarget;
  const Custom({super.key, required this.stepstarget});

  @override
  State<Custom> createState() => _CustomState();
}

class _CustomState extends State<Custom> {
  late PageController _pageController;

  int _currentPageIndex = DateTime.now().month - 1;
  late  List<DayProgress> dailyProgress = [

    // Add progress for other days
  ];
  // Start with the current month
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageIndex);
  }
  int daysInMonth(String Year, String Month) {
    int year=int.parse(Year);
    int month=int.parse(Month);
    if (month == 2) {
      // February
      if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
        // Leap year
        return 29;
      } else {
        // Non-leap year
        return 28;
      }
    } else if ([04, 06, 09, 11].contains(month)) {
      // April, June, September, November
      return 30;
    } else {
      // All other months
      return 31;
    }
  }

  Future<List<DayProgress>> getDailyStepsForCurrentMonth(final Month) async {

    final Map<String, dynamic> stepsData = await SharedPref().getStepsData();

    final now = DateTime.now();
    final year = now.year.toString();
    final month = Month < 10 ? "0" + Month.toString() : Month.toString();

    // Initialize a list to store daily steps for the current month
    List<int> dailyStepsList = [];

    Map<String, int> dailyStepsMap = {};
    for (int i = 1; i <= daysInMonth(year, month); i++) {
      String day = i < 10 ? "0$i" : "$i";
      dailyStepsMap["$day"] = 0;
    }
    if (stepsData.containsKey(year) && stepsData[year].containsKey(month)) {
      // Loop through each date in the current month
      stepsData[year][month].forEach((dateKey, dateValue) {
        // Calculate the total steps for the current date
        print(dateKey);
        int totalStepsForDate = dateValue.values.fold<dynamic>(
          0,
              (previousValue, element) => previousValue + (element is int ? element : 0),
        );

        // Add the total steps for the current date to the list
        if (totalStepsForDate > 0) {
          dailyStepsMap[dateKey] = totalStepsForDate;
          setState(() {
            dailyProgress.add(DayProgress(int.parse(dateKey), int.parse(month), totalStepsForDate/widget.stepstarget));
          });
        }
      });
    }else{
      print("not exist------------------------------------------------------------------------------------------------------------------------------->");
    }
    // Check if the current month exists in the stepsData
    return dailyProgress;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
          DateFormat('MMMM yyyy').format(DateTime(DateTime.now().year, _currentPageIndex + 1, 1)),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.0),
          SizedBox(
            height: 250,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                print("on change");
                setState(() {
                  _currentPageIndex = index;
                });
                // getDailyStepsForCurrentMonth(index+1).then((value) => {
                //   setState(() {
                //     dailyProgress=value;
                //   })
                // });
              },
              itemBuilder: (context, index) {

                getDailyStepsForCurrentMonth(index+1).then((value) => {
                setState(() {
                    dailyProgress=value;
                  })
                });
                return MonthCalendar(currentMonth: index + 1, StepsTarget: widget.stepstarget, dailyProgress: dailyProgress,);
              },
              itemCount: 12, // 12 months in a year

            ),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

class DayProgress {
  final int day;
  final int month;
  final double progress;

  DayProgress(this.day, this.month ,this.progress , );
}

class MonthCalendar extends StatefulWidget {
  final int currentMonth;
final int StepsTarget;
  final List<DayProgress> dailyProgress ;
  MonthCalendar({required this.currentMonth, required this.StepsTarget, required this.dailyProgress});

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  //
  // final List<DayProgress> dailyProgress = [
  //
  //   // Add progress for other days
  // ];


  // Rest of your existing code for DayTile, RingPainter, and DayProgress
  @override
  Widget build(BuildContext context) {
    // print("Yash"+widget.currentMonth.toString());
    // getDailyStepsForCurrentMonth();
    // Timer.periodic(Duration(seconds: 1), (timer) {
    //   getDailyStepsForCurrentMonth();
    // });
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 0.0,
        crossAxisSpacing: 0.0,
      ),
      itemBuilder: (context, index) {
        final day = index + 1;
        // Adjust the logic for progress based on the month
        final progress = widget.dailyProgress.firstWhere((dp) => dp.day == day && dp.month == widget.currentMonth, orElse: () => DayProgress(day, widget.currentMonth , 0.0)).progress;
        return DayTile(day: day, progress: progress);
      },
      itemCount: DateTime(DateTime.now().year, widget.currentMonth + 1, 0).day, // Number of days in the month
    );
  }
}
class DayTile extends StatelessWidget {
  final int day;
  final double progress;

  DayTile({required this.day, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.grey),
      // ),
      child: Center(
        child: CustomPaint(
          painter: RingPainter(progress, Color(0xFFFF8900),
            Color(0xD5CE00FF),),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              day.toString(),
              style: TextStyle(fontSize: 10),
            ),
          ),
        ),
      ),
    );
  }
}

class RingPainter extends CustomPainter {
  late final Color startColor;
  late final Color endColor;
  final double progress;

  RingPainter(this.progress, this.startColor,this.endColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 15.0;
    final strokeWidth = 3.0;
    final rect = new Rect.fromLTWH(0.0, 0.0, size.width, size.height);
    final gradient=SweepGradient(
      startAngle: 3*math.pi/2,
      endAngle: 7*math.pi/2,
      tileMode: TileMode.repeated,
      colors: [
        startColor,
        endColor,
        startColor,
      ],
    );
    final ringPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..strokeCap=StrokeCap.round
      ..shader=gradient.createShader(rect)
      ..style=PaintingStyle.stroke
      ..strokeWidth=strokeWidth;

    final backgroundPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Draw background ring
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress ring
    final progressAngle = 2 * 3.14 * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -3.14 / 2, progressAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}