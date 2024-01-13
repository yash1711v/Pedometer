import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../SharedPrefrences/SharedPref.dart';
import 'StepData.dart';

class DatabaseHelper {
  static const String _databaseName = 'steps_database.db';
  static const String _tableName = 'steps';

  Future<Database> initializeDatabase() async {
    final String path = join(await getDatabasesPath(), _databaseName);
    return openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE $_tableName (
          formattedDate TEXT,
          formattedTime TEXT,
          steps INTEGER,
          stepsTarget INTEGER
        )
      ''');
    });
  }

  Future<void> insertStep(int TotalSteps) async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String FormattedTime = DateFormat('hh a').format(now);
    DateTime startTime = DateTime(now.year, now.month, now.day, 0, 0);
    DateTime endTime = now.subtract(Duration(hours: 1));
    int intervalInMinutes = 60;
    int totalStepsForInterval = 0;
    for (DateTime loopTime = startTime; loopTime.isBefore(endTime); loopTime = loopTime.add(Duration(minutes: intervalInMinutes))) {
      // Format the current time in the desired format
      String formattedTime = DateFormat('hh a').format(loopTime);
      int stepsForTime = await getStepsForTime(formattedDate, formattedTime);
      // Accumulate total steps
      totalStepsForInterval += stepsForTime;
    }
     StepData stepData= StepData(formattedDate: formattedDate, formattedTime: FormattedTime, steps: totalStepsForInterval, stepsTarget: await SharedPref().getStepsTarget());
    final Database db = await initializeDatabase();
    await db.insert(_tableName, stepData.toMap()).then((value) async {
      List<StepData> allSteps = await getAllSteps();

      // Print the result in a tabular format
      print('formattedDate | formattedTime | steps | stepsTarget');
      print('--------------------------------------------------');
      for (StepData step in allSteps) {
        print('${step.formattedDate} | ${step.formattedTime} | ${step.steps} | ${step.stepsTarget}');
      }
    });
  }

  Future<int> getStepsForTime(String formattedDate, String formattedTime) async {
    final Database db = await initializeDatabase();
    List<Map<String, dynamic>> result = await db.query(
      _tableName,
      columns: ['steps'],
      where: 'formattedDate = ? AND formattedTime = ?',
      whereArgs: [formattedDate, formattedTime],
    );

    return result.isNotEmpty ? result.first['steps'] : 0;
  }


  Future<List<StepData>> getAllSteps() async {
    final Database db = await initializeDatabase();
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(maps.length, (index) {
      return StepData(
        formattedDate: maps[index]['formattedDate'],
        formattedTime: maps[index]['formattedTime'],
        steps: maps[index]['steps'],
        stepsTarget: maps[index]['stepsTarget'],
      );
    });
  }



}
