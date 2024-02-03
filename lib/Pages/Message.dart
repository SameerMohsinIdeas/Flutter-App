// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gulahmedshop/WebView/customwebview.dart';

class Message extends StatefulWidget {
  Message({super.key});

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> with TickerProviderStateMixin {
  //define payload
  Map payload = {};
  @override
  Widget build(BuildContext context) {
    //get data from route
    final data = ModalRoute.of(context)!.settings.arguments;
    //if it is a remote msg
    if (data is RemoteMessage) {
      payload = data.data;
      print("=>payload: $payload");
    }
    //if notification response
    if (data is NotificationResponse) {
      payload = jsonDecode(data.payload!);
      print("=>payloadNotificationResponse: $payload");
    }
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CustomWebView(url: payload["url"].toString()),
    );
  }
}
