import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:steptracking/presentations/HomePage.dart';
import '../SharedPrefrences/SharedPref.dart';
import 'SignUpScreen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}
bool onLastPage = false;
class _IntroScreenState extends State<IntroScreen> {
  // Future <void> checkPermission(Permission permission, BuildContext context) async {
  //   final status = await permission.request();
  //   final prefs = await SharedPreferences.getInstance();
  //   if (status.isGranted) {
  //
  //     prefs.setBool('notificaion', true);
  //
  //   } else{
  //     prefs.setBool('notification', false);
  //
  //   }
  // }
  PageController _controller=PageController();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      SystemNavigator.pop();
      return true;},
      child: Scaffold(
         backgroundColor: Color(0xFF2D2D2D),
        body: Stack(

          children: [
            PageView(
              controller: _controller,
              onPageChanged: (index){
                setState(() {
                  onLastPage=(index==2);
                });
              },
            children: [
                    Center(
                      child: Image(
                        image: AssetImage('lib/assests/Images/FirstOnBoardingVector.png'),
                      height: 650.h,
                      ),
                    ),
              Center(
                      child: Image(
                        image: AssetImage('lib/assests/Images/OnBrading2.png'),
                      height: 650.h,
                      ),
                    ),
              Center(
                      child: Image(
                        image: AssetImage('lib/assests/Images/Onboarding3.png'),
                      height: 650.h,
                      ),
                    ),
            ],
          ),

            Container(
                alignment: Alignment(0,0.9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(""),
                     SizedBox(width:100.w),
                     SmoothPageIndicator(
                         controller: _controller, count: 3,
                     effect: WormEffect(
                       activeDotColor: Colors.white,   // Color of the active dot
                       dotHeight: 10,                // Height of the dots
                       dotWidth: 15,                 // Width of the dots
                       spacing: 8.0,
                       paintStyle: PaintingStyle.stroke,  // Use stroke for non-active dots
                       strokeWidth: 1.5,                 // Stroke width for non-active dots
                       dotColor: Colors.white,
                       // Spacing between dots
                     ),
                     ),
                     SizedBox(width: 50.w,),
                     SizedBox(
                       width: 70.w,
                       height: 62.h,
                       child: OutlinedButton(
                          onPressed: () async => {

                            if(onLastPage){
                              SharedPref().setisOnboarding(true),
                         Get.to(()=>SignUpScreen(),
                           duration: const Duration(
                               seconds:
                               1),),
    //                           await checkPermission(Permission.notification, context).then((value) {  Get.to(()=>SignUpScreen(),
    //                             duration: const Duration(
    //                                 seconds:
    //                                 1),);
    //
    //                           // transition: Transition.fadeIn,
    //                           // curve: Curves.easeIn
    // }) ,

                            }
                            else{_controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn)}
                          },
                          style: ButtonStyle(
                              side: MaterialStateProperty.all(BorderSide(
                                  width: 2.0.w,
                                  color: Color(0xFFF3F3F3)
                                      )),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(10.0.r)))),
                          child: Icon(
                            Icons.arrow_forward,
                            color: Color(0xFFF3F3F3),
                          ),
                        ),
                     ),

                  ],
                )),
            
          ],
          
        ),
      )
    );
  }
}
