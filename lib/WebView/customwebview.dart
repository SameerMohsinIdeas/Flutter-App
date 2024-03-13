// ignore_for_file: prefer_const_constructors, must_be_immutable

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomWebView extends StatefulWidget {
  String url;
  // CustomWebView({super.key});
  CustomWebView({required this.url});

  @override
  State<CustomWebView> createState() => _CustomWebViewState();
}

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
    "https://m.facebook.com/profile",
    "https://twitter.com/intent/tweet",
    "http://pinterest.com/pin/create/button/"
  ];

  //webview controller
  InAppWebViewController? webViewController;

  //initialize the app
  @override
  void initState() {
    super.initState();

    //clear cache after x interval
    clearCacheAfterInterval(Duration(seconds: 3));

    //pull to refresh check if web or not
    PullToRefreshInit();
  }

  //dispose the app
  void dispose() {
    super.dispose();
    //dispose the webView
    webViewController?.dispose();
  }

  //getuserAgent at 
  GetUserAgent(webViewController) async {
    final defaultUserAgent = await InAppWebViewController.getDefaultUserAgent();
    print("=>defaultUserAgent $defaultUserAgent");
    String newUserAgent = defaultUserAgent.replaceFirst("; wv)", ");");
    String assignUserAgent = newUserAgent + " X-Flutter-InAppWebView";
    print("=>New User Agent: $assignUserAgent");
    try {
      await webViewController?.setSettings(
      settings: InAppWebViewSettings(
            userAgent: assignUserAgent,
            useShouldInterceptRequest: true,
            preferredContentMode: UserPreferredContentMode.MOBILE,
            useShouldOverrideUrlLoading: true,
            useHybridComposition: true),
      );
      final settings = await webViewController?.getSettings();
      final assignedUserAgent = await settings?.userAgent;
      print('=>***assignedUserAgent from GetUserAgent: $assignedUserAgent ***');
    } catch (e) {
      print("=>error $e ");
    }
  }

  //setDeafault UserAgent at login
  setDefaultUserAgent(webViewController) async {
    final defaultUserAgent = await InAppWebViewController.getDefaultUserAgent();
    print("=>defaultUserAgent $defaultUserAgent");
    final setUserAgent = 
    defaultUserAgent.replaceFirst("; wv)", ");").toString() + " X-Flutter-InAppWebView";
    try {
      await webViewController?.setSettings(settings: InAppWebViewSettings(userAgent: setUserAgent,preferredContentMode: UserPreferredContentMode.MOBILE));
      final setting = await webViewController?.getSettings();
      final userAgent = await setting?.userAgent;
      print('=>assignedUserAgent from setDefaultUserAgent: $userAgent');
    } catch (e) {
      print("=>error $e ");
    }
  }

  //InAppWebViewSettings instance varaible 
  InAppWebViewSettings settings = InAppWebViewSettings(
      userAgent: InAppWebViewController.getDefaultUserAgent().toString() + " X-Flutter-InAppWebView",
      useHybridComposition: true,
      preferredContentMode: UserPreferredContentMode.MOBILE,
      cacheMode: CacheMode.LOAD_CACHE_ELSE_NETWORK,
      cacheEnabled: true,
      clearCache: true,
      javaScriptEnabled: true,
      useShouldOverrideUrlLoading: true,
      useShouldInterceptRequest: true,
      useOnLoadResource: true,
      sharedCookiesEnabled: true,
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
              color: Color(0xff8CC63F),
            ),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
                // InAppWebViewController.clearAllCache();
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
      await InAppWebViewController.clearAllCache().whenComplete(() => print("=>cache cleared successfully!"));
    });
  }

  String prodBaseUrl = "https://www.gulahmedshop.com";
  String prodUaeBaseUrl="https://uae.gulahmedshop.com";
  String stagBaseUrl = "https://mcstaging.gulahmedshop.com";
  String stagUaeBaseUrl = "https://mcstaginguae.gulahmedshop.com";

  //function to open links in web or in their respective app
  linksToOpenInWebOrApp(uri,uriString,NavigationActionPolicy) async{
    if (uriString.startsWith("whatsapp://send") ||
        uriString.startsWith("https://web.whatsapp.com/send") ||
        uriString.startsWith("https://m.facebook.com/profile") ||
        uriString.startsWith("https://twitter.com/intent/tweet") ||
        uriString.startsWith(" http://pinterest.com/pin")) {
      //for whatsapp
      if (uriString.startsWith("https://web.whatsapp.com/send")) {
        print("=>uriString: Whatsapp " + uriString.toString());
        print("=>" + uriString.split("/send")[1].toString());
        if (await canLaunchUrl(uri)) {
          String whatsappUrl = "whatsapp://send" + uriString.split("/send")[1].toString();
          await launchUrl(Uri.parse(whatsappUrl),mode: LaunchMode.externalNonBrowserApplication);
          return NavigationActionPolicy.CANCEL;
        }
      }
      //for others
      if (await canLaunchUrl(uri)) 
      {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
      }
        return NavigationActionPolicy.CANCEL;
    }
  }

  //function to open in app browser view
  linksToOpenInAppBrowserView(uri,uriString,NavigationActionPolicy) async{
    if (uriString.startsWith("https://forms.office.com/Pages/ResponsePage.aspx")) {
      print("=>opening as inapp browser view");
      print("=>uriString: " + uriString.toString());
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      return NavigationActionPolicy.CANCEL;
    }
  }

  //override url
  Future<NavigationActionPolicy> _shouldOverrideUrlLoading(InAppWebViewController controller, NavigationAction shouldOverrideUrlLoadingRequest) async {
    //var for uri to override according to needs
    var uri = shouldOverrideUrlLoadingRequest.request.url;

    //check if the url is null
    if (uri == null) {
      return NavigationActionPolicy.CANCEL;
    }

    //var to convert uri into string
    final uriString = uri.toString();

    //socail sites to open on web or the app
    await linksToOpenInWebOrApp(uri, uriString, NavigationActionPolicy);

    //link to open as a inapp browser view
    await linksToOpenInAppBrowserView(uri, uriString, NavigationActionPolicy);
    
    //links to open inside the app
    if (uriString.contains("$prodBaseUrl/") ||
        uriString.contains("$prodUaeBaseUrl/") ||
        uriString.contains("$stagBaseUrl/") ||
        uriString.contains("$stagUaeBaseUrl/") 
       ) {
        
      print("=>links to open in app: " + uriString);
      print("=>uriString: " + uriString);
      return NavigationActionPolicy.ALLOW;
    } else {
      // Handle other schemes as needed
      await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
      return NavigationActionPolicy.CANCEL;
    }
  }

  //func to check if you can go back via history
  Future canGoBack() async {
    final controller = webViewController;
    if (controller != null) {
      if (await controller.canGoBack()) {
        controller.goBack();
        return false;
      }
    }
  }

  //loading function to show progress of the current page
  Loading(progress) {
    return
        //loader gif with backdrop filter
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

        //linear progess indicator with backdrop filter
        // progress < 1.0
        //     ? Center(
        //         child: Container(
        //             height: double.infinity,
        //             width: double.infinity,
        //             color: Colors.grey.withOpacity(0.5),
        //             child: Column(
        //               children: [
        //                 LinearProgressIndicator(
        //                   value: progress,
        //                   backgroundColor: Colors.white,
        //                   color: Color(0xFF8CC63F),
        //                 ),
        //                 BackdropFilter(
        //                   filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        //                   // child: Image.asset(
        //                   //   "assets/loader.gif",
        //                   //   scale: 1.7,
        //                   // )
        //                 ),
        //               ],
        //             )),
        //       )
        //     : Container();

        //Linear Progrss Inidicator without backdrop filter
        progress < 1.0
            ? LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white,
                color: Color(0xff8CC63F),
              )
            : Container();
  }

  //funtion to load url at social login and checkout pages
  loadUserAgentAtLoginAndCheckout(String urlString,controller) async {
    //condition for loading useragent at homepage
    if (
      //pk
      urlString == "$stagBaseUrl/" || urlString == "$prodBaseUrl/" ||
      //uae
      urlString == "$stagUaeBaseUrl/" || urlString == "$prodUaeBaseUrl/"
    ) {
          print("=>condition for loading useragent at homepage");
          await GetUserAgent(controller);
    }
    // condition for loading useragent at login and and checkout
    if (
      //login pk
      urlString.startsWith("$stagBaseUrl/customer/account/login/") || urlString.startsWith("$prodBaseUrl/customer/account/login/") ||
      //login uae
      urlString.startsWith("$stagUaeBaseUrl/customer/account/login/") || urlString.startsWith("$prodUaeBaseUrl/customer/account/login/") ||
      //checkout pk
      urlString.startsWith("$stagBaseUrl/onestepcheckout/") || urlString.startsWith("$prodBaseUrl/onestepcheckout/") ||
      //checkout uae
      urlString.startsWith("$stagUaeBaseUrl/onestepcheckout/") || urlString.startsWith("$prodUaeBaseUrl/onestepcheckout/") 
      ) 
    {
          print("=>condition for loading useragent at login and and checkout");
          await setDefaultUserAgent(controller);
    } 
    //condition for loading useragent without google login 
    if (urlString.startsWith("$prodBaseUrl/?token") || urlString.startsWith("$stagBaseUrl/?token") ||
        urlString.startsWith("$prodUaeBaseUrl/?token") || urlString.startsWith("$stagUaeBaseUrl/?token")) 
    {
        print("=>condition for loading useragent without google login.");
        await GetUserAgent(controller);
    }
  }

  //function to check internet disconnect and show error page
  showErrorPage(WebResourceError error)async {
    print("=>errorType: " + error.type.toString() + " errorDesription: " + error.description);
    setState(() {
      if (error.type.toString() == "HOST_LOOKUP" || error.description == "net::ERR_INTERNET_DISCONNECTED") {
          Navigator.pushNamed(context, '/splash');
      }
    });
  }

  //webview function to show all the things related to webview making it more readable
  Widget webViewWidget() {
    return WillPopScope(
      onWillPop: () async { canGoBack(); return false;},
      child: InAppWebView(
        key: webViewKey,
        initialUrlRequest: URLRequest(url: WebUri(widget.url.toString())),
        initialSettings: settings,
        pullToRefreshController: pullToRefreshController,
        onWebViewCreated: (controller) async {
          print("=>onWebViewCreated");
          webViewController = controller;
          await GetUserAgent(webViewController);
        },
        onPermissionRequest: (controller, request) async {
          return await PermissionResponse(resources: request.resources,action: PermissionResponseAction.GRANT);
        },
        shouldOverrideUrlLoading: _shouldOverrideUrlLoading,
        onLoadStart: (controller, url) async {
          var urlString = await url.toString();
          print("=>onLoadStart: $urlString");
          await loadUserAgentAtLoginAndCheckout(urlString, controller);  
        },
        onLoadStop: (controller, url) async {
          await pullToRefreshController?.endRefreshing();
          await Loading(progress);
        },
        onReceivedError: (controller, request, error) async{
          pullToRefreshController?.endRefreshing();
          await showErrorPage(error);
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
                print("=>Current Url: ");
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
          print("=>onUpdateVisitedHistory: " + url.toString());
        },
        onConsoleMessage: (controller, consoleMessage) {
          if (kDebugMode) {
            print("onConsoleMessage: " + consoleMessage.message);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light
              .copyWith(statusBarColor: Color(0xff000000)),
          child: SafeArea(
              maintainBottomViewPadding: true,
              child: Stack(
                children: [
                  //to display webview
                  webViewWidget(),
                  //load based on progress
                  Loading(progress),
                ],
              )),
        ));
  }
}

//unused code:

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

//place before webview widget code:

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
