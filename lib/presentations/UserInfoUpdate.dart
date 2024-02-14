import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:outline_gradient_button/outline_gradient_button.dart';
import 'package:wheel_slider/wheel_slider.dart';

import '../Firebasefunctionalities/DatabaseServices.dart';
import '../SharedPrefrences/SharedPref.dart';
import '../widgets/CustomSliderItem.dart';

class UserInfoUpdate extends StatefulWidget {
  const UserInfoUpdate({super.key});

  @override
  State<UserInfoUpdate> createState() => _UserInfoUpdateState();
}

class _UserInfoUpdateState extends State<UserInfoUpdate> {
  int _cCurrentValue = 160;
  int _cCurrentValueWeight = 55;
  late final TextEditingController ageController =
  TextEditingController();
  final FocusNode ageFocusNode = FocusNode();
  late final TextEditingController _defaultStepsController =
  TextEditingController();
  final FocusNode _defaultStepsNode = FocusNode();
  DatabaseServices _services =DatabaseServices();

  String UserName = "Enter Your Name";
  String Email = '';
  String Password = '';
  String UID = '';
  int defaultSteps = 6000;
  bool isGuest = false;
  List<Color> Theme1 = [
    Color(0xFFF7722A),
    Color(0xFFE032A1),
    Color(0xFFCF03F9)
  ];
  DatabaseServices services = DatabaseServices();
  Map<String, int?> map = {};
  double Height = 0;
  double Weight = 0;
  int Age = 0;
  int StepsTarget = 0;
  List<String> ActivityLevel = [
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Highly Active'
  ];
  List<double> ActivityLevelNumber = [1.2, 1.375, 1.55, 1.725];
  int ActivityIndex = 0;
  List<String> Images = [
    'lib/assests/NewImages/MaleTheme1.png',
    'lib/assests/NewImages/FemaleTheme1.png',
    'lib/assests/NewImages/OthersTheme1.png'
  ];
  List<String> Imagesunselected = [
    'lib/assests/NewImages/Male.png',
    'lib/assests/NewImages/Female.png',
    'lib/assests/NewImages/Others.png'
  ];
  int Gender = 0;
  void WhichGender(String gender) {
    if (gender == 'Male') {
      setState(() {
        Gender=0;
      });

    } else if (gender == 'Female') {
      setState(() {
        Gender=1;
      });
    } else {
      setState(() {
        Gender=2;
      });
    }
  }

  whichthemeImages() async {
    Images = await SharedPref().loadImageList();
  }

  Future<void> whichTheme() async {
    List<Color> Theme = await SharedPref().loadColorList();
    setState(() {
      Theme1 = Theme;
    });
  }

  double inMiles = 0;

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
  bool Geust=true;
  gettingEmailAndPassword() async {
    int height=await SharedPref().getHeight();
    int weight=await SharedPref().getWeight();
    int age=await SharedPref().getAge();
    double activityLevel=await SharedPref().getActivityLevel();
    String  gender=await SharedPref().getGender();
    bool guest=await SharedPref().getisguest();
    String uid=await SharedPref().getUid();
    whichTheme();
    print(gender);
    WhichGender(gender);
    setState(() {
      Geust=guest;
      UID=uid;
      Height=double.parse(height.toString());
      Weight=double.parse(weight.toString());
      _cCurrentValue=height;
      _cCurrentValueWeight=weight;
      Age=age;
      ageController.text=Age.toString();
       for(int i=0;i<ActivityLevelNumber.length;i++){
         if(activityLevel==ActivityLevelNumber[i]){
           setState(() {
             ActivityIndex=i;
           });
         }
       }


    });
  }


  FirebaseSetingUp(BuildContext context) async {
    Map<String, dynamic> stepsData={};
    stepsData=await SharedPref().getStepsData();
    print(stepsData);
    services.writeToDatabase(Uid: UID, username: UserName, Email: Email, gender: await SharedPref().getGender(), Password: Password, defaultSteps: await SharedPref().getStepsTarget(), DeviceId: await SharedPref().getDeviceid(), age: await SharedPref().getAge(), height: await SharedPref().getHeight(), weight: await SharedPref().getWeight(), activityLevel: await SharedPref().getActivityLevel(), context: context,).then((value) {
      services.sendStepsToFirebase(60);
    });
  }

  void initState() {
    setState(() {
      Theme1 = [
        Color(0xFFF7722A),
        Color(0xFFE032A1),
        Color(0xFFCF03F9)
      ];
    });
    whichTheme();
    whichthemeImages();
    super.initState();
    gettingEmailAndPassword();
  }













  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body:        Padding(
        padding:  EdgeInsets.symmetric(vertical: 50),
        child: SingleChildScrollView(
          child: Column(
            children: [
          
              Padding(
                padding:  EdgeInsets.only(left: 20),
                child: Row(
                  children: [
          
                    IconButton(onPressed: (){Get.back();}, icon: Icon(Icons.arrow_back_ios)),
                  ],
                ),
              ),
              SizedBox(height: 25,),
              Center(
                child: Text(
                  "Body Mass Index",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40.sp,
                    fontFamily: 'Teko',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
              ),
              SizedBox(height: 15,),
          
              Center(
                child: Text(
                  "Gender",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
              ),
              SizedBox(height: 15,),
          
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: OutlineGradientButton(
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            setState(() {
                              Gender = 0;
                            });
                            await SharedPref().setGender("Male");
                            if(Geust==false){
                              _services.UpdateGender(UID, "Male");
                            }
                          },
                          child: Image.asset(
                            Gender == 0
                                ? Images[0]
                                : Imagesunselected[0],
                            scale: 4,
                          ),
                          gradient: LinearGradient(
                              colors: Gender == 0
                                  ? Theme1
                                  : [
                                Colors.grey,
                                Colors.grey,
                              ]),
                          strokeWidth: 4,
                          elevation: 1,
                          radius: Radius.circular(15),
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            colors: Gender == 0
                                ? Theme1
                                : [
                              Colors.grey,
                              Colors.grey
                            ], // Replace these colors with your desired gradient colors
                            begin: Alignment.center,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        },
                        child: Text(
                          "Male",
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Work Sans',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            color: Colors
                                .white, // Set the color to white since it will be masked by the gradient
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: OutlineGradientButton(
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            setState(() {
                              Gender = 1;
                            });
                            await SharedPref().setGender("Female");
                            if(Geust==false){
                              _services.UpdateGender(UID, "Female");
                            }
                          },
                          child: Image.asset(
                            Gender == 1
                                ? Images[1]
                                : Imagesunselected[1],
                            scale: 4,
                          ),
                          gradient: LinearGradient(
                              colors: Gender == 1
                                  ? Theme1
                                  : [
                                Colors.grey,
                                Colors.grey,
                              ]),
                          strokeWidth: 4,
                          elevation: 1,
                          radius: Radius.circular(15),
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            colors: Gender == 1
                                ? Theme1
                                : [
                              Colors.grey,
                              Colors.grey
                            ], // Replace these colors with your desired gradient colors
                            begin: Alignment.center,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        },
                        child: Text(
                          "Female",
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Work Sans',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            color: Colors
                                .white, // Set the color to white since it will be masked by the gradient
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: OutlineGradientButton(
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            setState(() {
                              Gender = 2;
                            });
                            await SharedPref().setGender("Others");
                            if(Geust==false){
                              _services.UpdateGender(UID, "Others");
                            }
                          },
                          child: Image.asset(
                            Gender == 2
                                ? Images[2]
                                : Imagesunselected[2],
                            scale: 4,
                          ),
                          gradient: LinearGradient(
                              colors: Gender == 2
                                  ? Theme1
                                  : [
                                Colors.grey,
                                Colors.grey,
                              ]),
                          strokeWidth: 4,
                          elevation: 1,
                          radius: Radius.circular(15),
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            colors: Gender == 2
                                ? Theme1
                                : [
                              Colors.grey,
                              Colors.grey
                            ], // Replace these colors with your desired gradient colors
                            begin: Alignment.center,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        },
                        child: Text(
                          "Others",
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Work Sans',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            color: Colors
                                .white, // Set the color to white since it will be masked by the gradient
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20,),
              Text(
                'Height (in cm)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w400,
                  height: 0,
                  letterSpacing: 0.80,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: 328,
                height: 90,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        width: 1, color: Color(0xFF949494)),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 10, horizontal: 8),
                  child: WheelSlider.customWidget(
                    totalCount: 10000,
                    initValue: _cCurrentValue,
                    isInfinite: true,
                    scrollPhysics: const BouncingScrollPhysics(),
                    customPointer: CustomSliderItem(
                      color: Theme1[0],
                    ),
                    children: List.generate(
                        10000,
                            (index) => Center(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 25,
                                ),
                                Text(
                                  index.toString(),
                                  style: TextStyle(
                                      color: _cCurrentValue == index
                                          ? Theme1[0]
                                          : Colors.grey,
                                      fontSize: 20,
                                    fontFamily: 'Work Sans',),
                                ),
                              ],
                            ))),
                    onValueChanged: (val) async {
                      setState(()  {
                        _cCurrentValue = val;
                        Height = double.parse(val.toString());
                      });
                      await SharedPref().setHeight(int.parse(Height.toStringAsFixed(0)));
                      if(Geust==false){
                        _services.UpdateHeight(UID, int.parse(Height.toStringAsFixed(0)));
                      }
                      print(Height);
                    },
                    hapticFeedbackType:
                    HapticFeedbackType.lightImpact,
                    showPointer: true,
                    itemSize: 80,
                    horizontalListWidth: 100,
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                "Weight (in Kg)",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w400,
                  height: 0,
                  letterSpacing: 0.80,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: 328,
                height: 90,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        width: 1, color: Color(0xFF949494)),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 10, horizontal: 8),
                  child: WheelSlider.customWidget(
                    totalCount: 10000,
                    initValue: _cCurrentValueWeight,
                    isInfinite: true,
                    scrollPhysics: const BouncingScrollPhysics(),
                    customPointer: CustomSliderItem(
                      color: Theme1[0],
                    ),
                    children: List.generate(
                        10000,
                            (index) => Center(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 25,
                                ),
                                Text(
                                  index.toString(),
                                  style: TextStyle(
                                      color: _cCurrentValueWeight ==
                                          index
                                          ? Theme1[0]
                                          : Colors.grey,
                                      fontSize: 20,
                                    fontFamily: 'Work Sans',),
                                ),
                              ],
                            ))),
                    onValueChanged: (val) async {
                      setState(() {
                        _cCurrentValueWeight = val;
                        Weight = double.parse(val.toString());
                      });
                      await SharedPref().setWeight(int.parse(Weight.toStringAsFixed(0)));
                      if(Geust==false){
                        _services.UpdateWeight(UID, int.parse(Weight.toStringAsFixed(0)));
                      }
          
                    },
                    hapticFeedbackType:
                    HapticFeedbackType.lightImpact,
                    showPointer: true,
                    itemSize: 80,
                    horizontalListWidth: 100,
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                "Age",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w400,
                  height: 0,
                  letterSpacing: 0.80,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
          
                        setState(() {
                          if (Age > 0) {
                            Age = Age - 1;
          
                          } else {
                            Age = 0;
                          }
                        });
                        await SharedPref().setAge(Age);
                        if(Geust==false){
                          _services.UpdateAge(UID, int.parse(Age.toStringAsFixed(0)));
                        }
                      },
                      icon: ImageIcon(AssetImage(
                          "lib/assests/NewImages/Subtraction.png"))),
                  GestureDetector(
                    onTap: (){
                      showDialog(context: context, builder: (BuildContext context){
                        return   AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          backgroundColor: Colors.white,
                          title: Text('Enter Your Age',style: TextStyle(color: Colors.black),),
                          content: TextField(
                            controller: ageController,
                            focusNode: ageFocusNode,
                            style:  TextStyle(color: Colors.black),
          
                          ),
                          actions: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Trigger callback function with entered text
                                setState(() {
                                  Age=int.parse(ageController.text);
                                });
                                _services.UpdateAge(UID, int.parse(Age.toStringAsFixed(0)));
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      });
                    },
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          colors:
                          Theme1, // Replace these colors with your desired gradient colors
                          begin: Alignment.center,
                          end: Alignment.bottomRight,
                        ).createShader(bounds);
                      },
                      child: Text(
                        Age.toString(),
                        style: TextStyle(
                          fontSize: 46.sp,
                          fontFamily: 'Work Sans',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: Colors
                              .white, // Set the color to white since it will be masked by the gradient
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        setState(() {
                          Age = Age + 1;
                        });
                        await SharedPref().setAge(Age);
                        if(Geust==false){
                          _services.UpdateAge(UID, int.parse(Age.toStringAsFixed(0)));
                        }
                      },
                      icon: ImageIcon(AssetImage(
                          "lib/assests/NewImages/Addition.png"))),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "Your Activity Level",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w400,
                  height: 0,
                  letterSpacing: 0.80,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
          
                        setState(() {
                          if (ActivityIndex > 0) {
                            ActivityIndex = ActivityIndex - 1;
                          }
                        });
                        await SharedPref().setActivityLevel(ActivityLevelNumber[ActivityIndex]);
                      },
                      icon: Icon(
                        Icons.arrow_left_rounded,
                        size: 50,
                        color: Colors.white,
                      )),
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors:
                        Theme1, // Replace these colors with your desired gradient colors
                        begin: Alignment.center,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: Text(
                      ActivityLevel[ActivityIndex],
                      style: TextStyle(
                        fontSize: 46.sp,
                        fontFamily: 'Teko',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        color: Colors
                            .white, // Set the color to white since it will be masked by the gradient
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
          
                        setState(() {
                          if (ActivityIndex < 3)
                            ActivityIndex = ActivityIndex + 1;
                        });
                        await SharedPref().setActivityLevel(ActivityLevelNumber[ActivityIndex]);
                        if(Geust==false){
                          _services.UpdateActivityLevel(UID, ActivityLevelNumber[ActivityIndex]);
                        }
          
                      },
                      icon: Icon(
                        Icons.arrow_right_rounded,
                        size: 50,
                        color: Colors.white,
                      )),
                ],
              )
            ],
          ),
        ),
      ),
      );
  }
}
