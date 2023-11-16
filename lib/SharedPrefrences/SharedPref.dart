import 'dart:convert';

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






  setFirstrun(bool firstrun) async {
    print("setFirstrun");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("Firstrun", firstrun);
    // print(username);
  }

  getFirstrun() async {
    print("getFirstrun called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    Firstrun = pref.getBool("Firstrun")??false;
    return Firstrun;
  }













  setischecking(bool ischecking) async {
    print("setischecking");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("ischecking", ischecking);
    // print(username);
  }

  getischecking() async {
    print("getischecking called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    ischecking = pref.getBool("ischecking")??true;
    return ischecking;
  }











  setStepsTarget(int stepsTarget) async {
    print("setTodaysSteps");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt("StepsTarget", stepsTarget);
    // print(username);
  }

  getStepsTarget() async {
    print("getTodaysSteps called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    StepsTarget = pref.getInt("StepsTarget")??0;
    return StepsTarget;
  }


 setDeviceid(String deviceid) async {
    print("setDeviceid");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("Deviceid", deviceid);
    // print(username);
  }

  getDeviceid() async {
    print("getDeviceid called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    Deviceid = pref.getString("Deviceid")!;
    return Deviceid;
  }



  setextraSteps(int ExtraSteps) async {
    print("setExtraSteps");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt("extraSteps", ExtraSteps);
    // print(username);
  }

  getextraSteps() async {
    print("getExtraSteps called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    extraSteps = pref.getInt("extraSteps")??0;
    return extraSteps;
  }



















  setisguest(bool isguest) async {
    print("setisStart");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("isguest", isguest);
    // print(username);
  }

  getisguest() async {
    print("getisStart called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    isguest= pref.getBool("isguest")??true;
    return isguest;
  }

  setisOnboarding(bool isonboarding) async {
    print("isOnboarding");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("isOnboarding", isonboarding);
    // print(username);
  }

  getisOnboardingt() async {
    print("isOnboarding");
    SharedPreferences pref = await SharedPreferences.getInstance();
    isOnboarding= pref.getBool("isOnboarding")??false;
    return isOnboarding;
  }








  setifSwitchoffThenvalue(int ifswitchoffThenvalue) async {
    print("setifSwitchoffThenvalue");
    print("Value Coming in to set in SwitchOFF"+ifswitchoffThenvalue.toString());
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt("ifSwitchoffThenvalue", ifswitchoffThenvalue);
    // print(username);
  }

  getfSwitchoffThenvalue() async {
    print("getifSwitchoffThenvaluecalled");
    SharedPreferences pref = await SharedPreferences.getInstance();
    ifSwitchoffThenvalue = pref.getInt("ifSwitchoffThenvalue")!;
    print("Switch off value stored in Shared Pref:- "+ifSwitchoffThenvalue.toString());
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
    print("startTime");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("startTime", startTime);
    // print(username);
  }

  getStartTime() async {
    print("getisStart called");
    SharedPreferences pref = await SharedPreferences.getInstance();
   String startTime= pref.getString("startTime")??"";
   print("Start Time"+startTime);
     StartTime=DateTime.parse(startTime)??DateTime.now();
    print( StartTime);
    return StartTime;
  }













  setisStart(bool isstart) async {
    print("setisStart");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("isStart", isstart);
    // print(username);
  }

  getisStart() async {
    print("getisStart called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    isStart= pref.getBool("isStart")??false;
    return isStart;
  }

  Future<void> saveStepsData(Map<String, int> stepsData) async {
    print("------------------------Save Step Cunt is called --------------->"+stepsData.toString());
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
      print("sorted steps data: "+sortedData.toString());

      return sortedData;
    } else {
      return {};
    }
  }

  // Future<List<double>> getStepsDataInRange(DateTime startDate, DateTime endDate) async {
  //   Map<String, int?> sortedData = await getSortedStepsData();
  //
  //   List<double> weeklySummary = List.filled(7, 0); // Initialize with zeros
  //
  //   // Loop through dates from startDate to endDate
  //   for (var date = startDate; date.isBefore(endDate); date = date.add(Duration(days: 1))) {
  //     String formattedDate = date.toIso8601String();
  //
  //     // Check if the date has a step count entry
  //     if (sortedData.containsKey(formattedDate)) {
  //       int steps = sortedData[formattedDate]!;
  //       print("Steps: "+steps.toString());
  //       int dayOfWeek = date.weekday; // 1 for Monday, 2 for Tuesday, ..., 7 for Sunday
  //       int listIndex = (dayOfWeek + 5) % 7; // Adjust for list index (0 for Monday, 1 for Tuesday, ..., 6 for Sunday)
  //       weeklySummary[listIndex] = double.parse(steps.toString());
  //     }
  //   }
  //
  //   print("weekly steps data in shared pref"+weeklySummary.toString());
  //
  //   return weeklySummary;
  // }

  setTodaysSteps(int todaysSteps) async {
    print("setTodaysSteps");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt("TodaysSteps", todaysSteps);
    // print(username);
  }

  getTodaysSteps() async {
    print("getTodaysSteps called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    TodaysSteps = pref.getInt("TodaysSteps")?? 0;
    return TodaysSteps;
  }










  setLastDaySteps(int lastDaySteps) async {
    print("setLastDaySteps");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt("LastDaySteps", lastDaySteps);
    // print(username);
  }

  getLastDaySteps() async {
    print("getLastDaySteps called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    LastDaySteps = pref.getInt("LastDaySteps")?? 0;
    return LastDaySteps;
  }

  setUsername(String username) async {
    print("setUsername");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("Username", username);
    // print(username);
  }

  getUsername() async {
    print("getUsername called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    Username = pref.getString("Username")?? " ";
    return Username;
  }
  setisMiles(bool ismiles) async {
    print("setMiles");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("isMiles", ismiles);
    // print(username);
  }

  getisMiles() async {
    print("getUsername called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    _isMiles = pref.getBool("isMiles")??false;
    return _isMiles;
  }
  setEmail(String email) async {
    print("setEmail");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("email", email);
    // print(email);
  }

  getEmail() async {
    print("getEmail called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    Email = pref.getString("email")?? " ";
    return Email;
  }
  setPassword(String password) async {
    print("setPassword");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("Password", password);
    // print(password);
  }

  getPassword() async {
    print("getPassword called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    Password = pref.getString("Password")?? " ";
    return Password;
  }


  setIntroScreenInfo(bool intro) async {
    print("setINtroinfo called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("IntroInfo", intro);
    // print(intro);
  }

  getIntroScreenInfo() async {
    print("getIntroscreenInfo called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    introdone = pref.getBool("IntroInfo")?? false;
    return introdone;
  }
  setUid(String uid) async {
    print("uid called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("Uid", uid);
    // print(uid);
  }

  getUid() async {
    print("getIntroscreenInfo called");
    SharedPreferences pref = await SharedPreferences.getInstance();
    UID = pref.getString("Uid")?? "";
    return UID;
  }

}