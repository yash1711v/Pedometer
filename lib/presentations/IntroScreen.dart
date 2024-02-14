import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gradient_button/flutter_gradient_button.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:outline_gradient_button/outline_gradient_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:steptracking/presentations/HomePage.dart';
import 'package:steptracking/presentations/MainScreen.dart';
import 'package:steptracking/widgets/CustomSliderItem.dart';
import '../SharedPrefrences/SharedPref.dart';
import '../main.dart';
import 'SignUpScreen.dart';
import 'package:wheel_slider/wheel_slider.dart';
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}
bool onLastPage = false;
bool NotificationPermision=false;
bool ActivityPermission=false;
class _IntroScreenState extends State<IntroScreen> {

  List<String> image=[
    'lib/assests/NewImages/Themedata.png',
    'lib/assests/NewImages/theme2.png',
    'lib/assests/NewImages/Theme3.png'
  ];
  int value=0;
  PageController _controller=PageController();
  List<Color> Theme1=[];
  List<Color> Theme2=[];
  List<Color> Theme3=[];
  List<Color> whichTheme(){
    if(value==0){
      return Theme1;
    } else if(value==1){
      return Theme2;
    }else if(value==2){
      return Theme3;
    }
    return Theme1;
  }
  List<String> Images=[
    'lib/assests/NewImages/MaleTheme1.png',
    'lib/assests/NewImages/FemaleTheme1.png',
    'lib/assests/NewImages/OthersTheme1.png'
  ];
  List<String> Imagesunselected=[
    'lib/assests/NewImages/Male.png',
    'lib/assests/NewImages/Female.png',
    'lib/assests/NewImages/Others.png'
  ];
  defaulttheme() async {
    await SharedPref().saveColorList(Theme1);
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   setState(() {
     Theme1.add(Color(0xFFF7722A));
     Theme1.add(Color(0xFFE032A1));
     Theme1.add(Color(0xFFCF03F9));
     Theme2.add(Color(0xFF04EF77));
     Theme2.add(Color(0xFF1F8EAE));
     Theme2.add(Color(0xFF2E52D0));
     Theme3.add(Color(0xFFFF00E2));
     Theme3.add(Color(0xFF9242EB));
     Theme3.add(Color(0xFF2F7FF3));
   });
    whichTheme();
    defaulttheme();

  }
  int Gender=0;

  int Age=0;
  int StepsTarget=0;
  int page=0;
  double Height=0;
  double Weight=0;
  String WhichGender(int gender){
    if(gender==0){
      return 'male';
    }else if(gender==1){
      return 'female';
    }
    else {
      return 'other';
    }
    return 'male';
  }
  double inMiles=0;
  String time="";


  bool Notification =false;
  bool Activitysensor=false;

  Widget Whichtext() {
    if(page==3){
      return Text("Give Permision");
    }else if(page==3 && Notification==false && Activitysensor==false ){
      return  Text("Give Permision");
    }else if(page==3 && Activitysensor==true){
      return Text("Welcome");
    }else{
      return Text("Next");
    }
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      SystemNavigator.pop();
      return true;},
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(image: DecorationImage(
        image: AssetImage("lib/assests/NewImages/SplashScreen_bg.png"),
          fit: BoxFit.fitWidth
      )),
      child:  Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:  EdgeInsets.only(top: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                   IconButton(onPressed: (){
                     _controller.previousPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);

                   }, icon:   ImageIcon(AssetImage("lib/assests/NewImages/BackwordArrow.png")),
                   color: Colors.white,),
                    Container(width: 150,),
                    IconButton(onPressed: (){
                      _controller.jumpToPage(5);
                    }, icon:   ImageIcon(AssetImage("lib/assests/NewImages/cross.png"),
                    size: 28,), color: Colors.white,),

                ],),

              ),
              Container(
                height:MediaQuery.of(context).size.height-300,
                child: PageView(
                                controller: _controller,
                                onPageChanged: (index){

                                  setState(() {
                                    onLastPage=(index==3);
                                    page=index;

                                  });
                                  print(page);
                                  print(index);
                                  HapticFeedback.lightImpact();
                                },
                  children: [
                    SvgPicture.asset("lib/assests/NewImages/FirstScreenImage.svg",
                      height: MediaQuery.of(context).size.height-300,
                    ),
                    Center(
                      child: Stack(
                        children: [
                          Padding(
                            padding:  EdgeInsets.only(top: 35),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Embrace the Awards Challenge",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                    fontFamily: 'Teko',
                                    fontWeight: FontWeight.w400,
                                    height: 0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: Container(
                              height: 600,
                              width: 600,
                              child: Image.asset("lib/assests/NewImages/TemporarilyData.png",
                                width: 800,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Center(
                      child: Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Choose your Color theme",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontFamily: 'Teko',
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                ),
                              ),
                            ],
                          ),
                          Image.asset(image[value]),
                          Padding(
                            padding:  EdgeInsets.only(top: 400,left: 100,right: 90),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    HapticFeedback.lightImpact();
                                    setState(() {
                                      value=0;;
                                      Theme1.clear();
                                      Theme1.add(Color(0xFFF7722A));
                                      Theme1.add(Color(0xFFE032A1));
                                      Theme1.add(Color(0xFFCF03F9));
                                      Images.clear();
                                      Images.add('lib/assests/NewImages/MaleTheme1.png');
                                      Images.add('lib/assests/NewImages/FemaleTheme1.png');
                                      Images.add('lib/assests/NewImages/OthersTheme1.png');
                                    });
                                    print(Theme1);
                                    await SharedPref().saveColorList(Theme1);
                                    await SharedPref().saveImageList(Images);

                                  },
                                  child:
                                  Container(
                                    // color: Colors.white,
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: value==0?Colors.white:Colors.transparent, // Replace with your border color
                                        width: 3, // Replace with your border width
                                      ),
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFF7722A),
                                          Color(0xFFE032A1),
                                          Color(0xFFCF03F9),
                                        ], // Replace with your gradient colors
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                    // child: Center(child: Text("Next",style: TextStyle(color: Colors.white),)),
                                  ),
                                ),
                                SizedBox(width: 10,),

                                GestureDetector(
                                  onTap: () async {
                                    HapticFeedback.lightImpact();
                                    setState(() {
                                      value=1;
                                      Theme2.clear();
                                      Theme2.add(Color(0xFF04EF77));
                                      Theme2.add(Color(0xFF1F8EAE));
                                      Theme2.add(Color(0xFF2E52D0));
                                      Images.clear();
                                      Images.add('lib/assests/NewImages/MaleTheme2.png');
                                      Images.add('lib/assests/NewImages/FemaleTheme2.png');
                                      Images.add('lib/assests/NewImages/OthersTheme2.png');
                                    });
                                    print(Theme2);
                                    await SharedPref().saveColorList(Theme2);
                                    await SharedPref().saveImageList(Images);
                                  },
                                  child:
                                  Container(
                                    // color: Colors.white,
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: value==1?Colors.white:Colors.transparent, // Replace with your border color
                                        width: 3, // Replace with your border width
                                      ),
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF04EF77),
                                          Color(0xFF1F8EAE),
                                          Color(0xFF2E52D0),
                                        ], // Replace with your gradient colors
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                    // child: Center(child: Text("Next",style: TextStyle(color: Colors.white),)),
                                  ),
                                ),
                                SizedBox(width: 10,),
                                GestureDetector(
                                  onTap: () async {
                                    HapticFeedback.lightImpact();
                                    setState(() {
                                      value=2;
                                      Theme3.clear();
                                      Theme3.add(Color(0xFFFF00E2));
                                      Theme3.add(Color(0xFF9242EB));
                                      Theme3.add(Color(0xFF2F7FF3));
                                      Images.clear();
                                      Images.add('lib/assests/NewImages/MaleTheme3.png');
                                      Images.add('lib/assests/NewImages/FemaleTheme3.png');
                                      Images.add('lib/assests/NewImages/othersTheme3.png');
                                    });
                                    print(Theme3);
                                    await SharedPref().saveColorList(Theme3);
                                    await SharedPref().saveImageList(Images);
                                  },
                                  child:
                                  Container(
                                    // color: Colors.white,
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:  value==2?Colors.white:Colors.transparent, // Replace with your border color
                                        width: 3, // Replace with your border width
                                      ),
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFFF00E2),
                                          Color(0xFF9242EB),
                                          Color(0xFF2F7FF3),
                                        ], // Replace with your gradient colors
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                    // child: Center(child: Text("Next",style: TextStyle(color: Colors.white),)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Column(
                    //   children: [
                    //     SizedBox(height: 10,),
                    //     Center(
                    //       child: Text("Body Mass Index",
                    //         style: TextStyle(
                    //           color: Colors.white,
                    //           fontSize: 34,
                    //           fontFamily: 'Teko',
                    //           fontWeight: FontWeight.w400,
                    //           height: 0,
                    //         ),
                    //       ),
                    //     ),
                    //     Center(
                    //       child: Text("Gender",
                    //         style: TextStyle(
                    //           color: Colors.white,
                    //           fontSize: 26,
                    //           fontFamily: 'Teko',
                    //           fontWeight: FontWeight.w400,
                    //           height: 0,
                    //         ),
                    //       ),
                    //     ),
                    //     Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //       children: [
                    //         SizedBox(
                    //           height: 100,
                    //           width: 100,
                    //           child: OutlineGradientButton(
                    //             onTap: (){
                    //               HapticFeedback.lightImpact();
                    //               setState(() {
                    //                 Gender=0;
                    //               });
                    //             },
                    //             child:  Image.asset( Gender==0?Images[0]:Imagesunselected[0],
                    //             scale: 4,),
                    //             gradient: LinearGradient(colors: Gender==0?whichTheme():[Colors.grey,Colors.grey,]),
                    //             strokeWidth: 4,
                    //             elevation: 1,
                    //             radius: Radius.circular(15),
                    //           ),
                    //         ),
                    //         SizedBox(
                    //           height: 100,
                    //           width: 100,
                    //           child: OutlineGradientButton(
                    //             onTap: (){
                    //               HapticFeedback.lightImpact();
                    //               setState(() {
                    //                 Gender=1;
                    //               });
                    //             },
                    //             child:  Image.asset(Gender==1?Images[1]:Imagesunselected[1],
                    //               scale: 4,
                    //             ),
                    //             gradient: LinearGradient(colors: Gender==1?whichTheme():[Colors.grey,Colors.grey,]),
                    //             strokeWidth: 4,
                    //             elevation: 1,
                    //             radius: Radius.circular(15),
                    //           ),
                    //         ),
                    //         SizedBox(
                    //           height: 100,
                    //           width: 100,
                    //           child: OutlineGradientButton(
                    //             onTap: (){
                    //               HapticFeedback.lightImpact();
                    //               setState(() {
                    //                 Gender=2;
                    //               });
                    //             },
                    //             child:  Image.asset(Gender==2?Images[2]:Imagesunselected[2],
                    //               scale: 4,
                    //             ),
                    //             gradient: LinearGradient(colors:Gender==2?whichTheme():[Colors.grey,Colors.grey,]),
                    //             strokeWidth: 4,
                    //             elevation: 1,
                    //             radius: Radius.circular(15),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //     Row(
                    //
                    //       children: [
                    //         Padding(
                    //           padding:  EdgeInsets.only(left: 60),
                    //           child: ShaderMask(
                    //             shaderCallback: (Rect bounds) {
                    //               return LinearGradient(
                    //                 colors: Gender==0?whichTheme():[Colors.grey,Colors.grey],  // Replace these colors with your desired gradient colors
                    //                 begin: Alignment.center,
                    //                 end: Alignment.bottomRight,
                    //               ).createShader(bounds);
                    //             },
                    //             child: Text( "Male",
                    //               style: TextStyle(
                    //                 fontSize: 25.sp,
                    //                 fontFamily: 'Teko',
                    //                 fontWeight: FontWeight.w600,
                    //                 letterSpacing: 1.5,
                    //                 color: Colors.white,  // Set the color to white since it will be masked by the gradient
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //         Padding(
                    //           padding:  EdgeInsets.only(left: 90),
                    //           child: ShaderMask(
                    //             shaderCallback: (Rect bounds) {
                    //               return LinearGradient(
                    //                 colors: Gender==1?whichTheme():[Colors.grey,Colors.grey],  // Replace these colors with your desired gradient colors
                    //                 begin: Alignment.center,
                    //                 end: Alignment.bottomRight,
                    //               ).createShader(bounds);
                    //             },
                    //             child: Text( "FeMale",
                    //               style: TextStyle(
                    //                 fontSize: 25.sp,
                    //                 fontFamily: 'Teko',
                    //                 fontWeight: FontWeight.w600,
                    //                 letterSpacing: 1.5,
                    //                 color: Colors.white,  // Set the color to white since it will be masked by the gradient
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //         Padding(
                    //           padding:  EdgeInsets.only(left: 75),
                    //           child: ShaderMask(
                    //             shaderCallback: (Rect bounds) {
                    //               return LinearGradient(
                    //                 colors: Gender==2?whichTheme():[Colors.grey,Colors.grey],  // Replace these colors with your desired gradient colors
                    //                 begin: Alignment.center,
                    //                 end: Alignment.bottomRight,
                    //               ).createShader(bounds);
                    //             },
                    //             child: Text( "Others",
                    //               style: TextStyle(
                    //                 fontSize: 25.sp,
                    //                 fontFamily: 'Teko',
                    //                 fontWeight: FontWeight.w600,
                    //                 letterSpacing: 1.5,
                    //                 color: Colors.white,  // Set the color to white since it will be masked by the gradient
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //
                    //       ],
                    //     ),
                    //     SizedBox(height: 25,),
                    //     Text('Height (in cm)',
                    //       style: TextStyle(
                    //         color: Colors.white,
                    //         fontSize: 16,
                    //         fontFamily: 'Teko',
                    //         fontWeight: FontWeight.w400,
                    //         height: 0,
                    //         letterSpacing: 0.80,
                    //       ),),
                    //     SizedBox(height: 10,),
                    //     Container(
                    //       width: 328,
                    //       height: 90,
                    //       decoration: ShapeDecoration(
                    //         shape: RoundedRectangleBorder(
                    //           side: BorderSide(width: 1, color: Color(0xFF949494)),
                    //           borderRadius: BorderRadius.circular(15),
                    //         ),
                    //       ),
                    //       child: Padding(
                    //         padding:  EdgeInsets.symmetric(vertical: 10,horizontal: 8),
                    //         child: WheelSlider.customWidget(
                    //           totalCount: 10000,
                    //           initValue: _cCurrentValue,
                    //           isInfinite: true,
                    //           scrollPhysics: const BouncingScrollPhysics(),
                    //           customPointer: CustomSliderItem(color: Colors.pinkAccent,),
                    //           children: List.generate(10000, (index) =>  Center(
                    //             child: Column(
                    //               children: [
                    //                 SizedBox(height: 25,),
                    //                 Text(index.toString(),
                    //                 style: TextStyle(
                    //                   color: _cCurrentValue==index?Colors.pinkAccent:Colors.grey,
                    //                   fontSize: 25,
                    //                   fontFamily: 'teko'
                    //                 ),
                    //                 ),
                    //               ],
                    //             )
                    //           )),
                    //           onValueChanged: (val) {
                    //             setState(() {
                    //               _cCurrentValue = val;
                    //                 Height=double.parse(val.toString());
                    //             });
                    //             print(Height);
                    //           },
                    //           hapticFeedbackType: HapticFeedbackType.lightImpact,
                    //           showPointer: true,
                    //           itemSize: 80,
                    //           horizontalListWidth: 100,
                    //         ),
                    //       ),
                    //     ),
                    //     SizedBox(height: 30,),
                    //     Text("Weight (in Kg)",
                    //       style: TextStyle(
                    //         color: Colors.white,
                    //         fontSize: 16,
                    //         fontFamily: 'Teko',
                    //         fontWeight: FontWeight.w400,
                    //         height: 0,
                    //         letterSpacing: 0.80,
                    //       ),
                    //     ),
                    //     SizedBox(height: 10,),
                    //     Container(
                    //       width: 328,
                    //       height: 90,
                    //       decoration: ShapeDecoration(
                    //         shape: RoundedRectangleBorder(
                    //           side: BorderSide(width: 1, color: Color(0xFF949494)),
                    //           borderRadius: BorderRadius.circular(15),
                    //         ),
                    //       ),
                    //       child: Padding(
                    //         padding:  EdgeInsets.symmetric(vertical: 10,horizontal: 8),
                    //         child:
                    //         WheelSlider.customWidget(
                    //           totalCount: 10000,
                    //           initValue: _cCurrentValueWeight,
                    //           isInfinite: true,
                    //           scrollPhysics: const BouncingScrollPhysics(),
                    //           customPointer: CustomSliderItem(color: Colors.pinkAccent,),
                    //           children: List.generate(10000, (index) =>  Center(
                    //             child: Column(
                    //               children: [
                    //                 SizedBox(height: 25,),
                    //                 Text(index.toString(),
                    //                 style: TextStyle(
                    //                   color: _cCurrentValueWeight==index?Colors.pinkAccent:Colors.grey,
                    //                   fontSize: 25,
                    //                   fontFamily: 'teko'
                    //                 ),
                    //                 ),
                    //               ],
                    //             )
                    //           )),
                    //           onValueChanged: (val) {
                    //
                    //             setState(() {
                    //               _cCurrentValueWeight = val;
                    //               Weight=double.parse(val.toString());
                    //             });
                    //           },
                    //           hapticFeedbackType: HapticFeedbackType.lightImpact,
                    //           showPointer: true,
                    //           itemSize: 80,
                    //           horizontalListWidth: 100,
                    //         ),
                    //       ),
                    //     ),
                    //     SizedBox(height: 30,),
                    //     Text("Age",
                    //       style: TextStyle(
                    //         color: Colors.white,
                    //         fontSize: 16,
                    //         fontFamily: 'Teko',
                    //         fontWeight: FontWeight.w400,
                    //         height: 0,
                    //         letterSpacing: 0.80,
                    //       ),
                    //     ),
                    //     Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //       children: [
                    //         IconButton(onPressed: (){
                    //               HapticFeedback.lightImpact();
                    //
                    //           setState(() {
                    //             if(Age>0) {
                    //               Age = Age - 1;
                    //
                    //             }else{
                    //               Age=0;
                    //             }
                    //           });
                    //         }, icon: ImageIcon(AssetImage("lib/assests/NewImages/Subtraction.png"))),
                    //         ShaderMask(
                    //           shaderCallback: (Rect bounds) {
                    //             return LinearGradient(
                    //               colors:whichTheme(),  // Replace these colors with your desired gradient colors
                    //               begin: Alignment.center,
                    //               end: Alignment.bottomRight,
                    //             ).createShader(bounds);
                    //           },
                    //           child: Text(
                    //              Age.toString(),
                    //             style: TextStyle(
                    //               fontSize: 46.sp,
                    //               fontFamily: 'Teko',
                    //               fontWeight: FontWeight.w600,
                    //               letterSpacing: 1.5,
                    //               color: Colors.white,  // Set the color to white since it will be masked by the gradient
                    //             ),
                    //           ),
                    //         ),
                    //         IconButton(onPressed: (){
                    //           HapticFeedbackType.lightImpact;
                    //           setState(() {
                    //             Age = Age + 1;
                    //           });
                    //         }, icon: ImageIcon(AssetImage("lib/assests/NewImages/Addition.png"))),
                    //       ],
                    //     ) ,
                    //     SizedBox(height:  15,),
                    //     Text("Your Activity Level",
                    //       style: TextStyle(
                    //         color: Colors.white,
                    //         fontSize: 16,
                    //         fontFamily: 'Teko',
                    //         fontWeight: FontWeight.w400,
                    //         height: 0,
                    //         letterSpacing: 0.80,
                    //       ),
                    //     ),
                    //     Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //       children: [
                    //         IconButton(onPressed: (){
                    //               HapticFeedback.lightImpact();
                    //
                    //           setState(() {
                    //               if(ActivityIndex>0){
                    //                 ActivityIndex=ActivityIndex-1;
                    //               }
                    //           });
                    //         }, icon: Icon(Icons.arrow_left_rounded,size: 50,color: Colors.white,)),
                    //         ShaderMask(
                    //           shaderCallback: (Rect bounds) {
                    //             return LinearGradient(
                    //               colors:whichTheme(),  // Replace these colors with your desired gradient colors
                    //               begin: Alignment.center,
                    //               end: Alignment.bottomRight,
                    //             ).createShader(bounds);
                    //           },
                    //           child: Text(
                    //              ActivityLevel[ActivityIndex],
                    //             style: TextStyle(
                    //               fontSize: 46.sp,
                    //               fontFamily: 'Teko',
                    //               fontWeight: FontWeight.w600,
                    //               letterSpacing: 1.5,
                    //               color: Colors.white,  // Set the color to white since it will be masked by the gradient
                    //             ),
                    //           ),
                    //         ),
                    //         IconButton(onPressed: (){
                    //           HapticFeedback.lightImpact();
                    //
                    //           setState(() {
                    //             if( ActivityIndex<3)
                    //               ActivityIndex=ActivityIndex+1;
                    //           });
                    //         }, icon: Icon(Icons.arrow_right_rounded,size: 50,color: Colors.white,)),
                    //       ],
                    //     )
                    //
                    //   ],
                    // ),
                    // Column(
                    //
                    //   children: [
                    //     SizedBox(height: 50,),
                    //     Text("Your Goal",
                    //       style: TextStyle(
                    //         fontSize: 40.sp,
                    //         fontFamily: 'Teko',
                    //         fontWeight: FontWeight.w600,
                    //         letterSpacing: 1.5,
                    //         color: Colors.white,  // Set the color to white since it will be masked by the gradient
                    //       ),
                    //     ),
                    //     Text("According to the BMI",
                    //       style: TextStyle(
                    //         fontSize: 12.sp,
                    //         fontFamily: 'Teko',
                    //         fontWeight: FontWeight.w600,
                    //         letterSpacing: 1.5,
                    //         color: Colors.white,  // Set the color to white since it will be masked by the gradient
                    //       ),
                    //     ),
                    //     SizedBox(height: 15,),
                    //     Image.asset("lib/assests/NewImages/StepSettingPage.png",
                    //     scale: 3,
                    //     ),
                    //     SizedBox(height: 15,),
                    //     Text("Steps Target",
                    //       style: TextStyle(
                    //         fontSize: 46.sp,
                    //         fontFamily: 'Teko',
                    //         fontWeight: FontWeight.w600,
                    //         letterSpacing: 1.5,
                    //         color: Colors.white,  // Set the color to white since it will be masked by the gradient
                    //       ),
                    //     ),
                    //     Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //       children: [
                    //         IconButton(onPressed: (){
                    //           HapticFeedback.lightImpact();
                    //
                    //           setState(() {
                    //             if(StepsTarget>0) {
                    //               StepsTarget = StepsTarget - 50;
                    //
                    //             }else{
                    //               StepsTarget=0;
                    //             }
                    //           });
                    //         }, icon: ImageIcon(AssetImage("lib/assests/NewImages/Subtraction.png"))),
                    //         ShaderMask(
                    //           shaderCallback: (Rect bounds) {
                    //             return LinearGradient(
                    //               colors:whichTheme(),  // Replace these colors with your desired gradient colors
                    //               begin: Alignment.center,
                    //               end: Alignment.bottomRight,
                    //             ).createShader(bounds);
                    //           },
                    //           child: Text(
                    //             StepsTarget.toString(),
                    //             style: TextStyle(
                    //               fontSize: 46.sp,
                    //               fontFamily: 'Teko',
                    //               fontWeight: FontWeight.w600,
                    //               letterSpacing: 1.5,
                    //               color: Colors.white,  // Set the color to white since it will be masked by the gradient
                    //             ),
                    //           ),
                    //         ),
                    //         IconButton(onPressed: (){
                    //           HapticFeedbackType.lightImpact;
                    //           setState(() {
                    //             StepsTarget = StepsTarget + 100;
                    //           });
                    //         }, icon: ImageIcon(AssetImage("lib/assests/NewImages/Addition.png"))),
                    //       ],
                    //     ) ,
                    //     SizedBox(height: 58,),
                    //     Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //       children: [
                    //         Column(
                    //           crossAxisAlignment: CrossAxisAlignment.center,
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: [
                    //             ImageIcon(AssetImage("lib/assests/NewImages/Distance.png"),color: Colors.white,size: 34,),
                    //             Text(StepsToDistance(StepsTarget,false))
                    //           ],
                    //         ),
                    //         Column(
                    //           crossAxisAlignment: CrossAxisAlignment.center,
                    //            mainAxisAlignment: MainAxisAlignment.center,
                    //           children: [
                    //             ImageIcon(AssetImage("lib/assests/NewImages/Clock.png"),color: Colors.white,size: 34),
                    //             Text(calculateTimeToCoverDistance(height: Height, steps: StepsTarget, gender: WhichGender(Gender), distance: double.parse(
                    //                 StepsToDistanceDouble(StepsTarget,false).toString())                                )
                    //             ),
                    //
                    //           ],
                    //         ),
                    //         Column(
                    //           children: [
                    //             ImageIcon(AssetImage("lib/assests/NewImages/Calories.png"),color: Colors.white,size: 34,),
                    //             Text(calculateCaloriesBurned(weight: Weight, height: Height, age: Age, gender: WhichGender(Gender), steps: StepsTarget, activityLevel: ActivityLevelNumber[ActivityIndex]).toString())
                    //           ],
                    //         )
                    //       ],
                    //     )
                    //   ],
                    // ),
                   Column(
                     children: [
                     Padding(
                       padding:  EdgeInsets.only(top: 56,left: 29),
                       child: Row(
mainAxisAlignment: MainAxisAlignment.center,
                         children: [

                           Text(
                             'Permissions',
                             style: TextStyle(
                               color: Colors.white,
                               fontSize: 54.sp,
                               fontFamily: 'Teko',
                               fontWeight: FontWeight.w400,
                               height: 0,
                               letterSpacing: 4.80,
                             ),
                           )
                         ],
                       ),
                     ),
                     Padding(
                       padding:  EdgeInsets.only(top: 54,left: 29,right: 25),
                       child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Align(
                             alignment: Alignment.centerLeft,
                             child: Text(
                               'Notifications',
                               style: TextStyle(
                                 color: Colors.white,
                                 fontSize: 20.sp,
                                 fontFamily: 'Work Sans',
                                 fontWeight: FontWeight.w400,
                                 height: 0,
                               ),
                             ),
                           ),
                           // Align(
                           //   alignment: Alignment.centerRight,
                           //   child:
                           //   Container(
                           //     width: 18,
                           //     height: 18,
                           //     decoration:
                           //     Notification==true?ShapeDecoration(
                           //       gradient: LinearGradient(
                           //         begin: Alignment(1.00, -0.00),
                           //         end: Alignment(-1, 0),
                           //         colors: [Color(0xFFFC8010), Color(0xFFDF30A4), Color(0xFFCF03F9)],
                           //       ),
                           //       shape: OvalBorder(
                           //         side: BorderSide(
                           //           width: 1,
                           //           strokeAlign: BorderSide.strokeAlignOutside,
                           //           color: Colors.white,
                           //         ),
                           //       ),
                           //     ):ShapeDecoration(
                           //       shape: OvalBorder(
                           //         side: BorderSide(
                           //           width: 1,
                           //           strokeAlign: BorderSide.strokeAlignOutside,
                           //           color: Colors.white,
                           //         ),
                           //       ),
                           //     ),
                           //     child: Notification?Icon(Icons.check,color: Colors.white,size: 15,):Container(),
                           //   ),
                           // )
                         ],
                       ),
                     ),
                     Padding(
                       padding:  EdgeInsets.only(top: 54,left: 29,right: 25),
                       child: Column(
                         children: [
                           Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               Align(
                                 alignment: Alignment.centerLeft,
                                 child: Text(
                                   'Activity & Body Sensor',
                                   style: TextStyle(
                                     color: Colors.white,
                                     fontSize: 20.sp,
                                     fontFamily: 'Work Sans',
                                     fontWeight: FontWeight.w400,
                                     height: 0,
                                   ),
                                 ),
                               ),
                               // Align(
                               //   alignment: Alignment.centerRight,
                               //   child:
                               //   Container(
                               //     width: 18,
                               //     height: 18,
                               //     decoration:
                               //     Activitysensor?ShapeDecoration(
                               //       gradient: LinearGradient(
                               //         begin: Alignment(1.00, -0.00),
                               //         end: Alignment(-1, 0),
                               //         colors: [Color(0xFFFC8010), Color(0xFFDF30A4), Color(0xFFCF03F9)],
                               //       ),
                               //       shape: OvalBorder(
                               //         side: BorderSide(
                               //           width: 1,
                               //           strokeAlign: BorderSide.strokeAlignOutside,
                               //           color: Colors.white,
                               //         ),
                               //       ),
                               //     ):ShapeDecoration(
                               //       shape: OvalBorder(
                               //         side: BorderSide(
                               //           width: 1,
                               //           strokeAlign: BorderSide.strokeAlignOutside,
                               //           color: Colors.white,
                               //         ),
                               //       ),
                               //     ),
                               //     child: Activitysensor?Center(child: Icon(Icons.check,color: Colors.white,size: 15,)):Container(),
                               //
                               //   ),
                               // )
                             ],
                           ),

                         ],
                       ),
                     ),
                     ],
                   )
                  ],
                ),

              ),
              SizedBox(height: 65,),
              SmoothPageIndicator(
                  controller: _controller, count: 4,
                  effect: SwapEffect(
                    type: SwapType.yRotation,
                    activeDotColor: whichTheme()[0],   // Color of the active dot
                    dotHeight: 10,                // Height of the dots
                    dotWidth: 10,                 // Width of the dots
                    spacing: 8.0,
                    paintStyle: PaintingStyle.stroke,  // Use stroke for non-active dots
                    strokeWidth: 1.5,                 // Stroke width for non-active dots
                    dotColor: Colors.white,
                  )

              ),
              SizedBox(height: 30,),

              GradientButton(
                colors: whichTheme(),
                width: 329,
                    height: 56,
                radius: 10,
                gradientDirection: GradientDirection.leftToRight,
                textStyle: TextStyle(color: Colors.white),
                text:  Whichtext(),
                onPressed: () async {
                  print("Button clicked");
                  if(onLastPage){
                    PermissionStatus status1=await Permission.activityRecognition.request();
                    PermissionStatus status2=await Permission.notification.request();
                    if(status1.isGranted || status2.isGranted && Platform.isAndroid){
                      print("Status Granted");
                      print("Status1 $status1");
                      print("Status2 $status2");
                      if(status1==PermissionStatus.granted){
                        print("Status1 Granteed");
                        setState(() {
                          Activitysensor=true;
                        });
                        await SharedPref().setisOnboarding(true);
                        Get.to(()=>SignUpScreen());

                      }else{
                        print("Status1 denied");
                        setState(() {
                          Activitysensor=false;
                        });
                       await openAppSettings();
                      }
                      if(status2==PermissionStatus.granted){
                        print("Status2 Granteed");
                        setState(() {
                          Notification=true;
                        });

                      }else{
                        print("Status2 denied");
                        setState(() {
                          Notification=false;
                        });
                        status2=await Permission.activityRecognition.request();
                        await openAppSettings();

                      }

                    }else{
                      await SharedPref().setisOnboarding(true);
                      Get.to(()=>SignUpScreen());
                    }



                          }
                          else{_controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);}
                },
              ),

              SizedBox(height: 20,),
            ],
          ),
        ),
      ),
      )
    );
  }

}
