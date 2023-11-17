import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lottie/lottie.dart';
import 'package:steptracking/Firebasefunctionalities/AuthServices.dart';
import 'package:steptracking/appsflyer/appsflyerMethod.dart';
import 'package:steptracking/main.dart';
import '../SharedPrefrences/SharedPref.dart';
import 'HomePage.dart';
import 'Login.dart';
import 'UserNameScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _EmailController = TextEditingController();
  late TextEditingController _PassWordController = TextEditingController();
  final FocusNode _emailNode = FocusNode();
  final FocusNode _passwordNode = FocusNode();
  String _email = '';
  String password = '';
  String Error = "";
  bool _isVisible = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading=true;
  double deviceHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
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
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;
  final AuthServices _authServices = AuthServices();
  void initState() {}
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
            // to dismiss the keyboard when the user tabs out of the TextField
            splashColor: Colors.transparent,
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: SingleChildScrollView(

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: _emailNode.hasFocus || _passwordNode.hasFocus
                        ? MediaQuery.of(context).size.height / 2.9
                        : 350.h,
                    width: deviceWidth(context),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                            'lib/assests/Images/Circles_Signin_Page_Circles.png',

                          ),
                          fit: BoxFit.cover),
                    ),
                    child: Container(
                      margin: EdgeInsets.only(
                          top: _emailNode.hasFocus || _passwordNode.hasFocus
                              ? 125.h
                              : 150.h),
                      padding: EdgeInsets.symmetric(horizontal: 95.w),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'CREATE\n',
                              style: TextStyle(
                                color: Color(0xFFF3F3F3),
                                fontSize: 74.sp,
                                fontFamily: 'Teko',
                                fontWeight: FontWeight.w600,
                                height: 0,
                                letterSpacing: 2.96.sp,
                              ),
                            ),
                            TextSpan(
                              text: 'ACCOUNT',
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
                          "Email",
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

                            controller: _EmailController,
                            obscureText: false,
                            focusNode: _emailNode,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(

                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 2.w,
                                    color: Colors.grey), //<-- SEE HERE
                                borderRadius: BorderRadius.circular(10.0.r),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 2.sp,
                                    color: Color(0xFF2D2D2D)), //<-- SEE HERE
                                borderRadius: BorderRadius.circular(10.0.r),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) {
                              setState(() {
                                _email = value;
                              });
                            },

                          ),
                        ),
                        SizedBox(
                          height: 25.h,
                        ),
                        Text(
                          "Password",
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
                            controller: _PassWordController,
                            obscureText: _isVisible,
                            readOnly: !_validateEmail(_email) ? true : false,
                            focusNode: _passwordNode,
                            style: TextStyle(color: Colors.black),
                            onChanged: (value) {
                              password = value;
                            },
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isVisible = !_isVisible;
                                  });
                                },
                                icon: Icon(_isVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,

                                color: Colors.black,
                                ),
                                padding: EdgeInsets.fromLTRB(
                                    20, 0, 15, 0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 2.w,
                                    color: Colors.grey), //<-- SEE HERE
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 2.w,
                                    color: Color(0xFF2D2D2D)), //<-- SEE HERE
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        Text("Your password must contain 8 letters",
                        style:TextStyle(
                          color: Colors.grey,
                          fontSize: 12.sp,
                          fontFamily: 'Work Sans',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),),
                        SizedBox(
                          height: 25.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                                width: 375.w,
                              height: 60.h,
                              child: OutlinedButton(
                                onPressed: _validateEmail(_email) &&
                                        password.length>=8
                                    ? () async {
                                 showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      width: 1000,
                                        height: 1000,
                                        child: Lottie.asset('lib/assests/Images/New_loading_foot_step.json',

                                          //   fit: BoxFit.fitHeight
                                          ),
                                        );
                                  },
                                 );
                                 clicked("signup $_email");
                                  _authServices.SignUp(_email,password,context);
                                  Future.delayed(Duration(seconds: 1),(){Navigator.pop(context);});

                                }
                                    : () => {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Container(
                                child:
                                Text('Enter Valid Email and Password',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 0,
                                  ),
                                    ),
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Color(0xFF2D2D2D),
                                )),
                                },
                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0.r))),
                                backgroundColor: MaterialStateProperty.all<Color>(_validateEmail(_email) &&
                                    password.length>=8?Color(0xFF2D2D2D):Color(0xFF4D4D4D))
                                ),
                                child:   Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 5.h,),
                                    Text(
                                      'Sign Up',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFFEDE5DA),
                                        fontSize: 16.sp,
                                        fontFamily: 'Nunito Sans',
                                        fontWeight: FontWeight.w600,
                                        height: 0.07.h,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 26.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Divider(
                              height: 20.0.h,
                              thickness: 3.0,
                              color: Color(0xFFB1B1B1),
                              indent: 25.0,
                              endIndent: 25.0,
                            ),
                            Text(
                              " or ",
                              style:TextStyle(
                                color: Color(0xFFB1B1B1),
                                fontSize: 18.sp,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w400,
                                height: 0,
                                letterSpacing: 0.54,
                              ),
                            ),

                            Divider(
                              height: 20.0.h,
                              thickness: 3.0,
                              color: Color(0xFFB1B1B1),
                              indent: 25.0,
                              endIndent: 25.0,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 26.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 375.w,
                              height: 60.h,
                              child:  InkWell(
                                onTap: (){
                                  _authServices.signInWithGoogle(context);
                                },
                                  splashColor: Colors.grey,
                                child: Image(image: AssetImage("lib/assests/Images/Googlebutton.png"),
                            ),
                              ),
                            )],
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RichText(
                              text: TextSpan(
                                  text: 'Already have an account?',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'Work Sans',
                                    fontWeight: FontWeight.w400,
                                    height: 0,
                                    letterSpacing: 0.16,
                                  ),
                                  children: <TextSpan>[
                                    const TextSpan(text: " "),
                                    TextSpan(
                                      text: 'Login',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Loginpage();
                                        },
                                    ),
                                  ]),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 21.h,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: RichText(
                            text: TextSpan(children: <TextSpan>[
                              TextSpan(
                                text: 'Skip',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Work Sans',
                                  fontWeight: FontWeight.w400,
                                  decoration: TextDecoration.underline,
                                  height: 0,
                                  letterSpacing: 0.16,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    clicked("skip");
                                    String deviceid=await getDeviceUID();
                                    print("UID: "+deviceid);
                                    SharedPref().setDeviceid(deviceid);
                                    SharedPref().setStepsTarget(6000);
                                    SharedPref().setUsername("Guest");
                                    SharedPref().setEmail("Sign Up Now");
                                    SharedPref().setisguest(true);
                                    // await SharedPref().setTodaysSteps(0);
                                  // SharedPref().setIntroScreenInfo(false);
                                  //SharedPref().setisStart(false);
                                    Get.to(HomePage());
                                  },
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  void Loginpage() {
    Get.to(Login(),
        duration: Duration(seconds: 1));
  }

  bool _validateEmail(String value) {
    String pattern = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value.trim())) {
      return false;
    }
    return true;
  }

  bool isStrongPassword(String value) {
    String pattern = r'^(?=.*?[A-Z])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value.trim())) {
      return false;
    }
    return true;
  }
  clicked(String value){
    final Map<String, String> values = {
      "time_stamp": DateTime.timestamp().toString(),
      "time_zone": DateTime.timestamp().timeZoneName,
      "package_name":"com.pedometer.steptracker",
      "login_type":value,
    };

    afLogEvent(appsflyerSdk, "signup_opened",values);
  }
}

class ImageButton extends StatelessWidget {
  final VoidCallback onPressed;
  final ImageProvider<Object> image;
  double width;
  double height;
  ImageButton(
      {required this.onPressed,
      required this.image,
      required this.width,
      required this.height});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(0.05),
      splashColor: Colors.transparent,
      child: Image(
        image: image,
        width: width,
        height: height,
      ),
    );
  }
}
