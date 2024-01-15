// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'dart:ui';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // _controller = AnimationController(
    //   duration:
    //       const Duration(seconds: 3), // Adjust the duration of the rotation
    //   vsync: this,
    // )..repeat(); // Repeats the animation

    // Simulate a delay for the splash screen
    // Timer(Duration(seconds: 5), () {
    //   // Navigate to the main screen after the delay
    //   Navigator.of(context).pushReplacement(
    //     MaterialPageRoute(
    //       builder: (BuildContext context) => InAppWebViewScreen(),
    //     ),
    //   );
    // });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller to free up resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100], // Customize the background color
      body: Center(
        child: Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.grey.withOpacity(0.5),
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Image.asset(
                  "assets/loader.gif",
                  scale: 1.7,
                ))),
      ),
    );
  }
}
