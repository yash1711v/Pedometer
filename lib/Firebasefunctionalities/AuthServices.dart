import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:steptracking/presentations/MainScreen.dart';
import 'package:steptracking/presentations/SignUpScreen.dart';

import '../SharedPrefrences/SharedPref.dart';
import '../presentations/HomePage.dart';
import '../presentations/UserNameScreen.dart';
import 'DatabaseServices.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseServices services = DatabaseServices();
  FirebaseDatabase database = FirebaseDatabase.instance;
  final _googleSignIn = GoogleSignIn();
  late GoogleSignInAccount userObj;
  Future<int> getHourlyStepsForCurrentDate() async {
     Map<String, dynamic> stepsData={};
    String? Value=await  services.getStepsData();

  Future.delayed(Duration(seconds: 1),(){
       print("Steps Data In function $Value");
    print("Steps data coming from sharedPref in function getstepsdata----------> $Value");
       stepsData=json.decode(Value!);
    print("Steps data coming from sharedPref in function getstepsdata----------> $stepsData");
    final now = DateTime.now();
    final year = (now.year).toString();
    final month = now.month<10?"0"+now.month.toString():now.month.toString(); // Use month number directly
    final date = (now.day).toString();

    // Initialize a list to store hourly steps for the current date
    List<int> hourlyStepsList = [];

    // Check if the current date exists in the stepsData
    if (stepsData.containsKey(year) &&
        stepsData[year].containsKey(month) &&
        stepsData[year][month].containsKey(date)) {
      // Loop through each hour in the current date
      stepsData[year][month][date].forEach((hourKey, hourValue) {
        // Add the hourly step value to the list
        hourlyStepsList.add(hourValue.toInt());
      });
    }else{
      // print(" Doesn't contain ${hourlyStepsList}");
      // print("year ${stepsData.containsKey(year)}");
      // print("month ${stepsData[year].containsKey(month)}");
      // print("date ${stepsData[year][month].containsKey(date)}");
    }
    // print(" this is in hourly graph  ${hourlyStepsList}");
    int TotalSteps=0;
    List<int>   StepsList=hourlyStepsList;
    StepsList.forEach((element) {
      TotalSteps=TotalSteps+element;
    });
    print("this is in hourly graph "+TotalSteps.toString());
    var stepValue = TotalSteps;
    print("steps $TotalSteps");
    int? stepsComingFromFirebase=0;

    if (stepValue != null && stepValue!=0) {
      print("if not null");
      stepsComingFromFirebase = stepValue;
      SharedPref().setisStart(true);
    } else {
      print("if null");
      stepsComingFromFirebase = 0; // default value
    }
    print("Steps Coming From firebae"+stepsComingFromFirebase.toString());

    if(stepsComingFromFirebase==null || stepsComingFromFirebase==0){
      stepsComingFromFirebase=0;
      SharedPref().setTodaysSteps(TotalSteps);
      SharedPref().setStepsComingFromFirebase(stepsComingFromFirebase);
      Get.offAll(()=>MainScreen());
    }else{
      SharedPref().setTodaysSteps(TotalSteps);
      SharedPref().setStepsComingFromFirebase(stepsComingFromFirebase);
      //
      Get.offAll(()=>MainScreen());
    }
    print("Steps Coming From Firebase of same day:"+stepsComingFromFirebase.toString());
    return TotalSteps;
  });



    return 0;
  }
  signInWithGoogle(BuildContext context,String DeviceID) async {
    print("lib / services / firebase_services.dart / signInWithGoogle() called");

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Lottie.asset('lib/assests/Images/New_loading_foot_step.json');
            },
          );

    final GoogleSignInAccount? googleSignInAccount =
    await GoogleSignIn().signIn().then((value) {
      print("in then of google signin");
      int Steptarget=6000;
      Future.delayed(Duration(seconds: 1), () async {
        userObj = value!;
        SharedPref().setUid(userObj.id.toString());
        SharedPref().setUsername(userObj.displayName.toString());
        SharedPref().setEmail(userObj.email);
        final GoogleSignInAuthentication googleSignInAuthentication =
        await userObj!.authentication;
        final AuthCredential authCredential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken);
        print("Auth Credentials------------------------------------->"+ authCredential.toString() );
        await _auth.signInWithCredential(authCredential).then((value) {
          SharedPref().setisguest(false);
          Navigator.of(context).pop();

          SharedPref().setisguest(false);

          DateTime now = DateTime.now();
          String formattedDate = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
          print(formattedDate);
          print("DeviceID------------------->"+DeviceID);
            SharedPref().setischecking(false);
          DatabaseReference usersRef = database.ref().child('users').child(userObj.id);
                usersRef.once().then((DatabaseEvent event) async {
                  if (event.snapshot.exists) {
                    services.UpdateDeviceId(userObj.id,DeviceID);
                    // The uid exists, perform your task here
                    print("UID exists in the database. Performing task...");
                    SharedPref().setUsername(event.snapshot.child("username").value.toString());
                    SharedPref().setEmail(event.snapshot.child("email").value.toString());
                    SharedPref().setPassword(event.snapshot.child("password").value.toString());
                     Steptarget=int.parse(event.snapshot.child("StepsTarget").value.toString())!=null?int.parse(event.snapshot.child("StepsTarget").value.toString()):6000;
                    SharedPref().setStepsTarget(Steptarget);
print(int.parse(event.snapshot.child("StepsTarget").value.toString()));                    final now = DateTime.now();
                    final year = (now.year).toString();
                    final month = now.month<10?"0"+now.month.toString():now.month.toString(); // Use month number directly
                    final date = (now.day).toString();
                    final time = (DateFormat('hh a').format(now)).toString();
                    int steps=0;
                   await  getHourlyStepsForCurrentDate();
                    // formattedDate

                    // Call your method here
                   // Get.to(()=>MainScreen());
                  } else {
                    // The uid does not exist
                    print("UID does not exist in the database.");
                    services.UpdateDeviceId(userObj.id,DeviceID);
                    Get.offAll(()=>UserNameScreen());
                  }
                });
        }).catchError((e){
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Container(
              child: Text(e.toString(),
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
        });
      });
    }).catchError((e){
      print("Error:   "+e.toString());
    });

    }


















  SignUp(email, password, BuildContext context) {
    _auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) {
      print("Account Created");
      print("Direct Value${value.user!.uid}");
      SharedPref().setUid(value.user!.uid.toString());
      SharedPref().setEmail(email);
      SharedPref().setPassword(password);
      SharedPref().setisguest(false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Container(
          child: Text(
            'Account Created',
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
      Get.offAll(
        () => const UserNameScreen(),
        duration: const Duration(milliseconds: 600),
        // transition: Transition.fadeIn
      );

    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Container(
          child: Text(
            'Already Exist User',
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
      print("hello");
    });
  }

  Login(email, password,String Deviceid,BuildContext context,)
  {
  print("Device id in log in state: "+ Deviceid);
      _auth.signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        SharedPref().setUid(value.user!.uid.toString());
        DateTime now = DateTime.now();
        String formattedDate = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        print(formattedDate);
        print("DeviceID------------------->"+Deviceid);
        services.UpdateDeviceId(value.user!.uid.toString(), Deviceid);
        SharedPref().setDeviceid(Deviceid);
        DatabaseReference usersRef = database.ref().child('users').child(value.user!.uid.toString());
        usersRef.once().then((DatabaseEvent event) async {
          if (event.snapshot.exists) {
            // The uid exists, perform your task here
            print("UID exists in the database. Performing task...");
            SharedPref().setUsername(event.snapshot.child("username").value.toString());
            SharedPref().setEmail(event.snapshot.child("email").value.toString());
            SharedPref().setPassword(event.snapshot.child("password").value.toString());
            SharedPref().setStepsTarget(int.parse(event.snapshot.child("StepsTarget").value.toString()));
            print(int.parse(event.snapshot.child("StepsTarget").value.toString()));                    final now = DateTime.now();
            await  getHourlyStepsForCurrentDate();
          } else {
            // The uid does not exist
            print("UID does not exist in the database.");
            Get.offAll(()=>UserNameScreen());
          }

        });

      }).catchError((e){
        print("Error"+e.toString());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Container(
            child: Text(
              'Wrong Login Credentials',
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
      });

  }

  Future signout() async {
    try {
      print("logout clicked");
      return await _auth.signOut(); //signout method of Firebase Auth
    } catch (e) {
      print(e.toString());
    }
  }

  void resetPassword(String email, BuildContext context) async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email)
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Container(
            child: Text('Email Sent to the Mentioned  Email Id',
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
  }
}
