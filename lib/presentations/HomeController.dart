import 'package:get/get.dart';

class HomeControllwe extends GetxController{
  Rx<DateTime> selectedDate = DateTime.now().obs;
 Rx<int> StepsTarget=6000.obs;
  // Function to update the selected date
  void updateSelectedDate(DateTime newDate) {
    selectedDate.value = newDate;
  }
  void updateStepsTarget(int stepsTarget) {
    StepsTarget.value = stepsTarget;
  }

}