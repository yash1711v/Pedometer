// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
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
        print("Steps Completed--------jjjh------------>"+value2.toString());
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
                LineChartSample2("Day"),
                SizedBox(height: 90,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

