import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
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

  signInWithGoogle(BuildContext context) async {
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
      Future.delayed(Duration(seconds: 1), () async {
        userObj = value!;
        print("User ID --> " + userObj.id);
        print("User Name --> " + userObj.displayName.toString());
        print("User Email --> " + userObj.email);
        print("User Photo --> " + userObj.photoUrl.toString());
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Container(
              child: Text('Account Created',
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
          SharedPref().setisguest(false);
          DatabaseReference usersRef = database.ref().child('users').child(userObj.id);
                usersRef.once().then((DatabaseEvent event) {
                  if (event.snapshot.exists) {
                    // The uid exists, perform your task here
                    print("UID exists in the database. Performing task...");
                    // Call your method here
                   Get.to(()=>HomePage());
                  } else {
                    // The uid does not exist
                    print("UID does not exist in the database.");
                    Get.to(()=>UserNameScreen());
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
      Get.to(
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

  Login(email, password,String Deviceid,BuildContext context,) {
  print("Device id in log in state: "+ Deviceid);
      _auth.signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        SharedPref().setUid(value.user!.uid.toString());
        DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('users').child(value.user!.uid.toString()).child('Device_ID');
        try {
          databaseReference.onValue.listen((event) {
            print("Device id From the firebase"+event.snapshot.value.toString());

            if(Deviceid==event.snapshot.value.toString() || event.snapshot.value.toString().isEmpty){
                    print("id device id matches the Id from the firebase");
               services.UpdateDeviceId(value.user!.uid.toString(),Deviceid).then((value2) {
                 SharedPref().setDeviceid(Deviceid);
                 SharedPref().setEmail(email);
                 SharedPref().setPassword(password);
                 services.getUserData(value.user!.uid.toString()).then((value) {
                   SharedPref().setisguest(false);
                   Get.to(() => const HomePage(), duration: const Duration(seconds: 1),);
                 });
               });
            }else{
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: EdgeInsets.all(0),
                    child: Container(
                      width: 300.w,
                      height: 150.h,
                      decoration: ShapeDecoration(
                        color: Color(0xFF2D2D2D),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: Color(0xFF9D79BC)),
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: Padding(
                        padding:  EdgeInsets.symmetric(horizontal: 25.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Already Logged in Want to get Logout from another account',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white), // Adjust text style as needed
                            ),
                            SizedBox(height: 15.h),  // Adjust this spacing as needed
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.purple, // This is the primary color, i.e., the background color
                                    onPrimary: Colors.white, // This is the color of the text
                                    // Other styling properties can be added here too
                                  ),
                                  child: Text('OK'),
                                  onPressed: () {
                                    print("in ok state ");
                                    services.UpdateDeviceId(value.user!.uid.toString(),Deviceid).then((value2) {
                                      SharedPref().setDeviceid(Deviceid);
                                      SharedPref().setEmail(email);
                                      SharedPref().setPassword(password);
                                      services.getUserData(value.user!.uid.toString()).then((value) {
                                        SharedPref().setisguest(false);
                                        Get.to(() => const HomePage(), duration: const Duration(seconds: 1),);
                                      });

                                    });
                                    Navigator.of(context).pop(); // Closes the dialog
                                  },
                                ),
                                SizedBox(width: 15.w),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.purple, // This is the primary color, i.e., the background color
                                    onPrimary: Colors.white, // This is the color of the text
                                    // Other styling properties can be added here too
                                  ),
                                  child: Text('No!'),
                                  onPressed: () {
                                    print("in no");
                                    signout();
                                    Navigator.of(context).pop(); // Closes the dialog
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }

          });
        } catch (e) {
          print('Error: $e');
        }

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
