import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:level_map/level_map.dart';

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
 List<Color> Theme=[Color(0xFFF7722A),Color(0xFFE032A1),Color(0xFFCF03F9)];
 void initState() {
   super.initState();
   whichTheme();
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
 @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    for(int i=0;i<Images.length;i++) {
      AssetImage(Images[i]);
    }
  }
 @override
  Widget build(BuildContext context) {

    return Container(
         width: MediaQuery.of(context).size.width,
         height: MediaQuery.of(context).size.height,
         decoration: BoxDecoration(image: DecorationImage(image: AssetImage(Images[value]),fit: BoxFit.fill)),
        child: const LevelMapScreen());
  }
}
