import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class GradiantArchProgress extends CustomPainter {
  late final Color startColor;
  late final Color middle;
  late final Color endColor;
  late final  int StepsCompleted;
  late final  int StepsTarget;
  late double width;
    late double progress=0.0;
    late double progress2=0.0;
bool Greater=false;
  GradiantArchProgress(
      {required this.startColor,
      required this.middle,
      required this.endColor,
      required this.StepsCompleted,
      required this.StepsTarget,
      required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    // print("Steps Completed -------> $StepsCompleted");
    // print("Steps Target -------> $StepsTarget");
    if(StepsCompleted>StepsTarget){
      progress=StepsCompleted/StepsTarget;
      progress2=(StepsCompleted-StepsTarget)/StepsTarget;
      Greater=true;
    }else{
      progress=StepsCompleted/StepsTarget;
    }
    // print("Steps Completed---------->"+progress.toString());
    // TODO: implement paint
    final rect = new Rect.fromLTWH(0.0, 0.0, size.width, size.height);
    final gradient=SweepGradient(
        startAngle: 3*math.pi/2,
        endAngle: 7*math.pi/2,
        tileMode: TileMode.repeated,
        colors: [
          startColor,
          endColor,
          startColor,
        ],
    );

    final fullCircle=new Paint()
      ..strokeCap=StrokeCap.round
      ..style=PaintingStyle.stroke
      ..color=Color(0xFF252525)
      ..strokeWidth=width;

    final shadow=new Paint()
      ..strokeCap=StrokeCap.round
      ..style=PaintingStyle.stroke
      ..color=Colors.black
      ..maskFilter=MaskFilter.blur(BlurStyle.normal, 10)
      ..strokeWidth=width-4;

    final paint=new Paint()
      ..strokeCap=StrokeCap.round
      ..shader=gradient.createShader(rect)
      ..style=PaintingStyle.stroke
      ..strokeWidth=width;

    final center=new Offset(size.width/2,size.height/2);
    final radius=math.min(size.width/2,size.height/2)-(width/2);
    final startAngle=-math.pi/2;
    final sweepAngle=2*math.pi*progress;
    final sweepAngle2=2*math.pi*progress2;

    canvas.drawArc(new Rect.fromCircle(center: center, radius: radius), startAngle, 360, false, fullCircle);
    canvas.drawArc(new Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, paint);
    Greater?  canvas.drawArc(new Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle2 + 0.01, false, shadow):null;
    Greater? canvas.drawArc(new Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle2, false, paint):null;

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}