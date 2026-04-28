import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../config/app_theme.dart';
import 'offline_screen.dart';
import 'policy_screen.dart';

class WebviewScreen extends StatefulWidget {
  const WebviewScreen({super.key});

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true,
    javaScriptEnabled: true,
    domStorageEnabled: true,
    allowFileAccessFromFileURLs: true,
    allowUniversalAccessFromFileURLs: true,
    useOnDownloadStart: true,
    useShouldOverrideUrlLoading: true,
  );

  PullToRefreshController? pullToRefreshController;
  final String initialUrl = 'https://gomlatrade.com';
  double progress = 0;
  bool isOnline = true;

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: AppTheme.primaryOrange,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    bool connected = connectivityResult.contains(ConnectivityResult.mobile) ||
                     connectivityResult.contains(ConnectivityResult.wifi) ||
                     connectivityResult.contains(ConnectivityResult.ethernet);
    if (!connected && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OfflineScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('Gomlatrade'),
        backgroundColor: AppTheme.cardDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              webViewController?.reload();
            },
          ),
        ],
      ),
      drawer: _buildNativeDrawer(context),
      body: SafeArea(
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            if (webViewController != null) {
              if (await webViewController!.canGoBack()) {
                webViewController!.goBack();
              } else {
                if (context.mounted) {
                   SystemNavigator.pop();
                }
              }
            }
          },
          child: Column(
            children: <Widget>[
              if (progress < 1.0)
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
                ),
              Expanded(
                child: InAppWebView(
                  key: webViewKey,
                  initialUrlRequest: URLRequest(url: WebUri(initialUrl)),
                  initialSettings: settings,
                  pullToRefreshController: pullToRefreshController,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    _checkConnectivity();
                  },
                  shouldOverrideUrlLoading: (controller, navigationAction) async {
                    var uri = navigationAction.request.url!;

                    // Handle phone calls, emails, and whatsapp
                    if (!["http", "https", "file", "chrome", "data", "javascript", "about"].contains(uri.scheme)) {
                      if (await canLaunchUrl(uri)) {
                        // Launch the app
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                        return NavigationActionPolicy.CANCEL;
                      }
                    }
                    return NavigationActionPolicy.ALLOW;
                  },
                  onLoadStop: (controller, url) async {
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
                  onReceivedError: (controller, request, error) {
                    pullToRefreshController?.endRefreshing();
                  },
                  onDownloadStartRequest: (controller, downloadStartRequest) async {
                    final url = downloadStartRequest.url;
                    if (await canLaunchUrl(url)) {
                       await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNativeDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.darkBg,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.shopping_bag_rounded,
                  size: 60,
                  color: AppTheme.primaryOrange,
                ),
                SizedBox(height: 12),
                Text(
                  'Gomlatrade',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white70),
            title: const Text('Home', style: TextStyle(color: Colors.white)),
            onTap: () {
              webViewController?.loadUrl(
                  urlRequest: URLRequest(url: WebUri(initialUrl)));
              Navigator.pop(context); // Close drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.white70),
            title: const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PolicyScreen(
                    title: 'Privacy Policy',
                    content: genericPrivacyPolicy,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description, color: Colors.white70),
            title: const Text('Terms of Service', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PolicyScreen(
                    title: 'Terms of Service',
                    content: genericTermsOfService,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
