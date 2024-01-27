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
  String value="0";
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
    List<Color> theme=await SharedPref().loadColorList();
    setState(() {
      Email=email;
      UserName=useName;
      Uid=_uid;
      isMIles=isMiles;
      StepsTarget=stepTar;
      isGuest=isguest;
      _EmailController.text=UserName;
      Theme=theme;
      _dailyStepController.text=StepsTarget.toString();
      if(Theme[0]==Color(0xFFF7722A)){
        print("theme1");
        setState(() {
          initialSelectedReaction= Reaction<String>(
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
        });
      }else if(Theme[0]==Color(0xFF04EF77)){
        print("theme2");
          setState(() {

        initialSelectedReaction =    Reaction<String>(
          value: 'love',
          icon:  Container(
            // color: Colors.white,
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:Colors.transparent, // Replace with your border color
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
        );
          });
      }else{
        print("theme3");
      setState(() {

        initialSelectedReaction=  Reaction<String>(
          value: 'Amazing',
          icon:
          Container(
            // color: Colors.white,
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:  Colors.transparent, // Replace with your border color
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
        );
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
                                              // hintStyle:  TextStyle(
                                              //   color: Colors.black,
                                              //   fontSize: 16.w,
                                              //   fontFamily: 'Inter',
                                              //   fontWeight: FontWeight.w400,
                                              //   height: 0,
                                              // ),
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
                                                _dailyStepController.text=StepsTarget.toString();
                                              });
                                              SharedPref().setStepsTarget(StepsTarget);
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
                SizedBox(
                  width: 25,
                  child: ReactionButton(
                   toggle: false,
                    boxColor: Colors.white,
                    selectedReaction: initialSelectedReaction,
                    onReactionChanged: (Reaction<String>? reaction) async {
                      print(reaction?.value);
                       if(reaction?.value=="like") {
                        await SharedPref().saveColorList(Theme1);
                        setState(() {
                          Theme=Theme1;
                          initialSelectedReaction=reaction!;
                        });
                      }else if(reaction?.value=="love"){
                         await SharedPref().saveColorList(Theme2);
                         setState(() {
                           Theme=Theme2;
                           initialSelectedReaction=reaction!;
                         });
                       }else{
                         await SharedPref().saveColorList(Theme3);
                         setState(() {
                           Theme=Theme3;
                           initialSelectedReaction=reaction!;
                         });
                       }
                    }, reactions: <Reaction<String>>[
                    Reaction<String>(
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
                    ),
                    Reaction<String>(
                      value: 'love',
                      icon:  Container(
                        // color: Colors.white,
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:Colors.transparent, // Replace with your border color
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
                    Reaction<String>(
                      value: 'Amazing',
                      icon:
                      Container(
                        // color: Colors.white,
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:  Colors.transparent, // Replace with your border color
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
                    isChecked: false,
                    itemSize: const Size(30, 30), ),
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
      // bottomNavigationBar: BottomNavbar(
      //   currentIndex: 2,
      // ),
    );
  }
}

