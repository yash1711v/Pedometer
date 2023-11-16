import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../SharedPrefrences/SharedPref.dart';

class Mybargraph2 extends StatefulWidget {
  final List<double> monthlyData;
  const Mybargraph2({super.key,  required this.monthlyData});

  @override
  State<Mybargraph2> createState() => _Mybargraph2State();
}

class _Mybargraph2State extends State<Mybargraph2> {
  int StepsTarget = 6000;
  void initState() {
    super.initState();
    // getStepsData();
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        gridData: FlGridData(show: false),
        borderData: FlBorderData(
            show: true,
            border: Border(
                bottom: BorderSide(
                  color: Colors.white,
                  width: 2,
                )
            )
        ),
        titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40,
                getTitlesWidget: getrightTitles
            )),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
                 sideTitles: SideTitles(showTitles: false))
        ),
        // maxY: 25000,
        barGroups: widget.monthlyData
            .asMap()
            .entries
            .map((entry) => BarChartGroupData(
          x: entry.key,
          barRods: [BarChartRodData(
              toY: entry.value.toDouble(),
              color: Color(0xFF9D79BC),
            width: 8.w,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.r),
              topRight: Radius.circular(10.r),
          ),
              backDrawRodData: BackgroundBarChartRodData(
                  show: true, toY: 10000, color: Colors.grey.shade800))
                    ],
        ))
            .toList(),
      ),
    );
  }
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