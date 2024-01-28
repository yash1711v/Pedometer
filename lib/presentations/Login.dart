import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gradient_button/flutter_gradient_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import '../Firebasefunctionalities/AuthServices.dart';
import '../Firebasefunctionalities/DatabaseServices.dart';
import '../SharedPrefrences/SharedPref.dart';
import 'HomePage.dart';
import 'SignUpScreen.dart';
import 'UserNameScreen.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late TextEditingController _EmailController = TextEditingController();
  late TextEditingController _PassWordController = TextEditingController();
  final FocusNode _emailNode = FocusNode();
  final FocusNode _passwordNode = FocusNode();
  final AuthServices _authServices = AuthServices();
  String _email = '';
  String password = '';
  bool _isVisible = true;
  late TextEditingController _EmailController2 = TextEditingController();
  final FocusNode _emailNode2 = FocusNode();
  String _email2 = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseServices services = DatabaseServices();
  double deviceHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
 bool isguest=false;
  FirebaseDatabase database = FirebaseDatabase.instance;
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;
  List<Color> Theme=[Color(0xFFF7722A),Color(0xFFE032A1),Color(0xFFCF03F9)];
  List<String> ImagesBg=["lib/assests/NewImages/LoginScreenBg.png","lib/assests/NewImages/LoginScreenBg2.png","lib/assests/NewImages/LoginScreenBg3.png"];
  int value=0;
  void initState() {
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
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return true;
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(image: DecorationImage(image: AssetImage(ImagesBg[value],

          ),fit: BoxFit.fitWidth)),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 280,),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'LOGIN',
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
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 0.sp,
                            letterSpacing: 0.87.sp,
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
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 2.w,
                                    color: Colors.white), //<-- SEE HERE
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 2.w,
                                    color: Colors.white), //<-- SEE HERE
                                borderRadius: BorderRadius.circular(10.r),
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
                        SizedBox(height: 25.h,),
                        Text(
                          "Password",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 0,
                            letterSpacing: 0.90.sp,
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
                            style: const TextStyle(color: Colors.white),
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
              
                                  color: Colors.white,
                                ),
                                padding: EdgeInsets.fromLTRB(
                                    20, 0, 15, 0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 2.sp,
                                    color: Colors.white), //<-- SEE HERE
                                borderRadius: BorderRadius.circular(10.0.r),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 2.sp,
                                    color: Colors.white), //<-- SEE HERE
                                borderRadius: BorderRadius.circular(10.0.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 16.h,
                        ),
                        GestureDetector(
                          onTap: () => {
                            setState(() {
                              _EmailController2.text = "";
                            }),
                            showModalBottomSheet(
                                isDismissible: false,
                                context: context,
                                isScrollControlled: true,
                                shape: RoundedRectangleBorder(
                                  // <-- SEE HERE
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10.0.r),
                                      topRight: Radius.circular(10.0.r)),
                                ),
                                enableDrag: false,
                                backgroundColor: const Color(0xFF2D2D2D),
                                builder: (context) {
                                  return SizedBox(
                                      height:
                                          _emailNode2.hasFocus ? 650.h : 200.h,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25.w, vertical: 30.h),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                      controller:
                                                          _EmailController2,
                                                      obscureText: false,
                                                      focusNode: _emailNode2,
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                      decoration: InputDecoration(
                                                        hintText: "Type here",
                                                        hintStyle: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16.w,
                                                          fontFamily: 'Inter',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          height: 0,
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              width: 2.w,
                                                              color: Colors
                                                                  .white), //<-- SEE HERE
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10.r),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              width: 2.w,
                                                              color: Colors
                                                                  .white), //<-- SEE HERE
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10.r),
                                                        ),
                                                      ),
                                                      keyboardType: TextInputType
                                                          .emailAddress,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          _email2 = value;
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
                                                    onPressed: () async {
                                                      // Implement reset logic here
              
                                                      try {
              
                                                        await FirebaseAuth.instance
                                                            .sendPasswordResetEmail(email: _email2.trim())
                                                            .then((value) {
                                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                            content: Container(
                                                              child: Text('Link sent to the mentioned  email id',
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
                                                        side:
                                                            MaterialStateProperty
                                                                .all(BorderSide(
                                                                    width: 2.0.w,
                                                                    color: Colors
                                                                        .white)),
                                                        shape: MaterialStateProperty.all<
                                                                RoundedRectangleBorder>(
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0.r)))),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ));
                                }),
                          },
                          child: Text(
                            'Forgot Password',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.underline,
                              height: 0.sp,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 25.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 375.w,
                              height: 60.h,
                              child:
                              GradientButton(
                                colors: Theme,
                                width: 329,
                                height: 56,
                                radius: 10,
                                gradientDirection: GradientDirection.leftToRight,
                                textStyle: TextStyle(color: Colors.white),
                                text: Text("Login"),
                                onPressed:   _validateEmail(_email) ?
                                //&&
                                // password.length>=8 ?
                                    () async {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Lottie.asset('lib/assests/Images/New_loading_foot_step.json');
                                    },
                                  );
                                  SharedPref().setisguest(false);
                                  String deviceid=await getDeviceUID();
                                  print("UID: "+deviceid);
                                  SharedPref().setDeviceid(deviceid);
                                  _authServices.Login(_email, password,deviceid,context);
                                  Future.delayed(Duration(seconds: 1),(){Navigator.pop(context);});
                                }
                                    : () => {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Container(

                                      child:
                                      Text('Enter Valid Email and Password',
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
                                  )),
                                },
                              ),

                            ),
                          ],
                        ),

                        SizedBox(
                          height: 10.h,
                        ),

                        Center(
                          child: Text(
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
                        ),

                        SizedBox(
                          height: 10.h,
                        ),

                        Center(
                          child: SizedBox(
                            width: 375.w,
                            height: 60.h,
                            child:
                            GradientButton(
                              colors: Theme,
                              width: 329,
                              height: 56,
                              radius: 10,
                              gradientDirection: GradientDirection.leftToRight,
                              textStyle: TextStyle(color: Colors.white),
                              text: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset("lib/assests/NewImages/googleLogoImage.png",scale: 5,),
                                  SizedBox(width: 10,),
                                  Text("SignUp With Google")],),
                              onPressed:    () async {
                                print("hello");
                                String deviceid=await getDeviceUID();
                                print("UID: "+deviceid);
                                SharedPref().setDeviceid(deviceid);
                                _authServices.signInWithGoogle(context,deviceid);


                              },
                            ),

                          ),
                        ),
                        SizedBox(height: 20.h,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RichText(
                              text: TextSpan(
                                  text: 'Don’t have an account?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.2.sp,
                                    fontFamily: 'Work Sans',
                                    fontWeight: FontWeight.w400,
                                    height: 0.sp,
                                    letterSpacing: 0.16.sp,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(text: " "),
                                    TextSpan(
                                      text: 'SignUp',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 16.sp,
                                        fontFamily: 'Work Sans',
                                        fontWeight: FontWeight.w400,
                                        decoration: TextDecoration.underline,
                                        height: 0.sp,
                                        letterSpacing: 0.16.sp,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          signUpScreen();
                                        },
                                    ),
                                  ]),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: RichText(
                            text: TextSpan(children: <TextSpan>[
                              TextSpan(
                                text: 'Skip',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Work Sans',
                                  fontWeight: FontWeight.w400,
                                  decoration: TextDecoration.underline,
                                  height: 0,
                                  letterSpacing: 0.16,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    String deviceid=await getDeviceUID();
                                    print("UID: "+deviceid);
                                    SharedPref().setDeviceid(deviceid);
                                    SharedPref().setStepsTarget(6000);
                                    SharedPref().setUsername("Guest");
                                    SharedPref().setEmail("Sign Up Now");
                                    SharedPref().setisguest(true);
                                    // SharedPref().setIntroScreenInfo(false);
                                    Get.to(
                                      HomePage(),
                                      duration: const Duration(seconds: 1),
                                      // transition: Transition.fadeIn,
                                    );
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

  void signUpScreen() {
    Get.offAll(
      const SignUpScreen(),
      duration: const Duration(seconds: 1),
      transition: Transition.leftToRight
    );
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
}

class ResetPasswordBottomSheet extends StatefulWidget {
  @override
  State<ResetPasswordBottomSheet> createState() =>
      _ResetPasswordBottomSheetState();
}

class _ResetPasswordBottomSheetState extends State<ResetPasswordBottomSheet> {
  late TextEditingController _EmailController = TextEditingController();

  final FocusNode _emailNode = FocusNode();

  String _email = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.w),
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
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  width: 300.w,
                  child: TextField(
                    controller: _EmailController,
                    obscureText: false,
                    focusNode: _emailNode,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "Type here",
                      hintStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 0,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            width: 2, color: Colors.grey), //<-- SEE HERE
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            width: 2, color: Color(0xFF2D2D2D)), //<-- SEE HERE
                        borderRadius: BorderRadius.circular(15.0),
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
              ),
              SizedBox(width: 10.0),
              Expanded(
                child: SizedBox(
                  width: 80,
                  height: 60,
                  child: OutlinedButton(
                    onPressed: () {
                      // Implement reset logic here
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                    style: ButtonStyle(
                        side: MaterialStateProperty.all(
                            const BorderSide(width: 2.0, color: Colors.white)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10.0)))),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
