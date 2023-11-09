import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:steptracking/bar_graph/BarGraph.dart';
import 'package:steptracking/bar_graph2/BarGraph2.dart';

import '../SharedPrefrences/SharedPref.dart';
import '../widgets/BottomNavbar.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  PageController _pageController = PageController(initialPage: 1);
  List<DateTime> weekStartDates = [];
  int currentPage = 1;
  int index = 1;
  int index2 = 1;
  int AverageSteps=0;
  int AverageStepsMonthly=0;
  int StepsTarget=0;
  List<double> weeklySummary=[];
  List<double> MonthlyData=[];
  int MonthendDate=0;
  double deviceHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  bool isGuest=false;
  @override
  void initState() {
    super.initState();
    getData();
    StartDate();
    getWeeklyStepsData();
    currentDateIndex();
    setState(() {
      currentMonthIndex = DateTime.now().month - 1;
      weeklySummary = List.filled(7, 0.0);
    });
    getMonthlyStepsData(DateTime(DateTime.now().year, currentMonthIndex + 1, 1));
    // getWeeklyStepsData();
  }

getData() async {
  Map<String, int?> Map1=await SharedPref().getSortedStepsData();
  setState(() {
    weeklySummary = List.filled(7, 0.0);
    MonthlyData= List.filled(31, 0.0);
  });
  Map1.forEach((date, steps) {
    DateTime currentDate = DateFormat('yyyy-MM-dd').parse(date);
    int dayOfWeek = currentDate.weekday;
    setState(() {
        weeklySummary[dayOfWeek - 1] = double.parse(steps.toString());

      MonthlyData[dayOfWeek-1]=double.parse(steps.toString());
    });

  });


  }



  Future<void> getWeeklyStepsData() async {
    String _uid = await SharedPref().getUid();
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference(); // Replace with your user ID
    DateTime weekStart = weekStartDates[index];
    DateTime weekStartDate= weekStart.subtract(Duration(days: weekStart.weekday - 1));
    print("Start: "+weekStartDate.toString());
    DateTime weekEnd = weekStartDate.add(Duration(days: 6));
    print("End: "+ weekEnd.toString());
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(weekStartDate);
    print("Week Start Date: "+ formattedStartDate .toString());
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(weekEnd);
    print("Week Start Date: "+ formattedEndDate .toString());

    Map<String, int?> Map1=await SharedPref().getSortedStepsData();
      bool isguest=await SharedPref().getisguest();
    setState(() {
      weeklySummary = List.filled(7, 0.0);
      isGuest=isguest;
    });
    if(isGuest){
      print("in Guest Condition of weekly summery");
      List<MapEntry> entries = Map1.entries.toList();

      // Sort the list based on the date
      entries.sort((a, b) => a.key.compareTo(b.key));

      // Convert the sorted list back to a map
      Map<dynamic, dynamic> sortedMap = Map.fromEntries(entries);
      setState(() {
        weeklySummary = List.filled(7, 0.0);
        isGuest=isguest;
      });
      sortedMap.forEach((date, steps) {
        DateTime currentDate = DateFormat('yyyy-MM-dd').parse(date);
        print(currentDate.day);
        int dayOfWeek = currentDate.weekday;
        if(currentDate.isAfter(weekStartDate)  && currentDate.isBefore(weekEnd)  || (currentDate.day==weekStartDate.day ||  currentDate.day==weekEnd.day))
          {setState(() {weeklySummary[dayOfWeek-1]= double.parse(steps.toString());});}
      });
      print("------------------------------->weekly summary  After setting from SharedPref if  a guest "+weeklySummary.toString());

    }else{
      print("in not a Guest Condition of weekly summery");

      Map1.forEach((date, steps) {
      DateTime currentDate = DateFormat('yyyy-MM-dd').parse(date);
      int dayOfWeek = currentDate.weekday;
      if(currentDate.isAfter(weekStartDate)  && currentDate.isBefore(weekEnd)  || (currentDate.day==weekStartDate.day ||  currentDate.day==weekEnd.day)){setState(() {weeklySummary[dayOfWeek-1]= double.parse(steps.toString());});}

    });

    print("------------------------------->weekly summary  After setting from SharedPref if not a guest "+weeklySummary.toString());
    DatabaseReference databaseReference2 = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(_uid)
        .child('defaultsteps');
    try {
      databaseReference2.onValue.listen((event) {
        print(event.snapshot.value.toString());
        setState(() {
          StepsTarget = int.parse(event.snapshot.value.toString());
        });
      });
    } catch (e) {
      print('Error: $e');
    }
    var dataSnapshot = await databaseReference
        .child('users')
        .child(_uid)
        .child('steps')
        .orderByKey()
        .startAt(formattedStartDate)
        .endAt(formattedEndDate)
        .once();
    print(dataSnapshot.snapshot.value) ;
    if(dataSnapshot.snapshot.value.isNull){
      for(int i=0;i<weeklySummary.length;i++){
        setState(() {
          weeklySummary[i]=0;
        });
      }
    }
    Map<dynamic, dynamic> map = dataSnapshot.snapshot.value as Map??{};
      print("------------------------------->map coming from the firebase if not a guest "+ map.toString());
    Map<String, int> convertedMap = {};
    map.forEach((key, value) {
      convertedMap[key.toString()] = int.parse(value.toString());
    });
    // Initialize weeklySummary with zeros
    await SharedPref().saveStepsData(convertedMap);
    setState(() {
      weeklySummary = List.filled(7, 0.0);
    });
    if (map != null && map.isNotEmpty) {
      // Convert map to a list of map entries
      List<MapEntry> entries = map.entries.toList();

      // Sort the list based on the date
      entries.sort((a, b) => a.key.compareTo(b.key));

      // Convert the sorted list back to a map
      Map<dynamic, dynamic> sortedMap = Map.fromEntries(entries);

      sortedMap.forEach((date, steps) {
        DateTime currentDate = DateFormat('yyyy-MM-dd').parse(date);
        print("date: "+date.toString()+"steps: "+steps.toString());
        int dayOfWeek = currentDate.weekday;
        weeklySummary[dayOfWeek-1] = double.parse(steps.toString());

      });
      print(weeklySummary.toString());
      double totalSteps =  weeklySummary.reduce((sum, steps) => sum + steps);
      setState(() {
        AverageSteps = totalSteps ~/ 7; // Integer division for average
      });
    }


    }


  }
  Future<void> getMonthlyStepsData(DateTime selectedMonth) async {
    String _uid = await SharedPref().getUid();
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();

    DateTime startOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
    DateTime endOfMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(startOfMonth);
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(endOfMonth);
    Map<String, int?> Map1=await SharedPref().getSortedStepsData();
    bool isguest=await SharedPref().getisguest();
    setState(() {
      isGuest=isguest;
    });

    if(isGuest){
      setState(() {
        MonthlyData = List.filled(endOfMonth.day, 0.0);
        AverageStepsMonthly = 0;
      });
      Map1.forEach((date, steps) {
        DateTime currentDate = DateFormat('yyyy-MM-dd').parse(date);
        int dayOfWeek = currentDate.weekday;
        if(currentDate.isAfter(startOfMonth)  && currentDate.isBefore(endOfMonth )  || (currentDate.day==startOfMonth.day ||  currentDate.day==endOfMonth.day))

          {setState(() {MonthlyData[dayOfWeek-1]= double.parse(steps.toString());});}

      });
    }else{

      Map1.forEach((date, steps) {
        DateTime currentDate = DateFormat('yyyy-MM-dd').parse(date);
        int dayOfWeek = currentDate.weekday;
        setState(() {
          MonthlyData[dayOfWeek-1]= double.parse(steps.toString());

        });

      });






      var dataSnapshot = await databaseReference
          .child('users')
          .child(_uid)
          .child('steps')
          .orderByKey()
          .startAt(formattedStartDate)
          .endAt(formattedEndDate)
          .once();

      if (dataSnapshot.snapshot.value == null) {
        // Set all values to 0 if no data is available
        setState(() {
          MonthlyData = List.filled(endOfMonth.day, 0.0);
          AverageStepsMonthly = 0;
        });
        return;
      }

      Map<dynamic, dynamic> map = dataSnapshot.snapshot.value as Map??{};
      print("Month Data"+map.toString());
      // Initialize weeklySummary with zeros
      setState(() {
        MonthlyData = List.filled(endOfMonth.day, 0.0);
      });

      // Iterate through the data and update monthly
      map.forEach((date, steps) {
        DateTime currentDate = DateFormat('yyyy-MM-dd').parse(date);
        int dayOfWeek = currentDate.day;
        MonthlyData[dayOfWeek-1] = double.parse(steps.toString());
      });

      // Calculate average steps
      double totalSteps = MonthlyData.reduce((sum, steps) => sum + steps);
      setState(() {
        AverageStepsMonthly = totalSteps ~/ endOfMonth.day; // Integer division for average
      });



    }

  }

  StartDate() {
    // print("Datw");
    DateTime now = DateTime.now();
    for (int i = -1; i <= 1; i++) {
      DateTime weekStart = now.add(Duration(days: i * 7 - now.weekday));
      weekStartDates.add(weekStart);
     // getWeeklyStepsData(weekStart);
    }
      print("week Start dates"+weekStartDates.toString());
  }
  int currentMonthIndex = DateTime.now().month - 1; // Initialize with current month

  void goToNextMonth() {
    setState(() {
      currentMonthIndex = (currentMonthIndex + 1) % 12;
    });
  }

  void goToPreviousMonth() {
    setState(() {
      currentMonthIndex = (currentMonthIndex - 1) % 12;
    });
  }
  currentDateIndex() {

    DateTime now = DateTime.now();
    String Today = DateFormat('dd').format(now);
 print("current date: "+ Today );
    for (int i = 0; i < weekStartDates.length; i++) {
      print("insideloop");
      DateTime weekStart = weekStartDates[i];

      DateTime monday = weekStart.subtract(Duration(days: weekStart.weekday - 1));
      String weekStartMondayDay = DateFormat('dd').format(monday);
      // Calculate the end date as Sunday
      DateTime weekEndDate = monday.add(Duration(days: 6));
      String weekStartEndDateDay = DateFormat('dd').format(weekEndDate );
      print("inside if" + monday.toString() + "," + weekEndDate.toString());
      print("Checking week $i: Start: $monday, End: $weekEndDate");
      print(Today.compareTo(weekStartMondayDay).toString() + " hh "+ Today.compareTo(weekStartEndDateDay).toString());
      if (now.isAfter(monday) && now.isBefore(weekEndDate) || Today.compareTo(weekStartMondayDay)==0 || Today.compareTo(weekStartEndDateDay)==0) {
        setState(() {
          index = i;
          print("Current date index" + index.toString());
          print(weekStartDates[index]);
        //  getWeeklyStepsData(monday)

        });
        break;
      }
    }
  }
  DateTime? getMonthStartDate(String monthName) {
    // List of English month names
    List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'
    ];

    // Mahine ke naam ka index haasil karen
    int monthIndex = months.indexOf(monthName);

    // Agar mahine ka naam valid hai
    if (monthIndex >= 0) {
      // DateTime banakar mahine ki shuruat tareekh haasil karen
      return DateTime(DateTime.now().year, monthIndex + 1, 1);
    }

    // Agar mahine ka naam galat hai, to null return karen
    return null;
  }
  DateTime? getMonthEndDate(String monthName) {
    // Mahine ki shuruat tareekh haasil karen
    DateTime? startDate = getMonthStartDate(monthName);

    // Agar shuruat tareekh valid hai
    if (startDate != null) {
      // Mahine ki akhiri din ka tareekh haasil karen
      int lastDay = DateTime(DateTime.now().year, startDate.month + 1, 0).day;
      setState(() {
        MonthendDate=lastDay;
      });
      return DateTime(DateTime.now().year, startDate.month, lastDay);
    }

    // Agar mahine ka naam galat hai, to null return karen
    return null;
  }
  @override
  Widget build(BuildContext context) {
    DateTime currentMonth = DateTime(DateTime.now().year, currentMonthIndex + 1, 1);
    String monthName = DateFormat('MMMM').format(currentMonth);
    getMonthEndDate(monthName);
    int monthMiddleDate =int.parse((MonthendDate/2).toStringAsFixed(0));
    return Scaffold(
      backgroundColor: Color(0xFF2D2D2D),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0.w,),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 29.h,),
            Text(
              'REPORT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 54.sp,
                fontFamily: 'Teko',
                fontWeight: FontWeight.w600,
                height: 0,
              ),
            ),
            SizedBox(height: deviceHeight(context)<900?20.h:35.h,),
            GestureDetector(
              onPanUpdate: (details) {
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (index <= 0) {
                        setState(() {
                          index = 2;
                        });
                        getWeeklyStepsData();
                      } else {
                        setState(() {
                          index = index - 1;
                        });
                        getWeeklyStepsData();
                      }
                    },
                  ),
                  WeekWidget(weekStartDates[index],),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (index >= 2) {
                        setState(() {
                          index = 0;
                        });
                        getWeeklyStepsData();;
                      } else {
                        setState(() {
                          index = index + 1;
                        });
                        getWeeklyStepsData();
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 15.h,),
            Row(
              children: [
                Expanded(child: Text(
                  'Average steps :  $AverageSteps',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                )),
                // SizedBox(width: 173.w,),
                // Icon(Icons.calendar_today_outlined, size: 24,)
              ],
            ),
            SizedBox(height: deviceHeight(context)<900?51.h:34.h,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height:  190.h, width: 385.w,
                child: Mybargraph(weeklySummary: weeklySummary),
                ),
              ],
            ),
            SizedBox(height: deviceHeight(context)<900?20.h:40.h,),

            GestureDetector(
              onPanUpdate: (details) {
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      goToPreviousMonth();
                      getMonthlyStepsData(DateTime(DateTime.now().year, currentMonthIndex + 1, 1));

                    },
                  ),
                  Text('$monthName',
                    style: TextStyle(
                      color: Color(0xFFA9A9A9),
                      fontSize: 24.sp,
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      goToNextMonth();
                      getMonthlyStepsData(DateTime(DateTime.now().year, currentMonthIndex + 1, 1));

                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 15.h,),
            Row(
              children: [
                Expanded(child: Text(
                  'Average steps :  $AverageStepsMonthly',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                )),
                // SizedBox(width: 173.w,),
                // Icon(Icons.calendar_today_outlined, size: 24,)
              ],
            ),
            SizedBox(height: deviceHeight(context)<900?38.h:29.h,),
            Align(
              child: SizedBox(height: 187.h, width: 500.w,
                child: Mybargraph2(monthlyData: MonthlyData,),
              ),
            ),
            SizedBox(height: 5.h,),
            Row(
              children: [
                SizedBox(width: 40.w,),
                Text(monthName.substring(0, 3) + "  1",
                    style:TextStyle(
                      color: Color(0xFFA9A9A9),
                      fontSize: 18,
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    )
                ),
                SizedBox(width: 90.w,),
                Text(monthName.substring(0, 3) + "  "+monthMiddleDate.toString(),
                    style:TextStyle(
                      color: Color(0xFFA9A9A9),
                      fontSize: 18,
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    )

                ),
                SizedBox(width: 62.w,),
                Text(monthName.substring(0, 3)+"  "+MonthendDate.toString(),
                    style:TextStyle(
                      color: Color(0xFFA9A9A9),
                      fontSize: 18,
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    )

                ),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: 1,
      ),
    );
  }
}

class WeekWidget extends StatelessWidget {
  final DateTime weekStartDate;
  WeekWidget(this.weekStartDate,);

  @override
  Widget build(BuildContext context) {
    // Ensure that weekStartDate is a Monday
    DateTime monday =
        weekStartDate.subtract(Duration(days: weekStartDate.weekday - 1));

    // Calculate the end date as Sunday
    DateTime weekEndDate = monday.add(Duration(days: 6));

    String formattedStartDate = DateFormat('d').format(monday);
    String formattedEndDate = DateFormat('d MMM').format(weekEndDate);
    String month = DateFormat('MMM').format(weekEndDate);

    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '$formattedStartDate-$formattedEndDate',
            style: TextStyle(
              color: Color(0xFFA9A9A9),
              fontSize: 24.sp,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w400,
              height: 0,
            ),
          ),
        ],
      ),
    );
  }
}