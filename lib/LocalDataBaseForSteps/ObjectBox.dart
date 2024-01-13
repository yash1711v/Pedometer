import 'package:intl/intl.dart';
import 'package:objectbox/objectbox.dart';

import '../objectbox.g.dart';
import 'Model.dart';

class ObjectBoxClass {
  static late final Store _store;
  static bool _initialized = false;

  // Private constructor to prevent instantiation
  ObjectBoxClass._();

  // Singleton instance
  static final ObjectBoxClass _instance = ObjectBoxClass._();

  // Getter for the instance
  static ObjectBoxClass get instance => _instance;

  // Getter for the store
  Store get store {
    if (!_initialized) {
      throw Exception("ObjectBox store not initialized. Call init() first.");
    }
    return _store;
  }

  // Initialization method
  Future<void> init() async {
    _store = await openStore();
    _initialized = true;
  }

  // Check if ObjectBox store is initialized
  bool get isInitialized => _initialized;


  Future<void> storeSteps(int steps) async {
    // Get current date and time
    final now = DateTime.now();
    final year = now.year;
    final month = now.month.toString().padLeft(2, '0');
    final date = now.day.toString().padLeft(2, '0');
    final currentHour = now.hour;

    // Fetch existing steps data for the current date
    final box = _store.box<StepsEntity>();
    final existingStepsEntities = box.query(

        StepsEntity_.year.equals(year) &
        StepsEntity_.month.equals(month)  &
        StepsEntity_.date.equals(date),

    ).build().find();

    // Calculate total steps before the current hour
    int totalBeforeSteps = 0;
    for (final stepsEntity in existingStepsEntities) {
      final hour = int.parse(stepsEntity.hour);
      if (hour < currentHour) {
        totalBeforeSteps += stepsEntity.steps;
      }
    }

    // Subtract totalBeforeSteps from the given steps
    final stepsToStore = steps - totalBeforeSteps;

    // Store steps for each hour
    for (int hour = 0; hour <= currentHour; hour++) {
      final existingEntity = existingStepsEntities.firstWhere(
            (entity) => entity.hour == hour.toString().padLeft(2, '0'),
        orElse: () => StepsEntity(
          year: year,
          month: month,
          date: date,
          hour: hour.toString().padLeft(2, '0'),
          steps: 0,
        ),
      );

      existingEntity.steps = (hour == currentHour) ? stepsToStore : 0;

      box.put(existingEntity);
    }
  }



   Future<Map<String, dynamic>> getStepsData() async {
    final Map<String, dynamic> stepsData = {};

    final box = _store.box<StepsEntity>();
    final allStepsEntities = box.getAll();

    for (final stepsEntity in allStepsEntities) {
      final year = stepsEntity.year.toString();
      final month = stepsEntity.month;
      final date = stepsEntity.date;
      final hour = _formatHour(stepsEntity.hour);
      final steps = stepsEntity.steps;

      stepsData.putIfAbsent(year, () => {});
      stepsData[year].putIfAbsent(month, () => {});
      stepsData[year][month].putIfAbsent(date, () => {});
      stepsData[year][month][date].putIfAbsent(hour, () => steps);

      // Calculate TotalSteps for each day
      final dailyTotalSteps = stepsData[year][month][date].values.reduce((sum, steps) => sum + steps);
      stepsData[year][month][date]['TotalSteps'] = dailyTotalSteps;
    }

    // Calculate TotalMonthlySteps for each month
    for (final year in stepsData.keys) {
      for (final month in stepsData[year].keys) {
        final monthlyTotalSteps = stepsData[year][month].values
            .map((dayData) => dayData['TotalSteps'] as int)
            .reduce((sum, dailyTotalSteps) => sum + dailyTotalSteps);
        stepsData[year][month]['TotalMonthlySteps'] = monthlyTotalSteps;
      }
    }

    // Calculate TotalYearlySteps
    for (final year in stepsData.keys) {
      final yearlyTotalSteps = stepsData[year].values
          .map((monthData) => monthData['TotalMonthlySteps'] as int)
          .reduce((sum, monthlyTotalSteps) => sum + monthlyTotalSteps);
      stepsData[year]['TotalYearlySteps'] = yearlyTotalSteps;
    }

    return stepsData;
  }

  static String _formatHour(String hour) {
    final int hourValue = int.parse(hour);
    final String amPm = (hourValue < 12) ? 'AM' : 'PM';
    final int formattedHourValue = (hourValue % 12 == 0) ? 12 : hourValue % 12;
    return '$formattedHourValue $amPm';
  }

  Future<void> closeStore() async {
    if (_initialized) {
      _store.close();
      _initialized = false;
    }
  }



}
