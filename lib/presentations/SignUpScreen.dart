import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gradient_button/flutter_gradient_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lottie/lottie.dart';
import 'package:steptracking/Firebasefunctionalities/AuthServices.dart';
import 'package:steptracking/appsflyer/appsflyerMethod.dart';
import 'package:steptracking/main.dart';
import 'package:steptracking/presentations/MainScreen.dart';
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
  List<Color> Theme=[Color(0xFFF7722A),Color(0xFFE032A1),Color(0xFFCF03F9)];
List<String> ImagesBg=["lib/assests/NewImages/SignUpScreenBg.png","lib/assests/NewImages/SignUpscreenBgTheme2.png","lib/assests/NewImages/SignupScreenBgTheme3.png"];
int value=0;
  void initState() {
    whichTheme();
  }
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    for(int i=0;i<ImagesBg.length;i++) {
      AssetImage(ImagesBg[i]);
    }
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
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return true;
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(image: DecorationImage(image: AssetImage(ImagesBg[value]),fit: BoxFit.fitWidth)),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: Padding(
              padding:  EdgeInsets.only(top: 200),
              child: SingleChildScrollView(

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text.rich(TextSpan(
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
                            fontSize: 74,
                            fontFamily: 'Teko',
                            fontWeight: FontWeight.w600,
                            height: 0,
                            letterSpacing: 1.48,
                          ),
                        ),
                      ]

                    ),
                    textAlign: TextAlign.center,),
                  SizedBox(height: 35,),
                    Padding(
                      padding:  EdgeInsets.only(left: 35.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Email",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 0,
                            letterSpacing: 0.90,
                          ),
                        ),
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
                            borderRadius: BorderRadius.circular(10.0.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 2.sp,
                                color: Colors.white), //<-- SEE HERE
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
                  Padding(
                    padding:  EdgeInsets.only(left: 35.0),
                    child: Align(
                     alignment: Alignment.centerLeft,
                      child: Text(
                        "Password",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 0,
                          letterSpacing: 0.90,
                        ),
                      ),
                    ),),
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
                        style: TextStyle(color: Colors.white),
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
                      ),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                  Padding(
                    padding:  EdgeInsets.only(left: 35.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Your password must contain 8 letters",
                      style:TextStyle(
                        color: Colors.grey,
                        fontSize: 12.sp,
                        fontFamily: 'Work Sans',
                        fontWeight: FontWeight.w400,
                        height: 0,
                      ),),
                    ),),
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
                            text: Text("Sign up"),
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
                              String deviceid=await getDeviceUID();

                              SharedPref().setDeviceid(deviceid);
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
                          ),

                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.h,
                    ),

                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      " or ",
                      style:TextStyle(
                        color: Colors.white,
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
                          onPressed: () async {
                            String deviceid=await getDeviceUID();
                            print("UID: "+deviceid);
                            SharedPref().setDeviceid(deviceid);
                            _authServices.signInWithGoogle(context,deviceid);
                          },
                        ),

                      ),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                              text: 'Already have an account?',
                              style: const TextStyle(
                                color: Colors.white,
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
                                Get.offAll(MainScreen());
                              },
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  void Loginpage() {
    Get.to(Login(),
        duration: Duration(seconds: 1),transition: Transition.rightToLeft);
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
