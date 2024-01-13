class StepData{
  late final String formattedDate;
  late final String formattedTime;
  late final int steps;
  late final int stepsTarget;

  StepData({
    required this.formattedDate,
    required this.formattedTime,
    required this.steps,
    required this.stepsTarget,
  });
  Map<String, dynamic> toMap() {
    return {
      'formattedDate': formattedDate,
      'formattedTime': formattedTime,
      'steps': steps,
      'stepsTarget': stepsTarget,
    };
  }
}