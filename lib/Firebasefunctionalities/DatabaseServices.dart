
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

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
        DatabaseReference databaseReference = FirebaseDatabase.instance.reference(); // Replace with your user ID
        String _uid = await SharedPref().getUid();
        DateTime now = DateTime.now();
        Map<String,Object> newtimedatw={};
        String formattedDate = DateFormat('yyyy-MM-dd').format(now);
        String FormattedTime = DateFormat('hh a').format(now);
        String previoustime=await SharedPref().getPreviousTime()??"00 Am";
        String pre = DateFormat('hh a').format(now.subtract(Duration(hours: 1)));
        int lasttimesteps=0;
        DateTime startTime = DateTime(now.year, now.month, now.day, 0, 0);
        DateTime endTime = now.subtract(Duration(hours: 1));

        int intervalInMinutes = 60; // Adjust as needed

        // Run the loop
        for (DateTime loopTime = startTime; loopTime.isBefore(endTime); loopTime = loopTime.add(Duration(minutes: intervalInMinutes))) {
          // Format the current time in the desired format
          String formattedTime = DateFormat('hh a').format(loopTime);
          print(formattedTime);
          databaseReference
              .child('users')
              .child(_uid)
              .child('steps')
              .child(formattedDate)
              .child(formattedTime)
              .once().then((value) {
            var dataSnapshot =value;
            if(dataSnapshot.snapshot.value!=null){
              lasttimesteps=lasttimesteps+int.parse(dataSnapshot.snapshot.value.toString());
              int Stepstobeset=steps-lasttimesteps;
              databaseReference
                  .child('users')
                  .child(_uid)
                  .child('steps')
                  .child(formattedDate).update({FormattedTime:Stepstobeset});
              print("Lasttimestepsp in if condition--------------------->"+lasttimesteps.toString());
            }else{

              print("Lasttimestepsp in else condition--------------------->"+lasttimesteps.toString());
              databaseReference
                  .child('users')
                  .child(_uid)
                  .child('steps')
                  .child(formattedDate)
                  .child(formattedTime).set(0);
            }

          });
          // Print or use the formatted time as needed

        }
        databaseReference
            .child('users')
            .child(_uid)
            .child('steps')
            .child(formattedDate).update({"TotalSteps" : steps});
        databaseReference
            .child('users')
            .child(_uid)
            .child('steps')
            .child(formattedDate).update({"StepsTargetofTheDays" : await SharedPref().getStepsTarget()});

      }
}

