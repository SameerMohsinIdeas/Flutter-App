import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class TestApp extends StatefulWidget {
  const TestApp({Key? key}) : super(key: key);

  @override
  State<TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  final GlobalKey webViewKey = GlobalKey();
  // final homeUrl = WebUri("https://www.epicgames.com/id/login");
  final homeUrl = WebUri("https://www.gulahmedshop.com");

  InAppWebViewController? webViewController;

  void handleClick(int item) async {
    final defaultUserAgent = await InAppWebViewController.getDefaultUserAgent();
    if (kDebugMode) {
      print("Default User Agent: $defaultUserAgent");
    }

    String? newUserAgent;

    switch (item) {
      case 0:
        newUserAgent = defaultUserAgent;
        break;
      case 1:
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            // Remove "wv" from the Android WebView default user agent
            // https://developer.chrome.com/docs/multidevice/user-agent/#webview-on-android
            newUserAgent = defaultUserAgent.replaceFirst("; wv)", ")");
            break;
          case TargetPlatform.iOS:
            // Add Safari/604.1 at the end of the iOS WKWebView default user agent
            newUserAgent = "$defaultUserAgent Safari/604.1";
            break;
          default:
            newUserAgent = null;
        }
        break;
      case 2:
        // random desktop user agent
        newUserAgent =
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36';
        break;
    }

    if (kDebugMode) {
      print("New User Agent: $newUserAgent");
    }
    await webViewController?.setSettings(
        settings: InAppWebViewSettings(userAgent: newUserAgent));
    await goHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("InAppWebView test"),
          actions: <Widget>[
            IconButton(
                onPressed: () async {
                  await goHome();
                },
                icon: const Icon(Icons.home)),
            PopupMenuButton<int>(
              onSelected: (item) => handleClick(item),
              itemBuilder: (context) => [
                const PopupMenuItem<int>(
                    value: 0, child: Text('Use WebView User Agent')),
                const PopupMenuItem<int>(
                    value: 1, child: Text('Use Mobile User Agent')),
                const PopupMenuItem<int>(
                    value: 2, child: Text('Use Desktop User Agent')),
              ],
            ),
          ],
        ),
        body: Column(children: <Widget>[
          Expanded(
            child: InAppWebView(
              key: webViewKey,
              initialUrlRequest: URLRequest(url: homeUrl),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStart: (controller, url) {
                print("=>url: $url");
              },
            ),
          ),
        ]));
  }

  Future<void> goHome() async {
    await webViewController?.loadUrl(urlRequest: URLRequest(url: homeUrl));
  }
}