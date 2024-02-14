import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../SharedPrefrences/SharedPref.dart';
import '../widgets/BottomNavbar.dart';
import 'HomeController.dart';
import 'LevelMapScreen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
 List<String> Images=["lib/assests/NewImages/Theme1AwardsBg.png","lib/assests/NewImages/Theme2AwardsBg.png","lib/assests/NewImages/Theme3AwardsBg.png"];
 int value=0;


 List<String> CompletedThings=[
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
 ];

 List<Color> Theme=[Color(0xFFF7722A),Color(0xFFE032A1),Color(0xFFCF03F9)];
  Map<String, dynamic> stepsData ={};
  bool network=true;
 void initState() {
   super.initState();
   whichTheme();
   print(CompletedThings.length);
   StepsData();
   getMonthlySteps();
   WhicchImage();
   checkInternetConnection().then((value) {
     setState(() {
       network=value;
     });
   });

 }
 double Weight=60;
 double Height= 162;
 String Gender= "Male";
 double ActivityLevel= 1.25;
 int Age=26;
 Future<void> StepsData() async {
   final Map<String, dynamic> StepsData =  await SharedPref().getStepsData();
   int weight=await SharedPref().getWeight();
   int height= await SharedPref().getHeight();
   double activityLevel= await SharedPref().getActivityLevel();
   String gender= await SharedPref().getGender();
   int age=await SharedPref().getAge();
   int currentlevelsteps=await SharedPref().getCurrentLevelSteps();
   setState(() {
     stepsData=StepsData;
     Weight=double.parse(weight.toString());
      Height= double.parse(height.toString());
      Gender= gender;
      ActivityLevel=double.parse(activityLevel.toString());
      Age=age;
     currentlevel=currentlevelsteps;
   });
   getHourlyStepsForCurrentDate(currentlevelsteps);
   CaloriesLevel();
   DistanceLevel();
   whichBadges();

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
 int calculateCaloriesBurned({required int steps,})  {
   if (steps <= 0) {
     return 0; // Return 0 kcal if steps are zero or negative
   }

   // print("Steps-----------?$steps");
   // Calculate BMR using Harris-Benedict equation
   double bmr = (Gender.toLowerCase() == "male")
       ? 88.362 + (13.397 * Weight) + (4.799 * Height) - (5.677 * Age)
       : (Gender.toLowerCase() == "female")
       ? 447.593 + (9.247 * Weight) + (3.098 * Height) - (4.330 * Age)
       : 0.0; // Placeholder for other gender (customize as needed)

   // Calculate TDEE using activity factor
   double tdee = bmr * ActivityLevel;

   // Estimate calories burned during walking (calories per step)
   double caloriesPerStep =
   0.04; // Adjust this value based on walking conditions

   // Total calories burned during walking
   double caloriesBurned = steps * caloriesPerStep;
   // print("Calories Burned------> $caloriesBurned");
   // Add walking calories to TDEE
   double totalCaloriesBurned = caloriesBurned;

   return int.parse(totalCaloriesBurned.toStringAsFixed(0));
 }

 Future<int> getMonthlySteps() async {
   final Map<String, dynamic> stepsData = await SharedPref().getStepsData();

   // Initialize a map to store monthly steps for each month
   Map<String, List<int>> monthlyStepsMap = {};

   // Initialize a variable to store the total steps for each month
   Map<String, int> totalStepsForEachMonth = {};

   // Loop through each year in the stepsData
   stepsData.forEach((year, yearData) {
     yearData.forEach((month, monthData) {
       List<int> dailyStepsList = [];
       Map<String, int> dailyStepsMap = {};

       for (int i = 1; i <= daysInMonth(year, month); i++) {
         String day = i < 10 ? "0$i" : "$i";
         dailyStepsMap["$day"] = 0;
       }

       // Loop through each date in the current month
       monthData.forEach((dateKey, dateValue) {
         int totalStepsForDate = dateValue.values.fold<dynamic>(
           0,
               (previousValue, element) => previousValue + (element is int ? element : 0),
         );

         // Add the total steps for the current date to the list
         if (totalStepsForDate > 0) {
           dailyStepsMap[dateKey.toString().padLeft(2,"0")] = totalStepsForDate;
         }
       });
         print("DailySteps For each month-------> $dailyStepsMap");
       dailyStepsList = dailyStepsMap.values.toList();
       monthlyStepsMap["$year-$month"] = dailyStepsList;

       // Accumulate total steps for each month
       totalStepsForEachMonth["$year-$month"] ??= 0;
       totalStepsForEachMonth["$year-$month"] =  (totalStepsForEachMonth["$year-$month"]! + dailyStepsList.fold(0, (sum, steps) => sum + steps))!;
     });
   });

   // Return the total steps for all months
   int totalSteps = totalStepsForEachMonth.values.fold(0, (sum, steps) => sum + steps);
   print("Totalsteps for each month $totalSteps");
   print("Totalsteps for each month $totalStepsForEachMonth");
    return totalSteps;
 }

 int StepsToDistance(int steps) {
   print("Stepsss--------------->  $steps");
   double stepsInKm = steps / 1312.33595801;
   double totalDistance;
   String unit;
   double totalTimeInHours = stepsInKm / 4.82803;
   DateTime dateTime = DateTime(
       0, 0, 0, totalTimeInHours.toInt(), (totalTimeInHours % 1 * 60).toInt());
   String formattedTime =
       "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
   List<String> timeParts = formattedTime.split(':');
   totalDistance = stepsInKm * 1000;
   print("Steps in km $stepsInKm");
   return int.parse(stepsInKm.toStringAsFixed(0));
 }

 CaloriesLevel(){
   getMonthlySteps().then((value) {
     int coloriesburn=calculateCaloriesBurned(steps: value);
    print("caloriesburn-------------> $coloriesburn");
     if(coloriesburn>=500 && coloriesburn<1000){
       setState(() {
         currentlevelCalories=1;
       });
     }
     else if(coloriesburn>=1000 && coloriesburn<2500){
       setState(() {
         currentlevelCalories=2;
       });
     } else if(coloriesburn>=2500 && coloriesburn<5000){
       setState(() {
         currentlevelCalories=3;
       });
     }
     else if(coloriesburn>=5000 && coloriesburn<7500){
       setState(() {
         currentlevelCalories=4;
       });
     }
     else if(coloriesburn>=7500 && coloriesburn<10000){
       setState(() {
         currentlevelCalories=5;
       });
     } else if(coloriesburn>=10000 && coloriesburn<15000){
       setState(() {
         currentlevelCalories=6;
       });
     }else if(coloriesburn>=15000 && coloriesburn<20000){
       setState(() {
         currentlevelCalories=7;
       });
     }
     else if(coloriesburn>=20000 && coloriesburn<25000){
       setState(() {
         currentlevelCalories=8;
       });
     } else if(coloriesburn>=25000 && coloriesburn<30000){
       setState(() {
         currentlevelCalories=9;
       });
     }
     else if(coloriesburn>=30000 && coloriesburn<40000){
       setState(() {
         currentlevelCalories=10;
       });
     }
     else if(coloriesburn>=40000 && coloriesburn<50000){
       setState(() {
         currentlevelCalories=11;
       });
     }
     else if(coloriesburn>=50000 && coloriesburn<75000){
       setState(() {
         currentlevelCalories=12;
       });
     }
     else if(coloriesburn>=75000 && coloriesburn<100000){
       setState(() {
         currentlevelCalories=13;
       });
     }
     else if(coloriesburn>=100000 && coloriesburn<150000){
       setState(() {
         currentlevelCalories=14;
       });
     }
     else if(coloriesburn>=150000 && coloriesburn<200000){
       setState(() {
         currentlevelCalories=15;
       });
     }
     else if(coloriesburn>=200000 && coloriesburn<250000){
       setState(() {
         currentlevelCalories=16;
       });
     }
     else if(coloriesburn>=250000 && coloriesburn<300000){
       setState(() {
         currentlevelCalories=17;
       });
     }
     else if(coloriesburn>=300000 && coloriesburn<500000){
       setState(() {
         currentlevelCalories=18;
       });
     }
     else if(coloriesburn>=500000 && coloriesburn<1000000){
       setState(() {
         currentlevelCalories=19;
       });
     }
     else if(coloriesburn>=1000000){
       setState(() {
         currentlevelCalories=20;
       });
     }
   });
 }
 DistanceLevel(){
   getMonthlySteps().then((value) {
     print("Steps going to distance calculation--------> $value");
     int Distance=StepsToDistance(value);
     print("Distance is --------------->$Distance");
     if(Distance>=5 && Distance<10){
       setState(() {
         currentlevelKm=1;
       });
     }
     else if(Distance>=10 && Distance<25){
       setState(() {
         currentlevelKm=2;
       });
     } else if(Distance>=25 && Distance<50){
       setState(() {
         currentlevelKm=3;
       });
     }
     else if(Distance>=50 && Distance<75){
       setState(() {
         currentlevelKm=4;
       });
     }
     else if(Distance>=75 && Distance<100){
       setState(() {
         currentlevelKm=5;
       });
     } else if(Distance>=100 && Distance<150){
       setState(() {
         currentlevelKm=6;
       });
     }else if(Distance>=150 && Distance<200){
       setState(() {
         currentlevelKm=7;
       });
     }
     else if(Distance>=200 && Distance<300){
       setState(() {
         currentlevelKm=8;
       });
     } else if(Distance>=300 && Distance<500){
       setState(() {
         currentlevelKm=9;
       });
     }
     else if(Distance>=500 && Distance<750){
       setState(() {
         currentlevelKm=10;
       });
     }
     else if(Distance>=750 && Distance<1000){
       setState(() {
         currentlevelKm=11;
       });
     }
     else if(Distance>=1000 && Distance<1500){
       setState(() {
         currentlevelKm=12;
       });
     }
     else if(Distance>=1500 && Distance<2000){
       setState(() {
         currentlevelKm=13;
       });
     }
     else if(Distance>=2000 && Distance<2500){
       setState(() {
         currentlevelKm=14;
       });
     }
     else if(Distance>=2500 && Distance<3000){
       setState(() {
         currentlevelKm=15;
       });
     }
     else if(Distance>=3000 && Distance<4000){
       setState(() {
         currentlevelKm=16;
       });
     }
     else if(Distance>=4000 && Distance<5000){
       setState(() {
         currentlevelKm=17;
       });
     }
     else if(Distance>=5000 && Distance<7500){
       setState(() {
         currentlevelKm=18;
       });
     }
     else if(Distance>=7500 && Distance<10000){
       setState(() {
         currentlevelKm=19;
       });
     }
     else if(Distance>=10000){
       setState(() {
         currentlevelKm=20;
       });
     }
   });
 }

 int getHourlyStepsForCurrentDate(int currenevel)  {


   // print("this is in hourly graph "+stepsData.toString());
   final now = DateTime.now();
   final year = (now.year).toString();
   final month = now.month<10?"0"+now.month.toString():now.month.toString(); // Use month number directly
   final date = (now.day).toString();

   // Initialize a list to store hourly steps for the current date
   List<int> hourlyStepsList = [];

   // Check if the current date exists in the stepsData
   if (stepsData.containsKey(year) &&
       stepsData[year].containsKey(month) &&
       stepsData[year][month].containsKey(date)) {
     // Loop through each hour in the current date
     stepsData[year][month][date].forEach((hourKey, hourValue) {
       // Add the hourly step value to the list
       hourlyStepsList.add(hourValue.toInt());
     });
   }else{
     // print(" Doesn't contain ${hourlyStepsList}");
     // print("year ${stepsData.containsKey(year)}");
     // print("month ${stepsData[year].containsKey(month)}");
     // print("date ${stepsData[year][month].containsKey(date)}");
   }
   // print(" this is in hourly graph  ${hourlyStepsList}");
   setState(() {
     StepsList=hourlyStepsList;
   });
   print("----------------------------> $StepsList");
   int totalSteps=0;
   for(int i=0;i<StepsList.length;i++){
     totalSteps=totalSteps+StepsList[i];
   }
   print("----------------------------> $totalSteps");

   List<int> calories=[1000,2000,3000,4000,5000,6000,7000,8000,9000,10000,12000,15000,18000,20000,25000,30000,35000,40000,45000,50000];
   if(totalSteps>=calories[currenevel]){
     print("In greater calories-------------> ${calories[currenevel]} and Total steps are-----------> $totalSteps");
     if(totalSteps>=1000 && totalSteps<2000){
       setState(() {
         currentlevel=1;
       });
       SharedPref().setCurrentLevelSteps(currentlevel);
     }
     else if(totalSteps>=2000 && totalSteps<3000){
       setState(() {
         currentlevel=2;
       });
       SharedPref().setCurrentLevelSteps(currentlevel);
     }
     else if(totalSteps>=3000 && totalSteps<4000){
       setState(() {
         currentlevel=3;
       });
       SharedPref().setCurrentLevelSteps(currentlevel);
     }
     else if(totalSteps>=4000 && totalSteps<5000){
       setState(() {
         currentlevel=4;
       });
       SharedPref().setCurrentLevelSteps(currentlevel);
     }
     else if(totalSteps>=5000 && totalSteps<6000){
       setState(() {
         currentlevel=5;
       });
       SharedPref().setCurrentLevelSteps(currentlevel);
     }
     else if(totalSteps>=6000 && totalSteps<7000) {
       setState(() {
         currentlevel=6;
       });
       SharedPref().setCurrentLevelSteps(currentlevel);
     }
     else if(totalSteps>=7000 && totalSteps<8000){
       setState(() {
         currentlevel=7;
       });
       SharedPref().setCurrentLevelSteps(currentlevel);
     }
     else if(totalSteps>=8000 && totalSteps<9000){
       setState(() {
         currentlevel=8;
       });
       SharedPref().setCurrentLevelSteps(currentlevel);
     }
     else if(totalSteps>=9000 && totalSteps<10000){
       setState(() {
         currentlevel=9;
       });
       SharedPref().setCurrentLevelSteps(currentlevel);
     }
     else if(totalSteps>=10000 && totalSteps<12000){
       setState(() {
         currentlevel=10;
       });
       SharedPref().setCurrentLevelSteps(currentlevel);
     }
     else if(totalSteps>=12000 && totalSteps<15000){
       setState(() {
         currentlevel=11;
       });
       SharedPref().setCurrentLevelSteps(currentlevel);
     }
     else if(totalSteps>=15000 && totalSteps<18000){
       setState(() {
         currentlevel=12;
       });
       SharedPref().setCurrentLevelSteps(currentlevel);
     }
     else if(totalSteps>=18000 && totalSteps<20000){
       setState(() {
         currentlevel=13;
       });
       SharedPref().setCurrentLevelSteps(currentlevel);
     }
     else if(totalSteps>=20000 && totalSteps<25000){
       setState(() {
         currentlevel=14;
       });
       SharedPref().setCurrentLevelSteps(currentlevel);
     }
     else if(totalSteps>=25000 && totalSteps<30000){
       setState(() {
         currentlevel=15;
       });
       SharedPref().setCurrentLevelSteps(currentlevel);
     }
     else if(totalSteps>=30000 && totalSteps<35000){
       setState(() {
         currentlevel=16;
       });
       SharedPref().setCurrentLevelSteps(currentlevel);
     }
     else if(totalSteps>=35000 && totalSteps<40000){
       setState(() {
         currentlevel=17;
       });
       SharedPref().setCurrentLevelSteps(currentlevel);
     }
     else if(totalSteps>=40000 && totalSteps<45000){
       setState(() {
         currentlevel=18;
       });
       SharedPref().setCurrentLevelSteps(currentlevel);
     }
     else if(totalSteps>=45000 && totalSteps<50000){
       setState(() {
         currentlevel=19;
       });
       SharedPref().setCurrentLevelSteps(currentlevel);
     }
     else if(totalSteps>=50000){
       setState(() {
         currentlevel=20;
       });
       SharedPref().setCurrentLevelSteps(currentlevel);
     }
   }else{
     print("In less calories-------------> ${calories[currenevel]} and Total steps are-----------> $totalSteps");
     setState(() {
       currentlevel=currenevel;
     });
     SharedPref().setCurrentLevelSteps(currentlevel);
   }


   print(currentlevel);
   return currentlevel;
 }

 whichTheme() async {
   List<Color> Th= await SharedPref().loadColorList();
   setState(() {
     Theme=Th;
     if(Theme[0]==Color(0xFFF7722A)){
       print("theme1");
       setState(() {
         value=0;
       });
     }
     else if(Theme[0]==Color(0xFF04EF77)){
       print("theme2");
       setState(() {
         value=1;
       });
     }
     else{
       print("theme3");
       setState(() {
         value=2;
       });
     }
   });
 }

 List<int> StepsList = [];
 //for Hourly Steps
 @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    for(int i=0;i<Images.length;i++) {
      AssetImage(Images[i]);
    }
    for(int i=1;i<=21;i++){
      CachedNetworkImageProvider("http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=B$i&image_type=pathAndAwards");
      CachedNetworkImageProvider("http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=P$i&image_type=pathAndAwards");
      CachedNetworkImageProvider("http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=E$i&image_type=pathAndAwards");
    }
  }
  int currentlevel=0;
  int currentlevelKm=0;
  int currentlevelCalories=0;
 int currentOption=0;
 String Achievement="Achievement";
 String AchievedFor="Unlock";
 HomeControllwe homeControllwe = Get.find<HomeControllwe>();
 String Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=b1&image_type=awardsOnly";

 whichBadges(){
   if(currentOption==0){
     if(currentlevel==1){
       setState(() {
         Achievement="StepStarter";
         AchievedFor="1,000 steps";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=b1&image_type=awardsOnly";

       });

     }
     else if(currentlevel==2){
       setState(() {
         Achievement="StrideStar";
         AchievedFor="2,000 steps";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=b2&image_type=awardsOnly";

       });
     }
     else if(currentlevel==3){
       setState(() {
         Achievement="QuickQuota";
         AchievedFor="3,000 steps";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=b3&image_type=awardsOnly";

       });
     }
     else if(currentlevel==4){
       setState(() {
         Achievement="WalkWarrior";
         AchievedFor="4,000 steps";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=b4&image_type=awardsOnly";

       });
     }
     else if(currentlevel==5){
       setState(() {
         Achievement="StrollChamp";
         AchievedFor="5,000 steps";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=b5&image_type=awardsOnly";

       });
     }
     else if(currentlevel==6) {
       setState(() {
         Achievement="PedometerPro";
         AchievedFor="6,000 steps";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=b6&image_type=awardsOnly";

       });
     }
     else if(currentlevel==7){
       setState(() {
         Achievement="DailyDasher";
         AchievedFor="7,000 steps";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=b7&image_type=awardsOnly";

       });
     }
     else if(currentlevel==8){
       setState(() {
         Achievement="WalkWhiz";
         AchievedFor="8,000 steps";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=b8&image_type=awardsOnly";

       });
     }
     else if(currentlevel==9){
       setState(() {
         Achievement="StepSprinter";
         AchievedFor="9,000 steps";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=b9&image_type=awardsOnly";

       });
     }
     else if(currentlevel==10){
       setState(() {
         Achievement="TrekMaster";
         AchievedFor="10,000 steps";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=b10&image_type=awardsOnly";

       });
     }
     else if(currentlevel==11){
       setState(() {
         Achievement="StepHero";
         AchievedFor="12,000 steps)";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=b11&image_type=awardsOnly";

       });
     }
     else if(currentlevel==12){
       setState(() {
         Achievement="QuickQuotient";
         AchievedFor="15,000 steps";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=b12&image_type=awardsOnly";

       });
     }
     else if(currentlevel==13){
       setState(() {
         Achievement="StrideStrategist";
         AchievedFor="18,000 steps";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=b13&image_type=awardsOnly";

       });
     }
     else if(currentlevel==14){
       setState(() {
         Achievement="WalkVirtuoso";
         AchievedFor="20,000 steps";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=b14&image_type=awardsOnly";

       });
     }
     else if(currentlevel==15){
       setState(() {
         Achievement="StepSorcerer";
         AchievedFor="25,000 steps";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=b15&image_type=awardsOnly";

       });
     }
     else if(currentlevel==16){
       setState(() {
         Achievement="SwiftStrider";
         AchievedFor="30,000 steps";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=b16&image_type=awardsOnly";

       });
     }
     else if(currentlevel==17){
       setState(() {
         Achievement="StrollSavvy";
         AchievedFor="35,000 steps";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=b17&image_type=awardsOnly";

       });
     }
     else if(currentlevel==18){
       setState(() {
         Achievement="StepVoyager";
         AchievedFor="40,000 steps";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=b18&image_type=awardsOnly";

       });
     }
     else if(currentlevel==19){
       setState(() {
         Achievement="RapidRambler";
         AchievedFor="45,000 steps";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=b19&image_type=awardsOnly";

       });
     }
     else if(currentlevel==20){
       setState(() {
         Achievement="StepLegend";
         AchievedFor="50,000 steps";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=b20&image_type=awardsOnly";

       });
     }else{
       setState(() {
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=lock&image_type=awardsOnly";
          Achievement="Achievement";
          AchievedFor="Unlock";

       });
     }
   }
   else if(currentOption==1){
     print("Calories level  $currentlevelCalories");
     if(currentlevelCalories==1){
       setState(() {
         Achievement="Emberling";
         AchievedFor="500 calories";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=e20&image_type=awardsOnly";

       });

     }
     else if(currentlevelCalories==2){
       setState(() {
         Achievement="Blazelet";
         AchievedFor="1,000 calories";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=e19&image_type=awardsOnly";

       });
     }
     else if(currentlevelCalories==3){
       setState(() {
         Achievement="Infernite";
         AchievedFor="2,500 calories";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=e18&image_type=awardsOnly";

       });
     }
     else if(currentlevelCalories==4){
       setState(() {
         Achievement="Pyrobyte";
         AchievedFor="5,000 calories";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=e17&image_type=awardsOnly";

       });
     }
     else if(currentlevelCalories==5){
       setState(() {
         Achievement="Flamelet";
         AchievedFor="7,500 calories";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=e16&image_type=awardsOnly";

       });
     }
     else if(currentlevelCalories==6) {
       setState(() {
         Achievement="Scorchie";
         AchievedFor="10,000 calories";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=e15&image_type=awardsOnly";

       });
     }
     else if(currentlevelCalories==7){
       setState(() {
         Achievement="Fireling";
         AchievedFor="15,000 calories";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=e14&image_type=awardsOnly";

       });
     }
     else if(currentlevel==8){
       setState(() {
         Achievement="Incendio";
         AchievedFor="20,000 calories";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=e13&image_type=awardsOnly";

       });
     }
     else if(currentlevelCalories==9){
       setState(() {
         Achievement="Pyrokin";
         AchievedFor="25,000 calories";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=e12&image_type=awardsOnly";

       });
     }
     else if(currentlevelCalories==10){
       print(currentlevelCalories);
       setState(() {
         Achievement="Infernix";
         AchievedFor="30,000 calories";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=e11&image_type=awardsOnly";

       });
     }
     else if(currentlevelCalories==11){
       setState(() {
         Achievement="Emberite";
         AchievedFor="40,000 calories";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=e10&image_type=awardsOnly";

       });
     }
     else if(currentlevelCalories==12){
       setState(() {
         Achievement="Firestreak";
         AchievedFor="50,000 calories";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=e9&image_type=awardsOnly";

       });
     }
     else if(currentlevelCalories==13){
       setState(() {
         Achievement="Powerflame";
         AchievedFor="75,000 calories";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=e8&image_type=awardsOnly";

       });
     }
     else if(currentlevelCalories==14){
       setState(() {
         Achievement="Calorix";
         AchievedFor="100,000 calories";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=e7&image_type=awardsOnly";

       });
     }
     else if(currentlevelCalories==15){
       setState(() {
         Achievement="Enerdragon";
         AchievedFor="150,000 calories";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=e6&image_type=awardsOnly";

       });
     }
     else if(currentlevelCalories==16){
       setState(() {
         Achievement="Dracorix";
         AchievedFor="200,000 calories";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=e5&image_type=awardsOnly";

       });
     }
     else if(currentlevelCalories==17){
       setState(() {
         Achievement="Dynafire";
         AchievedFor="250,000 calories";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=e4&image_type=awardsOnly";

       });
     }
     else if(currentlevelCalories==18){
       setState(() {
         Achievement="Flareon";
         AchievedFor="300,000 calories";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=e3&image_type=awardsOnly";

       });
     }
     else if(currentlevelCalories==19){
       setState(() {
         Achievement="Alchemix";
         AchievedFor="500,000 calories";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=e2&image_type=awardsOnly";

       });
     }
     else if(currentlevelCalories==20){
       setState(() {
         Achievement="Legendrax";
         AchievedFor="1,000,000 calories";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=e1&image_type=awardsOnly";

       });
     }
     else{
       setState(() {

         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=lock&image_type=awardsOnly";
         Achievement="Achievement";
         AchievedFor="Unlock";
       });
     }
   }
   else{
     if(currentlevelKm==1){
       setState(() {
         Achievement="Swift Strider";
         AchievedFor="5 kms";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=p1&image_type=awardsOnly";
       });

     }
     else if(currentlevelKm==2){
       setState(() {
         Achievement="Vista Voyager";
         AchievedFor="10 kms";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=p2&image_type=awardsOnly";
       });
     }
     else if(currentlevelKm==3){
       setState(() {
         Achievement="Zenith Explorer";
         AchievedFor="25 kms";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=p3&image_type=awardsOnly";

       });
     }
     else if(currentlevelKm==4){
       setState(() {
         Achievement="Trail Blaze";
         AchievedFor="50 kms";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=p4&image_type=awardsOnly";

       });
     }
     else if(currentlevelKm==5){
       setState(() {
         Achievement="Lunar Nomad";
         AchievedFor="75 kms";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=p5&image_type=awardsOnly";

       });
     }
     else if(currentlevelKm==6) {
       setState(() {
         Achievement="Zephyr Roamer";
         AchievedFor="100 kms";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=p6&image_type=awardsOnly";

       });
     }
     else if(currentlevelKm==7){
       setState(() {
         Achievement="Aero Adventurer";
         AchievedFor="150 kms";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=p7&image_type=awardsOnly";

       });
     }
     else if(currentlevelKm==8){
       setState(() {
         Achievement="Pinnacle Wayfarer";
         AchievedFor="200 kms";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=p8&image_type=awardsOnly";

       });
     }
     else if(currentlevelKm==9){
       setState(() {
         Achievement="Stellar Trekker";
         AchievedFor="300 kms";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=p9&image_type=awardsOnly";

       });
     }
     else if(currentlevelKm==10){
       setState(() {
         Achievement="Nova Nomad";
         AchievedFor="500 kms";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=p10&image_type=awardsOnly";

       });
     }
     else if(currentlevelKm==11){
       setState(() {
         Achievement="Orbit Wayfarer";
         AchievedFor="750 kms";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=p11&image_type=awardsOnly";

       });
     }
     else if(currentlevelKm==12){
       setState(() {
         Achievement="Galaxy Globetrotter";
         AchievedFor="1,000 kms";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=p12&image_type=awardsOnly";

       });
     }
     else if(currentlevelKm==13){
       setState(() {
         Achievement="Zenith Adventurer";
         AchievedFor="1,500 kms";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=p13&image_type=awardsOnly";

       });
     }
     else if(currentlevelKm==14){
       setState(() {
         Achievement="Cosmo Explorer";
         AchievedFor="2,000 kms";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=p14&image_type=awardsOnly";

       });
     }
     else if(currentlevelKm==15){
       setState(() {
         Achievement="Lunar Legend";
         AchievedFor="2,500 kms";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=p15&image_type=awardsOnly";

       });
     }
     else if(currentlevelKm==16){
       setState(() {
         Achievement="Epic Hiker";
         AchievedFor="3,000 kms";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=p16&image_type=awardsOnly";

       });
     }
     else if(currentlevelKm==17){
       setState(() {
         Achievement="Nebula Trekker";
         AchievedFor="4,000 kms";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=p17&image_type=awardsOnly";

       });
     }
     else if(currentlevelKm==18){
       setState(() {
         Achievement="Zenith Master";
         AchievedFor="5,000 kms";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=p18&image_type=awardsOnly";

       });
     }
     else if(currentlevelKm==19){
       setState(() {
         Achievement="Celestial Nomad";
         AchievedFor="7,500 kms";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=p19&image_type=awardsOnly";

       });
     }
     else if(currentlevelKm==20){
       setState(() {
         Achievement="Mystic Nomad";
         AchievedFor="10,000 kms";
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=p20&image_type=awardsOnly";
       });
     }else{
       setState(() {
         Ig="http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=lock&image_type=awardsOnly";
         Achievement="Achievement";
         AchievedFor="Unlock";
       });
     }
   }
 }
 String WhicchImage(){


   if(currentOption==0){
     // print("In which Image current option= $currentOption  and Currenr level = $currentlevel");
     if(currentlevel==1){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=B2&image_type=pathAndAwards";

     }
     else if(currentlevel==2){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=B3&image_type=pathAndAwards";
     }
     else if(currentlevel==3){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=B4&image_type=pathAndAwards";
     }
     else if(currentlevel==4){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=B5&image_type=pathAndAwards";
     }
     else if(currentlevel==5){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=B6&image_type=pathAndAwards";
     }
     else if(currentlevel==6) {
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=B7&image_type=pathAndAwards";
     }
     else if(currentlevel==7){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=B8&image_type=pathAndAwards";
     }
     else if(currentlevel==8){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=B9&image_type=pathAndAwards";
     }
     else if(currentlevel==9){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=B10&image_type=pathAndAwards";
     }
     else if(currentlevel==10){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=B11&image_type=pathAndAwards";
     }
     else if(currentlevel==11){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=B12&image_type=pathAndAwards";
     }
     else if(currentlevel==12){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=B13&image_type=pathAndAwards";
     }
     else if(currentlevel==13){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=B14&image_type=pathAndAwards";
     }
     else if(currentlevel==14){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=B15&image_type=pathAndAwards";
     }
     else if(currentlevel==15){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=B16&image_type=pathAndAwards";
     }
     else if(currentlevel==16){
       return "lhttp://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=B17&image_type=pathAndAwards";
     }
     else if(currentlevel==17){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=B18&image_type=pathAndAwards";
     }
     else if(currentlevel==18){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=B19&image_type=pathAndAwards";
     }
     else if(currentlevel==19){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=B20&image_type=pathAndAwards";
     }
     else if(currentlevel==20){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=B21&image_type=pathAndAwards";
     }else{
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=B1&image_type=pathAndAwards";
     }
   }
   if(currentOption==1){
     // print("In which Image current option= $currentOption  and CcurrentlevelCalories = $currentlevelCalories");
     if(currentlevelCalories==1){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=E2&image_type=pathAndAwards";

     }
     else if(currentlevelCalories==2){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=E3&image_type=pathAndAwards";
     }
     else if(currentlevelCalories==3){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=E4&image_type=pathAndAwards";

     }
     else if(currentlevelCalories==4){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=E5&image_type=pathAndAwardsg";

     }
     else if(currentlevelCalories==5){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=E6&image_type=pathAndAwards";

     }
     else if(currentlevelCalories==6) {
       print(6);
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=E7&image_type=pathAndAwards";

     }
     else if(currentlevelCalories==7){
       print(7);
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=E8&image_type=pathAndAwards";

     }
     else if(currentlevel==8){
       print(8);
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=E9&image_type=pathAndAwards";

     }
     else if(currentlevelCalories==9){

       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=E10&image_type=pathAndAwards";

     }
     else if(currentlevelCalories==10){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=E11&image_type=pathAndAwards";

     }
     else if(currentlevelCalories==11){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=E12&image_type=pathAndAwards";

     }
     else if(currentlevelCalories==12){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=E13&image_type=pathAndAwards";

     }
     else if(currentlevelCalories==13){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=E14&image_type=pathAndAwards";

     }
     else if(currentlevelCalories==14){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=E15&image_type=pathAndAwards";

     }
     else if(currentlevelCalories==15){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=E16&image_type=pathAndAwards";

     }
     else if(currentlevelCalories==16){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=E17&image_type=pathAndAwards";

     }
     else if(currentlevelCalories==17){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=E18&image_type=pathAndAwards";

     }
     else if(currentlevelCalories==18){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=E19&image_type=pathAndAwards";

     }
     else if(currentlevelCalories==19){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=E20&image_type=pathAndAwards";

     }
     else if(currentlevelCalories==20){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=E21&image_type=pathAndAwards";

     }
     else{
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=E1&image_type=pathAndAwards";

     }
   }
   if(currentOption==2){
     // print("In which Image current option= $currentOption  and currentlevelKm = $currentlevelCalories");
     if(currentlevelKm==1){
       print(1);
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=P2&image_type=pathAndAwards";
     }
     else if(currentlevelKm==2){
       print(2);

       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=P3&image_type=pathAndAwards";

     }
     else if(currentlevelKm==3){
       print(3);

       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=P4&image_type=pathAndAwards";

     }
     else if(currentlevelKm==4){
       print(4);

       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=P5&image_type=pathAndAwards";

     }
     else if(currentlevelKm==5){
       print(5);

       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=P6&image_type=pathAndAwards";

     }
     else if(currentlevelKm==6) {
       print(6);

       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=P7&image_type=pathAndAwards";

     }
     else if(currentlevelKm==7){
       print(7);

       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=P8&image_type=pathAndAwards";

     }
     else if(currentlevelKm==8){
       print(8);

       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=P9&image_type=pathAndAwards";

     }
     else if(currentlevelKm==9){
       print(9);

       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=P10&image_type=pathAndAwards";

     }
     else if(currentlevelKm==10){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=P11&image_type=pathAndAwards";

     }
     else if(currentlevelKm==11){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=P12&image_type=pathAndAwards";

     }
     else if(currentlevelKm==12){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=P13&image_type=pathAndAwards";

     }
     else if(currentlevelKm==13){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=P14&image_type=pathAndAwards";

     }
     else if(currentlevelKm==14){
       return "lhttp://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=P15&image_type=pathAndAwards";
     }
     else if(currentlevelKm==15){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=P16&image_type=pathAndAwards";
     }
     else if(currentlevelKm==16){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=P17&image_type=pathAndAwards";
     }
     else if(currentlevelKm==17){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=P18&image_type=pathAndAwards";
     }
     else if(currentlevelKm==18){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=P19&image_type=pathAndAwards";
     }
     else if(currentlevelKm==19){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=P20&image_type=pathAndAwards";
     }
     else if(currentlevelKm==20){
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=P21&image_type=pathAndAwards";
     }else {
       return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=P1&image_type=pathAndAwards";
     }
   }
   return "http://soundscape.boostproductivity.online/api/steptracker/v1/media/getSTImage?image_name=B1&image_type=pathAndAwards";
 }
 @override
  Widget build(BuildContext context) {
    return
      WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return true;
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(image: DecorationImage(image: AssetImage(Images[value]),fit: BoxFit.fill)),
          child: Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 60,),
                  Container(
                    width: 319,
                    height: 126,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(1.00, 0.02),
                        end: Alignment(-1, -0.02),
                        colors: [Theme[0].withOpacity(0.5), Theme[1].withOpacity(0.5), Theme[2].withOpacity(0.5)],
                      ),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1, color: Color(0xFFDA9629)),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 4,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 17,
                          top: 15,
                          child: Text(
                            'Your Highest achievement',
                            style: TextStyle(
                              color: Color(0xFFCDCDCD),
                              fontSize: 10,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                              height: 0,
                              letterSpacing: 0.10,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 17,
                          top: 43,
                          child: Text(
                              AchievedFor,
                            style: TextStyle(
                              color: Color(0xFFF3F3F3),
                              fontSize: 20,
                              fontFamily: 'Teko',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 17,
                          top: 57,
                          child: Text(
                            Achievement,
                            style: TextStyle(
                              color: Color(0xFFF3F3F3),
                              fontSize: 48,
                              fontFamily: 'Teko',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 210,
                          top: 15,
                          child:
                           Container(
                               width: 100,
                               height: 100,
                               child: CachedNetworkImage(
                                 imageUrl: Ig,
                                 progressIndicatorBuilder: (context, url, downloadProgress) =>
                                     Padding(
                                       padding: const EdgeInsets.only(bottom: 2000),
                                       child: Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                                     ),
                                 errorWidget: (context, url, error) => Padding(
                                   padding: const EdgeInsets.only(bottom: 2000),
                                   child: Icon(Icons.error),
                                 ),
                               ),)
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 25,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          currentOption=0;
                        });
                        // getHourlyStepsForCurrentDate();
                        whichBadges();
                      },
                      child: Container(
                        width: 80,
                        height: 34,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(0.98, 0.19),
                            end: Alignment(-0.98, -0.19),
                            colors: currentOption==0?[Theme[0],Theme[2]]:
                            [Color(0xFF8800),
                              Color(0xCE00FE)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Steps',
                              style: TextStyle(
                                color: Color(0xFFF3F3F3),
                                fontSize: 24,
                                fontFamily: 'Teko',
                                fontWeight: FontWeight.w400,
                                height: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            currentOption=1;
                          });
                          // CaloriesLevel();
                          whichBadges();
                        },
                      child: Container(
                        width: 80,
                        height: 34,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(0.98, 0.19),
                            end: Alignment(-0.98, -0.19),
                            colors: currentOption==1?[Theme[0],Theme[2]]:
                            [Color(0xFF8800),
                              Color(0xCE00FE)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Calories',
                              style: TextStyle(
                                color: Color(0xFFF3F3F3),
                                fontSize: 24,
                                fontFamily: 'Teko',
                                fontWeight: FontWeight.w400,
                                height: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            currentOption=2;
                          });
                          // DistanceLevel();
                          whichBadges();
                        },
                      child: Container(
                        width: 80,
                        height: 34,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(0.98, 0.19),
                            end: Alignment(-0.98, -0.19),
                            colors: currentOption==2?[Theme[0],Theme[2]]:
                            [Color(0xFF8800),
                              Color(0xCE00FE)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Kms',
                              style: TextStyle(
                                color: Color(0xFFF3F3F3),
                                fontSize: 24,
                                fontFamily: 'Teko',
                                fontWeight: FontWeight.w400,
                                height: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],),
                 SizedBox(height: 15,),

                  Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height*2.7,
                          padding: EdgeInsets.zero,
                    //          decoration: BoxDecoration(
                    //            image: DecorationImage(image: CachedNetworkImageProvider(WhicchImage())
                    //
                    //            // AssetImage(WhicchImage())
                    // )
                    //          ),
                      child: CachedNetworkImage(
                        imageUrl: WhicchImage(),
                        progressIndicatorBuilder: (context, url, downloadProgress) =>
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2000),
                              child: Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                            ),
                        errorWidget: (context, url, error) => Padding(
                          padding: const EdgeInsets.only(bottom: 2000),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Please Check Your Internet Connection"),
                              SizedBox(height: 10,),
                              Icon(Icons.error),
                            ],
                          ),
                        ),
                      ),
                    )
                  )

                 , SizedBox(height: 100,),
                ],
              ),
            ),
          )),
      );
  }
 Future<bool> checkInternetConnection() async {
   try {
     final result = await InternetAddress.lookup('google.com');
     if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
       return true;
     }
   } on SocketException catch (_) {
     return false;
   }
   return false;
 }
}

