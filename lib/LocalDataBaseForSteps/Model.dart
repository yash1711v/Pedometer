import 'package:objectbox/objectbox.dart';

@Entity()
class StepsEntity {
  int id;

  int year;
  String month;
  String date;
  String hour;
  int steps;

  StepsEntity({
    this.id = 0,
    required this.year,
    required this.month,
    required this.date,
    required this.hour,
    required this.steps,
  });
}
