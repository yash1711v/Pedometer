import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:device_info/device_info.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gradient_button/flutter_gradient_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:outline_gradient_button/outline_gradient_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:steptracking/presentations/HomePage.dart';
import 'package:steptracking/presentations/MainScreen.dart';
import 'package:wheel_slider/wheel_slider.dart';

import '../Firebasefunctionalities/DatabaseServices.dart';
import '../SharedPrefrences/SharedPref.dart';
import '../widgets/CustomSliderItem.dart';

class UserNameScreen extends StatefulWidget {
  const UserNameScreen({super.key});

  @override
  State<UserNameScreen> createState() => _UserNameScreenState();
}

class _UserNameScreenState extends State<UserNameScreen> {

  int _cCurrentValue = 160;
  int _cCurrentValueWeight = 55;
  late final TextEditingController ageController =
      TextEditingController();
  final FocusNode ageFocusNode = FocusNode();
  late final TextEditingController _defaultStepsController =
      TextEditingController();
  final FocusNode _defaultStepsNode = FocusNode();
  List<String> Images=[
    'lib/assests/NewImages/MaleTheme1.png',
    'lib/assests/NewImages/FemaleTheme1.png',
    'lib/assests/NewImages/OthersTheme1.png'
  ];
  List<String> imagesFoot=[
    'lib/assests/NewImages/SetSettingpageTheme1.png',
    'lib/assests/NewImages/StepSettingpageTheme2.png',
    'lib/assests/NewImages/StepSettingpageTheme3.png'
  ];
  String UserName = "Enter Your Name";
  String Email = '';
  String Password = '';
  String UID = '';
  int defaultSteps = 6000;
  bool isGuest = false;
  List<Color> Theme1 = [
    Color(0xFFF7722A),
    Color(0xFFE032A1),
    Color(0xFFCF03F9)
  ];

  DatabaseServices services = DatabaseServices();
  Map<String, int?> map = {};
  double Height = 166;
  double Weight = 58;
  int Age = 25;
  int StepsTarget = 6000;
  List<String> ActivityLevel = [
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Highly Active'
  ];
  List<double> ActivityLevelNumber = [1.2, 1.375, 1.55, 1.725];
  int ActivityIndex = 0;

  List<String> Imagesunselected = [
    'lib/assests/NewImages/Male.png',
    'lib/assests/NewImages/Female.png',
    'lib/assests/NewImages/Others.png'
  ];
  int Gender = 0;
  String WhichGender(int gender) {
    if (gender == 0) {
      return 'male';
    } else if (gender == 1) {
      return 'female';
    } else {
      return 'other';
    }
  }
int value=0;
  whichthemeImages() async {
    Images = await SharedPref().loadImageList();
  }

  Future<void> whichTheme() async {
    List<Color> Theme = await SharedPref().loadColorList();
    setState(() {
      Theme1 = Theme;
    });
    if(Theme1[0]==Color(0xFFF7722A)){
      setState(() {
        value=0;
      });
    }else if(Theme1[0]==Color(0xFF04EF77)){
      setState(() {
        value=1;
      });
    }else if(Theme1[0]==Color(0xFFFF00E2)){
      setState(() {
        value=2;
      });
    }
    print("which theme image value $value & ${imagesFoot[value]}");
  }

  double inMiles = 0;

  Future<String> getDeviceUID() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceUID = '';

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceUID = androidInfo.androidId; // Or any unique identifier
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceUID = iosInfo.identifierForVendor; // Or any unique identifier
    }

    return deviceUID;
  }
  gettingEmailAndPassword() async {
    String uid=await SharedPref().getUid();
    String email=await SharedPref().getEmail();
    String pass=await SharedPref().getPassword();
    bool isgues=await SharedPref().getisguest();
    ageController.text=Age.toString();
    setState(() {
      UID = uid;
      Email=email;
      Password=pass;
      isGuest=isgues;
    });
  }


  FirebaseSetingUp(BuildContext context) async {
    Map<String, dynamic> stepsData={};
    stepsData=await SharedPref().getStepsData();
    print(stepsData);
    services.writeToDatabase(Uid: UID, username: UserName, Email: Email, gender: await SharedPref().getGender(), Password: Password, defaultSteps: await SharedPref().getStepsTarget(), DeviceId: await SharedPref().getDeviceid(), age: await SharedPref().getAge(), height: await SharedPref().getHeight(), weight: await SharedPref().getWeight(), activityLevel: await SharedPref().getActivityLevel(), context: context,).then((value) {
      services.sendStepsToFirebase(60);
    });
  }
  String formatted2(double totalDistance, bool isMiles, String unit) {
    if (totalDistance >= 1000) {
      // If the total distance is 1 kilometer or more, return in kilometers
      setState(() {
        // totalDuration = Duration.zero; // or set it to the desired value
        inMiles = isMiles ? totalDistance : totalDistance / 1609.34;
      });
      // SharedPref().saveDuration(totalDuration);
      return "${isMiles ? totalDistance.toStringAsFixed(1) : (totalDistance / 1000).toStringAsFixed(1)}";
    } else {
      // If the total distance is less than 1 kilometer, return in meters
      setState(() {
        // totalDuration = Duration.zero; // or set it to the desired value
        inMiles = isMiles ? totalDistance * 1609.34 : totalDistance;
      });
      // SharedPref().saveDuration(totalDuration);
      setState(() {
        time =
        "${isMiles ? (totalDistance * 1609.34).toStringAsFixed(1) : totalDistance.toStringAsFixed(1)}";
      });
      return "${isMiles ? (totalDistance * 1609.34).toStringAsFixed(1) : totalDistance.toStringAsFixed(1)}";
    }
  }

  void initState() {
    setState(() {
      Theme1 = [
        Color(0xFFF7722A),
        Color(0xFFE032A1),
        Color(0xFFCF03F9)
      ];
    });
    whichTheme();
    whichthemeImages();
    super.initState();
    gettingEmailAndPassword();
  }
   String _errorText ="";
  void _validateTextField(String value) {
    if (int.tryParse(value) != null) {
      int enteredValue = int.parse(value);
      if (enteredValue < 2000) {
        setState(() {
          _errorText = 'Value must be 2000 or greater';
        });
        return;
      }
    }
    setState(() {
      _errorText = "";
    });
  }
  String formatTime(double timeInMinutes) {
    print(timeInMinutes.toStringAsFixed(0));
    if (timeInMinutes <= 1) {
      // Return seconds
      int seconds = int.parse((timeInMinutes * 60).toStringAsFixed(0));
      return '$seconds sec${seconds != 1 ? 's' : ''}';
    } else if (timeInMinutes < 60) {
      // Return minutes
      int minutes = int.parse(timeInMinutes.toStringAsFixed(0));
      return '$minutes min${minutes != 1 ? 's' : ''}';
    } else if (timeInMinutes < 1440) {
      // Return hours
      int hours = timeInMinutes ~/ 60;
      return '$hours H${hours != 1 ? 's' : ''}';
    } else if (timeInMinutes < 43200) {
      // Return days
      int days = timeInMinutes ~/ 1440;
      return '$days day${days != 1 ? 's' : ''}';
    } else {
      // Return years
      int years = timeInMinutes ~/ 525600;
      return '$years year${years != 1 ? 's' : ''}';
    }
  }

  String calculateTimeToCoverDistance({
    required double height,
    required int steps,
    required String gender,
    required double distance,
  }) {
    print(distance);
    print(steps);
    double walkingSpeed = 4.8;

    print("walkingSpeed $walkingSpeed");

    // Calculate time to cover the distance (in minutes)
    double timeInMinutes = (distance / walkingSpeed);

    print("timeInHours " + timeInMinutes.toString());

    print("time in minutes ${timeInMinutes*60}");
    // print("timeInMinutes " + timeInMinutes.toStringAsFixed(3));

    return formatTime(double.parse((timeInMinutes*60).toString()));
  }

  String calculateCaloriesBurned({
    required double weight,
    required double height,
    required int age,
    required String gender,
    required int steps,
    required double activityLevel,
  }) {
    // Calculate BMR using Harris-Benedict equation
    double bmr = (gender.toLowerCase() == "male")
        ? 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age)
        : (gender.toLowerCase() == "female")
            ? 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age)
            : 0.0; // Placeholder for other gender (customize as needed)

    // Calculate TDEE using activity factor
    double tdee = bmr * activityLevel;

    // Estimate calories burned during walking (calories per step)
    double caloriesPerStep =
        0.04; // Adjust this value based on walking conditions

    // Total calories burned during walking
    double caloriesBurned = steps * caloriesPerStep;

    // Add walking calories to TDEE


    return caloriesBurned.toStringAsFixed(0) + " kcal";
  }

  double StepsToDistanceDouble(int steps, bool isMiles) {
    double stepsInKm = steps / 1312.33595801;
    double totalDistance;
    String unit;
    double totalTimeInHours = stepsInKm / 4.82803;
    DateTime dateTime = DateTime(
        0, 0, 0, totalTimeInHours.toInt(), (totalTimeInHours % 1 * 60).toInt());
    String formattedTime =
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    List<String> timeParts = formattedTime.split(':');

    if (isMiles) {
      // Convert steps to miles
      totalDistance = stepsInKm * 0.62137;
      unit = " miles";
    } else {
      // Convert steps to meters
      totalDistance = stepsInKm * 1000;
      unit = " m";
    }
    totalDistance=double.parse(formatted2(totalDistance, isMiles, unit));
    return totalDistance;
  }

  String time = "";
  String formatted(double totalDistance, bool isMiles, String unit) {
    if (totalDistance >= 1000) {
      // If the total distance is 1 kilometer or more, return in kilometers
      setState(() {
        // totalDuration = Duration.zero; // or set it to the desired value
        inMiles = isMiles ? totalDistance : totalDistance / 1609.34;
      });
      // SharedPref().saveDuration(totalDuration);
      return "${isMiles ? totalDistance.toStringAsFixed(1) + unit : (totalDistance / 1000).toStringAsFixed(1) + " Km"} ";
    } else {
      // If the total distance is less than 1 kilometer, return in meters
      setState(() {
        // totalDuration = Duration.zero; // or set it to the desired value
        inMiles = isMiles ? totalDistance * 1609.34 : totalDistance;
      });
      // SharedPref().saveDuration(totalDuration);
      setState(() {
        time =
            "${isMiles ? (totalDistance * 1609.34).toStringAsFixed(1) + unit : totalDistance.toStringAsFixed(1)} ";
      });
      return "${isMiles ? (totalDistance * 1609.34).toStringAsFixed(1) + unit : totalDistance.toStringAsFixed(1)} ";
    }
  }

  String StepsToDistance(int steps, bool isMiles) {
    double stepsInKm = steps / 1312.33595801;
    double totalDistance;
    String unit;
    double totalTimeInHours = stepsInKm / 4.82803;
    DateTime dateTime = DateTime(
        0, 0, 0, totalTimeInHours.toInt(), (totalTimeInHours % 1 * 60).toInt());
    String formattedTime =
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    List<String> timeParts = formattedTime.split(':');

    if (isMiles) {
      // Convert steps to miles
      totalDistance = stepsInKm * 0.62137;
      unit = " miles";
    } else {
      // Convert steps to meters
      totalDistance = stepsInKm * 1000;
      unit = " m";
    }
    return formatted(totalDistance, isMiles, unit);
  }

  PageController _controller = PageController();
  double deviceHeight(BuildContext context) => MediaQuery.of(context).size.height;

  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return true;
        },
        child: Scaffold(
          backgroundColor: Colors.black54,
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
            child: Padding(
              padding:  EdgeInsets.only(top: 35),
              child: Column(
                children: [
                AnimatedContainer(
                  duration: Duration(seconds: 1),
                  height: onLastPage?680:800,
                  child:   PageView(
                      controller: _controller,
                      onPageChanged: (index) {
                        setState(() {
                          onLastPage = (index == 1);
                        });
                        print(index);
                        HapticFeedback.lightImpact();
                      },
                      children: [
                        Column(
                          children: [
                            SizedBox(height: 40,),
                            Center(
                              child: Text(
                                "Body Mass Index",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 35.sp,
                                  fontFamily: 'Teko',
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                ),
                              ),
                            ),
                            SizedBox(height: 10,),
                            Center(
                              child: Text(
                                "Gender",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Work Sans',
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                ),
                              ),
                            ),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: OutlineGradientButton(
                                        onTap: () async {
                                          HapticFeedback.lightImpact();
                                          setState(() {
                                            Gender = 0;
                                          });
                                          await SharedPref().setGender("Male");
                                        },
                                        child: Image.asset(
                                          Gender == 0
                                              ? Images[0]
                                              : Imagesunselected[0],
                                          scale: 4,
                                        ),
                                        gradient: LinearGradient(
                                            colors: Gender == 0
                                                ? Theme1
                                                : [
                                              Colors.grey,
                                              Colors.grey,
                                            ]),
                                        strokeWidth: 4,
                                        elevation: 1,
                                        radius: Radius.circular(15),
                                      ),
                                    ),
                                    ShaderMask(
                                      shaderCallback: (Rect bounds) {
                                        return LinearGradient(
                                          colors: Gender == 0
                                              ? Theme1
                                              : [
                                            Colors.grey,
                                            Colors.grey
                                          ], // Replace these colors with your desired gradient colors
                                          begin: Alignment.center,
                                          end: Alignment.bottomRight,
                                        ).createShader(bounds);
                                      },
                                      child: Text(
                                        "Male",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Work Sans',
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.5,
                                          color: Colors
                                              .white, // Set the color to white since it will be masked by the gradient
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: OutlineGradientButton(
                                        onTap: () async {
                                          HapticFeedback.lightImpact();
                                          setState(() {
                                            Gender = 1;
                                          });
                                          await SharedPref().setGender("Female");
                                        },
                                        child: Image.asset(
                                          Gender == 1
                                              ? Images[1]
                                              : Imagesunselected[1],
                                          scale: 4,
                                        ),
                                        gradient: LinearGradient(
                                            colors: Gender == 1
                                                ? Theme1
                                                : [
                                              Colors.grey,
                                              Colors.grey,
                                            ]),
                                        strokeWidth: 4,
                                        elevation: 1,
                                        radius: Radius.circular(15),
                                      ),
                                    ),
                                    ShaderMask(
                                      shaderCallback: (Rect bounds) {
                                        return LinearGradient(
                                          colors: Gender == 1
                                              ? Theme1
                                              : [
                                            Colors.grey,
                                            Colors.grey
                                          ], // Replace these colors with your desired gradient colors
                                          begin: Alignment.center,
                                          end: Alignment.bottomRight,
                                        ).createShader(bounds);
                                      },
                                      child: Text(
                                        "Female",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Work Sans',
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.5,
                                          color: Colors
                                              .white, // Set the color to white since it will be masked by the gradient
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: OutlineGradientButton(
                                        onTap: () async {
                                          HapticFeedback.lightImpact();
                                          setState(() {
                                            Gender = 2;
                                          });
                                          await SharedPref().setGender("Others");
                                        },
                                        child: Image.asset(
                                          Gender == 2
                                              ? Images[2]
                                              : Imagesunselected[2],
                                          scale: 4,
                                        ),
                                        gradient: LinearGradient(
                                            colors: Gender == 2
                                                ? Theme1
                                                : [
                                              Colors.grey,
                                              Colors.grey,
                                            ]),
                                        strokeWidth: 4,
                                        elevation: 1,
                                        radius: Radius.circular(15),
                                      ),
                                    ),
                                    ShaderMask(
                                      shaderCallback: (Rect bounds) {
                                        return LinearGradient(
                                          colors: Gender == 2
                                              ? Theme1
                                              : [
                                            Colors.grey,
                                            Colors.grey
                                          ], // Replace these colors with your desired gradient colors
                                          begin: Alignment.center,
                                          end: Alignment.bottomRight,
                                        ).createShader(bounds);
                                      },
                                      child: Text(
                                        "Others",
                                        style: TextStyle(
                                          fontSize: 25.sp,
                                          fontFamily: 'Work Sans',
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.5,
                                          color: Colors
                                              .white, // Set the color to white since it will be masked by the gradient
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 15,),
                            Text(
                              'Height (in cm)',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Work Sans',
                                fontWeight: FontWeight.w400,
                                height: 0,
                                letterSpacing: 0.80,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: 328,
                              height: 90,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      width: 1, color: Color(0xFF949494)),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 8),
                                child: WheelSlider.customWidget(
                                  totalCount: 10000,
                                  initValue: _cCurrentValue,
                                  isInfinite: true,
                                  scrollPhysics: const BouncingScrollPhysics(),
                                  customPointer: CustomSliderItem(
                                    color: Theme1[0],
                                  ),
                                  children: List.generate(
                                      10000,
                                          (index) => Center(
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 25,
                                              ),
                                              Text(
                                                index.toString(),
                                                style: TextStyle(
                                                    color: _cCurrentValue == index
                                                        ? Theme1[0]
                                                        : Colors.grey,
                                                    fontSize: 20,
                                                  fontFamily: 'Work Sans',),
                                              ),
                                            ],
                                          ))),
                                  onValueChanged: (val) async {
                                    setState(()  {
                                      _cCurrentValue = val;
                                      Height = double.parse(val.toString());
                                    });
                                    await SharedPref().setHeight(int.parse(Height.toStringAsFixed(0)));
                                    print(Height);
                                  },
                                  hapticFeedbackType:
                                  HapticFeedbackType.lightImpact,
                                  showPointer: true,
                                  itemSize: 80,
                                  horizontalListWidth: 100,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              "Weight (in Kg)",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Work Sans',
                                fontWeight: FontWeight.w400,
                                height: 0,
                                letterSpacing: 0.80,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: 328,
                              height: 90,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      width: 1, color: Color(0xFF949494)),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 8),
                                child: WheelSlider.customWidget(
                                  totalCount: 10000,
                                  initValue: _cCurrentValueWeight,
                                  isInfinite: true,
                                  scrollPhysics: const BouncingScrollPhysics(),
                                  customPointer: CustomSliderItem(
                                    color: Theme1[0],
                                  ),
                                  children: List.generate(
                                      10000,
                                          (index) => Center(
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 25,
                                              ),
                                              Text(
                                                index.toString(),
                                                style: TextStyle(
                                                    color: _cCurrentValueWeight ==
                                                        index
                                                        ? Theme1[0]
                                                        : Colors.grey,
                                                    fontSize: 20,
                                                  fontFamily: 'Work Sans',),
                                              ),
                                            ],
                                          ))),
                                  onValueChanged: (val) async {
                                    setState(() {
                                      _cCurrentValueWeight = val;
                                      Weight = double.parse(val.toString());
                                    });
                                    await SharedPref().setWeight(int.parse(Weight.toStringAsFixed(0)));

                                  },
                                  hapticFeedbackType:
                                  HapticFeedbackType.lightImpact,
                                  showPointer: true,
                                  itemSize: 80,
                                  horizontalListWidth: 100,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              "Age",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Work Sans',
                                fontWeight: FontWeight.w400,
                                height: 0,
                                letterSpacing: 0.80,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                    onPressed: () async {
                                      HapticFeedback.lightImpact();

                                      setState(() {
                                        if (Age > 0) {
                                          Age = Age - 1;

                                        } else {
                                          Age = 0;
                                        }
                                      });
                                      setState(() {
                                        ageController.text=Age.toString();
                                      });
                                      await SharedPref().setAge(Age);
                                    },
                                    icon: ImageIcon(AssetImage(
                                        "lib/assests/NewImages/Subtraction.png"))),
                                GestureDetector(
                                  onTap: (){
                                    showDialog(context: context, builder: (BuildContext context){
                                      return   AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        backgroundColor: Colors.white,
                                        title: Text('Enter Your Age',style: TextStyle(color: Colors.black),),
                                        content: TextField(
                                          controller: ageController,
                                          focusNode: ageFocusNode,
                                          style:  TextStyle(color: Colors.black),

                                        ),
                                        actions: <Widget>[
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              // Trigger callback function with entered text
                                              setState(() {
                                                Age=int.parse(ageController.text);
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('OK'),
                                          ),
                                        ],
                                      );
                                    });
                                  },
                                  child: ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      return LinearGradient(
                                        colors:
                                        Theme1, // Replace these colors with your desired gradient colors
                                        begin: Alignment.center,
                                        end: Alignment.bottomRight,
                                      ).createShader(bounds);
                                    },
                                    child: Text(
                                      Age.toString(),
                                      style: TextStyle(
                                        fontSize: 46.sp,
                                        fontFamily: 'Work Sans',
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.5,
                                        color: Colors
                                            .white, // Set the color to white since it will be masked by the gradient
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                    onPressed: () async {
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        Age = Age + 1;
                                      });
                                      setState(() {
                                        ageController.text=Age.toString();
                                      });
                                      await SharedPref().setAge(Age);
                                    },
                                    icon: ImageIcon(AssetImage(
                                        "lib/assests/NewImages/Addition.png"))),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              "Your Activity Level",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Work Sans',
                                fontWeight: FontWeight.w400,
                                height: 0,
                                letterSpacing: 0.80,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                    onPressed: () async {
                                      HapticFeedback.lightImpact();

                                      setState(() {
                                        if (ActivityIndex > 0) {
                                          ActivityIndex = ActivityIndex - 1;
                                        }
                                      });
                                      await SharedPref().setActivityLevel(ActivityLevelNumber[ActivityIndex]);
                                    },
                                    icon: Icon(
                                      Icons.arrow_left_rounded,
                                      size: 50,
                                      color: Colors.white,
                                    )),
                                ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return LinearGradient(
                                      colors:
                                      Theme1, // Replace these colors with your desired gradient colors
                                      begin: Alignment.center,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds);
                                  },
                                  child: Text(
                                    ActivityLevel[ActivityIndex],
                                    style: TextStyle(
                                      fontSize: 46.sp,
                                      fontFamily: 'Teko',
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5,
                                      color: Colors
                                          .white, // Set the color to white since it will be masked by the gradient
                                    ),
                                  ),
                                ),
                                IconButton(
                                    onPressed: () async {
                                      HapticFeedback.lightImpact();

                                      setState(() {
                                        if (ActivityIndex < 3)
                                          ActivityIndex = ActivityIndex + 1;
                                      });
                                      await SharedPref().setActivityLevel(ActivityLevelNumber[ActivityIndex]);

                                    },
                                    icon: Icon(
                                      Icons.arrow_right_rounded,
                                      size: 50,
                                      color: Colors.white,
                                    )),
                              ],
                            )
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Steps Target",
                              style: TextStyle(
                                fontSize: 45.sp,
                                fontFamily: 'Teko',
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                                color: Colors
                                    .white, // Set the color to white since it will be masked by the gradient
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Image.asset(
                              imagesFoot[value],
                             // imagesFoot[value],
                              scale: 3,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                    onPressed: () async {
                                      HapticFeedback.lightImpact();

                                      setState(() {
                                        if (StepsTarget > 2000 ) {
                                          StepsTarget = StepsTarget - 50;
                                        } else {
                                          StepsTarget = 0;
                                        }
                                      });
                                      await SharedPref().setStepsTarget(StepsTarget);
                                    },
                                    icon: ImageIcon(AssetImage(
                                       "lib/assests/NewImages/Subtraction.png"))),
                                GestureDetector(
                                  onTap: (){
                                    showDialog(context: context, builder: (BuildContext context){
                                      return   AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        backgroundColor: Colors.white,
                                        title: Text('Enter Steps Target',style: TextStyle(color: Colors.black),),
                                        content: TextField(
                                          keyboardType: TextInputType.number,
                                          controller: _defaultStepsController,
                                          focusNode: _defaultStepsNode,
                                          style:  TextStyle(color: Colors.black,

                                          ),
                                          onChanged: (String value) {
                                            _validateTextField(
                                                value);
                                          },
                                          decoration: InputDecoration(
                                            errorText: _errorText,
                                            errorStyle: TextStyle(color:Colors.black)
                                          ),
                                        ),
                                        actions: <Widget>[
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              // Trigger callback function with entered text
                                            if(int.parse(
                                                _defaultStepsController
                                                    .text)>=2000)  {
                                                      setState(() {
                                                        StepsTarget = int.parse(
                                                            _defaultStepsController
                                                                .text);
                                                      });
                                                      setState(() {
                                                        _defaultStepsController
                                                                .text =
                                                            StepsTarget
                                                                .toString();
                                                      });
                                                      await SharedPref().setStepsTarget(StepsTarget);
                                                      Navigator.of(context)
                                                          .pop();
                                                    }else{
                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                        content: Text('Value Must be Greater than 2000 or equals to 2000'),
                                                        backgroundColor: Colors.white,
                                                        duration: Duration(seconds: 2),
                                                      ));
                                            }
                                                  },
                                            child: Text('OK'),
                                          ),
                                        ],
                                      );
                                    });
                                  },
                                  child: ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      return LinearGradient(
                                        colors:
                                        Theme1, // Replace these colors with your desired gradient colors
                                        begin: Alignment.center,
                                        end: Alignment.bottomRight,
                                      ).createShader(bounds);
                                    },
                                    child: Text(
                                      StepsTarget.toString(),
                                      style: TextStyle(
                                        fontSize: 40.sp,
                                        fontFamily: 'Work Sans',
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.5,
                                        color: Colors
                                            .white, // Set the color to white since it will be masked by the gradient
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                    onPressed: () async {
                                      HapticFeedbackType.lightImpact;
                                      setState(() {
                                        StepsTarget = StepsTarget + 100;
                                      });
                                      setState(() {
                                        _defaultStepsController.text=StepsTarget.toString();
                                      });
                                      await SharedPref().setStepsTarget(StepsTarget);
                                    },
                                    icon: ImageIcon(AssetImage(
                                        "lib/assests/NewImages/Addition.png"))),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ImageIcon(
                                      AssetImage(
                                          "lib/assests/NewImages/Distance.png"),
                                      color: Colors.white,
                                      size: 34,
                                    ),
                                    Text(StepsToDistance(StepsTarget, false))
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ImageIcon(
                                        AssetImage(
                                            "lib/assests/NewImages/Clock.png"),
                                        color: Colors.white,
                                        size: 34),
                                    Text(calculateTimeToCoverDistance(
                                        height: Height,
                                        steps: StepsTarget,
                                        gender: WhichGender(Gender),
                                        distance: double.parse(
                                            StepsToDistanceDouble(
                                                StepsTarget, false)
                                                .toString()))),
                                  ],
                                ),
                                Column(
                                  children: [
                                    ImageIcon(
                                      AssetImage(
                                          "lib/assests/NewImages/Calories.png"),
                                      color: Colors.white,
                                      size: 34,
                                    ),
                                    Text(calculateCaloriesBurned(
                                        weight: Weight,
                                        height: Height,
                                        age: Age,
                                        gender: WhichGender(Gender),
                                        steps: StepsTarget,
                                        activityLevel: ActivityLevelNumber[
                                        ActivityIndex])
                                        .toString())
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ]),
                ),
                  SmoothPageIndicator(
                      controller: _controller,
                      count: 2,
                      effect: SwapEffect(
                        type: SwapType.yRotation,
                        activeDotColor:
                        Theme1[0], // Color of the active dot
                        dotHeight: 10, // Height of the dots
                        dotWidth: 10, // Width of the dots
                        spacing: 8.0,
                        paintStyle: PaintingStyle
                            .stroke, // Use stroke for non-active dots
                        strokeWidth: 1.5, // Stroke width for non-active dots
                        dotColor: Colors.white,
                      )),
                  GradientButton(
                    colors: Theme1,
                    width: 329,
                    height: 56,
                    radius: 10,
                    gradientDirection: GradientDirection.leftToRight,
                    textStyle: TextStyle(color: Colors.white),
                    text: onLastPage ? Text("Welcome") : Text("Next"),
                    onPressed: () async {
                      SharedPref().setActivityLevel(ActivityLevelNumber[ActivityIndex]);
                      SharedPref().setAge(Age);
                      SharedPref().setStepsTarget(StepsTarget);
                      SharedPref().setHeight(int.parse(Height.toStringAsFixed(0)));
                      SharedPref().setWeight(int.parse(Weight.toStringAsFixed(0)));
                      SharedPref().setGender(WhichGender(Gender));
                      print("Button clicked");
                      if (onLastPage) {
                        if(isGuest){
                          Get.to(()=>MainScreen(),
                              duration: const Duration(
                                  seconds:
                                  1),
                              transition: Transition.fadeIn
                          );
                        }else {
                          FirebaseSetingUp(context);
                        }
                      } else {
                        _controller.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeIn);
                      }
                    },
                  ),
                  SizedBox(height: 20,)
                ],
              ),
            ),
          ),
        ));
  }

  bool isValidUserName(String value) {
    String regularExpression = r"^[a-z0-9_-]{4,16}$";
    RegExp regex = RegExp(regularExpression);
    if (!regex.hasMatch(value.trim())) {
      return false;
    }
    return true;
  }

  String generateRandomUsername() {
    String pattern =
        r'^[a-zA-Z0-9_]{4,}$'; // Example regex pattern (alphanumeric and underscores, at least 4 characters long)
    RegExp regex = RegExp(pattern);

    Random random = Random();

    String username;
    do {
      username = String.fromCharCodes(List.generate(
          8,
          (index) =>
              random.nextInt(26) +
              97)); // Generates a random string of 8 lowercase characters
    } while (!regex.hasMatch(username));

    return username;
  }
}
