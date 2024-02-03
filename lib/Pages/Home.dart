// ignore_for_file: prefer_const_constructors, must_be_immutable

import 'package:flutter/material.dart';
import 'package:gulahmedshop/WebView/customwebview.dart';

//production url
String _baseUrlProduction = "https://gulahmedshop.com/";
//staging url
String _baseUrlStaging = "https://mcstaging.gulahmedshop.com/";
//method to get the url based on the option
getUrl(int i) {
  //var for url
  final url;
  if (i == 1) {
    //if 1 then production url
    url = _baseUrlProduction.toString();
    return url;
  } else if (i == 2) {
    //if 2 then staging url
    url = _baseUrlStaging.toString();
    return url;
  }
}

class Home extends StatefulWidget {
  int option;
  // Home({super.key});
  Home({required this.option});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CustomWebView(url: getUrl(widget.option)),
    );
  }
}
