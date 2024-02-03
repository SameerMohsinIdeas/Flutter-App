import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gulahmedshop/firebase/Notification/Notification.dart';
import 'package:gulahmedshop/firebase/firebase_options.dart';

class FirebaseInit {
  //function to initailze and listen to changes
  static Future firebaseInitAndState(navigatorKey) async {
    //firebase init
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // on background notification tapped
    _firebaseBackgroundTap(navigatorKey);

    //Push Notification initialization
    PushNotification.init();
    PushNotification.localNotiInit();

    // Listen to background notifications
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

    // to handle foreground notifications
    _firebaseForegroundNotification();

    // for handling in terminated state
    _firebaseTerminationState(navigatorKey);
  }

  //function to listen to background changes
  static Future _firebaseBackgroundMessage(RemoteMessage message) async {
    final msg = await message;
    print("=>in firebaseBackground func");
    if (msg.notification != null) {
      print("=>New notification");
    }
    if (await msg.data.isNotEmpty) {
      print("=>data: " + msg.data["url"].toString());
    }
  }

  //function to listen to background tap
  static Future _firebaseBackgroundTap(navigatorKey) async {
    // on background notification tapped
    await FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.notification != null) {
        print("Background Notification Tapped");
        navigatorKey.currentState!.pushNamed("/message", arguments: message);
      }
    });
  }

  //function to listen to foreground notification
  static Future _firebaseForegroundNotification() async {
    await FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String payloadData = jsonEncode(message.data);
      print("=>Got a message in foreground");
      print("=>payloadData: " + payloadData.toString());
      if (message.notification != null) {
        PushNotification.showSimpleNotification(
            title: message.notification!.title!,
            body: message.notification!.body!,
            payload: payloadData);
      }
    });
  }

  //function to listen to firebase at termination state
  static Future _firebaseTerminationState(navigatorKey) async {
    // for handling in terminated state
    final RemoteMessage? message =
        await FirebaseMessaging.instance.getInitialMessage();

    if (message != null) {
      print("Launched from terminated state");
      Future.delayed(Duration(seconds: 1), () {
        navigatorKey.currentState!.pushNamed("/message", arguments: message);
      });
    }
  }
}
