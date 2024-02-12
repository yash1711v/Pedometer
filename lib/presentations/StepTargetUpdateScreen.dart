import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wheel_slider/wheel_slider.dart';

import '../SharedPrefrences/SharedPref.dart';
import 'HomeController.dart';
class StepTargetUpdateScreen extends StatefulWidget {
  const StepTargetUpdateScreen({super.key});

  @override
  State<StepTargetUpdateScreen> createState() => _StepTargetUpdateScreenState();
}

class _StepTargetUpdateScreenState extends State<StepTargetUpdateScreen> {
 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Info();
  }
 HomeControllwe homeControllwe = Get.find<HomeControllwe>();
 late final TextEditingController _defaultStepsController =
 TextEditingController();
 final FocusNode _defaultStepsNode = FocusNode();
 int currentSteps=0;
 Info() async {
   int height=await SharedPref().getHeight();
   int weight=await SharedPref().getWeight();
   int age=await SharedPref().getAge();
   double activityLevel=await SharedPref().getActivityLevel();
   String  gender=await SharedPref().getGender();
   int stepsTarget=await SharedPref().getStepsTarget();
   int steps=await SharedPref().getTodaysSteps();

   whichTheme();
   setState(() {
     Height=double.parse(height.toString());
     Weight=double.parse(weight.toString());
     Age=age;
     Activitylevel=activityLevel;
     Gender=gender;
     StepsTarget=stepsTarget;
     currentSteps=steps;
     _defaultStepsController.text=StepsTarget.toString();
   });

   print("Height $Height");
   print("Weight $Weight");
   print("Age $Age");
   print("Activitylevel $Activitylevel");
   print("Gender $Gender");
  }
  double Height = 0;
  double Activitylevel = 0;
  double Weight = 0;
  int Age = 0;
  int StepsTarget = 0;
  String time = "";
  double inMiles = 0;

  List<Color> Theme1 = [
    Color(0xFFF7722A),
    Color(0xFFE032A1),
    Color(0xFFCF03F9)
  ];
  Future<void> whichTheme() async {
    List<Color> Theme = await SharedPref().loadColorList();
    setState(() {
      Theme1 = Theme;
    });
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
    return totalDistance;
  }
  String Gender = "Male";
  String WhichGender(int gender) {
    if (gender == 0) {
      return 'male';
    } else if (gender == 1) {
      return 'female';
    } else {
      return 'other';
    }
  }
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
    // Calculate step length
    double stepLength = (height * 0.415) / steps;
    print("stepslength $stepLength");
    // Number of steps for 1 kilometer (adjust as needed)
    double stepsPerKilometer = 1000 / stepLength;
    print("stepsPerKilometer $stepsPerKilometer");

    // Calculate walking speed (kilometers per minute)
    double walkingSpeed = stepsPerKilometer / distance;
    if (!walkingSpeed.isFinite || walkingSpeed <= 0) {
      return "0";
    }
    print("walkingSpeed $walkingSpeed");

    // Calculate time to cover the distance (in minutes)
    double timeInMinutes = distance / walkingSpeed;
    print("timeInMinutes " + timeInMinutes.toStringAsFixed(3));

    return formatTime(double.parse(timeInMinutes.toStringAsFixed(0)));
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding:  EdgeInsets.symmetric(vertical: 50),
        child: Column(
          children: [
            Padding(
              padding:  EdgeInsets.only(left: 20),
              child: Row(
                children: [

                  IconButton(onPressed: (){Get.back();}, icon: Icon(Icons.arrow_back_ios)),
                ],
              ),
            ),
            SizedBox(
              height: 100,
            ),
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
              "lib/assests/NewImages/StepSettingPage.png",
              scale: 3,
            ),

            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      setState(() {
                        if (StepsTarget > 0 && StepsTarget>currentSteps) {
                          StepsTarget = StepsTarget - 50;
                        } else {
                          StepsTarget = currentSteps;
                        }
                      });
                      await SharedPref().setStepsTarget(StepsTarget);
                      setState(() {
                        _defaultStepsController.text=StepsTarget.toString();
                      });

                      homeControllwe.updateStepsTarget(StepsTarget);

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
                          controller: _defaultStepsController,
                          focusNode: _defaultStepsNode,
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
                                StepsTarget=int.parse(_defaultStepsController.text);
                              });
                         SharedPref().setStepsTarget(StepsTarget);
                              homeControllwe.updateStepsTarget(StepsTarget);
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
                      StepsTarget.toString(),
                      style: TextStyle(
                        fontSize: 40.sp,
                        fontFamily: 'Teko',
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
                      homeControllwe.updateStepsTarget(StepsTarget);
                    },
                    icon: ImageIcon(AssetImage(
                        "lib/assests/NewImages/Addition.png"))),
              ],
            ),
            SizedBox(
              height: 25,
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
                        gender: Gender,
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
                        gender: Gender,
                        steps: StepsTarget,
                        activityLevel: Activitylevel)
                        .toString())
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
