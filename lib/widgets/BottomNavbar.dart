import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../presentations/HomePage.dart';
import '../presentations/ReportScreen.dart';
import '../presentations/SettingsScreen.dart';



class BottomNavbar extends StatefulWidget {
  var currentIndex;
  BottomNavbar({required this.currentIndex});
  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {


  Widget build(BuildContext context) {
    route(int currentindex){
      if(currentindex==0){
        Get.to(()=>HomePage(),
            duration: const Duration(
                seconds:
                1),
            // transition: Transition.fadeIn
        );
      }else if(currentindex==1){
        Get.to(()=>ReportScreen(),
            duration: const Duration(
                seconds:
                1),
            // transition: Transition.fadeIn
        );
      }else{
        Get.to(()=>SettingsScreen(),
            duration: const Duration(
                seconds:
                1),
            // transition: Transition.fadeIn
        );
      }
    }
    return
      Container(
      height: 100.h,
      child: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 68.w,vertical: 10.h),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(10.r)),
          child: BottomNavigationBar(
            selectedItemColor: Color(0xFFF3F3F3),
            unselectedItemColor: Color(0x4CF3F3F3),
            showSelectedLabels: true,
            backgroundColor: Colors.black,
            currentIndex: widget.currentIndex,
            onTap: (int index){
              route(index);
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.directions_walk,

              ),
              label: "Activity"
              ),
              BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined,),
              label: "Report"
              ) ,
              BottomNavigationBarItem(icon: Icon(Icons.settings,
              ),
              label: "settings"
              )
            ],),
        ),
      ),
    );
  }
}