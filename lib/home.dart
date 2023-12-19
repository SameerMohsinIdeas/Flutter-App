// ignore_for_file: prefer_const_constructors, 

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:gulahmedshop/SplashScreen.dart';

class InAppWebViewScreen extends StatefulWidget {
  const InAppWebViewScreen({Key? key}) : super(key: key);

  @override
  State<InAppWebViewScreen> createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppWebViewScreen> {
  final GlobalKey webViewKey = GlobalKey();
  //production
  Uri myUrl = Uri.parse("https://www.gulahmedshop.com/");
  //staging
  // Uri myUrl = Uri.parse("https://mcstaging.gulahmedshop.com/");
  late final InAppWebViewController webViewController;
  late final PullToRefreshController pullToRefreshController;
  double progress = 0;

  @override
  void initState() {
    super.initState();

    pullToRefreshController = (kIsWeb
        ? null
        : PullToRefreshController(
            // options: PullToRefreshOptions(
            //   color: Colors.green,
            // ),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                webViewController.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController.getUrl()));
              }
            },
          ))!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: WillPopScope(
                onWillPop: () => _goBack(context),
                child: Stack(
                  children: [
                    progress < 100 ? SplashScreen() : Container(),
                    Column(children: <Widget>[
                      Expanded(
                          child: Stack(children: [
                        InAppWebView(
                          key: webViewKey,
                          initialUrlRequest: URLRequest(url: WebUri.uri(myUrl)),
                          initialOptions: InAppWebViewGroupOptions(
                            crossPlatform: InAppWebViewOptions(
                                transparentBackground: true,
                                javaScriptCanOpenWindowsAutomatically: true,
                                javaScriptEnabled: true,
                                useOnDownloadStart: true,
                                useOnLoadResource: true,
                                useShouldOverrideUrlLoading: true,
                                mediaPlaybackRequiresUserGesture: true,
                                allowFileAccessFromFileURLs: true,
                                allowUniversalAccessFromFileURLs: true,
                                verticalScrollBarEnabled: true,
                                userAgent: 'random',
                                cacheEnabled: true),
                            android: AndroidInAppWebViewOptions(
                                useHybridComposition: true,
                                allowContentAccess: true,
                                builtInZoomControls: true,
                                thirdPartyCookiesEnabled: true,
                                allowFileAccess: true,
                                supportMultipleWindows: true),
                            ios: IOSInAppWebViewOptions(
                              allowsInlineMediaPlayback: true,
                              allowsBackForwardNavigationGestures: true,
                            ),
                          ),
                          pullToRefreshController: pullToRefreshController,
                          onLoadStart:
                              (InAppWebViewController controller, uri) {
                            setState(() {
                              myUrl = uri!;
                            });
                          },
                          onLoadStop: (InAppWebViewController controller, uri) {
                            setState(() {
                              myUrl = uri!;
                            });
                          },
                          onProgressChanged: (controller, progress) {
                            if (progress == 100) {
                              pullToRefreshController.endRefreshing();
                            }
                            setState(() {
                              this.progress = progress / 100;
                            });
                          },
                          androidOnPermissionRequest:
                              (controller, origin, resources) async {
                            return PermissionRequestResponse(
                                resources: resources,
                                action: PermissionRequestResponseAction.GRANT);
                          },
                          onWebViewCreated:
                              (InAppWebViewController controller) {
                            webViewController = controller;
                          },
                          onCreateWindow:
                              (controller, createWindowRequest) async {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 400,
                                    child: InAppWebView(
                                      // Setting the windowId property is important here!
                                      windowId: createWindowRequest.windowId,
                                      initialOptions: InAppWebViewGroupOptions(
                                        android: AndroidInAppWebViewOptions(
                                          builtInZoomControls: true,
                                          thirdPartyCookiesEnabled: true,
                                        ),
                                        crossPlatform: InAppWebViewOptions(
                                          cacheEnabled: true,
                                          javaScriptEnabled: true,
                                          userAgent: 'random',
                                        ),
                                        ios: IOSInAppWebViewOptions(
                                          allowsInlineMediaPlayback: true,
                                          allowsBackForwardNavigationGestures:
                                              true,
                                        ),
                                      ),
                                      onCloseWindow: (controller) async {
                                        if (Navigator.canPop(context)) {
                                          Navigator.pop(context);
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                            return true;
                          },
                        )
                      ]))
                    ]),
                  ],
                ))));
  }

  Future<bool> _goBack(BuildContext context) async {
    if (await webViewController.canGoBack()) {
      webViewController.goBack();
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
