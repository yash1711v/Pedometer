
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../SharedPrefrences/SharedPref.dart';
import '../presentations/HomePage.dart';
class DatabaseServices {
      void writeToDatabase(String Uid,String username, String Email , String Password, int defaultSteps,String DeviceId,BuildContext context) {
        DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
      try{
        databaseReference.child('users').child(Uid).set({
          'username': username,
          'email': Email,
          'password' : Password,
          'defaultsteps' :  defaultSteps,
          "Device_ID" : DeviceId
         }).then((value) {

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Container(
              child: Text('Data Saved',
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

          SharedPref().setUsername(username);
            // Get.to(()=>HomePage(),
            //     duration: const Duration(
            //         seconds:
            //         1),
            //     transition: Transition.fadeIn
            // );
        });
      }catch(error){print(error);
      }

  }

  Future<void> getUserData(String uid) async {
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('users').child(uid).child('username');
    try {
      databaseReference.onValue.listen((event) {
        print(event.snapshot.value.toString());
        SharedPref().setUsername(event.snapshot.value.toString());
      });
    } catch (e) {
      print('Error: $e');
    }
  }

      void Update(String Uid, int defaultSteps) {
        DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
        try{
          databaseReference.child('users').child(Uid).update({
            'defaultsteps' :  defaultSteps
          });
        }catch(error){print(error);
        }

      }
      Future<void> UpdateDeviceId(String id, String DeviceId) async {
        DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
        try{
          databaseReference.child('users').child(id).update({
            'Device_ID' :  DeviceId
          });
        }catch(error){print(error);
        }

      }

}

