// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
InAppWebViewController? webViewController;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewSettings settings = InAppWebViewSettings(
      userAgent: Platform.isAndroid ? "Android" : "iOS",
      preferredContentMode: UserPreferredContentMode.MOBILE,
      cacheEnabled: true,
      clearCache: true,
      useHybridComposition: true,
      appCachePath: "assets/cache",
      cacheMode: CacheMode.LOAD_DEFAULT,
      isInspectable: kDebugMode,
      useShouldOverrideUrlLoading: true,
      sharedCookiesEnabled: true,
      javaScriptCanOpenWindowsAutomatically: false,
      transparentBackground: true,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera;",
      allowUniversalAccessFromFileURLs: true,
      iframeAllowFullscreen: true);

  PullToRefreshController? pullToRefreshController;
  double progress = 0;
  @override
  void initState() {
    super.initState();
    clearCacheAfterInterval(Duration(minutes: 15));
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

//overrideurlLoading
  // Future<NavigationActionPolicy> _shouldOverrideUrlLoading(
  //     InAppWebViewController controller,
  //     NavigationAction shouldOverrideUrlLoadingRequest) async {
  //   var uri = await shouldOverrideUrlLoadingRequest.request.url;
  //   if (uri == null) {
  //     return NavigationActionPolicy.CANCEL;
  //   }
  //   final uriString = await uri.toString();

  //   print("sameer");
  //   for (var element in linksToOpenInChrome) {
  //     print("url :" + uriString);
  //     print("List: " + element);
  //   }
  //   if (uriString.startsWith("whatsapp://send") ||
  //       uriString.startsWith("https://m.facebook.com/login") ||
  //       uriString.startsWith("https://twitter.com/intent/tweet") ||
  //       uriString.startsWith(" http://pinterest.com/pin")) {
  //     if (await canLaunchUrl(uri)) {
  //       // await launchUrl(uri, mode: LaunchMode.externalApplication);
  //       await launchUrl(uri, mode: LaunchMode.externalApplication);
  //     } else {
  //       // launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
  //       launchUrl(uri, mode: LaunchMode.platformDefault);
  //     }
  //     return NavigationActionPolicy.CANCEL;
  //   }
  //   if (linksToOpenInChrome.contains(uriString)) {
  //     print("links to open in chrome");
  //     // await launchUrl(uri, mode: LaunchMode.externalApplication);
  //     await launchUrl(uri, mode: LaunchMode.platformDefault);
  //     return NavigationActionPolicy.CANCEL;
  //   } else if (uriString.contains("https://www.gulahmedshop.com/") ||
  //       uriString.contains("https://uae.gulahmedshop.com/") ||
  //       uriString.contains("https://mcstaging.gulahmedshop.com/") ||
  //       uriString.contains("https://mcstaginguae.gulahmedshop.com/")) {
  //     print("links to open in app: " + uriString);
  //     return NavigationActionPolicy.ALLOW;
  //   } else {
  //     // Handle other schemes as needed
  //     // await launchUrl(uri, mode: LaunchMode.externalApplication);
  //     await launchUrl(uri, mode: LaunchMode.platformDefault);
  //     return NavigationActionPolicy.CANCEL;
  //   }
  // }

  Future<NavigationActionPolicy> _shouldOverrideUrlLoading(
      InAppWebViewController controller,
      NavigationAction shouldOverrideUrlLoadingRequest) async {
    var uri = shouldOverrideUrlLoadingRequest.request.url;
    if (uri == null) {
      return NavigationActionPolicy.CANCEL;
    }

    final uriString = uri.toString();
    //socail sites to open on web or the app
    if (uriString.startsWith("whatsapp://send") ||
        uriString.startsWith("https://web.whatsapp.com/send") ||
        uriString.startsWith("https://m.facebook.com/login") ||
        uriString.startsWith("https://twitter.com/intent/tweet") ||
        uriString.startsWith(" http://pinterest.com/pin")) {
      print("=>uriString: " + uriString.toString());
      if (uriString.contains("https://web.whatsapp.com/send")) {
        print("=>uriString: Whatsapp " + uriString.toString());
        print("=>" + uriString.split("/send")[1].toString());
        if (await canLaunchUrl(uri)) {
          await launchUrl(
              Uri.parse(
                  "whatsapp://send" + uriString.split("/send")[1].toString()),
              mode: LaunchMode.externalNonBrowserApplication);
          return NavigationActionPolicy.CANCEL;
        }
        return NavigationActionPolicy.CANCEL;
      }
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
      }
      return NavigationActionPolicy.CANCEL;
    }

    //links to open in chrome
    if (linksToOpenInChrome.toString().startsWith(uriString)) {
      print("=>links to open in chrome");
      print("=>uriString: " + uriString.toString());
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return NavigationActionPolicy.CANCEL;
    }

    //links to open in app
    if (uriString.contains("https://www.gulahmedshop.com/") ||
        uriString.contains("https://uae.gulahmedshop.com/") ||
        uriString.contains("https://mcstaging.gulahmedshop.com/") ||
        uriString.contains("https://mcstaginguae.gulahmedshop.com/")) {
      print("=>links to open in app: " + uriString);
      print("=>uriString: " + uriString.toString());
      return NavigationActionPolicy.ALLOW;
    } else {
      // Handle other schemes as needed
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return NavigationActionPolicy.CANCEL;
    }
  }

  // Future<void> SetCachedData(String url) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final currentUrl = await webViewController?.getUrl();
  //   final htmlContent = await webViewController?.getHtml();
  //   print("=>htmlContent: " + await htmlContent.toString());
  //   final cacheKey = 'cached_html_${await url.toString()}';
  //   final existing = prefs.containsKey(cacheKey);
  //   print("\n=>cache key: " + cacheKey);
  //   print("=>get cache data " + existing.toString());
  //   try {
  //     print("=>in try");
  //     if (htmlContent != null && existing != true) {
  //       // Only set cache if it doesn't already exist
  //       print("=>in if");
  //       await prefs.setString(cacheKey, jsonEncode(htmlContent));
  //       print('=>set:');
  //       print("=>url: " +
  //           cacheKey +
  //           " content: " +
  //           htmlContent.toString() +
  //           "\n");
  //     } else {
  //       print("=>in else");
  //       print('=>Cache already exists, skipping set.');
  //       // return await loadCachedData(await cacheKey);
  //     }
  //   } catch (e) {
  //     // await loadCachedData(await cacheKey);
  //     print("=>in catch");
  //     print("=>" + e.toString());
  //   }
  // }

  // Future<void> loadCachedData(cacheKey) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   print("=>cache key in loadcache: " + await cacheKey);
  //   try {
  //     final checkHtml = prefs.containsKey(await cacheKey);
  //     if (checkHtml == true) {
  //       final cachedHtml = prefs.getString(await cacheKey).toString();
  //       // if (await cachedHtml != (null)) {
  //       print("=>saved cached data: " + await cachedHtml);
  //       await webViewController?.loadData(
  //           data: await cachedHtml, mimeType: "text/html", historyUrl: null);
  //       // }
  //     }
  //   } catch (e) {
  //     print("=>error in loadcache" + e.toString());
  //   }

  //   //  else {
  //   //   print('null ideas');
  //   //   await webViewController?.loadUrl(
  //   //       urlRequest: URLRequest(url: WebUri(site)));
  //   // }
  // }

  Future<void> clearCacheAfterInterval(Duration interval) async {
    await Future.delayed(interval, () async {
      final prefs = await SharedPreferences.getInstance();
      // await prefs.clear();
      // print('Cache cleared after interval');
      await prefs.clear();
      await InAppWebViewController.clearAllCache();
      print("=>cache cleared successfully");
    });
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
                initialUrlRequest: URLRequest(url: WebUri(url)),
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
                  // print("=>await url: " + await url.toString());
                  final cacheKey = 'cached_html_${await url.toString()}';
                  print("=>" + DateTime.now().toString());
                  // await loadCachedData(await cacheKey);
                  // await SetCachedData(await url.toString());
                },
                onLoadStop: (controller, url) async {
                  pullToRefreshController?.endRefreshing();
                  final cacheKey = 'cached_html_${await url.toString()}';
                  print("=>" + DateTime.now().toString());
                  print("=>delay of 1-min");
                  // await Future.delayed(Duration(minutes: 2), () async {
                  //   SetCachedData(await url.toString());
                  // });
                  print("=>delay of 1-min complete");
                  // await SetCachedData(await cacheKey);
                  // clearCacheAfterInterval(Duration(seconds: 20));
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
                        WebUri? currentUrl = await webViewController?.getUrl();
                        print("Current Url: ");
                        print(currentUrl);
                        webViewController?.loadUrl(
                            urlRequest: URLRequest(url: currentUrl));
                        launchUrl(
                          url,
                        ); // to open with the system browser
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
            // Loading(progress)
            progress < 1.0
                ? LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white,
                    color: Colors.green,
                  )
                : Container(),
          ],
        ),
      ),
    ])));
  }
}

//loading function if the page is not loaded
Loading(progress) {
  return progress < 1.0
      ? Center(
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
        )
      : Container();
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