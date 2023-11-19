import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:steptracking/presentations/Back_Service.dart';
import 'package:steptracking/presentations/HomePage.dart';
import 'package:steptracking/presentations/SignUpScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Firebasefunctionalities/AuthServices.dart';
import '../Firebasefunctionalities/DatabaseServices.dart';
import '../SharedPrefrences/SharedPref.dart';
import '../widgets/BottomNavbar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void initState(){
    getUserData();
  }
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
  Future<void> getUserData() async {
    bool isMiles=await SharedPref().getisMiles();
    String useName = await SharedPref().getUsername();
    print("user Name----------------------------------->"+useName);
    String _uid = await SharedPref().getUid();
    String email = await SharedPref().getEmail();
    int stepTar=await SharedPref().getStepsTarget();
    bool isguest=await SharedPref().getisguest();
    setState(() {
      Email=email;
      UserName=useName;
      Uid=_uid;
      isMIles=isMiles;
      StepsTarget=stepTar;
      isGuest=isguest;
    });
    print("isguest----------------------------------------------------->"+isguest.toString());
    if(isGuest){}else{
      DatabaseReference databaseReference = FirebaseDatabase.instance
          .reference()
          .child('users')
          .child(_uid)
          .child('defaultsteps');
      try {
        databaseReference.onValue.listen((event) {
          print(event.snapshot.value.toString());
          setState(() {
            StepsTarget = int.parse(event.snapshot.value.toString());

          });
          SharedPref().setStepsTarget(int.parse(event.snapshot.value.toString()));
        });
      } catch (e) {
        print('Error: $e');
      }
    }

  }

  Future<void> _launchURL() async {
    const url = 'https://sites.google.com/view/steptracker-privacypolicy/home'; // Replace with your privacy policy URL
    await launchUrl(Uri.parse(url));
  }




  bool isMIles = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D2D2D),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w,),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 62.h,),

            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'SETTINGS',
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
            SizedBox(
              height: 25.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                 // SizedBox(width: 185.w,),
                Text(
                 UserName,
                  style: TextStyle(
                    color: Color(0xFFA9A9A9),
                    fontSize: 18.sp,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15.h,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Email',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
                // SizedBox(width: 161.w,),
                GestureDetector(
                  onTap: (){
                    isGuest?Get.to(()=>SignUpScreen()):null;
                  },
                  child: Text(
                    Email,
                    style: TextStyle(
                      color: Color(0xFFA9A9A9),
                      fontSize: 18.sp,
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h,),
            Row(
            mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(width:235.w ,),
                TextButton(onPressed: (){
                  setState(() {
                    _EmailController.text="";
                  });
                isGuest?Get.to(()=>SignUpScreen()):showModalBottomSheet(
                    isDismissible: false,
                      context: context,
                      isScrollControlled: true,
                      shape:  RoundedRectangleBorder( // <-- SEE HERE
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0.r),
                            topRight: Radius.circular(10.0.r)
                        ),
                      ),
                      enableDrag: false,
                      backgroundColor: const Color(0xFF2D2D2D),
                      builder: (context){
                        return  SizedBox(
                            height: _emailNode.hasFocus?650.h:200.h,
                            child: Padding(
                              padding:  EdgeInsets.symmetric(horizontal: 25.w,vertical: 30.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[

                                  Text(
                                    'Email ID',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 0,
                                    ),
                                  ),
                                  SizedBox(height: 8.0.h),
                                  const Text(
                                    'Reset link will be sent to this ID',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 0,
                                    ),
                                  ),
                                  SizedBox(height: 16.0.h),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          width: 340.w,
                                          height: 60.h,
                                          child: TextField(
                                            controller: _EmailController,
                                            readOnly: false,
                                            obscureText: false,
                                            focusNode: _emailNode,
                                            style:  TextStyle(
                                                color: Colors.white
                                            ),
                                            decoration: InputDecoration(
                                              hintText: Email,
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
                                            onChanged: (value){
                                              setState(() {
                                                _email = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8.0.w),
                                      SizedBox(
                                        width: 74.w,
                                        height: 60.h,
                                        child: OutlinedButton(
                                          onPressed: () async {

                                            // Implement reset logic here
                                            try {
                                              await FirebaseAuth.instance
                                                  .sendPasswordResetEmail(email: Email.trim())
                                                  .then((value) {
                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                  content: Container(
                                                    child: Text('reset link succesfully sent to Id',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16.sp,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w400,
                                                        height: 0,
                                                      ),

                                                    ),
                                                  ),
                                                  behavior: SnackBarBehavior.floating,
                                                  backgroundColor: Colors.black,
                                                ));

                                                print("succesfully sent ");
                                              });
                                              // Reset email sent successfully
                                            } catch (e) {
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                content: Container(
                                                  child: Text('Enter Valid Email',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16.sp,
                                                      fontFamily: 'Inter',
                                                      fontWeight: FontWeight.w400,
                                                      height: 0,
                                                    ),

                                                  ),
                                                ),
                                                behavior: SnackBarBehavior.floating,
                                                backgroundColor: Colors.black,
                                              ));

                                              print("Error: $e");
                                              // Handle error
                                            }
                                          Navigator.pop(context);
                                          },
                                          child: const Icon(
                                            Icons.arrow_forward,
                                            color: Colors.white,
                                          ),
                                          style: ButtonStyle(
                                              side: MaterialStateProperty.all(BorderSide(width: 2.0.w,color: Colors.white)),
                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10.0.r)
                                                  )
                                              )
                                          ) ,
                                        ),
                                      ),
                                    ],
                                  ),

                                ],
                              ),
                            ));
                      });
                },
                  child: Text(
                  isGuest? "Create Account":'Change Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.underline,
                    height: 0,
                  ),),),
              ],
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
                TextButton(onPressed: (){
                  setState(() {
                    _dailyStepController.text="";
                  });
                  showModalBottomSheet(
                      isDismissible: false,
                      context: context,
                      isScrollControlled: true,
                      shape:  RoundedRectangleBorder( // <-- SEE HERE
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0.r),
                            topRight: Radius.circular(10.0.r)
                        ),
                      ),
                      enableDrag: false,
                      backgroundColor: Colors.white,
                      builder: (context){
                        return  SizedBox(
                            height: _dailyStep.hasFocus?650.h:175.h,
                            child: Padding(
                              padding:  EdgeInsets.symmetric(horizontal: 25.w,vertical: 30.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[

                                  Text(
                                    'SET DAILY STEP GOAL',
                                    style: TextStyle(
                                      color: Color(0xFF2D2D2D),
                                      fontSize: 18.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 0,
                                    ),
                                  ),
                                  SizedBox(height: 10.0.h),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          width: 290.w,
                                          height: 62.h,
                                          child: TextField(
                                            controller: _dailyStepController,
                                            obscureText: false,
                                            focusNode: _dailyStep,
                                            style:  TextStyle(
                                                color: Colors.black
                                            ),
                                            decoration: InputDecoration(
                                              hintText: StepsTarget.toString(),
                                              hintStyle:  TextStyle(
                                                color: Colors.black,
                                                fontSize: 16.w,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w400,
                                                height: 0,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    width: 2.w,
                                                    color: Colors.black
                                                ), //<-- SEE HERE
                                                borderRadius: BorderRadius.circular(10.r),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide:  BorderSide(
                                                    width: 2.w,
                                                    color:Colors.black), //<-- SEE HERE
                                                borderRadius: BorderRadius.circular(10.r),
                                              ),
                                            ),
                                            keyboardType: TextInputType.number,
                                            onChanged: (value){
                                              setState(() {
                                                StepsTarget = int.parse(value);
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10.0.w),
                                      SizedBox(
                                        width: 74.w,
                                        height: 60.h,
                                        child: OutlinedButton(
                                          onPressed: () {
                                            if(isGuest){
                                              Navigator.pop(context);
                                              SharedPref().setStepsTarget(StepsTarget);
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                content: Container(
                                                  child:
                                                  Text('Daily Target Updated',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16.sp,
                                                      fontFamily: 'Inter',
                                                      fontWeight: FontWeight.w400,
                                                      height: 0,
                                                    ),
                                                  ),
                                                ),
                                                behavior: SnackBarBehavior.floating,
                                                backgroundColor: Color(0xFF2D2D2D),
                                              ));
                                            }else{
                                              Navigator.pop(context);
                                              services.Update(Uid, StepsTarget);
                                              SharedPref().setStepsTarget(StepsTarget);
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                content: Container(
                                                  child:
                                                  Text('Daily Target Updated',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16.sp,
                                                      fontFamily: 'Inter',
                                                      fontWeight: FontWeight.w400,
                                                      height: 0,
                                                    ),
                                                  ),
                                                ),
                                                behavior: SnackBarBehavior.floating,
                                                backgroundColor: Color(0xFF2D2D2D),
                                              ));
                                            }
                                            // Implement reset logic here

                                          },
                                          child: const Icon(
                                            Icons.arrow_forward,
                                            color: Colors.black,
                                          ),
                                          style: ButtonStyle(
                                              side: MaterialStateProperty.all(BorderSide(width: 2.0.w,color: Colors.black)),
                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10.0.r)
                                                  )
                                              )
                                          ) ,
                                        ),
                                      ),
                                    ],
                                  ),

                                ],
                              ),
                            ));
                      });
                 },
                    child: Row(
                  children: [
                    Text(
                      StepsTarget.toString()+' steps',
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
                  activeColor: Colors.red,
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
                 await SharedPref().clearAllPreferences(),
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
            SizedBox(height: 41.h,),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                'Version 1.2',
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
      bottomNavigationBar: BottomNavbar(
        currentIndex: 2,
      ),
    );
  }
}

