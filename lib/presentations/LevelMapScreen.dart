// import 'dart:math';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:level_map/level_map.dart';
//
// class LevelMapScreen extends StatefulWidget {
//   const LevelMapScreen({super.key});
//
//   @override
//   State<LevelMapScreen> createState() => _LevelMapScreenState();
// }
//
// class _LevelMapScreenState extends State<LevelMapScreen> {
//   List<String> completedLevelImages = [
//     "lib/assests/NewImages/p1.png",
//     "lib/assests/NewImages/p2.png",
//     "lib/assests/NewImages/p3.png",
//     "lib/assests/NewImages/p4.png",
//     "lib/assests/NewImages/p5.png",
//     "lib/assests/NewImages/p6.png",
//     "lib/assests/NewImages/p7.png",
//     "lib/assests/NewImages/p8.png",
//     "lib/assests/NewImages/p9.png",
//     "lib/assests/NewImages/p10.png",
//     "lib/assests/NewImages/p11.png",
//     "lib/assests/NewImages/p12.png",
//     "lib/assests/NewImages/p13.png",
//     "lib/assests/NewImages/p14.png",
//     "lib/assests/NewImages/p15.png",
//     "lib/assests/NewImages/p16.png",
//     "lib/assests/NewImages/p17.png",
//     "lib/assests/NewImages/p18.png",
//     "lib/assests/NewImages/p19.png",
//     "lib/assests/NewImages/p20.png",
//     "lib/assests/NewImages/p21.png",
//     // Add paths for other levels
//   ];
//
//   int currentLevel = 1;
//
//   void increaseLevel() {
//     setState(() {
//       // Update the current level
//       currentLevel = min(20, currentLevel + 1); // You can set a maximum level if needed
//     });
//   }
//   @override
//   Widget build(BuildContext context) {// Set the initial value or get it from somewhere
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         LevelMap(
//           key: UniqueKey(),
//           backgroundColor: Colors.transparent,
//           levelMapParams: LevelMapParams(
//             minReferencePositionOffsetFactor: Offset(1,0.2),
//           maxVariationFactor: 5,
//             levelCount: 20,
//             currentLevel: double.parse(currentLevel.toString()),
//             pathColor: Colors.white,
//             currentLevelImage: ImageParams(
//               path: "lib/assests/NewImages/Dummy1.png",
//               size: Size(40,47),
//             ),
//             lockedLevelImage: ImageParams(
//               path: "lib/assests/NewImages/Lockeditem.png",
//               size: Size(100,50),
//             ),
//             completedLevelImage: [
//               ImageParams(
//               path: completedLevelImages[min(19, currentLevel - 1)],
//               size: Size(150,150),
//             ),]
//           ),
//         ),
//         ElevatedButton(
//           onPressed: increaseLevel,
//           child: Text('Increase Level'),
//         ),
//       ],
//     );
//   }
// }
