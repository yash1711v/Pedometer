import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../SharedPrefrences/SharedPref.dart';
import '../widgets/BottomNavbar.dart';
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
 void initState() {
   super.initState();
   whichTheme();
   print(CompletedThings.length);
   StepsData();
   getMonthlySteps();

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
           dailyStepsMap[dateKey] = totalStepsForDate;
         }
       });

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

     if(coloriesburn==500){
       setState(() {
         currentlevelCalories=1;
       });
     }
     else if(coloriesburn==1000){
       setState(() {
         currentlevelCalories=2;
       });
     } else if(coloriesburn==2500){
       setState(() {
         currentlevelCalories=3;
       });
     }
     else if(coloriesburn==5000){
       setState(() {
         currentlevelCalories=4;
       });
     }
     else if(coloriesburn==7500){
       setState(() {
         currentlevelCalories=5;
       });
     } else if(coloriesburn==10000){
       setState(() {
         currentlevelCalories=6;
       });
     }else if(coloriesburn==15000){
       setState(() {
         currentlevelCalories=7;
       });
     }
     else if(coloriesburn==20000){
       setState(() {
         currentlevelCalories=8;
       });
     } else if(coloriesburn==25000){
       setState(() {
         currentlevelCalories=9;
       });
     }
     else if(coloriesburn==30000){
       setState(() {
         currentlevelCalories=10;
       });
     }
     else if(coloriesburn==40000){
       setState(() {
         currentlevelCalories=11;
       });
     }
     else if(coloriesburn==50000){
       setState(() {
         currentlevelCalories=12;
       });
     }
     else if(coloriesburn==75000){
       setState(() {
         currentlevelCalories=13;
       });
     }
     else if(coloriesburn==100000){
       setState(() {
         currentlevelCalories=14;
       });
     }
     else if(coloriesburn==150000){
       setState(() {
         currentlevelCalories=15;
       });
     }
     else if(coloriesburn==200000){
       setState(() {
         currentlevelCalories=16;
       });
     }
     else if(coloriesburn==250000){
       setState(() {
         currentlevelCalories=17;
       });
     }
     else if(coloriesburn==300000){
       setState(() {
         currentlevelCalories=18;
       });
     }
     else if(coloriesburn==500000){
       setState(() {
         currentlevelCalories=19;
       });
     }
     else if(coloriesburn==1000000){
       setState(() {
         currentlevelCalories=20;
       });
     }
   });
 }
 DistanceLevel(){
   getMonthlySteps().then((value) {
     int Distance=StepsToDistance(value);
     if(Distance==5){
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
   int totalSteps=0;
   for(int i=0;i<StepsList.length;i++){
     totalSteps=totalSteps+i;
   }
   List<int> calories=[1000,2000,3000,4000,5000,6000,7000,8000,9000,10000,12000,15000,18000,20000,25000,30000,35000,40000,45000,50000];
   if(totalSteps>calories[currenevel]){
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
  }
  int currentlevel=20;
  int currentlevelKm=20;
  int currentlevelCalories=20;
 int currentOption=0;
 @override
  Widget build(BuildContext context) {
    return
      Container(
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
                          'The Neighbourhood ',
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
                          'Explorer',
                          style: TextStyle(
                            color: Color(0xFFF3F3F3),
                            fontSize: 48,
                            fontFamily: 'Teko',
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        ),
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
                Stack(
                    children:
                [
                  Padding(
                    padding:  EdgeInsets.only(top: 37,left: 20),
                    child: Center(child: Image(image: AssetImage("lib/assests/NewImages/PathImage.png"),width: 200,)),
                  ),
                  Visibility(
                    visible: currentOption==0,
                    child:
                    Column(
                      children: [

                        Row(
                          children: [
                            Padding(
                              padding:  EdgeInsets.only(left: currentlevel>=1?MediaQuery.of(context).size.width*0.2:MediaQuery.of(context).size.width*0.22),
                              child: Image(image: AssetImage(currentlevel>=1?"lib/assests/NewImages/b20.png":CompletedThings[0]),width: currentlevel>=1?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 3,),
                        Row(
                          children: [
                            Padding(
                              padding:  EdgeInsets.only(left:currentlevel>=2? 40:150),
                              child: Image(image: AssetImage((currentlevel>=2?"lib/assests/NewImages/b19.png":CompletedThings[0])),width: currentlevel>=2?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 5,),
                        Row(
                          children: [
                            Padding(
                              padding:  EdgeInsets.only(left: currentlevel>=3?MediaQuery.of(context).size.width*0.42:MediaQuery.of(context).size.width*0.45),
                              child: Image(image: AssetImage(currentlevel>=3?"lib/assests/NewImages/b18.png":CompletedThings[0]),width: currentlevel>=3?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 20,),
                        Row(
                          children: [

                            Padding(
                              padding: EdgeInsets.only(left: currentlevel>=4?MediaQuery.of(context).size.width*0.30:MediaQuery.of(context).size.width*0.30),
                              child: Image(image: AssetImage(currentlevel>=4?"lib/assests/NewImages/b17.png":CompletedThings[0]),width: currentlevel>=4?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 20,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: currentlevel>=5?MediaQuery.of(context).size.width*0.325:MediaQuery.of(context).size.width*0.55),
                              child: Image(image: AssetImage(currentlevel>=5?"lib/assests/NewImages/b16.png":CompletedThings[0]),width: currentlevel>=5?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 50,),
                        Row(
                          children: [

                            Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.240),
                              child: Image(image: AssetImage(currentlevel>=6?"lib/assests/NewImages/b15.png":CompletedThings[0]),width: currentlevel>=6?180:80,),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.46),
                              child: Image(image: AssetImage(currentlevel>=7?"lib/assests/NewImages/b14.png":CompletedThings[0]),width: currentlevel>=7?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 25,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: currentlevel>=8?MediaQuery.of(context).size.width*0.4:MediaQuery.of(context).size.width*0.65),
                              child: Image(image: AssetImage(currentlevel>=8?"lib/assests/NewImages/b13.png":CompletedThings[0]),width: currentlevel>=8?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 25,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: currentlevel>=9?MediaQuery.of(context).size.width*0.10:MediaQuery.of(context).size.width*0.45),
                              child: Image(image: AssetImage(currentlevel>=9?"lib/assests/NewImages/b12.png":CompletedThings[0]),width: currentlevel>=9?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 35,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.24),
                              child: Image(image: AssetImage( currentlevel>=10?"lib/assests/NewImages/b11.png":CompletedThings[0]),width:  currentlevel>=10?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 15,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.40),
                              child: Image(image: AssetImage(currentlevel>=11?"lib/assests/NewImages/b10.png":CompletedThings[0]),width: currentlevel>=11?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 15,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: currentlevel>=12?MediaQuery.of(context).size.width*0.35:MediaQuery.of(context).size.width*0.60),
                              child: Image(image: AssetImage(currentlevel>=12?"lib/assests/NewImages/b9.png":CompletedThings[0]),width: currentlevel>=12?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 20,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: currentlevel>=13?MediaQuery.of(context).size.width*0.20:MediaQuery.of(context).size.width*0.45),
                              child: Image(image: AssetImage(currentlevel>=13?"lib/assests/NewImages/b8.png":CompletedThings[0]),width: currentlevel>=13?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 30,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.25),
                              child: Image(image: AssetImage(currentlevel>=14?"lib/assests/NewImages/b7.png":CompletedThings[0]),width: currentlevel>=14?180:95,),
                            )
                          ],
                        ),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.42),
                              child: Image(image: AssetImage(currentlevel>=15?"lib/assests/NewImages/b6.png":CompletedThings[0]),width: currentlevel>=15?180:100,),
                            )
                          ],
                        ),
                        SizedBox(height: 20,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: currentlevel>=16?MediaQuery.of(context).size.width*0.35:MediaQuery.of(context).size.width*0.58),
                              child: Image(image: AssetImage(currentlevel>=16?"lib/assests/NewImages/b5.png":CompletedThings[0]),width: currentlevel>=16?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 15,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: currentlevel>=17?MediaQuery.of(context).size.width*0.16:MediaQuery.of(context).size.width*0.3),
                              child: Image(image: AssetImage(currentlevel>=17?"lib/assests/NewImages/b4.png":CompletedThings[0]),width: currentlevel>=17?180:100,),
                            )
                          ],
                        ),
                        SizedBox(height: 25,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: currentlevel>=18?MediaQuery.of(context).size.width*0.32:MediaQuery.of(context).size.width*0.30),
                              child: Image(image: AssetImage(currentlevel>=18?"lib/assests/NewImages/b3.png":CompletedThings[0]),width: currentlevel>=18?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 105,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.5),
                              child: Image(image: AssetImage(currentlevel>=19?"lib/assests/NewImages/b2.png":CompletedThings[0]),width: currentlevel>=19?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 85,),

                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left:currentlevel>=20? MediaQuery.of(context).size.width*0.2:MediaQuery.of(context).size.width*0.45),
                              child: Image(image: AssetImage(currentlevel>=20?"lib/assests/NewImages/b1.png":CompletedThings[0]),width: currentlevel>=20?180:80,),
                            )
                          ],
                        ),

                      ],
                    ),
                  ),
                  Visibility(
                    visible: currentOption==1,
                    child:
                    Column(
                      children: [

                        Row(
                          children: [
                            Padding(
                              padding:  EdgeInsets.only(left:  currentlevelCalories>=1?MediaQuery.of(context).size.width*0.2:MediaQuery.of(context).size.width*0.22),
                              child: Image(image: AssetImage( currentlevelCalories>=1?"lib/assests/NewImages/e20.png":CompletedThings[0]),width:  currentlevelCalories>=1?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 5,),
                        Row(
                          children: [
                            Padding(
                              padding:  EdgeInsets.only(left: currentlevelCalories>=2? 35:150),
                              child: Image(image: AssetImage(( currentlevelCalories>=2?"lib/assests/NewImages/e19.png":CompletedThings[0])),width:  currentlevelCalories>=2?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 5,),
                        Row(
                          children: [
                            Padding(
                              padding:  EdgeInsets.only(left:  currentlevelCalories>=3?MediaQuery.of(context).size.width*0.42:MediaQuery.of(context).size.width*0.45),
                              child: Image(image: AssetImage( currentlevelCalories>=3?"lib/assests/NewImages/e18.png":CompletedThings[0]),width:  currentlevelCalories>=3?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 20,),
                        Row(
                          children: [

                            Padding(
                              padding: EdgeInsets.only(left:  currentlevelCalories>=4?MediaQuery.of(context).size.width*0.30:MediaQuery.of(context).size.width*0.30),
                              child: Image(image: AssetImage( currentlevelCalories>=4?"lib/assests/NewImages/e17.png":CompletedThings[0]),width:  currentlevelCalories>=4?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 25,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left:  currentlevelCalories>=5?MediaQuery.of(context).size.width*0.34:MediaQuery.of(context).size.width*0.55),
                              child: Image(image: AssetImage( currentlevelCalories>=5?"lib/assests/NewImages/e16.png":CompletedThings[0]),width:  currentlevelCalories>=5?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 50,),
                        Row(
                          children: [

                            Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.240),
                              child: Image(image: AssetImage( currentlevelCalories>=6?"lib/assests/NewImages/e15.png":CompletedThings[0]),width:  currentlevelCalories>=6?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 15,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left:  currentlevelCalories>=7?MediaQuery.of(context).size.width*0.50:MediaQuery.of(context).size.width*0.46),
                              child: Image(image: AssetImage( currentlevelCalories>=7?"lib/assests/NewImages/e14.png":CompletedThings[0]),width:  currentlevelCalories>=7?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 35,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left:  currentlevelCalories>=8?MediaQuery.of(context).size.width*0.43:MediaQuery.of(context).size.width*0.65),
                              child: Image(image: AssetImage( currentlevelCalories>=8?"lib/assests/NewImages/e13.png":CompletedThings[0]),width:  currentlevelCalories>=8?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 25,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left:  currentlevelCalories>=9?MediaQuery.of(context).size.width*0.09:MediaQuery.of(context).size.width*0.35),
                              child: Image(image: AssetImage( currentlevelCalories>=9?"lib/assests/NewImages/e12.png":CompletedThings[0]),width:  currentlevelCalories>=9?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 45,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.25),
                              child: Image(image: AssetImage(  currentlevelCalories>=10?"lib/assests/NewImages/e11.png":CompletedThings[0]),width: currentlevelCalories>=10?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.50),
                              child: Image(image: AssetImage( currentlevelCalories>=11?"lib/assests/NewImages/e10.png":CompletedThings[0]),width:  currentlevelCalories>=11?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 35,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left:  currentlevelCalories>=12?MediaQuery.of(context).size.width*0.3:MediaQuery.of(context).size.width*0.55),
                              child: Image(image: AssetImage( currentlevelCalories>=12?"lib/assests/NewImages/e9.png":CompletedThings[0]),width:  currentlevelCalories>=12?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 20,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left:  currentlevelCalories>=13?MediaQuery.of(context).size.width*0.08:MediaQuery.of(context).size.width*0.34),
                              child: Image(image: AssetImage( currentlevelCalories>=13?"lib/assests/NewImages/e8.png":CompletedThings[0]),width:  currentlevelCalories>=13?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 45,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.35),
                              child: Image(image: AssetImage( currentlevelCalories>=14?"lib/assests/NewImages/e7.png":CompletedThings[0]),width:  currentlevelCalories>=14?180:95,),
                            )
                          ],
                        ),
                        SizedBox(height: 35,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: currentlevelCalories>=15?MediaQuery.of(context).size.width*0.55:MediaQuery.of(context).size.width*0.55),
                              child: Image(image: AssetImage( currentlevelCalories>=15?"lib/assests/NewImages/e6.png":CompletedThings[0]),width:  currentlevelCalories>=15?180:100,),
                            )
                          ],
                        ),
                        SizedBox(height: 45,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left:  currentlevelCalories>=16?MediaQuery.of(context).size.width*0.32:MediaQuery.of(context).size.width*0.30),
                              child: Image(image: AssetImage( currentlevelCalories>=16?"lib/assests/NewImages/e2.png":CompletedThings[0]),width:  currentlevelCalories>=16?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 55,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left:  currentlevelCalories>=17?MediaQuery.of(context).size.width*0.15:MediaQuery.of(context).size.width*0.40),
                              child: Image(image: AssetImage( currentlevelCalories>=17?"lib/assests/NewImages/e4.png":CompletedThings[0]),width:  currentlevelCalories>=17?180:100,),
                            )
                          ],
                        ),
                        SizedBox(height: 25,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left:  currentlevelCalories>=18?MediaQuery.of(context).size.width*0.49:MediaQuery.of(context).size.width*0.49),
                              child: Image(image: AssetImage( currentlevelCalories>=18?"lib/assests/NewImages/e3.png":CompletedThings[0]),width:  currentlevelCalories>=18?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 25,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: currentlevelCalories>=19?MediaQuery.of(context).size.width*0.35:MediaQuery.of(context).size.width*0.35),
                              child: Image(image: AssetImage( currentlevelCalories>=19?"lib/assests/NewImages/e2.png":CompletedThings[0]),width:  currentlevelCalories>=19?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: currentlevelCalories>=20?5:0,),

                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: currentlevelCalories>=20? MediaQuery.of(context).size.width*0.2:MediaQuery.of(context).size.width*0.45),
                              child: Image(image: AssetImage( currentlevelCalories>=20?"lib/assests/NewImages/e1.png":CompletedThings[0]),width:  currentlevelCalories>=20?180:80,),
                            )
                          ],
                        ),

                      ],
                    ),
                  ),
                  Visibility(
                    visible: currentOption==2,
                    child:
                    Column(
                      children: [

                        Row(
                          children: [
                            Padding(
                              padding:  EdgeInsets.only(left: currentlevelKm>=1?MediaQuery.of(context).size.width*0.04:MediaQuery.of(context).size.width*0.22),
                              child: Image(image: AssetImage(currentlevelKm>=1?"lib/assests/NewImages/p20.png":CompletedThings[0]),width: currentlevelKm>=1?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 5,),
                        Row(
                          children: [
                            Padding(
                              padding:  EdgeInsets.only(left:currentlevelKm>=2? 175:150),
                              child: Image(image: AssetImage((currentlevelKm>=2?"lib/assests/NewImages/p19.png":CompletedThings[0])),width: currentlevelKm>=2?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 20,),
                     Row(
                          children: [
                            Padding(
                              padding:  EdgeInsets.only(left: currentlevelKm>=3?MediaQuery.of(context).size.width*0.42:MediaQuery.of(context).size.width*0.45),
                              child: Image(image: AssetImage(currentlevelKm>=3?"lib/assests/NewImages/p18.png":CompletedThings[0]),width: currentlevelKm>=3?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 20,),
                        Row(
                          children: [

                            Padding(
                              padding: EdgeInsets.only(left: currentlevelKm>=4?MediaQuery.of(context).size.width*0.15:MediaQuery.of(context).size.width*0.32),
                              child: Image(image: AssetImage(currentlevelKm>=4?"lib/assests/NewImages/p17.png":CompletedThings[0]),width: currentlevelKm>=4?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 20,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: currentlevelKm>=5?MediaQuery.of(context).size.width*0.325:MediaQuery.of(context).size.width*0.55),
                              child: Image(image: AssetImage(currentlevelKm>=5?"lib/assests/NewImages/p16.png":CompletedThings[0]),width: currentlevelKm>=5?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 50,),
                        Row(
                          children: [

                            Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.265),
                              child: Image(image: AssetImage(currentlevelKm>=6?"lib/assests/NewImages/p15.png":CompletedThings[0]),width: currentlevelKm>=6?180:80,),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.53),
                              child: Image(image: AssetImage(currentlevelKm>=7?"lib/assests/NewImages/p14.png":CompletedThings[0]),width: currentlevelKm>=7?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 25,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: currentlevelKm>=8?MediaQuery.of(context).size.width*0.41:MediaQuery.of(context).size.width*0.65),
                              child: Image(image: AssetImage(currentlevelKm>=8?"lib/assests/NewImages/p13.png":CompletedThings[0]),width: currentlevelKm>=8?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 25,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: currentlevelKm>=9?MediaQuery.of(context).size.width*0.10:MediaQuery.of(context).size.width*0.45),
                              child: Image(image: AssetImage(currentlevelKm>=9?"lib/assests/NewImages/p12.png":CompletedThings[0]),width: currentlevelKm>=9?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 35,),
                       Row(
                         children: [
                            Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.24),
                              child: Image(image: AssetImage( currentlevelKm>=10?"lib/assests/NewImages/p11.png":CompletedThings[0]),width:  currentlevelKm>=10?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 15,),
                        Row(
                         children: [
                            Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.47),
                              child: Image(image: AssetImage(currentlevelKm>=11?"lib/assests/NewImages/p10.png":CompletedThings[0]),width: currentlevelKm>=11?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 15,),
                        Row(
                         children: [
                            Padding(
                              padding: EdgeInsets.only(left: currentlevelKm>=12?MediaQuery.of(context).size.width*0.33:MediaQuery.of(context).size.width*0.60),
                              child: Image(image: AssetImage(currentlevelKm>=12?"lib/assests/NewImages/p9.png":CompletedThings[0]),width: currentlevelKm>=12?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 20,),
                         Row(
                         children: [
                            Padding(
                              padding: EdgeInsets.only(left: currentlevelKm>=13?MediaQuery.of(context).size.width*0.11:MediaQuery.of(context).size.width*0.45),
                              child: Image(image: AssetImage(currentlevelKm>=13?"lib/assests/NewImages/p8.png":CompletedThings[0]),width: currentlevelKm>=13?180:80,),
                            )
                          ],
                        ),
                            SizedBox(height: 30,),
                            Row(
                         children: [
                            Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.25),
                              child: Image(image: AssetImage(currentlevelKm>=14?"lib/assests/NewImages/p7.png":CompletedThings[0]),width: currentlevelKm>=14?180:95,),
                            )
                          ],
                        ),
                        SizedBox(height: 10,),
                           Row(
                         children: [
                            Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.45),
                              child: Image(image: AssetImage(currentlevelKm>=15?"lib/assests/NewImages/p6.png":CompletedThings[0]),width: currentlevelKm>=15?180:100,),
                            )
                          ],
                        ),
                             SizedBox(height: 20,),
                             Row(
                         children: [
                              Padding(
                              padding: EdgeInsets.only(left: currentlevelKm>=16?MediaQuery.of(context).size.width*0.38:MediaQuery.of(context).size.width*0.58),
                              child: Image(image: AssetImage(currentlevelKm>=16?"lib/assests/NewImages/p5.png":CompletedThings[0]),width: currentlevelKm>=16?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 15,),
                        Row(
                         children: [
                              Padding(
                              padding: EdgeInsets.only(left: currentlevelKm>=17?MediaQuery.of(context).size.width*0.35:MediaQuery.of(context).size.width*0.3),
                              child: Image(image: AssetImage(currentlevelKm>=17?"lib/assests/NewImages/p4.png":CompletedThings[0]),width: currentlevelKm>=17?180:100,),
                            )
                          ],
                        ),
                        SizedBox(height: 90,),
                       Row(
                         children: [
                              Padding(
                              padding: EdgeInsets.only(left: currentlevelKm>=18?MediaQuery.of(context).size.width*0.39:MediaQuery.of(context).size.width*0.45),
                              child: Image(image: AssetImage(currentlevelKm>=18?"lib/assests/NewImages/p3.png":CompletedThings[0]),width: currentlevelKm>=18?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 15,),
                        Row(
                         children: [
                              Padding(
                              padding: EdgeInsets.only(left:currentlevelKm>=19? MediaQuery.of(context).size.width*0.30:MediaQuery.of(context).size.width*0.50),
                              child: Image(image: AssetImage(currentlevelKm>=19?"lib/assests/NewImages/p2.png":CompletedThings[0]),width: currentlevelKm>=19?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 75,),

                        Row(
                         children: [
                              Padding(
                              padding: EdgeInsets.only(left:currentlevelKm>=20? MediaQuery.of(context).size.width*0.35:MediaQuery.of(context).size.width*0.45),
                              child: Image(image: AssetImage(currentlevelKm>=20?"lib/assests/NewImages/p1.png":CompletedThings[0]),width: currentlevelKm>=20?180:80,),
                            )
                          ],
                        ),

                      ],
                    ),
                  ),



                 ]
                ),
                SizedBox(height: 100,),
              ],
            ),
          ),
        ));
  }
}
