// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'SplashScreen.dart';

List<String> linksToOpenInChrome = [
  "mailto:corporate@ideas.com.pk",
  "https://api.whatsapp.com/send/",
  "https://www.facebook.com/GulahmedFashion",
  "https://www.instagram.com/gulahmedfashion/",
  "https://twitter.com/gulahmedfashion?lang=en",
  "https://www.youtube.com/channel/UCsAIxl3qvpy1DofpwDEx6Ow",
  "https://www.tiktok.com/@ideasbygulahmed",
  "https://web.whatsapp.com/send?text=https://www.gulahmedshop.com/",
  "https://m.facebook.com/login",
  "https://twitter.com/intent/tweet",
  "http://pinterest.com/pin/create/button/"
];
//production
String _baseUrlProduction = "https://gulahmedshop.com/";
//staging
String _baseUrlStaging = "https://mcstaging.gulahmedshop.com/";
String url = _baseUrlProduction;
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }
  await Permission.camera.request();
  await Permission.storage.request();
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;

  InAppWebViewSettings settings = InAppWebViewSettings(
      userAgent:
          "Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Mobile Safari/537.36",
      preferredContentMode: UserPreferredContentMode.MOBILE,
      cacheEnabled: true,
      isInspectable: kDebugMode,
      javaScriptCanOpenWindowsAutomatically: true,
      transparentBackground: true,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera;",
      iframeAllowFullscreen: true);

  PullToRefreshController? pullToRefreshController;
  double progress = 0;

  @override
  void initState() {
    super.initState();

    pullToRefreshController = kIsWeb
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(
              color: Colors.green,
            ),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                webViewController?.reload();
              }
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(children: <Widget>[
      Expanded(
        child: Stack(
          children: [
            WillPopScope(
              onWillPop: () async {
                final controller = webViewController;
                if (controller != null) {
                  if (await controller.canGoBack()) {
                    controller.goBack();
                    return false;
                  }
                }
                return true;
              },
              child: InAppWebView(
                key: webViewKey,
                initialUrlRequest: URLRequest(url: WebUri(_baseUrlStaging)),
                initialSettings: settings,
                pullToRefreshController: pullToRefreshController,
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onPermissionRequest: (controller, request) async {
                  return PermissionResponse(
                      resources: request.resources,
                      action: PermissionResponseAction.GRANT);
                },
                shouldOverrideUrlLoading: _shouldOverrideUrlLoading,
                onLoadStart: (controller, url) async {
                  setState(() {
                    SplashScreen();
                  });
                },
                onLoadStop: (controller, url) async {
                  pullToRefreshController?.endRefreshing();
                },
                onReceivedError: (controller, request, error) {
                  pullToRefreshController?.endRefreshing();
                },
                onProgressChanged: (controller, progress) {
                  if (progress == 100) {
                    pullToRefreshController?.endRefreshing();
                  }
                  setState(() {
                    this.progress = progress / 100;
                  });
                },
                onCreateWindow: (controller, createWindowAction) async {
                  // create a headless WebView using the createWindowAction.windowId to get the correct URL
                  HeadlessInAppWebView? headlessWebView;
                  headlessWebView = HeadlessInAppWebView(
                    windowId: createWindowAction.windowId,
                    onLoadStart: (controller, url) async {
                      if (url != null) {
                        launchUrl(url,
                            mode: LaunchMode
                                .externalNonBrowserApplication); // to open with the system browser
                        // or use the https://pub.dev/packages/url_launcher plugin
                      }
                      // dispose it immediately
                      await headlessWebView?.dispose();
                      headlessWebView = null;
                    },
                  );
                  headlessWebView?.run();
                  // return true to tell that we are handling the new window creation action
                  return true;
                },
                onUpdateVisitedHistory: (controller, url, androidIsReload) {
                  print("here is the url: " + url.toString());
                },
                onConsoleMessage: (controller, consoleMessage) {
                  if (kDebugMode) {
                    print(consoleMessage);
                  }
                },
              ),
            ),
            progress < 1.0
                ? Center(
                    child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        color: Colors.grey.withOpacity(0.5),
                        child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                            child: Image.asset(
                              "assets/loader.gif",
                              scale: 1.7,
                            ))),
                  )
                : Container(),
          ],
        ),
      ),
    ])));
  }
}

Future<NavigationActionPolicy> _shouldOverrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction shouldOverrideUrlLoadingRequest) async {
  var uri = shouldOverrideUrlLoadingRequest.request.url;
  if (uri == null) {
    return NavigationActionPolicy.CANCEL;
  }

  final uriString = uri.toString();
  print("sameer");
  for (var element in linksToOpenInChrome) {
    print("url :" + uriString);
    print("List: " + element);
  }
  if (uriString.startsWith("whatsapp://send") ||
      uriString.startsWith("https://m.facebook.com/login") ||
      uriString.startsWith("https://twitter.com/intent/tweet") ||
      uriString.startsWith(" http://pinterest.com/pin")) {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
    }
    return NavigationActionPolicy.CANCEL;
  }
  if (linksToOpenInChrome.contains(uriString)) {
    print("links to open in chrome");
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    return NavigationActionPolicy.CANCEL;
  } else if (uriString.contains("https://www.gulahmedshop.com/") ||
      uriString.contains("https://uae.gulahmedshop.com/") ||
      uriString.contains("https://mcstaging.gulahmedshop.com/") ||
      uriString.contains("https://mcstaginguae.gulahmedshop.com/")) {
    print("links to open in app: " + uriString);
    return NavigationActionPolicy.ALLOW;
  } else {
    // Handle other schemes as needed
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    return NavigationActionPolicy.CANCEL;
  }
}
//unused
// Future<bool> _launchURL(String uri) async {
//   return await launchUrl(
//     uri as Uri,
//     mode: LaunchMode.platformDefault,
//   );
// }
// Future<bool> _onCreateWindow(
//     InAppWebViewController controller, CreateWindowAction action) async {
//   var uri = action.request.url;
//   if (uri == null) {
//     // controller.goBack();
//     return false;
//   }
//   final uriString = uri.toString();
//   if (uriString.startsWith('http://') || uriString.startsWith('https://')) {
//     return true;
//   } else {
//     // controller.goBack();
//     _launchURL(uriString);
//     return false;
//   }
// }
