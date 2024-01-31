import 'package:get/get.dart';

class HomeControllwe extends GetxController{
  Rx<DateTime> selectedDate = DateTime.now().obs;

  // Function to update the selected date
  void updateSelectedDate(DateTime newDate) {
    selectedDate.value = newDate;
  }
}