import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../SharedPrefrences/SharedPref.dart';

class Mybargraph extends StatefulWidget {
  final List<double> weeklySummary;
  const Mybargraph({super.key, required this.weeklySummary});

  @override
  State<Mybargraph> createState() => _MybargraphState();
}

class _MybargraphState extends State<Mybargraph> {
  int StepsTarget = 6000;
  void initState() {
    super.initState();
    // getStepsData();
  }

  @override
  Widget build(BuildContext context) {
    double maxValue = widget.weeklySummary.reduce((max, value) => max > value ? max : value);

    return BarChart(
        BarChartData(
        gridData: FlGridData(show: false),
        borderData: FlBorderData(
            show: true,
          border: const Border(
            bottom: BorderSide(
              color: Colors.white,
              width: 2,
            )
          )
        ),
        titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: getrightTitles)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
           bottomTitles: AxisTitles(
               sideTitles: SideTitles(
                 reservedSize: 30,
             showTitles: true,
             getTitlesWidget: getBottomTitles
           ))
        ),
         // maxY: 2,
        // minY: 0,
        barGroups: widget.weeklySummary
            .asMap()
            .entries
            .map((entry) =>BarChartGroupData(x: entry.key, barRods: [
                  BarChartRodData(
                      toY: entry.value.toDouble(),

                      color: Color(0xFF9D79BC),
                      width: 35.51.w,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.r),
                        topRight: Radius.circular(10.r),
                      ),

                      backDrawRodData: BackgroundBarChartRodData(
                          show: true, toY: 10000, color: Colors.grey.shade800)
                  )
                ]))
            .toList(),
          barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: Colors.blueGrey,
          tooltipRoundedRadius: 8,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
           late String weekDay;
            switch (group.x.toInt()) {
              case 0:
                weekDay = 'Mon';
                break;
              case 1:
                weekDay = 'Tue';
                break;
              case 2:
                weekDay = 'Wed';
                break;
              case 3:
                weekDay = 'Thu';
                break;
              case 4:
                weekDay = 'Fri';
                break;
              case 5:
                weekDay = 'Sat';
                break;
              case 6:
                weekDay = 'Sun';
                break;
            }
            return BarTooltipItem(
              '$weekDay: ${group.barRods[rodIndex].toY.round().toString()}',
              TextStyle(color: Colors.white),
            );
          },
        ),
    ),
    ),

    );
  }
}
Widget getBottomTitles(double value , TitleMeta meta){
 const style =TextStyle(
   color: Color(0xFFA9A9A9),
   fontSize: 12,
   fontFamily: 'Work Sans',
   fontWeight: FontWeight.w400,
   height: 0,
 );
 Widget text = Text("",style: style,);
  switch (value.toInt()){
   case 0:
     text = const Text('MO',style: style,);
     break;
     case 1:
     text = const Text('TU',style: style,);
     break;
     case 2:
     text = const Text('WE',style: style,);
     break;
     case 3:
     text = const Text('TH',style: style,);
     break;
     case 4:
     text = const Text('FR',style: style,);
     break;
     case 5:
     text = const Text('SA',style: style,);
     break;
     case 6:
     text = const Text('SU',style: style,);
     break;
 }
 return SideTitleWidget(axisSide: meta.axisSide, child: text);
}
Widget getrightTitles(double value , TitleMeta meta){
     var style =TextStyle(
   color: Color(0xFFA9A9A9),
   fontSize: 12.sp,
   fontFamily: 'Work Sans',
   fontWeight: FontWeight.w400,
   height: 0,
 );
 Widget text = Text(value.toString(),style: style,);

 if (value >= 1000000) {
   String num =(value / 1000000).toStringAsFixed(0);
    text= Text(num+'M',style: style,);
 } else if (value >= 1000) {
   String num =(value / 1000).toStringAsFixed(0);
   text= Text(num+'k',style: style,);
 } else {
   String num =value.toStringAsFixed(0);
   text= Text(num,style: style,);
 }
 return SideTitleWidget(axisSide: meta.axisSide, child: text);
}
