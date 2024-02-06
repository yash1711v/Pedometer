
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:steptracking/presentations/MainScreen.dart';

import '../SharedPrefrences/SharedPref.dart';
import '../presentations/HomePage.dart';
class DatabaseServices {
      Future<void> writeToDatabase(
          {required String Uid,
      required String username,
      required String Email,
      required String gender,
      required String Password,
      required int defaultSteps,
      required String DeviceId,
      required int age ,
      required int height ,
      required int weight ,
      required double activityLevel ,
      required BuildContext context,

          }) async {
        DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
      try{
        databaseReference.child('users').child(Uid).set({
          'username': username,
          'email': Email,
          'password' : Password,
          'StepsTarget' :  defaultSteps,
          'Gender':gender,
          'Age':age,
          'Height':height,
          'Weight':weight,
          'ActivityLevel':activityLevel,
          "Device_ID" : DeviceId
         }).then((value) {

          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //   content: Container(
          //     child: Text('Data Saved',
          //       style: TextStyle(
          //         color: Colors.white,
          //         fontSize: 16.sp,
          //         fontFamily: 'Inter',
          //         fontWeight: FontWeight.w400,
          //         height: 0,
          //       ),
          //
          //     ),
          //   ),
          //   behavior: SnackBarBehavior.floating,
          //   backgroundColor: Colors.black,
          // ));

          SharedPref().setUsername(Email);
            Get.to(()=>MainScreen(),
                duration: const Duration(
                    seconds:
                    1),
                transition: Transition.fadeIn
            );
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
            'StepsTarget' :  defaultSteps
          });
        }catch(error){print(error);
        }

      }
      void UpdateEmail(String Uid, String Email) {
        DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
        try{
          databaseReference.child('users').child(Uid).update({
            'username' :  Email,
          });
        }catch(error){print(error);
        }

      }
      Future<void> UpdateDeviceId(String id, String DeviceId) async {
        DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
        print("deviceid Coming to set"+DeviceId);
        try{
          databaseReference.child('users').child(id).update({
            'Device_ID' :  DeviceId
          }).then((value) {
            print("DevideID set successfully");
          });
        }catch(error){print(error);
        }

      }

      void sendStepsToFirebase(int steps) async {
        print("----------------------------------------------?jmbhjch");
        DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
        String _uid = await SharedPref().getUid();
        print("In store in firebase methof------>"+_uid);
        final Map<String, dynamic> stepsData = await SharedPref().getStepsData();// Replace with your user ID
        String stepsDataJson = json.encode(stepsData);
         databaseReference
            .child('users')
            .child(_uid).child('steps').once().then((DatabaseEvent event) {
              if(event.snapshot.exists){
                databaseReference
                    .child('users')
                    .child(_uid)
                // .child('steps')
                    .update({'steps': stepsDataJson});
              }else{
                databaseReference
                    .child('users')
                    .child(_uid).child('steps').set(stepsDataJson);

              }

         });


      }
     Future<String?> getStepsData() async {
        String _uid = await SharedPref().getUid();
        String? stepsDataJson = "";
        Map<String, dynamic> stepsData={};
        DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('users').child(_uid).child('steps');

        try {
          DatabaseEvent event = await databaseReference.once();
          event.snapshot.value;
          print( event.snapshot.value);
            stepsDataJson = event.snapshot.value.toString();
              stepsData=json.decode(stepsDataJson);
          SharedPref().setStepsDataFromFirebase(stepsData).then((value) async => {
          await SharedPref().getStepsData().then((value) {
            print("stepsData after getting from firebase and setting to the Shared Pref ${value}");

          })
          });
        } catch (e) {
          print('Error: $e');
        }
        print("stepsData  ${stepsDataJson}");

        return stepsDataJson;

      }
}

