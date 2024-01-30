import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../SharedPrefrences/SharedPref.dart';
import '../widgets/BottomNavbar.dart';
import 'LevelMapScreen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
 List<String> Images=["lib/assests/NewImages/Theme1AwardsBg.png","lib/assests/NewImages/Theme2AwardsBg.png","lib/assests/NewImages/Theme3AwardsBg.png"];
 int value=0;


 List<String> CompletedThings=[
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
   "lib/assests/NewImages/Lockeditem.png",
 ];

 List<Color> Theme=[Color(0xFFF7722A),Color(0xFFE032A1),Color(0xFFCF03F9)];
 void initState() {
   super.initState();
   whichTheme();
   print(CompletedThings.length);
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
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    for(int i=0;i<Images.length;i++) {
      AssetImage(Images[i]);
    }
  }
  int currentlevel=1;
 int currentOption=0;
 @override
  Widget build(BuildContext context) {

    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage(Images[value]),fit: BoxFit.fill)),
        child: Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 60,),
                Container(
                  width: 319,
                  height: 126,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(1.00, 0.02),
                      end: Alignment(-1, -0.02),
                      colors: [Theme[0].withOpacity(0.5), Theme[1].withOpacity(0.5), Theme[2].withOpacity(0.5)],
                    ),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1, color: Color(0xFFDA9629)),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 17,
                        top: 15,
                        child: Text(
                          'Your Highest achievement',
                          style: TextStyle(
                            color: Color(0xFFCDCDCD),
                            fontSize: 10,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            height: 0,
                            letterSpacing: 0.10,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 17,
                        top: 43,
                        child: Text(
                          'The Neighbourhood ',
                          style: TextStyle(
                            color: Color(0xFFF3F3F3),
                            fontSize: 20,
                            fontFamily: 'Teko',
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 17,
                        top: 57,
                        child: Text(
                          'Explorer',
                          style: TextStyle(
                            color: Color(0xFFF3F3F3),
                            fontSize: 48,
                            fontFamily: 'Teko',
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        currentOption=0;
                      });
                    },
                    child: Container(
                      width: 80,
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0.98, 0.19),
                          end: Alignment(-0.98, -0.19),
                          colors: currentOption==0?[Theme[0],Theme[2]]:
                          [Color(0xFF8800),
                            Color(0xCE00FE)],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Steps',
                            style: TextStyle(
                              color: Color(0xFFF3F3F3),
                              fontSize: 24,
                              fontFamily: 'Teko',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          currentOption=1;
                        });
                      },
                    child: Container(
                      width: 80,
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0.98, 0.19),
                          end: Alignment(-0.98, -0.19),
                          colors: currentOption==1?[Theme[0],Theme[2]]:
                          [Color(0xFF8800),
                            Color(0xCE00FE)],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Calories',
                            style: TextStyle(
                              color: Color(0xFFF3F3F3),
                              fontSize: 24,
                              fontFamily: 'Teko',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          currentOption=2;
                        });
                      },
                    child: Container(
                      width: 80,
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0.98, 0.19),
                          end: Alignment(-0.98, -0.19),
                          colors: currentOption==2?[Theme[0],Theme[2]]:
                          [Color(0xFF8800),
                            Color(0xCE00FE)],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Kms',
                            style: TextStyle(
                              color: Color(0xFFF3F3F3),
                              fontSize: 24,
                              fontFamily: 'Teko',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],),
                SizedBox(height: 15,),
                Stack(
                    children:
                [

                  Padding(
                    padding:  EdgeInsets.only(top: 37,left: 20),
                    child: Center(child: Image(image: AssetImage("lib/assests/NewImages/PathImage.png"),width: 200,)),
                  ),
                  // Visibility(
                  //   visible: currentOption==0,
                  //   child:
                  //   Column(
                  //     children: [
                  //
                  //       Row(
                  //         children: [
                  //           Padding(
                  //             padding:  EdgeInsets.only(left: currentlevel>=20?MediaQuery.of(context).size.width*0.2:MediaQuery.of(context).size.width*0.22),
                  //             child: Image(image: AssetImage(currentlevel>=20?"lib/assests/NewImages/p20.png":CompletedThings[0]),width: currentlevel>=20?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 3,),
                  //       Row(
                  //         children: [
                  //           Padding(
                  //             padding:  EdgeInsets.only(left:currentlevel>=19? 40:150),
                  //             child: Image(image: AssetImage((currentlevel>=19?"lib/assests/NewImages/p19.png":CompletedThings[0])),width: currentlevel>=19?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 5,),
                  //    Row(
                  //         children: [
                  //           Padding(
                  //             padding:  EdgeInsets.only(left: currentlevel>=18?MediaQuery.of(context).size.width*0.42:MediaQuery.of(context).size.width*0.45),
                  //             child: Image(image: AssetImage(currentlevel>=18?"lib/assests/NewImages/p18.png":CompletedThings[0]),width: currentlevel>=18?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 20,),
                  //       Row(
                  //         children: [
                  //
                  //           Padding(
                  //             padding: EdgeInsets.only(left: currentlevel>=17?MediaQuery.of(context).size.width*0.30:MediaQuery.of(context).size.width*0.30),
                  //             child: Image(image: AssetImage(currentlevel>=17?"lib/assests/NewImages/p17.png":CompletedThings[0]),width: currentlevel>=17?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 20,),
                  //       Row(
                  //         children: [
                  //           Padding(
                  //             padding: EdgeInsets.only(left: currentlevel>=16?MediaQuery.of(context).size.width*0.325:MediaQuery.of(context).size.width*0.55),
                  //             child: Image(image: AssetImage(currentlevel>=16?"lib/assests/NewImages/p16.png":CompletedThings[0]),width: currentlevel>=16?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 50,),
                  //       Row(
                  //         children: [
                  //
                  //           Padding(
                  //             padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.240),
                  //             child: Image(image: AssetImage(currentlevel>=15?"lib/assests/NewImages/p15.png":CompletedThings[0]),width: currentlevel>=15?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       Row(
                  //         children: [
                  //           Padding(
                  //             padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.46),
                  //             child: Image(image: AssetImage(currentlevel>=14?"lib/assests/NewImages/p14.png":CompletedThings[0]),width: currentlevel>=14?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 25,),
                  //       Row(
                  //         children: [
                  //           Padding(
                  //             padding: EdgeInsets.only(left: currentlevel>=13?MediaQuery.of(context).size.width*0.4:MediaQuery.of(context).size.width*0.65),
                  //             child: Image(image: AssetImage(currentlevel>=13?"lib/assests/NewImages/p13.png":CompletedThings[0]),width: currentlevel>=14?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 25,),
                  //       Row(
                  //         children: [
                  //           Padding(
                  //             padding: EdgeInsets.only(left: currentlevel>=12?MediaQuery.of(context).size.width*0.10:MediaQuery.of(context).size.width*0.45),
                  //             child: Image(image: AssetImage(currentlevel>=12?"lib/assests/NewImages/p12.png":CompletedThings[0]),width: currentlevel>=12?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 35,),
                  //      Row(
                  //        children: [
                  //           Padding(
                  //             padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.24),
                  //             child: Image(image: AssetImage( currentlevel>=11?"lib/assests/NewImages/e11.png":CompletedThings[0]),width:  currentlevel>=11?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 15,),
                  //       Row(
                  //        children: [
                  //           Padding(
                  //             padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.40),
                  //             child: Image(image: AssetImage(currentlevel>=10?"lib/assests/NewImages/p10.png":CompletedThings[0]),width: currentlevel>=10?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 15,),
                  //       Row(
                  //        children: [
                  //           Padding(
                  //             padding: EdgeInsets.only(left: currentlevel>=9?MediaQuery.of(context).size.width*0.33:MediaQuery.of(context).size.width*0.60),
                  //             child: Image(image: AssetImage(currentlevel>=9?"lib/assests/NewImages/p9.png":CompletedThings[0]),width: currentlevel>=9?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 20,),
                  //        Row(
                  //        children: [
                  //           Padding(
                  //             padding: EdgeInsets.only(left: currentlevel>=8?MediaQuery.of(context).size.width*0.11:MediaQuery.of(context).size.width*0.45),
                  //             child: Image(image: AssetImage(currentlevel>=8?"lib/assests/NewImages/p8.png":CompletedThings[0]),width: currentlevel>=8?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //           SizedBox(height: 30,),
                  //           Row(
                  //        children: [
                  //           Padding(
                  //             padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.22),
                  //             child: Image(image: AssetImage(currentlevel>=7?"lib/assests/NewImages/p7.png":CompletedThings[0]),width: currentlevel>=7?180:95,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 10,),
                  //          Row(
                  //        children: [
                  //           Padding(
                  //             padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.42),
                  //             child: Image(image: AssetImage(currentlevel>=6?"lib/assests/NewImages/p6.png":CompletedThings[0]),width: currentlevel>=6?180:100,),
                  //           )
                  //         ],
                  //       ),
                  //            SizedBox(height: 20,),
                  //            Row(
                  //        children: [
                  //             Padding(
                  //             padding: EdgeInsets.only(left: currentlevel>=5?MediaQuery.of(context).size.width*0.35:MediaQuery.of(context).size.width*0.58),
                  //             child: Image(image: AssetImage(currentlevel>=5?"lib/assests/NewImages/p5.png":CompletedThings[0]),width: currentlevel>=5?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 15,),
                  //       Row(
                  //        children: [
                  //             Padding(
                  //             padding: EdgeInsets.only(left: currentlevel>=4?MediaQuery.of(context).size.width*0.16:MediaQuery.of(context).size.width*0.3),
                  //             child: Image(image: AssetImage(currentlevel>=4?"lib/assests/NewImages/p4.png":CompletedThings[0]),width: currentlevel>=4?180:100,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 25,),
                  //      Row(
                  //        children: [
                  //             Padding(
                  //             padding: EdgeInsets.only(left: currentlevel>=3?MediaQuery.of(context).size.width*0.25:MediaQuery.of(context).size.width*0.30),
                  //             child: Image(image: AssetImage(currentlevel>=3?"lib/assests/NewImages/p3.png":CompletedThings[0]),width: currentlevel>=3?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 105,),
                  //       Row(
                  //        children: [
                  //             Padding(
                  //             padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.5),
                  //             child: Image(image: AssetImage(currentlevel>=2?"lib/assests/NewImages/p2.png":CompletedThings[0]),width: currentlevel>=2?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 85,),
                  //
                  //       Row(
                  //        children: [
                  //             Padding(
                  //             padding: EdgeInsets.only(left:currentlevel>=1? MediaQuery.of(context).size.width*0.2:MediaQuery.of(context).size.width*0.45),
                  //             child: Image(image: AssetImage(currentlevel>=1?"lib/assests/NewImages/p1.png":CompletedThings[0]),width: currentlevel>=1?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //
                  //     ],
                  //   ),
                  // ),
                  Visibility(
                    visible: currentOption==1,
                    child:
                    Column(
                      children: [

                        Row(
                          children: [
                            Padding(
                              padding:  EdgeInsets.only(left: currentlevel>=20?MediaQuery.of(context).size.width*0.2:MediaQuery.of(context).size.width*0.22),
                              child: Image(image: AssetImage(currentlevel>=20?"lib/assests/NewImages/e20.png":CompletedThings[0]),width: currentlevel>=20?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 3,),
                        Row(
                          children: [
                            Padding(
                              padding:  EdgeInsets.only(left:currentlevel>=19? 40:150),
                              child: Image(image: AssetImage((currentlevel>=19?"lib/assests/NewImages/e19.png":CompletedThings[0])),width: currentlevel>=19?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 5,),
                     Row(
                          children: [
                            Padding(
                              padding:  EdgeInsets.only(left: currentlevel>=18?MediaQuery.of(context).size.width*0.42:MediaQuery.of(context).size.width*0.45),
                              child: Image(image: AssetImage(currentlevel>=18?"lib/assests/NewImages/e18.png":CompletedThings[0]),width: currentlevel>=18?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 20,),
                        Row(
                          children: [

                            Padding(
                              padding: EdgeInsets.only(left: currentlevel>=17?MediaQuery.of(context).size.width*0.30:MediaQuery.of(context).size.width*0.30),
                              child: Image(image: AssetImage(currentlevel>=17?"lib/assests/NewImages/p17.png":CompletedThings[0]),width: currentlevel>=17?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 20,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: currentlevel>=16?MediaQuery.of(context).size.width*0.325:MediaQuery.of(context).size.width*0.55),
                              child: Image(image: AssetImage(currentlevel>=16?"lib/assests/NewImages/p16.png":CompletedThings[0]),width: currentlevel>=16?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 50,),
                        Row(
                          children: [

                            Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.240),
                              child: Image(image: AssetImage(currentlevel>=15?"lib/assests/NewImages/e15.png":CompletedThings[0]),width: currentlevel>=15?180:80,),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.46),
                              child: Image(image: AssetImage(currentlevel>=14?"lib/assests/NewImages/e14.png":CompletedThings[0]),width: currentlevel>=14?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 25,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: currentlevel>=13?MediaQuery.of(context).size.width*0.4:MediaQuery.of(context).size.width*0.65),
                              child: Image(image: AssetImage(currentlevel>=13?"lib/assests/NewImages/e13.png":CompletedThings[0]),width: currentlevel>=14?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 25,),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: currentlevel>=12?MediaQuery.of(context).size.width*0.10:MediaQuery.of(context).size.width*0.45),
                              child: Image(image: AssetImage(currentlevel>=12?"lib/assests/NewImages/e12.png":CompletedThings[0]),width: currentlevel>=12?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 35,),
                       Row(
                         children: [
                            Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.24),
                              child: Image(image: AssetImage( currentlevel>=11?"lib/assests/NewImages/e11.png":CompletedThings[0]),width:  currentlevel>=11?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 15,),
                        Row(
                         children: [
                            Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.35),
                              child: Image(image: AssetImage(currentlevel>=10?"lib/assests/NewImages/e10.png":CompletedThings[0]),width: currentlevel>=10?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 15,),
                        Row(
                         children: [
                            Padding(
                              padding: EdgeInsets.only(left: currentlevel>=9?MediaQuery.of(context).size.width*0.33:MediaQuery.of(context).size.width*0.60),
                              child: Image(image: AssetImage(currentlevel>=9?"lib/assests/NewImages/e9.png":CompletedThings[0]),width: currentlevel>=9?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 20,),
                         Row(
                         children: [
                            Padding(
                              padding: EdgeInsets.only(left: currentlevel>=8?MediaQuery.of(context).size.width*0.25:MediaQuery.of(context).size.width*0.45),
                              child: Image(image: AssetImage(currentlevel>=8?"lib/assests/NewImages/e8.png":CompletedThings[0]),width: currentlevel>=8?180:80,),
                            )
                          ],
                        ),
                            SizedBox(height: 30,),
                            Row(
                         children: [
                            Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.22),
                              child: Image(image: AssetImage(currentlevel>=7?"lib/assests/NewImages/e7.png":CompletedThings[0]),width: currentlevel>=7?180:95,),
                            )
                          ],
                        ),
                        SizedBox(height: 10,),
                           Row(
                         children: [
                            Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.42),
                              child: Image(image: AssetImage(currentlevel>=6?"lib/assests/NewImages/e6.png":CompletedThings[0]),width: currentlevel>=6?180:100,),
                            )
                          ],
                        ),
                             SizedBox(height: 10,),
                             Row(
                         children: [
                              Padding(
                              padding: EdgeInsets.only(left: currentlevel>=5?MediaQuery.of(context).size.width*0.55:MediaQuery.of(context).size.width*0.58),
                              child: Image(image: AssetImage(currentlevel>=5?"lib/assests/NewImages/e2.png":CompletedThings[0]),width: currentlevel>=5?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 25,),
                        Row(
                         children: [
                              Padding(
                              padding: EdgeInsets.only(left: currentlevel>=4?MediaQuery.of(context).size.width*0.125:MediaQuery.of(context).size.width*0.3),
                              child: Image(image: AssetImage(currentlevel>=4?"lib/assests/NewImages/e4.png":CompletedThings[0]),width: currentlevel>=4?180:100,),
                            )
                          ],
                        ),
                        SizedBox(height: 25,),
                       Row(
                         children: [
                              Padding(
                              padding: EdgeInsets.only(left: currentlevel>=3?MediaQuery.of(context).size.width*0.3:MediaQuery.of(context).size.width*0.30),
                              child: Image(image: AssetImage(currentlevel>=3?"lib/assests/NewImages/e3.png":CompletedThings[0]),width: currentlevel>=3?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 105,),
                        Row(
                         children: [
                              Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.5),
                              child: Image(image: AssetImage(currentlevel>=2?"lib/assests/NewImages/e2.png":CompletedThings[0]),width: currentlevel>=2?180:80,),
                            )
                          ],
                        ),
                        SizedBox(height: 85,),

                        Row(
                         children: [
                              Padding(
                              padding: EdgeInsets.only(left:currentlevel>=1? MediaQuery.of(context).size.width*0.2:MediaQuery.of(context).size.width*0.45),
                              child: Image(image: AssetImage(currentlevel>=1?"lib/assests/NewImages/e1.png":CompletedThings[0]),width: currentlevel>=1?180:80,),
                            )
                          ],
                        ),

                      ],
                    ),
                  ),
                  // Visibility(
                  //   visible: currentOption==2,
                  //   child:
                  //   Column(
                  //     children: [
                  //
                  //       Row(
                  //         children: [
                  //           Padding(
                  //             padding:  EdgeInsets.only(left: currentlevel>=20?MediaQuery.of(context).size.width*0.2:MediaQuery.of(context).size.width*0.22),
                  //             child: Image(image: AssetImage(currentlevel>=20?"lib/assests/NewImages/p20.png":CompletedThings[0]),width: currentlevel>=20?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 3,),
                  //       Row(
                  //         children: [
                  //           Padding(
                  //             padding:  EdgeInsets.only(left:currentlevel>=19? 40:150),
                  //             child: Image(image: AssetImage((currentlevel>=19?"lib/assests/NewImages/p19.png":CompletedThings[0])),width: currentlevel>=19?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 5,),
                  //    Row(
                  //         children: [
                  //           Padding(
                  //             padding:  EdgeInsets.only(left: currentlevel>=18?MediaQuery.of(context).size.width*0.42:MediaQuery.of(context).size.width*0.45),
                  //             child: Image(image: AssetImage(currentlevel>=18?"lib/assests/NewImages/p18.png":CompletedThings[0]),width: currentlevel>=18?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 20,),
                  //       Row(
                  //         children: [
                  //
                  //           Padding(
                  //             padding: EdgeInsets.only(left: currentlevel>=17?MediaQuery.of(context).size.width*0.30:MediaQuery.of(context).size.width*0.30),
                  //             child: Image(image: AssetImage(currentlevel>=17?"lib/assests/NewImages/p17.png":CompletedThings[0]),width: currentlevel>=17?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 20,),
                  //       Row(
                  //         children: [
                  //           Padding(
                  //             padding: EdgeInsets.only(left: currentlevel>=16?MediaQuery.of(context).size.width*0.325:MediaQuery.of(context).size.width*0.55),
                  //             child: Image(image: AssetImage(currentlevel>=16?"lib/assests/NewImages/p16.png":CompletedThings[0]),width: currentlevel>=16?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 50,),
                  //       Row(
                  //         children: [
                  //
                  //           Padding(
                  //             padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.240),
                  //             child: Image(image: AssetImage(currentlevel>=15?"lib/assests/NewImages/p15.png":CompletedThings[0]),width: currentlevel>=15?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       Row(
                  //         children: [
                  //           Padding(
                  //             padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.46),
                  //             child: Image(image: AssetImage(currentlevel>=14?"lib/assests/NewImages/p14.png":CompletedThings[0]),width: currentlevel>=14?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 25,),
                  //       Row(
                  //         children: [
                  //           Padding(
                  //             padding: EdgeInsets.only(left: currentlevel>=13?MediaQuery.of(context).size.width*0.4:MediaQuery.of(context).size.width*0.65),
                  //             child: Image(image: AssetImage(currentlevel>=13?"lib/assests/NewImages/p13.png":CompletedThings[0]),width: currentlevel>=14?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 25,),
                  //       Row(
                  //         children: [
                  //           Padding(
                  //             padding: EdgeInsets.only(left: currentlevel>=12?MediaQuery.of(context).size.width*0.10:MediaQuery.of(context).size.width*0.45),
                  //             child: Image(image: AssetImage(currentlevel>=12?"lib/assests/NewImages/p12.png":CompletedThings[0]),width: currentlevel>=12?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 35,),
                  //      Row(
                  //        children: [
                  //           Padding(
                  //             padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.24),
                  //             child: Image(image: AssetImage( currentlevel>=11?"lib/assests/NewImages/p11.png":CompletedThings[0]),width:  currentlevel>=11?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 15,),
                  //       Row(
                  //        children: [
                  //           Padding(
                  //             padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.40),
                  //             child: Image(image: AssetImage(currentlevel>=10?"lib/assests/NewImages/p10.png":CompletedThings[0]),width: currentlevel>=10?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 15,),
                  //       Row(
                  //        children: [
                  //           Padding(
                  //             padding: EdgeInsets.only(left: currentlevel>=9?MediaQuery.of(context).size.width*0.33:MediaQuery.of(context).size.width*0.60),
                  //             child: Image(image: AssetImage(currentlevel>=9?"lib/assests/NewImages/p9.png":CompletedThings[0]),width: currentlevel>=9?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 20,),
                  //        Row(
                  //        children: [
                  //           Padding(
                  //             padding: EdgeInsets.only(left: currentlevel>=8?MediaQuery.of(context).size.width*0.11:MediaQuery.of(context).size.width*0.45),
                  //             child: Image(image: AssetImage(currentlevel>=8?"lib/assests/NewImages/p8.png":CompletedThings[0]),width: currentlevel>=8?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //           SizedBox(height: 30,),
                  //           Row(
                  //        children: [
                  //           Padding(
                  //             padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.22),
                  //             child: Image(image: AssetImage(currentlevel>=7?"lib/assests/NewImages/p7.png":CompletedThings[0]),width: currentlevel>=7?180:95,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 10,),
                  //          Row(
                  //        children: [
                  //           Padding(
                  //             padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.42),
                  //             child: Image(image: AssetImage(currentlevel>=6?"lib/assests/NewImages/p6.png":CompletedThings[0]),width: currentlevel>=6?180:100,),
                  //           )
                  //         ],
                  //       ),
                  //            SizedBox(height: 20,),
                  //            Row(
                  //        children: [
                  //             Padding(
                  //             padding: EdgeInsets.only(left: currentlevel>=5?MediaQuery.of(context).size.width*0.35:MediaQuery.of(context).size.width*0.58),
                  //             child: Image(image: AssetImage(currentlevel>=5?"lib/assests/NewImages/p5.png":CompletedThings[0]),width: currentlevel>=5?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 15,),
                  //       Row(
                  //        children: [
                  //             Padding(
                  //             padding: EdgeInsets.only(left: currentlevel>=4?MediaQuery.of(context).size.width*0.16:MediaQuery.of(context).size.width*0.3),
                  //             child: Image(image: AssetImage(currentlevel>=4?"lib/assests/NewImages/p4.png":CompletedThings[0]),width: currentlevel>=4?180:100,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 25,),
                  //      Row(
                  //        children: [
                  //             Padding(
                  //             padding: EdgeInsets.only(left: currentlevel>=3?MediaQuery.of(context).size.width*0.25:MediaQuery.of(context).size.width*0.30),
                  //             child: Image(image: AssetImage(currentlevel>=3?"lib/assests/NewImages/p3.png":CompletedThings[0]),width: currentlevel>=3?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 105,),
                  //       Row(
                  //        children: [
                  //             Padding(
                  //             padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.5),
                  //             child: Image(image: AssetImage(currentlevel>=2?"lib/assests/NewImages/p2.png":CompletedThings[0]),width: currentlevel>=2?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(height: 85,),
                  //
                  //       Row(
                  //        children: [
                  //             Padding(
                  //             padding: EdgeInsets.only(left:currentlevel>=1? MediaQuery.of(context).size.width*0.2:MediaQuery.of(context).size.width*0.45),
                  //             child: Image(image: AssetImage(currentlevel>=1?"lib/assests/NewImages/p1.png":CompletedThings[0]),width: currentlevel>=1?180:80,),
                  //           )
                  //         ],
                  //       ),
                  //
                  //     ],
                  //   ),
                  // ),
                 ]
                ),
                SizedBox(height: 100,),
              ],
            ),
          ),
        ));
  }
}
