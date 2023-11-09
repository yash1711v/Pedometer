import 'dart:io';
import 'dart:math';

import 'package:device_info/device_info.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:steptracking/presentations/HomePage.dart';

import '../Firebasefunctionalities/DatabaseServices.dart';
import '../SharedPrefrences/SharedPref.dart';

class UserNameScreen extends StatefulWidget {
  const UserNameScreen({super.key});

  @override
  State<UserNameScreen> createState() => _UserNameScreenState();
}

class _UserNameScreenState extends State<UserNameScreen> {
  late final TextEditingController _UserNameController = TextEditingController();
  final FocusNode _UserNameNode = FocusNode();
  late final TextEditingController _defaultStepsController = TextEditingController();
  final FocusNode _defaultStepsNode = FocusNode();
  String UserName = "Enter Your Name";
  String Email = '';
  String Password = '';
  String UID = '';
  int defaultSteps=6000;
  bool isGuest=false;
  DatabaseServices services = DatabaseServices();
  Map<String, int?> map={};
  gettingEmailAndPassword() async {
    String UserN=await SharedPref().getUsername();
    String _Email=await SharedPref().getEmail();
    setState(() {
      Email=_Email;
      UserName=UserN;
    });
    String _Pass=await SharedPref().getPassword();
    setState(() {
      Password=_Pass;
    });
    String _uid=await SharedPref().getUid();
    setState(() {
     UID=_uid;
    });
    bool isguest= await SharedPref().getisguest();
    setState(() {
      isGuest=isguest;
    });
    Map<String, int?> Map1=await SharedPref().getSortedStepsData();
    setState(() {
      map = Map1;
    });
    print("Map in user Screen"+map.toString());
  }
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
  void initState() {
    super.initState();
      gettingEmailAndPassword();

  }
  double deviceHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return true;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          body: InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Container(
                  height: _UserNameNode.hasFocus || _defaultStepsNode.hasFocus
                      ? MediaQuery.of(context).size.height / 2.7
                      : 421.h,
                  width: deviceWidth(context),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                            'lib/assests/Images/Circles_Signin_Page_Circles.png'),
                        fit: BoxFit.cover),
                  ),
                  child: Container(
                    margin: EdgeInsets.only(
                        top: _UserNameNode.hasFocus || _defaultStepsNode.hasFocus
                            ? 140.h
                            : 209.h),
                    child:  Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'PICK A\n',
                            style: TextStyle(
                              color: Color(0xFFF3F3F3),
                              fontSize: 74.sp,
                              fontFamily: 'Teko',
                              fontWeight: FontWeight.w600,
                              height: 0,
                              letterSpacing: 2.96,
                            ),
                          ),
                          TextSpan(
                            text: 'USERNAME',
                            style: TextStyle(
                              color: Color(0xFFF3F3F3),
                              fontSize: 74.sp,
                              fontFamily: 'Teko',
                              fontWeight: FontWeight.w600,
                              height: 0,
                              letterSpacing: 1.48.sp,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                    SizedBox(
                      height: 37.h,
                    ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(
                        "Username",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF2D2D2D),
                          fontSize: 18.sp,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 0,
                          letterSpacing: 0.90,
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      SizedBox(
                        width: 378.w,
                        height: 60.h,
                        child: TextField(
                          controller: _UserNameController,
                          obscureText: false,
                          focusNode: _UserNameNode,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: UserName,
                            hintStyle: TextStyle(color: Colors.grey),
                            enabledBorder: OutlineInputBorder(
                              borderSide:  BorderSide(
                                  width: 2.w,
                                  color: Colors.grey), //<-- SEE HERE
                              borderRadius: BorderRadius.circular(10.0.r),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:  BorderSide(
                                  width: 2.w,
                                  color: Color(0xFF2D2D2D)), //<-- SEE HERE
                              borderRadius: BorderRadius.circular(10.0.r),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) {
                            setState(() {
                              UserName = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        height: 25.h,
                      ),
                      Text(
                        "Enter Your Daily Goal",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF2D2D2D),
                          fontSize: 18.sp,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 0,
                          letterSpacing: 0.90,
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      SizedBox(
                        width: 378.w,
                        height: 60.h,
                        child: TextField(
                          obscureText: false,
                          controller: _defaultStepsController,
                          focusNode: _defaultStepsNode,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide:  BorderSide(
                                  width: 2.w,
                                  color: Colors.grey), //<-- SEE HERE
                              borderRadius: BorderRadius.circular(10.0.r),
                            ),
                            hintText: "Default 6000 steps are stored",
                            hintStyle: TextStyle(color: Colors.grey),
                            focusedBorder: OutlineInputBorder(
                              borderSide:  BorderSide(
                                  width: 2.w,
                                  color: Color(0xFF2D2D2D)), //<-- SEE HERE
                              borderRadius: BorderRadius.circular(10.0.r),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              defaultSteps = int.parse(value);
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        height: 170.h,
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: SizedBox(
                          width: 70.w,
                          height: 62.h,
                          child: OutlinedButton(
                            onPressed: UserName.length>4 && UserName.isNotEmpty?() async {
                              if(UserName.length>4 && UserName.isNotEmpty){
                                String DeviceId=await getDeviceUID();
                                SharedPref().setDeviceid(DeviceId);
                                if( isGuest){
                                  SharedPref().setisguest(false);
                                  // SharedPref().setIntroScreenInfo(false);
                                  String DeviceId= await getDeviceUID();
                                  services.writeToDatabase(UID,UserName, Email, Password , defaultSteps,DeviceId,context);
                                  DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
                              print(isGuest);
                                  try{
                                    databaseReference.child('users').child(UID).update({'defaultsteps' :  defaultSteps}).then((value) {
                                      map.forEach((date, steps) {
                                        DateTime currentDate = DateFormat('yyyy-MM-dd').parse(date);
                                        String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
                                        setState(() {
                                          databaseReference
                                              .child('users')
                                              .child(UID)
                                              .child('steps')
                                              .child(formattedDate)
                                              .set(steps);
                                        });

                                      });

                                    });

                                 services.UpdateDeviceId(UID, DeviceId);
                                  }catch(error){print(error);
                                  }

                                  Get.to(()=>HomePage());
                                }else{
                                  services.writeToDatabase(UID,UserName, Email, Password , defaultSteps,DeviceId,context);
                                  services.UpdateDeviceId(UID, DeviceId);
                                  SharedPref().setStepsTarget(defaultSteps);
                                  SharedPref().setUsername(UserName);
                                  // SharedPref().setIntroScreenInfo(false);
                                  Get.to(()=>HomePage());
                                }
                              }

                            }:(){
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Container(
                                  child: Text(' Username should have more than 4 letters',
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
                            },
                            child: Icon(
                              Icons.arrow_forward,
                              color: UserName.length>4?Colors.black:Colors.grey,
                            ),
                            style: ButtonStyle(
                                side: MaterialStateProperty.all(BorderSide(width: 2.0,color:UserName.length>4?Colors.black:Colors.grey)),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0)
                                    )
                                )
                            ) ,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),


              ])),
        ));
  }
  bool isValidUserName(String value) {
    String regularExpression= r"^[a-z0-9_-]{4,16}$";
    RegExp regex = RegExp(regularExpression);
    if (!regex.hasMatch(value.trim())) {
      return false;
    }
    return true;
  }
  String generateRandomUsername() {
    String pattern = r'^[a-zA-Z0-9_]{4,}$'; // Example regex pattern (alphanumeric and underscores, at least 4 characters long)
    RegExp regex = RegExp(pattern);

    Random random = Random();

    String username;
    do {
      username = String.fromCharCodes(List.generate(8, (index) => random.nextInt(26) + 97)); // Generates a random string of 8 lowercase characters
    } while (!regex.hasMatch(username));

    return username;
  }
}
