import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:steptracking/presentations/HomePage.dart';
import 'package:steptracking/presentations/LevelMapScreen.dart';
import 'package:steptracking/presentations/ReportScreen.dart';
import 'package:steptracking/presentations/SettingsScreen.dart';

import '../SharedPrefrences/SharedPref.dart';
import '../widgets/BottomNavbar.dart';
import 'Linechart.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // controller. milestonesAchieved.value.clear();


  }
  late List<Color> Themee=[];
  Future<void> getColors() async {
    List<Color> loadedTheme = await SharedPref().loadColorList();
    setState(() {
      Themee=loadedTheme;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getColors();
  }
  @override
  Widget build(BuildContext context) {
    getColors();
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          HomePage(),
          ReportScreen(),
          SettingsScreen(),

        ],
      ),
      bottomNavigationBar: Stack(
        children: [
          Positioned(
            bottom: 16.0,
            left: 0,
            right: 0,
            child: Container(
              height: 80.0,
              margin: EdgeInsets.symmetric(horizontal: 68.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: Themee, // Add your desired colors
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),

                ],
              ),
              child:  ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10.r)),
                      child:BottomNavigationBar(
                        selectedItemColor: Color(0xFFF3F3F3),
                        unselectedItemColor: Color(0x4CF3F3F3),
                        showSelectedLabels: true,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        currentIndex: _selectedIndex,
                        onTap: (index){
                          setState(() {
                            _selectedIndex=index;
                          });

                          _pageController.jumpToPage(_selectedIndex);
                        },
                        items:  [
                          BottomNavigationBarItem(
                              icon: ImageIcon(AssetImage("lib/assests/NewImages/footSteps.png")),
                              activeIcon: ImageIcon(AssetImage("lib/assests/NewImages/footstepsfilled.png")),
                              label: "Activity"
                          ),
                          BottomNavigationBarItem(
                              icon: ImageIcon(AssetImage("lib/assests/NewImages/Awards.png")),
                              activeIcon: ImageIcon(AssetImage("lib/assests/NewImages/AwardsFilled.png")),
                              label: "Awards"
                          ) ,
                          BottomNavigationBarItem(
                              icon: ImageIcon(AssetImage("lib/assests/NewImages/Settings.png")),
                              activeIcon: ImageIcon(AssetImage("lib/assests/NewImages/SettingsFilled.png")),
                              label: "Settings"
                          ),

                        ],),

                  ),

            ),
            ),
       ],
        )
      // Container(
      //   height: 100.h,
      //   child: Padding(
      //     padding:  EdgeInsets.symmetric(horizontal: 68.w,vertical: 10.h),
      //     child: ClipRRect(
      //       borderRadius: BorderRadius.all(Radius.circular(10.r)),
      //       child:

      //   ),
      // ),
    );
  }
}
