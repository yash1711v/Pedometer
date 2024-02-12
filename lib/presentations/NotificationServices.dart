import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';






class NotificationServices{
static final  _flutterLocalNotificationsPlugin=FlutterLocalNotificationsPlugin();
// static final onNotifications = BehaviorSubject<String?>();
final AndroidInitializationSettings _androidInitializationSettings = AndroidInitializationSettings("small_logo");


NotificationDetails platformChannelSpecifics =
const NotificationDetails(android: AndroidNotificationDetails(
  'Step Tracking',
  'Step Tracker',
  color: Colors.black,
  enableLights: true,
  enableVibration: true,
  playSound: true,
  icon: 'small_logo',
  colorized: true,
  largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
  channelDescription: "This is Notification is to give  you alert to start and check your daily steps ",
  importance: Importance.max,
) );
void initializeNotification() async {
  // _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

  InitializationSettings initializationSettings=InitializationSettings(
    android: _androidInitializationSettings
  );
  await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
  // onDidReceiveNotificationResponse: (playload) async{
  //       onNotifications.add(playload.payload);
  // }
  );
  tz.initializeTimeZones();
  final String timeZoneName = 'Asia/Kolkata';
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
 }
Future scheduleNotifications() async {
    // Cancel existing notifications to prevent duplicates
    await _flutterLocalNotificationsPlugin.cancelAll();
    print("HElooooo");
    // Schedule morning notification at 8 AM
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      12000,
      'Morning walk reminder',
      'Good morning! Start your day with a refreshing walk and boost your energy.',
      _nextInstanceOf8AM(),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    ).then((value) => print("Scheduled notification for 8 Am"));

    // Schedule evening notification at 8 PM
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      2000000,
      'Daily goal check',
      'Have you reached your daily step goal? A little more effort can make it happen!',
      _nextInstanceOf8PM(),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    ).then((value) => print("Scheduled notification for 8 Pm"));
  }

  Future<void> showStepGoalNotification() async {


    await _flutterLocalNotificationsPlugin.show(
      0, // A unique ID for the notification
      'Step Goal Completed',
      'Voila! You have achieved your today’s goal of 6000 steps.',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  tz.TZDateTime _nextInstanceOf8AM() {
  print("in nextInstance");
    const String timeZoneName = 'Asia/Kolkata';
    final tz.Location local = tz.getLocation('Asia/Kolkata');
    final  now = tz.TZDateTime.now(tz.local);
    print("now hours: -------------->"+now.hour.toString());
    print("local time:"+tz.local.toString());
 final scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 8);
    // if (scheduledDate.isBefore(now)) {
    //   scheduledDate = scheduledDate.add(const Duration(days: 1));
    // }
  print("Schedule------------------------------------------------------------>");
  print(scheduledDate.isBefore(now)?scheduledDate.add(const Duration(days: 1)):scheduledDate);
    return scheduledDate.isBefore(now)?scheduledDate.add(const Duration(days: 1)):scheduledDate;
  }

  tz.TZDateTime _nextInstanceOf8PM() {
    print("in nextInstance");
    // const String timeZoneName = 'Asia/Kolkata';
    // final tz.Location local = tz.getLocation('Asia/Kolkata');
    final  now = tz.TZDateTime.now(tz.local);
    print("now hours: -------------->"+now.hour.toString());
    print("local time:"+tz.local.toString());
    final scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20);
    // if (scheduledDate.isBefore(now)) {
    //   scheduledDate = scheduledDate.add(const Duration(days: 1));
    // }
    print("Schedule------------------------------------------------------------>");
    print(scheduledDate.isBefore(now)?scheduledDate.add(const Duration(days: 1)):scheduledDate);
    return scheduledDate.isBefore(now)?scheduledDate.add(const Duration(days: 1)):scheduledDate;
  }
}



// import 'dart:math';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart';
//
// class NotificationService {
//   final FlutterLocalNotificationsPlugin notificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   Future<void> initNotification() async {
//     AndroidInitializationSettings initializationSettingsAndroid =
//     const AndroidInitializationSettings('small_logo');
//
//     var initializationSettingsIOS = DarwinInitializationSettings(
//         requestAlertPermission: true,
//         requestBadgePermission: true,
//         requestSoundPermission: true,
//         onDidReceiveLocalNotification:
//             (int id, String? title, String? body, String? payload) async {});
//
//     var initializationSettings = InitializationSettings(
//         android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
//     await notificationsPlugin.initialize(initializationSettings,
//         onDidReceiveNotificationResponse:
//             (NotificationResponse notificationResponse) async {});
//     tz.initializeTimeZones();
//   }
//
//   notificationDetails() {
//     return const NotificationDetails(
//         android: AndroidNotificationDetails('channelId', 'channelName',
//             importance: Importance.max),
//         iOS: DarwinNotificationDetails());
//   }
//
//   Future showNotification(
//       {int id = 0, String? title, String? body, String? payLoad}) async {
//     return notificationsPlugin.show(
//         id, title, body, await notificationDetails());
//   }
//
//   // Map<String, dynamic> getNextScheduledNotificationInfo() {
//   //   final nextScheduledTime = getNextScheduledTime();
//   //   final message = getNextScheduledMessage();
//   //   final formattedTime =
//   //       nextScheduledTime.toString(); // You can format the time as needed.
//
//   //   return {
//   //     'time': formattedTime,
//   //     'message': message,
//   //   };
//   // }
//
//   Future scheduleNotification(
//       {int id = 0,
//         String? title,
//         String? body,
//         String? payLoad,
//         required DateTime scheduledNotificationDateTime}) async {
//     return notificationsPlugin.zonedSchedule(
//         id,
//         title,
//         body,
//         tz.TZDateTime.from(
//           scheduledNotificationDateTime,
//           tz.getLocation('Asia/Kolkata'),
//         ),
//         await notificationDetails(),
//         androidAllowWhileIdle: true,
//         uiLocalNotificationDateInterpretation:
//         UILocalNotificationDateInterpretation.absoluteTime);
//   }
//
//   void scheduleRecurringNotifications() {
//     final now = tz.TZDateTime.now(getLocation('Asia/Kolkata'));
//     // print(now);
//
//     tz.TZDateTime next8AM = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       8,
//       0,
//     );
//
//     tz.TZDateTime next6PM = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       18,
//       0,
//     );
//
//     // while (next8AM.isBefore(now)) {
//     //   next8AM = next8AM.add(const Duration(days: 1));
//     // }
//     final desiredTimeZone = tz.getLocation('Asia/Kolkata');
//     final nowFormatted = tz.TZDateTime.from(now, desiredTimeZone);
//     if (kDebugMode) {
//       print(nowFormatted);
//     }
//
//     if (kDebugMode) {
//       print("next6pm: $next6PM");
//     }
//     if (kDebugMode) {
//       print("next8AM: $next8AM");
//     }
//
//     bool condition = nowFormatted.isAfter(next6PM);
//     // print(condition);
//
//     bool condition2 = nowFormatted.isAfter(next8AM);
//
//     // print(condition2);
//
//     // final next8AMInKolkata = tz.TZDateTime.from(next8AM, desiredTimeZone);
//     // print('nowFormatted: $nowFormatted');
//     // print('next8AMInKolkata: $next8AMInKolkata');
//
//     // bool condition3 = nowFormatted.isAfter(next8AMInKolkata);
//     // print(condition3);
//
//     final next8AMInKolkata = tz.TZDateTime(
//       desiredTimeZone,
//       next8AM.year,
//       next8AM.month,
//       next8AM.day,
//       next8AM.hour,
//       next8AM.minute,
//     );
//
//     final next6PMInKolkata = tz.TZDateTime(
//       desiredTimeZone,
//       next6PM.year,
//       next6PM.month,
//       next6PM.day,
//       next6PM.hour,
//       next6PM.minute,
//     );
//     bool condition3 = nowFormatted.isAfter(next8AMInKolkata);
//     if (kDebugMode) {
//       print(condition3);
//     }
//     bool condition4 = nowFormatted.isAfter(next6PMInKolkata);
//     if (kDebugMode) {
//       print(condition4);
//     }
//
//     if (nowFormatted.isAfter(next6PMInKolkata)) {
//       next6PM = next6PM.add(const Duration(days: 1));
//       if (kDebugMode) {
//         print("next6pm: $next6PM");
//       }
//     } else if (nowFormatted.isAfter(next8AMInKolkata)) {
//       next8AM = next8AM.add(const Duration(days: 1));
//       if (kDebugMode) {
//         print("next8AM: $next8AM");
//       }
//     }
//
// // Schedule both morning and evening notifications.
//     // scheduleDailyNotification(8, 0, next8AM, nowFormatted);
//     // scheduleDailyNotification(18, 0, next6PM, nowFormatted);
//
// // Schedule both morning and evening notifications.
//     scheduleDailyNotification(8, 0, next8AMInKolkata, nowFormatted);
//     scheduleDailyNotification(18, 0, next6PMInKolkata, nowFormatted);
//   }
//
//   void scheduleDailyNotification(
//       int hour, int minute, tz.TZDateTime scheduledTime, TZDateTime now) {
//     // final now = tz.TZDateTime.now(tz.local);
//
//     // Calculate the next scheduled time based on the provided hour and minute.
//     tz.TZDateTime nextScheduledTime = tz.TZDateTime(
//       tz.getLocation('Asia/Kolkata'),
//       now.year,
//       now.month,
//       now.day,
//       hour,
//       minute,
//     );
//
//     // If the calculated nextScheduledTime is before the current time, schedule it for the same time on the next day.
//     if (nextScheduledTime.isBefore(now)) {
//       nextScheduledTime = nextScheduledTime.add(const Duration(days: 1));
//     }
//     if (kDebugMode) {
//       print({"Next scheduled time:$nextScheduledTime"});
//     }
//
//     const android = AndroidNotificationDetails(
//         'recurring_channel_id',
//         'Recurring Channel',
//         importance: Importance.max,
//         priority: Priority.high,
//         channelShowBadge: true,
//         icon: 'small_logo'
//     );
//
//     const platformChannelSpecifics = NotificationDetails(
//       android: android,
//     );
//     if (kDebugMode) {
//       print(getNextScheduledTitle(nextScheduledTime));
//     }
//     if (kDebugMode) {
//       print(getNextScheduledMessage(nextScheduledTime));
//     }
//
//     notificationsPlugin.zonedSchedule(
//       hour * 60 + minute, // Notification ID
//       getNextScheduledTitle(nextScheduledTime),
//       getNextScheduledMessage(
//           nextScheduledTime), // Set the notification body here
//       nextScheduledTime,
//       platformChannelSpecifics,
//       androidScheduleMode: AndroidScheduleMode.exact,
//       uiLocalNotificationDateInterpretation:
//       UILocalNotificationDateInterpretation.absoluteTime,
//       androidAllowWhileIdle: true,
//       matchDateTimeComponents: DateTimeComponents.time,
//       payload: 'customData',
//
//       // androidAllowWhileIdle: true,
//       // uiLocalNotificationDateInterpretation:
//       //     UILocalNotificationDateInterpretation.absoluteTime,
//       // payload: 'customData',
//       // timeZoneName: 'Asia/Kolkata', // Specify the desired timezone here
//     );
//   }
//
//   String getNextScheduledTitle(tz.TZDateTime scheduledTime) {
//     final timeIdentifier = getNextScheduledTimeIdentifier(scheduledTime);
//     return timeIdentifier == '8AM' ? 'Mindful Reminder' : 'Mindful Tip';
//   }
//
//   tz.TZDateTime getNextScheduledTime() {
//     final now = tz.TZDateTime.now(tz.local);
//     tz.TZDateTime next8AM = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       8,
//       0,
//     );
//     tz.TZDateTime next1PM = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       13,
//       0,
//     );
//     tz.TZDateTime next6PM = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       18,
//       0,
//     );
//     final desiredTimeZone = tz.getLocation('Asia/Kolkata');
//     final nowFormatted = tz.TZDateTime.from(now, desiredTimeZone);
//
//     final next8AMInKolkata = tz.TZDateTime(
//       desiredTimeZone,
//       next8AM.year,
//       next8AM.month,
//       next8AM.day,
//       next8AM.hour,
//       next8AM.minute,
//     );
//     final next1PMInKolkata = tz.TZDateTime(
//       desiredTimeZone,
//       next1PM.year,
//       next1PM.month,
//       next1PM.day,
//       next1PM.hour,
//       next1PM.minute,
//     );
//
//     final next6PMInKolkata = tz.TZDateTime(
//       desiredTimeZone,
//       next6PM.year,
//       next6PM.month,
//       next6PM.day,
//       next6PM.hour,
//       next6PM.minute,
//     );
//
//     // If it's already past 6 PM today, schedule for 8 AM tomorrow.
//     if (nowFormatted.isAfter(next6PMInKolkata)) {
//       next8AM = next8AM.add(const Duration(days: 1));
//     }
//
//     // If it's already past 8 AM today, schedule for 6 PM today.
//     if (nowFormatted.isAfter(next8AMInKolkata)) {
//       next6PM = next6PM.add(const Duration(days: 1));
//     }
//
//     // Choose the earlier of the two times.
//     return next8AMInKolkata.isBefore(next6PMInKolkata) ? next8AM : next6PM;
//   }
//
//   String getNextScheduledTimeIdentifier(tz.TZDateTime scheduledTime) {
//     if (scheduledTime.hour == 8) {
//       return '8AM';
//     } else if (scheduledTime.hour == 18) {
//       return '6PM';
//     } else {
//       return '8AM'; // Default to 8 am if it's neither 8 AM nor 6 PM.
//     }
//   }
//
//   List<String> messages8AM = [
//     "Good morning! Begin your day with a peaceful meditation session. Start Now!",
//     "Wake up and meditate: The perfect way to set a positive tone.",
//     "Embrace the serenity of morning meditation. Start now!",
//     "Meditation in the morning can calm your mind for the day ahead. Start now!",
//     "Your day starts with a deep breath and a peaceful mind. Meditate now!",
//     "Welcome the day with mindfulness. Meditate now for a peaceful morning!",
//     "Begin your day with gratitude and a peaceful meditation practice. Start now!",
//     "Morning meditation: A gift to your mind, body, and soul. Start now!",
//     "Start your day fresh and focused with a morning meditation. Start now!",
//     "Set your intention for the day through mindful meditation. Begin Now!",
//     "Meditation: Your daily ritual for clarity and inner peace. Meditate Now!",
//     "Morning meditation boosts productivity and inner harmony. Begin now!",
//     "Awaken your inner calm with a morning meditation session. Start now!",
//     "Find stillness and mindfulness in your morning meditation. Start now!",
//     "Morning meditation: A beautiful way to greet the day. Start now!",
//     "Pause, breathe, meditate: Your morning routine for inner peace. Start now!",
//     "Start your day mindfully with a morning meditation practice.",
//     "Meditation can be the sunrise of your day. Begin now.",
//     "Morning meditation sets the stage for a balanced day. Start now!",
//     "Refresh your mind with a few moments of morning meditation. Begin now!",
//     "Morning meditation: The key to a centered and balanced day. Start now!",
//     "Begin your day with silence and serenity. Meditate now!",
//     "Greet the morning with a calm heart and a clear mind through meditation. Start now!",
//     "Meditate in the morning for a day filled with mindfulness. Begin now!",
//     "Let meditation guide your morning and elevate your day. Start now!",
//     "Start your day with mindfulness. Meditate and find your center. Start now!",
//     "Morning meditation: Fuel for your inner peace and strength. Begin now!",
//     "Morning moments of meditation bring clarity to your day. Start now!",
//     "Begin your day the mindful way: with morning meditation.",
//     "Meditation is the sunrise of inner calm. Embrace it each morning."
//   ];
//
//   List<String> messages6PM = [
//     "Take a mindful walk outside and connect with nature.",
//     "Unplug from screens for an hour and focus on real-world experiences.",
//     "Write down three things you're grateful for today.",
//     "Set boundaries and say 'no' when needed without feeling guilty.",
//     "Indulge in your favorite healthy snack mindfully.",
//     "Engage in a creative activity that brings you joy.",
//     "Prioritize a good night's sleep for rejuvenation.",
//     "Practice deep breathing exercises whenever you feel stressed.",
//     "Make time for a relaxing bath to unwind.",
//     "Reach out to a friend and have a heart-to-heart conversation.",
//     "Dedicate 10 minutes to stretch and move your body gently.",
//     "Create a calming space at home and declutter a small area.",
//     "Treat yourself to a soothing cup of herbal tea.",
//     "Start a journal to reflect on your thoughts and emotions.",
//     "Try a meditation session focusing on self-love and acceptance.",
//     "Listen to soothing music that resonates with your mood.",
//     "Watch the sunrise or sunset and savor the moment.",
//     "Learn to say positive affirmations to boost your confidence.",
//     "Pamper yourself with a mini DIY spa session.",
//     "Engage in a hobby that allows you to express yourself.",
//     "Disconnect from digital distractions before bedtime.",
//     "Set achievable goals for the day to build a sense of accomplishment.",
//     "Practice mindful eating by savoring each bite of your meals.",
//     "Explore a new book or a podcast that interests you.",
//     "Experiment with aromatherapy to create a peaceful atmosphere.",
//     "Express your feelings through art, writing, or another creative outlet.",
//     "Do a short body scan meditation to connect with your sensations.",
//     "Practice forgiveness, both for others and yourself.",
//     "Make a list of things that make you smile and revisit it often.",
//     "Reflect on your successes, no matter how small, and celebrate them.",
//   ];
//
//   String getNextScheduledMessage(tz.TZDateTime scheduledTime) {
//     final timeIdentifier = getNextScheduledTimeIdentifier(scheduledTime);
//     final List<String> messages =
//     timeIdentifier == '8AM' ? messages8AM : messages6PM;
//     final random = Random();
//     final randomIndex = random.nextInt(messages.length);
//     return messages[randomIndex];
//   }
//
//   Future<void> cancelScheduledNotifications() async {
//     await notificationsPlugin
//         .cancelAll(); // This will cancel all scheduled notifications.
//   }
// }
