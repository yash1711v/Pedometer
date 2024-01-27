import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomSliderItem extends StatelessWidget {
  final Color color;

  CustomSliderItem({ required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
    mainAxisAlignment: MainAxisAlignment.center,
      children: [
         Padding(padding: EdgeInsets.only(bottom: 28),
         child: Icon(Icons.arrow_drop_down_rounded,size: 40,color: color,)), // Adjust the spacing between the line and text
      ],
    );
  }
}
