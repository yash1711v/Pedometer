import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:steptracking/presentations/Back_Service.dart';
import 'package:steptracking/presentations/HomePage.dart';
import 'package:steptracking/presentations/SignUpScreen.dart';
import 'package:steptracking/presentations/StepTargetUpdateScreen.dart';
import 'package:steptracking/presentations/UserInfoUpdate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Firebasefunctionalities/AuthServices.dart';
import '../Firebasefunctionalities/DatabaseServices.dart';
import '../SharedPrefrences/SharedPref.dart';
import '../widgets/BottomNavbar.dart';
import 'HomeController.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void initState(){
    setState(() {
      Theme.add(Color(0xFFF7722A));
      Theme.add(Color(0xFFE032A1));
      Theme.add(Color(0xFFCF03F9));
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
    getUserData();
  }
  Reaction<String> initialSelectedReaction = Reaction<String>(
    value: 'like',
    icon:  Container(
      // color: Colors.white,
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.transparent, // Replace with your border color
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
  );
  late TextEditingController _EmailController = TextEditingController();

  final FocusNode _emailNode = FocusNode();
  late TextEditingController _dailyStepController = TextEditingController();

  final FocusNode _dailyStep = FocusNode();
  DatabaseServices services = DatabaseServices();
  String _email = '';
  String Email="";
  String UserName="";
  String Uid="";
  int StepsTarget = 0;
  bool isGuest=false;
  String Deviceid="";
  List<Color> Theme1=[];
  List<Color> Theme=[];
  List<Color> Theme2=[];
  List<Color> Theme3=[];
  int value=1;
      String formattedDate = DateFormat('yyyy-MM-dd').format( DateTime.now());
  DatabaseReference ref= FirebaseDatabase.instance.reference();
  final AuthServices _authServices=AuthServices();
  Future<String> getDeviceUID() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceUID = '';

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceUID = androidInfo.androidId; // Or any unique identifier
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceUID = iosInfo.identifierForVendor; // Or any unique identifier
    }

    return deviceUID;
  }
  HomeControllwe homeControllwe = Get.find<HomeControllwe>();
  Future<void> getUserData() async {
    bool isMiles=await SharedPref().getisMiles();
    String useName = await SharedPref().getUsername();
    print("user Name----------------------------------->"+useName);
    String _uid = await SharedPref().getUid();
    String email = await SharedPref().getEmail();
    int stepTar=await SharedPref().getStepsTarget();
    bool isguest=await SharedPref().getisguest();
    List<Color> theme=await SharedPref().loadColorList();
    homeControllwe.updateStepsTarget(stepTar);
    setState(() {
      Email=email;
      UserName=useName;
      Uid=_uid;
      isMIles=isMiles;
      StepsTarget=homeControllwe.StepsTarget.value;
      isGuest=isguest;
      _EmailController.text=UserName;
      Theme=theme;
      _dailyStepController.text=StepsTarget.toString();

      if(Theme[0]==Color(0xFFF7722A)){
        print("theme1");
        setState(() {
          value=1;
        });
      }
      else if(Theme[0]==Color(0xFF04EF77)){
        print("theme2");
          setState(() {
            value=2;
          });
      }
      else{
        print("theme3");
      setState(() {
        value=3;
      });
      }
    });

    print("isguest----------------------------------------------------->"+isguest.toString());


  }

  Future<void> _launchURL() async {
    const url = 'https://sites.google.com/view/steptracker-privacypolicy/home'; // Replace with your privacy policy URL
    await launchUrl(Uri.parse(url));
  }




  bool isMIles = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       resizeToAvoidBottomInset: true,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w,),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 62.h,),

            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Profile',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 54.sp,
                    fontFamily: 'Teko',
                    fontWeight: FontWeight.w600,
                    height: 0,
                    letterSpacing: 3),
              ),
            ),
            SizedBox(height: 35.h),
            Text(
              'ACCOUNT',
              style: TextStyle(
                color: Color(0xFFA9A9A9),
                fontSize: 20.sp,
                fontFamily: 'Work Sans',
                fontWeight: FontWeight.w600,
                height: 0,
              ),
            ),

            SizedBox(height: 15.h,),
            Text(
              'Username',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontFamily: 'Work Sans',
                fontWeight: FontWeight.w400,
                height: 0,
              ),
            ),
            SizedBox(height: 15,),
            TextField(
              textAlign: TextAlign.center,
              controller: _EmailController,
              readOnly: false,
              obscureText: false,
              focusNode: _emailNode,
              style:  TextStyle(
                  color: Colors.white
              ),
              decoration: InputDecoration(
                hintStyle:  TextStyle(
                  color: Colors.white,
                  fontSize: 16.w,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 2.w,
                      color: Colors.white
                  ), //<-- SEE HERE
                  borderRadius: BorderRadius.circular(10.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:  BorderSide(
                      width: 2.w,
                      color:Colors.white), //<-- SEE HERE
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) async {
                setState(() {
                  _email = value;
                });
                await SharedPref().setUsername(_email);
                 services.UpdateEmail(Uid, _email);

              },
            ),

            SizedBox(height: 59.h,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('OTHERS',
                  style: TextStyle(
                    color: Color(0xFFA9A9A9),
                    fontSize: 20,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w600,
                    height: 0,
                  ),)
              ],
            ),
            SizedBox(height: 20.h,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Update',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
                // SizedBox(width: 91.w,),
                TextButton(
                    onPressed: (){
                      Get.to(()=>UserInfoUpdate());
                    },
                    child: Row(
                      children: [
                        SizedBox(width: 5.w,),
                        Icon(Icons.arrow_forward_ios_outlined,
                          size: 20,
                          color: Colors.white,)
                      ],
                    )),
              ],
            ),
            SizedBox(height: 20.h,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Step Goal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
                // SizedBox(width: 91.w,),
                TextButton(
                    onPressed: (){
                       Get.to(()=>StepTargetUpdateScreen());
                 },
                    child: Row(
                  children: [
                    Text(
                      homeControllwe.StepsTarget.value.toString()+' steps',
                      style: TextStyle(
                        color: Color(0xFFA9A9A9),
                        fontSize: 17.sp,
                        fontFamily: 'Work Sans',
                        fontWeight: FontWeight.w400,
                        height: 0,
                      ),),
                    SizedBox(width: 5.w,),
                    Icon(Icons.arrow_forward_ios_outlined,
                    size: 20,
                    color: Colors.white,)
                  ],
                )),
              ],
            ),
            SizedBox(height: 5.h,),

            SizedBox(height: 5.h,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                     'Distance in miles',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
                // SizedBox(width: 160.w,),
                Switch(
                  // This bool value toggles the switch.
                  value: isMIles,
                  activeColor: Theme[0],
                  onChanged: (bool value) {
                    // This is called when the user toggles the switch.
                    setState(() {
                      isMIles = value;
                      SharedPref().setisMiles(value);
                    });
                  },
                ),
              ],
            ),

            Opacity(
              opacity: 0.50,
              child: Text(
                'Default is in Kilometres.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
            SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Theme',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
                SizedBox(width: 120),
                GestureDetector(
                  onTap: (){
                    setState(() {
                      Theme=Theme1;
                      value=1;
                    });
                    SharedPref().saveColorList(Theme);

                  },
                  child: Container(
                    // color: Colors.white,
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:  value==1?Colors.white:Colors.transparent,
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
                GestureDetector(
                  onTap: (){
                    setState(() {
                      Theme=Theme2;
                      value=2;

                    });
                    SharedPref().saveColorList(Theme);

                  },
                  child: Container(
                    // color: Colors.white,
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:  value==2?Colors.white:Colors.transparent,                        width: 3, // Replace with your border width
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
                GestureDetector(
                  onTap: (){
                    setState(() {
                      Theme=Theme3;
                      value=3;
                    });
                    SharedPref().saveColorList(Theme);
                  },
                  child: Container(
                    // color: Colors.white,
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:  value==3?Colors.white:Colors.transparent, // Replace with your border color
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
            SizedBox(height: 30.h,),
            GestureDetector(
              onTap: () async =>{
                _launchURL(),
              },
              child: Text(
                'Privacy Policy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
            SizedBox(height: 20.h,),
           GestureDetector(
             onTap: () async =>{


                ref
                .child('users')
                .child(Uid)
                .child('steps')
                .child(formattedDate)
                .set(0),
             await SharedPref().setIntroScreenInfo(false),
             await SharedPref().setisStart(false),
               await SharedPref().setisMiles(false),
               await SharedPref().setTodaysSteps(0),
               await SharedPref().setStepsTarget(6000),
               SharedPref().setStepsComingFromFirebase(0),
               await stopBackgroundService(),
               Get.to(()=>HomePage()),
             },
             child: Text(
                  'Reset',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
           ),
            SizedBox(height: 35.h,),
           Visibility(
             visible: isGuest==false,
             child: GestureDetector(
               onTap: () async =>{
                 _authServices.signout(),
                 print("logout clicked"),
                 // await SharedPref().clearAllPreferences(),
               await SharedPref().setIntroScreenInfo(false),
                SharedPref().setStepsComingFromFirebase(0),
                SharedPref().setEmail(""),
                SharedPref().setPassword(""),
                SharedPref().setUsername(""),
                SharedPref().setisguest(true),
               await SharedPref().setisStart(false),
                 await SharedPref().setTodaysSteps(0),
                 await SharedPref().setisMiles(false),
                 await SharedPref().setStepsTarget(6000),
                 await stopBackgroundService(),
                 services.UpdateDeviceId(Uid," ").then((value) =>  Get.to(()=>SignUpScreen())),
               },
               child: Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                  ),
             ),
           ),
            SizedBox(height: 25.h,),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                'Version 2.0',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14.sp,
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            )
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavbar(
      //   currentIndex: 2,
      // ),
    );
  }
}

