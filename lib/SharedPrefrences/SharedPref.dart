import 'dart:convert';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref{
  bool introdone=false;
  bool _isMiles=false;
  String UID = "";
  String Username = "";
  String Email = "";
  String Password = "";
  int LastDaySteps=0;
  int TodaysSteps=0;
  bool isStart=false;
  DateTime StartTime=DateTime.now();
  Duration Activityduration =Duration.zero;
  int ifSwitchoffThenvalue=0;
  int StepsTarget=0;
  bool isguest=false;
  bool isOnboarding=false;
  int extraSteps=0;
  String Deviceid="";
  bool ischecking=true;
  bool Firstrun=false;
 int StepsComingFromFirebase=0;

 String PreviousTime="00 Am";
int lasttimeSteps=0;


  setlasttimeSteps(int LasttimeSteps) async {
    // print("lasttimeSteps");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt("slasttimeSteps", LasttimeSteps);
    // print(username);
  }

  getlasttimeSteps() async {
    // print("lasttimeSteps");
    SharedPreferences pref = await SharedPreferences.getInstance();
    lasttimeSteps = pref.getInt("lasttimeSteps")??0;
    return lasttimeSteps;
  }


   Future<void> setStepsData(int steps) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> stepsData = await getStepsData();
  // print("get in set Steps data ${stepsData}");
      final now = DateTime.now();
      final year = (now.year).toString();
      final month = now.month<10?"0"+now.month.toString():now.month.toString(); // Use month number directly
      final date = (now.day).toString();
      final time = (DateFormat('hh a').format(now)).toString();
    String FormattedTime = DateFormat('hh a').format(now);
    DateTime startTime = DateTime(now.year, now.month, now.day, 0, 0);
    DateTime endTime = now.subtract(Duration(hours: 1));
    int intervalInMinutes = 60; // Adjust as needed
    // Loop from 12 AM to the hour before the current hour
    int? totalBeforeSteps = 0;

    // Run the loop
    for (DateTime loopTime = startTime; loopTime.isBefore(endTime); loopTime = loopTime.add(Duration(minutes: intervalInMinutes))) {
      String formattedTime = DateFormat('hh a').format(loopTime);
      // print(formattedTime);
      if(stepsData.isNotEmpty && !stepsData.isNull){
        // print("not Null  ${stepsData}");
        if(stepsData['${year}']['${month}']['${date}'].containsKey(formattedTime)) {
          totalBeforeSteps = int.parse((totalBeforeSteps! +
                      stepsData['${year}']['${month}']['${date}']
                          [formattedTime] ??
                  0)
              .toString());
        }else{
          stepsData['${year}']['${month}']['${date}'][formattedTime]=0;
          totalBeforeSteps = int.parse((totalBeforeSteps! +
              stepsData['${year}']['${month}']['${date}']
              [formattedTime] ??
              0)
              .toString());
        }
      }
    }

    // Subtract totalBeforeSteps from the given steps
    final stepsToStore = steps - totalBeforeSteps!;
       stepsData[year][month][date][FormattedTime]=stepsToStore;
    // Initialize variables to store total steps
    // Save updated steps data to SharedPreferences
    await prefs.setString("StepsData", json.encode(stepsData));
  }

  // Get Steps Data from Shared Preferences
  Future<Map<String, dynamic>> getStepsData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString("StepsData");
    final Map<String, dynamic> stepsData = jsonString != null ? json.decode(jsonString) : {};

    // Check if the map is empty
    if (stepsData.isEmpty) {
      // Initialize with the current year, month, date, and set all hours to zero
      initializeStepsData(stepsData);
    }else{
        final now = DateTime.now();
        final year = (now.year).toString();
        final month = now.month<10?"0"+now.month.toString():now.month.toString(); // Use month number directly
        final date = (now.day).toString();
        if(stepsData.containsKey('$year')){

        }else{
          print("doestnotcontain Year");
          stepsData['$year']={};
        }
        if(stepsData['$year']!.containsKey('$month')){

        }else{
          print("doestnotcontain Month");
          stepsData['$year']!['$month']={};
        }
      if (stepsData['$year']!['$month']!.containsKey('$date')) {
        // If the current date doesn't exist, add it with all hours initialized to zero

      }
      else{
        print("doestnotcontain");
        DateTime startTime = DateTime(now.year, now.month, now.day, 0, 0);
        DateTime endTime = now.subtract(Duration(hours: 1));
        int intervalInMinutes = 60;
        final map={};
        for (DateTime loopTime = startTime; loopTime.isBefore(endTime); loopTime = loopTime.add(Duration(minutes: intervalInMinutes))) {
          String formattedTime = DateFormat('hh a').format(loopTime);
           map.assign(formattedTime, 0);
          // stepsData[year][month][date][formattedTime] = 0;

        }
        stepsData.update('$year', (yearValue) {
          return {
            ...yearValue,
            '$month': {
              ...yearValue?['$month'],
              '$date': map,
            },
          };
        });
        print(stepsData);

      }
    }

    return stepsData;
  }

  void initializeStepsData(Map<String, dynamic> stepsData) {
    final now = DateTime.now();
    final year = (now.year).toString();
    final month = now.month<10?"0"+now.month.toString():now.month.toString(); // Use month number directly
    final date = (now.day).toString();
    final time = (DateFormat('hh a').format(now)).toString();

    DateTime startTime = DateTime(now.year, now.month, now.day, 0, 0);
    DateTime endTime = now.subtract(Duration(hours: 1));
    int intervalInMinutes = 60; // Adjust as needed

    stepsData[year] = {
      month: {
        date: {

        },
      },
    };

    for (DateTime loopTime = startTime; loopTime.isBefore(endTime); loopTime = loopTime.add(Duration(minutes: intervalInMinutes))) {
      String formattedTime = DateFormat('hh a').format(loopTime);
      stepsData[year][month][date][formattedTime] = 0;
    }


  }













  setPreviousTime(String previousTime) async {
    // print("previousTime");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("PreviousTime", previousTime);
    // print(username);
  }
  getPreviousTime() async {
    // print("PreviousTime called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    PreviousTime = pref.getString("PreviousTime")??"00 Am";
    return PreviousTime;
  }


  setStepsComingFromFirebase(int stepsComingFromFirebase) async {
    // print("setStepsComingFromFirebase");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt("stepsComingFromFirebase", stepsComingFromFirebase);
    // print(username);
  }

  getStepsComingFromFirebase() async {
    // print("getStepsComingFromFirebase called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    StepsComingFromFirebase = pref.getInt("stepsComingFromFirebase")??0;
    return StepsComingFromFirebase;
  }




  setFirstrun(bool firstrun) async {
    // print("setFirstrun");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("Firstrun", firstrun);
    // print(username);
  }

  getFirstrun() async {
    // print("getFirstrun called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    Firstrun = pref.getBool("Firstrun")??false;
    return Firstrun;
  }













  setischecking(bool ischecking) async {
    // print("setischecking"+ischecking.toString());
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("ischecking", ischecking);
    // print(username);
  }

  getischecking() async {
    // print("getischecking called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    ischecking = pref.getBool("ischecking")??true;
     // print("is checking is-----------------------------------------------------------------------------------> "+ischecking.toString());
    return ischecking;
  }











  setStepsTarget(int stepsTarget) async {
    // print("setTodaysSteps");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt("StepsTarget", stepsTarget);
    // print(username);
  }

  getStepsTarget() async {
    // print("getTodaysSteps called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    StepsTarget = pref.getInt("StepsTarget")??0;
    return StepsTarget;
  }


 setDeviceid(String deviceid) async {
    // print("setDeviceid");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("Deviceid", deviceid);
    // print(username);
  }

  getDeviceid() async {
    // print("getDeviceid called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    Deviceid = pref.getString("Deviceid")??"";
    return Deviceid;
  }



  setextraSteps(int ExtraSteps) async {
    // print("setExtraSteps");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt("extraSteps", ExtraSteps);
    // print(username);
  }

  getextraSteps() async {
    // print("getExtraSteps called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    extraSteps = pref.getInt("extraSteps")??0;
    return extraSteps;
  }



















  setisguest(bool isguest) async {
    // print("setisStart");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("isguest", isguest);
    // print(username);
  }

  getisguest() async {
    // print("getisStart called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    isguest= pref.getBool("isguest")??true;
    return isguest;
  }

  setisOnboarding(bool isonboarding) async {
    // print("isOnboarding");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("isOnboarding", isonboarding);
    // print(username);
  }

  getisOnboardingt() async {
    // print("isOnboarding");
    SharedPreferences pref = await SharedPreferences.getInstance();
    isOnboarding= pref.getBool("isOnboarding")??false;
    return isOnboarding;
  }








  setifSwitchoffThenvalue(int ifswitchoffThenvalue) async {
    // print("setifSwitchoffThenvalue");
    // print("Value Coming in to set in SwitchOFF"+ifswitchoffThenvalue.toString());
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt("ifSwitchoffThenvalue", ifswitchoffThenvalue);
    // print(username);
  }

  getfSwitchoffThenvalue() async {
    // print("getifSwitchoffThenvaluecalled");
    SharedPreferences pref = await SharedPreferences.getInstance();
    ifSwitchoffThenvalue = pref.getInt("ifSwitchoffThenvalue")??0;
    // print("Switch off value stored in Shared Pref:- "+ifSwitchoffThenvalue.toString());
    return ifSwitchoffThenvalue;
  }






















  void saveDuration(Duration duration) async {
    // print("saveDuration");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('duration_seconds', duration.inSeconds);
  }

  Future<Duration?> getSavedDuration() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? durationSeconds = prefs.getInt('duration_seconds');
    return durationSeconds != null ? Duration(seconds: durationSeconds) : null;
  }



  setStartTime(String startTime) async {
    // print("startTime");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("startTime", startTime);
    // print(username);
  }

  getStartTime() async {
    // print("getisStart called");
    SharedPreferences pref = await SharedPreferences.getInstance();
   String startTime= pref.getString("startTime")??"";
   // print("Start Time"+startTime);
     StartTime=DateTime.parse(startTime)??DateTime.now();
    print( StartTime);
    return StartTime;
  }




  Future<void> clearAllPreferences() async {
    // print("Clearing all shared preferences");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  setisStart(bool isstart) async {
    // print("setisStart");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("isStart", isstart);
    // print(username);
  }

  getisStart() async {
    // print("getisStart called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    isStart= pref.getBool("isStart")??false;
    return isStart;
  }

  Future<void> saveStepsData(Map<String, int> stepsData) async {
    // print("------------------------Save Step Cunt is called --------------->"+stepsData.toString());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('stepsData', jsonEncode(stepsData));
  }

  Future<Map<String, int?>> getSortedStepsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('stepsData');

    if (jsonData != null) {
      Map<String, dynamic> decodedData = jsonDecode(jsonData);
      // Convert dynamic to int for the step counts
      Map<String, int> stepsData = Map.from(decodedData);
      // Sort the data by timestamp
      var sortedKeys = stepsData.keys.toList(growable: false)
        ..sort((k1, k2) => DateTime.parse(k1).compareTo(DateTime.parse(k2)));

      Map<String, int?> sortedData = Map.fromIterable(sortedKeys,
          key: (k) => k, value: (k) => stepsData[k]);
      // print("sorted steps data: "+sortedData.toString());

      return sortedData;
    } else {
      return {};
    }
  }


  setTodaysSteps(int todaysSteps) async {
    // print("setTodaysSteps");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt("TodaysSteps", todaysSteps);
    // print(username);
  }

  getTodaysSteps() async {
    // print("getTodaysSteps called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    print("Todays before Steps ${TodaysSteps}");
    TodaysSteps = pref.getInt("TodaysSteps")?? 0;
    print("Todays After Steps ${TodaysSteps}");
    return TodaysSteps;
  }










  setLastDaySteps(int lastDaySteps) async {
    // print("setLastDaySteps");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt("LastDaySteps", lastDaySteps);
    // print(username);
  }

  getLastDaySteps() async {
    // print("getLastDaySteps called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    LastDaySteps = pref.getInt("LastDaySteps")?? 0;
    return LastDaySteps;
  }

  setUsername(String username) async {
    // print("setUsername");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("Username", username);
    // print(username);
  }

  getUsername() async {
    // print("getUsername called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    Username = pref.getString("Username")?? " ";
    return Username;
  }
  setisMiles(bool ismiles) async {
    // print("setMiles");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("isMiles", ismiles);
    // print(username);
  }

  getisMiles() async {
    // print("getUsername called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    _isMiles = pref.getBool("isMiles")??false;
    return _isMiles;
  }
  setEmail(String email) async {
    // print("setEmail");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("email", email);
    // print(email);
  }

  getEmail() async {
    // print("getEmail called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    Email = pref.getString("email")?? " ";
    return Email;
  }
  setPassword(String password) async {
    // print("setPassword");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("Password", password);
    // print(password);
  }

  getPassword() async {
    // print("getPassword called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    Password = pref.getString("Password")?? " ";
    return Password;
  }


  setIntroScreenInfo(bool intro) async {
    // print("setINtroinfo called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("IntroInfo", intro);
    // print(intro);
  }

  getIntroScreenInfo() async {
    // print("getIntroscreenInfo called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    introdone = pref.getBool("IntroInfo")?? false;
    return introdone;
  }
  setUid(String uid) async {
    // print("uid called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("Uid", uid);
    // print(uid);
  }

  getUid() async {
    // print("getIntroscreenInfo called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    UID = pref.getString("Uid")?? "";
    return UID;
  }














}