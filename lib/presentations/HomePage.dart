// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
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
import '../SharedPrefrences/SharedPref.dart';
import '../main.dart';
import '../widgets/BottomNavbar.dart';
import 'Back_Service.dart';
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

class _HomePageState extends State<HomePage> {
  int StepsTarget = 0;
  int StepsCompleted = 0;
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
  void initState() {
    super.initState();
    AndroidAlarmManager.initialize();


    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    notificationServices.initializeNotification() ;
    _getLastResetDay();
    getUserData();
    firebaseData();

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
    print("this Speed is In get Speed Method------------------------------------------>"+currentSpeed.toString());
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
       print("infirebase data");
       print("Print is guest in firebase "+isGuest.toString());
      String _uid = await SharedPref().getUid();
      DatabaseReference databaseReference = FirebaseDatabase.instance
          .reference()
          .child('users')
          .child(_uid)
          .child('defaultsteps');
      try {
        databaseReference.onValue.listen((event) {
          print("sixinxs: "+event.snapshot.value.toString());
          setState(() {
           StepsTarget = int.parse(event.snapshot.value.toString());
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

  String StepstoKilometer(int steps) {
    double StepsinKm = steps / 1312.33595801;
    double totalTimeInHours = StepsinKm / speedInHours;
    DateTime dateTime = DateTime(0, 0, 0, totalTimeInHours.toInt(), (totalTimeInHours % 1 * 60).toInt());
    String formattedTime = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    List<String> timeParts = formattedTime.split(':');
    int hours = int.parse(timeParts[0]);
    int minutes = int.parse(timeParts[1]);
    double inMils= StepsinKm* 0.62137;
    print("in hours-------------------------------------->"+hours.toString());
  print("in minutes-------------------------------------->"+minutes.toString());
    setState(() {
    totalDuration= Duration(hours: hours, minutes: minutes);
      inMiles=inMils;
    });
    SharedPref().saveDuration( totalDuration);
    return StepsinKm.toStringAsFixed(1);
  }

  void _getLastResetDay() async {
    print("--------------------------->getlast reset Day");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastResetDay = prefs.getInt('lastResetDay');
    });
    print("--------------------------->last reset Day"+_lastResetDay.toString());
    print("--------------------------->Today Day"+DateTime.now().day.toString());
    if (_lastResetDay != DateTime.now().day){
      print("--------------------------->in no equals to of last reset day");
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
    print(" firstTimeInstalled");
    await SharedPref().setLastDaySteps(steps);
    await SharedPref().setIntroScreenInfo(true);
    setState(() {
      introdone=true;
      LastDaySteps=steps;
      StepsCompleted=steps-LastDaySteps;
      ExtraSteps=0;
      isStart=true;
    });
     if(isGuest){
       print("first Time Called Guest");
       SharedPref().setStepsTarget(StepsTarget);
       SharedPref().setisStart(true);
     }else{
       print("first Time Called login");
       sendStepsToFirebase(StepsCompleted);
       SharedPref().setStepsTarget(StepsTarget);
     }
  }
  Future<int> startListening(BuildContext context) async {

    print("startListening()");

        if(await Permission.activityRecognition.request().isGranted){
          int Switchoff=0;
        Future<void> Switchoffmethod() async {
          int Switch =await SharedPref().getfSwitchoffThenvalue()??0;
          setState(() {
            Switchoff=Switch;
          });
        }

        _subscription = Pedometer.stepCountStream.listen(
              (StepCount event) async {
                getSpeed();
                if(event.steps==0){
                  SharedPref().setifSwitchoffThenvalue(StepsCompleted);
                }
                if( introdone==false){
                  print("in Intro Done");
                  firstTimeInstalled(event.steps);
                }
                else if(DateTime.now().day!=_lastResetDay){
                  print("in not equals to last day");
                  _resetStepCount(event.steps);
                }else {
                  print("steps " + StepsCompleted.toString() + "Last Day Steps " +
                      (LastDaySteps).toString());
                  StepsCompleted = event.steps - LastDaySteps;
                  if (StepsCompleted < 0) {
                    print("less zero in home");
                    Switchoff = await SharedPref().getfSwitchoffThenvalue();
                    // Switchoffmethod();
                    // int laststeps=await SharedPref().getfSwitchoffThenvalue();
                    // setState(() {
                    //   LastDaySteps = laststeps;
                    // });
                    print("new Last steps "+Switchoff.toString());
                      setState(() {
                        StepsCompleted = Switchoff + event.steps;
                      });
                    print("Steps Newwww--------------------->"+ StepsCompleted.toString());
                    Future.delayed(Duration(seconds: 2),()
                    async {
                      indicatorProgress = (StepsCompleted / StepsTarget) as double;
                      if (indicatorProgress >= 1) {
                        setState(() {
                          indicatorProgress = 1;
                        });
                      }
                      await SharedPref().setTodaysSteps(StepsCompleted);
                      print("Steps After All calculations" + StepsCompleted.toString());
                    DateTime now = DateTime.now();
                    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
                    updateStepCount(DateTime.parse(formattedDate), StepsCompleted);
                    isGuest==false?sendStepsToFirebase(StepsCompleted):null;
                    print("Map is ---------------------------------------------------->" + stepCounts.toString());
                    SharedPref().saveStepsData(stepCounts);
                    });
                  } else {
                    setState(() {
                      StepsCompleted = event.steps - LastDaySteps;
                    });
                    print("More zero in home");
                    indicatorProgress = (StepsCompleted / StepsTarget) as double;
                    if (indicatorProgress >= 1) {
                      setState(() {
                        indicatorProgress = 1;
                      });
                    }
                    await SharedPref().setTodaysSteps(StepsCompleted);
                    print("Steps After All calculations" + StepsCompleted.toString());
                    DateTime now = DateTime.now();
                    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
                    updateStepCount(DateTime.parse(formattedDate), StepsCompleted);
                    isGuest==false?sendStepsToFirebase(StepsCompleted):null;
                    print("Map is ---------------------------------------------------->" + stepCounts.toString());
                    SharedPref().saveStepsData(stepCounts);
                    SharedPref().setifSwitchoffThenvalue(StepsCompleted);
                    print("Steps Coming back from Set Switchoff"+await SharedPref().getfSwitchoffThenvalue().toString());
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
    setState(() {
      _lastResetDay=DateTime.now().day;
      LastDaySteps=steps;
      StepsCompleted =0;
      newday=false;
      ExtraSteps=0;
    });
    print("new Day in _reset last day------------------->"+newday.toString());
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

  Future<void> getUserData() async {
    bool IntroDone=await SharedPref().getIntroScreenInfo();
    bool isstart=await SharedPref().getisStart();
    int TodaysSteps=await SharedPref().getTodaysSteps()??0;
    bool isguest=await SharedPref().getisguest();
    String _uid = await SharedPref().getUid();
    int target=await SharedPref().getStepsTarget();
    bool isChecking=await SharedPref().getischecking();
      print("Target From shared Pref-------------------------->"+target.toString());
    // DateTime StartTi=await SharedPref().getStartTime()??DateTime.now();
    Duration? Activity = await SharedPref().getSavedDuration();
    bool isMiles=await SharedPref().getisMiles();
    print("intro done: "+IntroDone.toString());
    print("Guest: before setting"+isGuest.toString());
    // print(StartTi);
    int lastDayStep=await SharedPref().getLastDaySteps();
    int extra=await SharedPref().getextraSteps()??0;
    print("Uid in get userdata :  "+_uid);
    setState(() {
      Uid=_uid;
      ischecking=isChecking;
      introdone=IntroDone;
      isGuest=isguest;
      LastDaySteps=lastDayStep;
      StepsCompleted=TodaysSteps;
      isStart=isstart;
      StepsTarget=target;
      // startTime=StartTi;
      totalDuration=Activity??Duration.zero;
      // SharedPref().setIntroScreenInfo(true);
      isMils=isMiles;
      ExtraSteps=extra;
    });
    print("Guest: after setting"+isGuest.toString());
    if(isstart){
      startListening(context);
      await initializeService();
    }

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
  void showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(0),
          child: Container(
            width: 300.w,
            height: 250.h,
            decoration: ShapeDecoration(
              color: Color(0xFF2D2D2D),
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: Color(0xFF9D79BC)),
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            child: Padding(
              padding:  EdgeInsets.symmetric(horizontal: 25.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // SizedBox(height: 10.h,),
                   Stack(

                      children: [Lottie.asset("lib/assests/Images/Confetti_Animation.json", width: 100.w,),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 25.w,vertical: 25),
                          child: Image(
                            image: AssetImage("lib/assests/Images/twemoji_confetti-ball.png"),
                            width: 50.w,
                          ),
                        ),
                      ]
                    ),
                    // Image(
                    //   image: AssetImage("lib/assests/Images/twemoji_confetti-ball.png"),
                    //   width: 50.w,
                    // ),

                  // SizedBox(height: 5.h),  // Adjust this spacing as needed
                  Text(
                    'Voila! You have achieved your today’s goal of $StepsTarget steps.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white), // Adjust text style as needed
                  ),
                  SizedBox(height: 5.h),  // Adjust this spacing as needed
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.purple, // This is the primary color, i.e., the background color
                        onPrimary: Colors.white, // This is the color of the text
                        // Other styling properties can be added here too
                      ),
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop(); // Closes the dialog
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

  }
void checkisSingleDeviceloggedIn() async{
    print("checkSingleDeviceLoggededIn calling after 1 sec");
  AuthServices authServices2=AuthServices();
    String Firebaseid="";
    print("Uid:  "+  Uid);
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('users').child(Uid).child('Device_ID');
  try {
    databaseReference.onValue.listen((event) async {
      Firebaseid=event.snapshot.value.toString();
      print("Firebase Devide Idddddddddd"+event.snapshot.value.toString());
      print("Firebase Deviceid"+Firebaseid);
      print("SharedPref Device ID:"+Deviceid);
    });
  } catch (e) {
    print('Error: $e');
  }
    Future.delayed(Duration(seconds: 5),(){
      if(isGuest){}else{
        if(Deviceid!=Firebaseid && Firebaseid!=null){
          print("in notEquals");
          // setState(() {
          //   ischecking=false;
          //
          // });
          SharedPref().setischecking(false);
          authServices2.signout().then((value) => Get.offAll(()=>SignUpScreen()));
        }
        else{
          print("in Equals");
        }
      }
    });
}
  @override
  Widget build(BuildContext context) {
    // Timer.periodic(Duration(seconds: 60), (timer) async {
    //   int steps=await SharedPref().getTodaysSteps()??0;
    //   setState(() {
    //     StepsCompleted=steps;
    //   });
    // });
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: Color(0xFF2D2D2D),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w,
          //70.h
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 55.h,),

              Text(
                'TODAY’S STEPS',
                style: TextStyle(
                  color: Color(0xFFF3F3F3),
                  fontSize: 54.sp,
                  fontFamily: 'Teko',
                  fontWeight: FontWeight.w600,
                  height: 0,
                ),
              ),
              SizedBox(
                  height: deviceHeight(context) < 900 ? 70.h : 50.h
              ),
              Visibility(
                visible: isStart!=true,
                child: Center(
                  child: Text(
                    'Press To Start Tracking Your Steps',
                    style: TextStyle(
                      color: Color(0xFFF3F3F3),
                      fontSize: 25.sp,
                      fontFamily: 'Teko',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      height: 0,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: deviceHeight(context) < 900 ? 45.h : 100.h
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularPercentIndicator(
                    radius: 150.r,
                    animation: true,
                    animationDuration: 1000,
                    animateFromLastPercent: true,
                    reverse: true,
                    circularStrokeCap: CircularStrokeCap.round,
                    percent: indicatorProgress<0?0:indicatorProgress,
                    lineWidth: 12.w,
                    progressColor: Color(0xFF9D79BC),
                    center:

                    isStart?Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: StepsCompleted.toString(),
                                  style: TextStyle(
                                    color: Color(0xFFF3F3F3),
                                    fontSize: 75.sp,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    height: 0,
                                  ),
                                ),
                                TextSpan(text: "  "),
                                TextSpan(
                                  text: '/',
                                  style: TextStyle(
                                    color: Color(0xFFF3F3F3),
                                    fontSize: 25.sp,
                                    fontFamily: 'Work Sans',
                                    fontWeight: FontWeight.w400,
                                    height: 0,
                                  ),
                                ),
                                TextSpan(
                                  text: "\n$StepsTarget ($_pedestrianStatus)",
                                  style: TextStyle(
                                    color: Color(0xFFF3F3F3),
                                    fontSize: 20.sp,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 0,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ):Container(
                      height: 10000.h,
                            width: 10000.w,
                            child: IconButton(onPressed: () async {
                              showDialog(
                                builder: (BuildContext context) {
                                  return SizedBox(
                                    child: Dialog(

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(9.r),
                                        side: BorderSide(color: Color(0xFF9D79BC),width: 2,),

                                      ),

                                      child:
                                      Container(
                                        height:550.h,
                                        width: 1000.w,
                                        color: Colors.black,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 35.h,),
                                            Image.asset("lib/assests/Images/DialogueboxLOgo.png",
                                            height: 75.h,
                                            ),
                                            SizedBox(height: 25.h,),
                                            SizedBox(
                                                width: 300.w,
                                                child: Text(
                                                  'Step tracker needs below Permissions to Function Properly.',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18.sp,
                                                    fontFamily: 'Nunito',
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                            ),
                                            SizedBox(height: 15.h,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width:300.w,
                                                  child: RichText(
                                                    text:  TextSpan(
                                                        text: '• "Physical Activity": ',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16.sp,
                                                          fontFamily: 'Nunito',
                                                          fontWeight: FontWeight.bold,
                                                          height: 0,
                                                          letterSpacing: 0.16,
                                                        ),
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                            text: 'This permission is\n  necessary for the app to accurately count\n  your steps. It enables the app to monitor\n  your physical movements and determine\n  when you'+'re walking.\n',
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontFamily: 'Nunito',
                                                              fontSize: 14.sp,
                                                              fontWeight: FontWeight.w400,
                                                              height: 1,
                                                            ),
                                                            // recognizer: TapGestureRecognizer()
                                                            //   ..onTap = () {
                                                            //     Loginpage();
                                                            //   },
                                                          ),
                                                        ]),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 2.h,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width:300.w,
                                                  child: RichText(
                                                    text:  TextSpan(
                                                        text: '• "Location": ',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16.sp,
                                                          fontFamily: 'Nunito',
                                                          fontWeight: FontWeight.bold,
                                                          height: 0,
                                                          letterSpacing: 0.16,
                                                        ),
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                            text: 'The location permission is used\n   to distinguish whether you are walking or\n   using a vehicle. By checking your location,\n   the app can better determine your mode of\n   transportation, helping it provide you with\n   more precise step tracking information.',
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontFamily: 'Nunito',
                                                              fontSize: 14.sp,
                                                              fontWeight: FontWeight.w400,
                                                              height: 1,
                                                            ),
                                                            // recognizer: TapGestureRecognizer()
                                                            //   ..onTap = () {
                                                            //     Loginpage();
                                                            //   },
                                                          ),
                                                        ]),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 15.h,),
                                            SizedBox(
                                                width: 300.w,
                                                child: Text("By granting these permissions, you allow the app to provide you with the most accurate step tracking experience possible.",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14.sp,
                                                    fontFamily: 'Nunito',
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                )),
                                            SizedBox(height: 20.h,),
                                            ElevatedButton(style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                              overlayColor: MaterialStateProperty.all<Color>(Colors.white.withOpacity(1)), // Adjust opacity as needed
                                            ),onPressed: () async {
                                              PermissionStatus status1=await Permission.activityRecognition.request();
                                              PermissionStatus status2=await Permission.location.request();
                                              PermissionStatus status3=await Permission.sensors.request();
                                              if(status1.isGranted && status2.isGranted){
                                                startListening(context).then((value) async {
                                                Future.delayed(Duration(seconds: 10),() async {
                                                      await initializeService();
                                                     });
                                                });

                                                // notificationServices.scheduleNotifications();
                                                setState(() {
                                                  isStart = true;
                                                });
                                                SharedPref().setisStart(true);
                                              }else{
                                                setState(() {
                                                  isStart = false;
                                                });
                                                SharedPref().setisStart(false);
                                                showDialog(
                                                  builder: (BuildContext context) {
                                                    return Dialog(

                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(9.r),
                                                        side: BorderSide(color: Color(0xFF9D79BC),width: 2,),

                                                      ),

                                                      child:
                                                      Container(
                                                        height:171.h,
                                                        width: 362,
                                                        color: Colors.black,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            SizedBox(height: 35.h,),
                                                            Text(
                                                              'Allow the permission',
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 20,
                                                                fontFamily: 'Nunito',
                                                                fontWeight: FontWeight.w400,
                                                                height: 0.06,
                                                              ),
                                                            ),
                                                            SizedBox(height: 20.h,),
                                                            Image.asset("lib/assests/Images/Small_Logo.png",),
                                                            SizedBox(height: 7.h,),
                                                            ElevatedButton(style: ButtonStyle(
                                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                                              overlayColor: MaterialStateProperty.all<Color>(Colors.white.withOpacity(1)), // Adjust opacity as needed
                                                            ),onPressed: () async {

                                                              bool isOpened = await openAppSettings();
                                                              print('App settings opened: $isOpened');
                                                              Navigator.pop(context);

                                                            }, child: Text("Allow",
                                                              style: TextStyle(
                                                                  color: Colors.black
                                                              ),
                                                            ))
                                                          ],
                                                        ),
                                                      ),

                                                    );
                                                  },
                                                  context: context,
                                                );
                                              }

                                              Navigator.pop(context);

                                            }, child: Text("Allow",
                                              style: TextStyle(
                                                  color: Colors.black
                                              ),
                                            ))
                                          ],
                                        ),
                                      ),

                                    ),
                                  );
                                },
                                context: context,
                              );
                            }, icon: Icon(Icons.play_arrow_rounded,
                              size: 200,
                    ),),
                          ),
                  ),
                ],
              ),
              SizedBox(
                height: 155.h,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    Container(
                      width: 113.w,
                      height: 84.h,
                      // padding: const EdgeInsets.symmetric(horizontal: 10., vertical: 15),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: Color(0xFFE2C391),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 13.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Opacity(
                              opacity: 0.50,
                              child: Text(
                                'TIME',
                                style: TextStyle(
                                  color: Color(0xFF2D2D2D),
                                  fontSize: 14.sp,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  height: 0,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 8.h,
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${totalDuration.inHours.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      color: Color(0xFF2D2D2D),
                                      fontSize: 21.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'h',
                                    style: TextStyle(
                                      color: Color(0xFF2D2D2D),
                                      fontSize: 12.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' ${(totalDuration.inMinutes % 60).toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      color: Color(0xFF2D2D2D),
                                      fontSize: 21.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'm',
                                    style: TextStyle(
                                      color: Color(0xFF2D2D2D),
                                      fontSize: 12.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 0,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                    Container(
                      width: 113.w,
                      height: 84.h,
                      // padding: const EdgeInsets.symmetric(horizontal: 10., vertical: 15),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: Color(0xFF9BBEC7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 13.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Opacity(
                              opacity: 0.50,
                              child: Text(
                                'DISTANCE',
                                style: TextStyle(
                                  color: Color(0xFF2D2D2D),
                                  fontSize: 14.sp,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  height: 0,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 6.h,
                            ),
                            Center(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: isMils?inMiles.toString():StepstoKilometer(StepsCompleted),
                                      style: TextStyle(
                                        color: Color(0xFF2D2D2D),
                                        fontSize: 22.sp,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 0,
                                      ),
                                    ),
                                    TextSpan(
                                      text: isMils?"mi":'Km.',
                                      style: TextStyle(
                                        color: Color(0xFF2D2D2D),
                                        fontSize: 12.sp,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 0,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                    Container(
                      width: 113.w,
                      height: 84.h,
                      // padding: const EdgeInsets.symmetric(horizontal: 10., vertical: 15),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: Color(0xFFF6E27F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 17.w, vertical: 13.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Opacity(
                              opacity: 0.50,
                              child: Text(
                                'CALORIES',
                                style: TextStyle(
                                  color: Color(0xFF2D2D2D),
                                  fontSize: 14.sp,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  height: 0,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 6.h,
                            ),
                            Center(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: calculateCaloriesBurnt(
                                              StepsCompleted)
                                          .toStringAsFixed(0),
                                      style: TextStyle(
                                        color: Color(0xFF2D2D2D),
                                        fontSize: 22.sp,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 0,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Kcal',
                                      style: TextStyle(
                                        color: Color(0xFF2D2D2D),
                                        fontSize: 12.sp,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 0,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: BottomNavbar(
          currentIndex: 0,
        ),
      ),
    );
  }
}

class AskPermission extends StatefulWidget {
  const AskPermission({super.key});

  @override
  State<AskPermission> createState() => _AskPermissionState();
}

class _AskPermissionState extends State<AskPermission> {
  bool isCross = false;
  Map<Permission, PermissionStatus> status = {};
  String Status = "";
  Future<void> requestLocationPermission(Permission permission) async {
    final status = await permission.request();
    print('Location Permission Status: $status');
    setState(() {
      Status = status.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          !isCross
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      isCross = true;
                    });
                  },
                  icon: Icon(
                    Icons.cancel_outlined,
                    color: Colors.black,
                  ))
              : Container(),
          SizedBox(
            height: isCross ? 63.h : 13.h,
          ),
          SizedBox(
            width: 383.w,
            child: isCross
                ? Text(
                    'Without this permission the App will not work',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  )
                : Text(
                    'This app requires permission to access your physical activity to track steps.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  ),
          ),
          SizedBox(
            height: 40.w,
          ),
          Container(
            width: 381.w,
            height: 62.h,
            child: OutlinedButton(
              onPressed: () async {
                await Permission.activityRecognition.request();
                if ( await Permission.activityRecognition.request().isGranted) {
                  Navigator.of(context).pop();
                }
              },
              style: ButtonStyle(
                  side: MaterialStateProperty.all(
                      BorderSide(width: 2.w, color: Colors.black)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0.r)))),
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'ALLOW',
                      style: TextStyle(
                        color: Color(0xFF2D2D2D),
                        fontSize: 18.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 0,
                      ),
                    ),
                  ]),
            ),
          )
        ],
      ),
    );
  }
}
