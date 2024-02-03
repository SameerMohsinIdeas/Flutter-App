// ignore_for_file: prefer_const_constructors, must_be_immutable

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomWebView extends StatefulWidget {
  String url;
  // CustomWebView({super.key});
  CustomWebView({required this.url});

  @override
  State<CustomWebView> createState() => _CustomWebViewState();
}

//handle click
// void handleClick(int item) async {
//   final defaultUserAgent = await InAppWebViewController.getDefaultUserAgent();
//   if (kDebugMode) {
//     print("Default User Agent: $defaultUserAgent");
//   }

//   String? newUserAgent;

//   switch (item) {
//     case 0:
//       newUserAgent = defaultUserAgent;
//       break;
//     case 1:
//       switch (defaultTargetPlatform) {
//         case TargetPlatform.android:
//           // Remove "wv" from the Android WebView default user agent
//           // https://developer.chrome.com/docs/multidevice/user-agent/#webview-on-android
//           newUserAgent = defaultUserAgent.replaceFirst("; wv)", ")");
//           break;
//         case TargetPlatform.iOS:
//           // Add Safari/604.1 at the end of the iOS WKWebView default user agent
//           newUserAgent = "$defaultUserAgent Safari/604.1";
//           break;
//         default:
//           newUserAgent = null;
//       }
//       break;
//     case 2:
//       // random desktop user agent
//       newUserAgent =
//           'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36';
//       break;
//   }

//   if (kDebugMode) {
//     print("New User Agent: $newUserAgent");
//   }
//   await webViewController?.setSettings(
//       settings: InAppWebViewSettings(userAgent: newUserAgent));
//   // await goCustomWebView();
// }

class _CustomWebViewState extends State<CustomWebView>
    with TickerProviderStateMixin {
  //global webview key
  final GlobalKey webViewKey = GlobalKey();

  //list of links to open in chrome
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

  //webview controller
  InAppWebViewController? webViewController;

  //change user agent
  getUserAgent() async {
    final defaultUserAgent = await InAppWebViewController.getDefaultUserAgent();
    String newUserAgent;
    if (Platform.isAndroid) {
      print("=>android platform");
      newUserAgent = defaultUserAgent.replaceFirst("; wv)", ")").toString();
      print("=>" + newUserAgent);
      await webViewController?.setSettings(
          settings: InAppWebViewSettings(userAgent: newUserAgent));
      return newUserAgent;
    } else {
      print("=>ios platform");
      newUserAgent = "$defaultUserAgent Safari/604.1";
      await webViewController?.setSettings(
          settings: InAppWebViewSettings(userAgent: newUserAgent));
      return newUserAgent;
    }
  }

  //inappwebview setting
  InAppWebViewSettings settings = InAppWebViewSettings(
      // userAgent: Platform.operatingSystem.toUpperCase(),
      // userAgent: "random",
      preferredContentMode: UserPreferredContentMode.MOBILE,
      cacheMode: CacheMode.LOAD_CACHE_ELSE_NETWORK,
      cacheEnabled: true,
      clearCache: true,
      javaScriptEnabled: true,
      useShouldOverrideUrlLoading: true,
      useOnLoadResource: true,
      useHybridComposition: true,
      isInspectable: kDebugMode,
      sharedCookiesEnabled: true,
      javaScriptCanOpenWindowsAutomatically: false,
      transparentBackground: true,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera;",
      allowUniversalAccessFromFileURLs: true,
      iframeAllowFullscreen: true);

  //pull to refresh controller
  PullToRefreshController? pullToRefreshController;

  //pull to refresh init
  PullToRefreshInit() {
    return pullToRefreshController = kIsWeb
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

  //initialize progress
  double progress = 0;

  //function to clear cache after x interval
  Future<void> clearCacheAfterInterval(Duration interval) async {
    await Future.delayed(interval, () async {
      final prefs = await SharedPreferences.getInstance();
      // await prefs.clear();
      // print('Cache cleared after interval');
      await prefs.clear();
      await InAppWebViewController.clearAllCache()
          .whenComplete(() => print("=>cache cleared successfully"));
    });
  }

  @override
  void initState() {
    super.initState();

    //clear cache after x interval
    clearCacheAfterInterval(Duration(seconds: 5));

    //pull to refresh check if web or not
    PullToRefreshInit();
  }

  // void dispose() {
  //   super.dispose();
  //   webViewController!.dispose();
  // }

  //override loading url
  Future<NavigationActionPolicy> _shouldOverrideUrlLoading(
      InAppWebViewController controller,
      NavigationAction shouldOverrideUrlLoadingRequest) async {
    var uri = shouldOverrideUrlLoadingRequest.request.url;
    if (uri == null) {
      return NavigationActionPolicy.CANCEL;
    }

    final uriString = uri.toString();
    //check if login site then open in app
    if (uriString
        .startsWith("https://www.gulahmedshop.com/customer/account/login/")) {
      getUserAgent();
      return NavigationActionPolicy.CANCEL;
    }
    if (uriString.startsWith(
        "https://accounts.google.com/o/oauth2/v2/auth?scope=email+profile+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile+openid&access_type=offline&include_granted_scopes=true&state=state_parameter_passthrough_value&client_id=519526400043-s2usj1mi1546htd72d434k0ak1cdevr2.apps.googleusercontent.com&redirect_uri=https://www.gulahmedshop.com/sociallogin/account/login/type/google/&response_type=code")) {
      // getUserAgent();
      // handleClick(1);
      // print("=>got user agent");
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
        return NavigationActionPolicy.CANCEL;
      }
    }
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

  //func to check if you can go back via history
  Future _canGoBack() async {
    final controller = webViewController;
    if (controller != null) {
      if (await controller.canGoBack()) {
        controller.goBack();
        return false;
      }
      // else {
      //   await controller.loadUrl(
      //       urlRequest: URLRequest(url: WebUri(_baseUrlProduction)));
      //   return false;
      // }
    }
  }

  //loading function to show loader
  Loading(progress) {
    return
        // progress < 1.0
        //     ? Center(
        //         child: Container(
        //             height: double.infinity,
        //             width: double.infinity,
        //             color: Colors.grey.withOpacity(0.5),
        //             child: BackdropFilter(
        //                 filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        //                 child: Image.asset(
        //                   "assets/loader.gif",
        //                   scale: 1.7,
        //                 ))),
        //       )
        //     : Container();

        progress < 1.0
            ? LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white,
                color: Colors.green,
              )
            : Container();
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

  //webview function to show all the things related to webview making it more readable
  WebViewFunc() {
    return WillPopScope(
      onWillPop: () async {
        _canGoBack();
        return false;
      },
      child: InAppWebView(
        key: webViewKey,
        initialUrlRequest: URLRequest(url: WebUri(widget.url.toString())),
        initialSettings: settings,
        pullToRefreshController: pullToRefreshController,
        onWebViewCreated: (controller) async {
          webViewController = controller;
        },
        onPermissionRequest: (controller, request) async {
          return PermissionResponse(
              resources: request.resources,
              action: PermissionResponseAction.GRANT);
        },
        shouldOverrideUrlLoading: _shouldOverrideUrlLoading,
        onLoadStart: (controller, url) async {
          print("=>await url: " + await url.toString());
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
            child: Stack(
          children: [
            //to display webview
            WebViewFunc(),
            //load based on progress
            Loading(progress),
          ],
        )));
  }
}
