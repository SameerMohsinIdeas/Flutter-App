// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:gulahmedshop/Pages/SplashScreen.dart';
import 'package:gulahmedshop/example.dart';
import 'package:gulahmedshop/firebase/Notification/firebase_init.dart';
import 'package:gulahmedshop/Pages/Home.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Pages/Message.dart';

//navaigation key
final navigatorKey = GlobalKey<NavigatorState>();

//function to handle permission and initialization
Future PermissionInit() async {
  await WidgetsFlutterBinding.ensureInitialized();

  //check platform and assign debug mode
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  //permission for camera and storage
  await Permission.camera.request();
  await Permission.storage.request();
  await Permission.location.request();

  //firebase permissions & initializtion
  await FirebaseInit.firebaseInitAndState(navigatorKey);
}

Future main() async {
  //all the permission handling
  await PermissionInit();

  //run application
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    //type 1 for production, 2 for staging
    int option = 1;
    option == 1 ? log("=>production", time: DateTime.now()) : log("=>staging", time: DateTime.now());
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/home': (context) => Home(
              option: option,
            ),
        '/message': (context) => NotificationMessage(),
        '/splash': (context) => SplashScreen(),
        '/example': (context) => ExampleClass()
      },
    );
  }
}
