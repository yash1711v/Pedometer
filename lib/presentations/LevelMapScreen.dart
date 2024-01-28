import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:level_map/level_map.dart';

class LevelMapScreen extends StatefulWidget {
  const LevelMapScreen({super.key});

  @override
  State<LevelMapScreen> createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends State<LevelMapScreen> {
  @override
  Widget build(BuildContext context) {
    return LevelMap(
      key: UniqueKey(),
      backgroundColor: Colors.transparent,
      levelMapParams: LevelMapParams(
        levelCount: 20,
        currentLevel: 3.5,
        pathColor: Colors.white,
        currentLevelImage: ImageParams(
          path: "lib/assests/NewImages/Dummy1.png",
          size: Size(40,47),
        ),
        lockedLevelImage: ImageParams(
          path: "lib/assests/NewImages/Dummy3.png",
          size: Size(40,47),
        ),
        completedLevelImage: ImageParams(
          path: "lib/assests/NewImages/Dummy2.png",
          size: Size(40,47),
        ),
      ),
    );;
  }
}
