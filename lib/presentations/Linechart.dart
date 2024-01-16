import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steptracking/SharedPrefrences/SharedPref.dart';

class LineChartSample2 extends StatefulWidget {
  String which="";


  LineChartSample2(this.which);

  @override
  State<LineChartSample2> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  List<Color> gradientColors = [
    Color(0xFFFF8900),
    Color(0xD5CE00FF),
  ];
  List<int> StepsList = [];
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
  Future<List<int>> getHourlyStepsForCurrentDate() async {

    final Map<String, dynamic> stepsData = await SharedPref().getStepsData();
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

    return hourlyStepsList;
  }

  Future<List<int>> getDailyStepsForCurrentMonth() async {

    final Map<String, dynamic> stepsData = await SharedPref().getStepsData();
// print("this is in monthly ${stepsData}");
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month < 10 ? "0" + now.month.toString() : now.month.toString();

    // Initialize a list to store daily steps for the current month
    List<int> dailyStepsList = [];

    Map<String, int> dailyStepsMap = {};
    for (int i = 1; i <= daysInMonth(year, month); i++) {
      String day = i < 10 ? "0$i" : "$i";
      dailyStepsMap["$day"] = 0;
    }
    // Check if the current month exists in the stepsData
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

        }
      });
    }
    // print("${dailyStepsMap}");
    dailyStepsList=dailyStepsMap.values.toList();
    // print('-------------jg\n--------->${dailyStepsList}');
   setState(() {
     StepsList=dailyStepsList;
   });
    return dailyStepsList;
  }


  Future<Map<int, List<int>>> categorizeStepsByWeek() async {
       final Map<String, dynamic> stepsData = await SharedPref().getStepsData();
     // print(stepsData);
      final now = DateTime.now();
      // print(now);
      final year = now.year.toString();
      final month = now.month < 10 ? "0" + now.month.toString() : now.month.toString();

      // Initialize a list to store daily steps for the current month
      List<int> dailyStepsList = [];

      Map<String, int> dailyStepsMap = {};
      for (int i = 1; i <= daysInMonth(year, month); i++) {
        String day = i < 10 ? "0$i" : "$i";
        dailyStepsMap["${day}"] = 0;
      }
      // Check if the current month exists in the stepsData
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
          }
        });
      }
      // print(dailyStepsMap);
    Map<int, List<int>> weeklyStepsMap = {};

    int currentWeekNumber = 1;
    int daysInCurrentWeek = 0;
    int maxDaysInWeek = 7; // Assuming a Monday-to-Sunday week structure

    dailyStepsMap.forEach((date, steps) {

      // print(now.day);

      String datee= "${now.year}-${now.month.toString().padLeft(2,"0")}-${date}";
      DateTime currentDate = DateTime.parse(datee);
      int currentDayOfWeek = currentDate.weekday;
     // print("ugvjhjhhjb ${currentDayOfWeek}");
      // Check if we need to move to the next week
      if (currentDayOfWeek == DateTime.monday && daysInCurrentWeek > 0) {
        currentWeekNumber++;
        daysInCurrentWeek = 0;
      }

      // Add steps to the current week
      weeklyStepsMap.putIfAbsent(currentWeekNumber, () => []);
      weeklyStepsMap[currentWeekNumber]!.add(steps);

      daysInCurrentWeek++;
      // print('-------------jg\n--------->${weeklyStepsMap}');
    });
         // print('-------------jg\n--------->${weeklyStepsMap}');
    return weeklyStepsMap;
  }

  bool showAvg = false;



  @override
  Widget build(BuildContext context) {
    if(widget.which=="Day"){
   getHourlyStepsForCurrentDate().toString();
    }else if(widget.which=="Month"){
    getDailyStepsForCurrentMonth().toString();
    }else{
      categorizeStepsByWeek().toString();
    }

    // print("-------------jgvhgvhgvhmvhm\n--------->"+getDailyStepsForCurrentMonth().toString());

    return Center(
      child: Stack(
        children: <Widget>[

          AspectRatio(
            aspectRatio: 1.75,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 18,
                left: 12,
                top: 24,
                bottom: 12,
              ),
              child:
              // Container()
              LineChart(
                showAvg ? avgData() : mainData(StepsList),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    // print("Value in bottom->"+value.toString());
    Widget text;
    switch (value.toInt()) {
      case 0:
        text =  Text(value.toString(), style: style);
        break;
        case 1:
        text =  Text(value.toString(), style: style);
        break;
        case 2:
        text =  Text(value.toString(), style: style);
        break;
        case 3:
        text =  Text(value.toString(), style: style);
        break;
        case 4:
        text =  Text(value.toString(), style: style);
        break;
        case 5:
        text =  Text(value.toString(), style: style);
        break;
        case 6:
        text =  Text(value.toString(), style: style);
        break;
        case 7:
        text =  Text(value.toString(), style: style);
        break;
        case 8:
        text =  Text(value.toString(), style: style);
        break;
        case 9:
        text =  Text(value.toString(), style: style);
        break;
        case 10:
        text =  Text(value.toString(), style: style);
        break;
        case 11:
        text =  Text(value.toString(), style: style);
        break;
        case 12:
        text =  Text(value.toString(), style: style);
        break;
        case 13:
        text =  Text(value.toString(), style: style);
        break;
        case 14:
        text =  Text(value.toString(), style: style);
        break;
        case 15:
        text =  Text(value.toString(), style: style);
        break;
        case 16:
        text =  Text(value.toString(), style: style);
        break;
        case 17:
        text =  Text(value.toString(), style: style);
        break;
        case 18:
        text =  Text(value.toString(), style: style);
        break;
        case 19:
        text =  Text(value.toString(), style: style);
        break;
        case 20:
        text =  Text(value.toString(), style: style);
        break;
    case 21:
        text =  Text(value.toString(), style: style);
        break;
        case 22:
        text =  Text(value.toString(), style: style);
        break;

      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    // print("Value----------------\n ${value}");
    String text=value.toString();
    // switch (value.toInt()) {
    //   case 1:
    //     text = value.toString();
    //     break;
    //   case 3:
    //     text = value.toString();
    //     break;
    //   case 5:
    //     text = value.toString();
    //     break;
    //   default:
    //     return Container();
    // }

    return   SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style, textAlign: TextAlign.left),
    );



  }

  LineChartData mainData(List<int> stepsList) {
    int maxYValue = stepsList.isNotEmpty ? stepsList.reduce((max, value) => max > value ? max : value) : 6000;
       // print("ujuxbjk bdkj xjkbcskjxb kjszbckjbzsckjbjz xbjhzdv"+stepsList.length.toString());
    return LineChartData(
      gridData: FlGridData(
        show: false,
        drawVerticalLine: false,
        horizontalInterval: 1,
        verticalInterval: 10,
        drawHorizontalLine: false,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color:   Color(0xFFFF8900),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color:   Color(0xFFFF8900),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: stepsList.length/2!=0?stepsList.length/2:15,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1000,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 50,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: stepsList.length.toDouble(),
      minY: 0,
      maxY: maxYValue.toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(stepsList.length, (index) {
            return FlSpot(index.toDouble(), stepsList[index].toDouble());
          }),
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 0,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3.44),
            FlSpot(2.6, 3.44),
            FlSpot(4.9, 3.44),
            FlSpot(6.8, 3.44),
            FlSpot(8, 3.44),
            FlSpot(9.5, 3.44),
            FlSpot(11, 3.44),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}