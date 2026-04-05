import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

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
      useShouldOverrideUrlLoading: true,
      useOnDownloadStart: true,
      supportZoom: false);

  PullToRefreshController? pullToRefreshController;
  String url = "https://gomlatrade.com/";
  double progress = 0;
  bool _isConnected = true;
  bool _isInitError = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _initPullToRefresh();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await Permission.storage.request();
    }
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (!mounted) return;
    setState(() {
      _isConnected = !connectivityResult.contains(ConnectivityResult.none);
    });
  }

  void _initPullToRefresh() {
    pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Colors.orange,
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

  Future<bool> _onWillPop() async {
    if (webViewController != null) {
      if (await webViewController!.canGoBack()) {
        final currentUrl = await webViewController!.getUrl();
        if (currentUrl != null &&
            (currentUrl.toString() == 'https://gomlatrade.com/' ||
                currentUrl.toString() == 'https://gomlatrade.com')) {
          return true; // close app on domain root
        }
        webViewController!.goBack();
        return false; // prevent closing
      }
    }
    return true; // close app
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: !_isConnected || _isInitError
              ? _buildOfflineScreen()
              : Stack(
                  children: [
                    InAppWebView(
                      key: webViewKey,
                      initialUrlRequest:
                          URLRequest(url: WebUri("https://gomlatrade.com")),
                      initialSettings: settings,
                      pullToRefreshController: pullToRefreshController,
                      onWebViewCreated: (controller) {
                        webViewController = controller;
                      },
                      onLoadStart: (controller, url) {
                        setState(() {
                          this.url = url.toString();
                        });
                      },
                      shouldOverrideUrlLoading:
                          (controller, navigationAction) async {
                        var uri = navigationAction.request.url!;

                        if (![
                          "http",
                          "https",
                          "file",
                          "chrome",
                          "data",
                          "javascript",
                          "about"
                        ].contains(uri.scheme)) {
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                            );
                            return NavigationActionPolicy.CANCEL;
                          }
                        }
                        return NavigationActionPolicy.ALLOW;
                      },
                      onLoadStop: (controller, url) async {
                        pullToRefreshController?.endRefreshing();
                        setState(() {
                          this.url = url.toString();
                        });
                      },
                      onReceivedError: (controller, request, error) {
                        pullToRefreshController?.endRefreshing();
                        setState(() {
                            // Display fallback for main frame error
                            if(request.isForMainFrame == true) {
                                _isInitError = true;
                            }
                        });
                      },
                      onProgressChanged: (controller, progress) {
                        if (progress == 100) {
                          pullToRefreshController?.endRefreshing();
                        }
                        setState(() {
                          this.progress = progress / 100;
                        });
                      },
                      onUpdateVisitedHistory: (controller, url, androidIsReload) {
                        setState(() {
                          this.url = url.toString();
                        });
                      },
                      onDownloadStartRequest: (controller, downloadStartRequest) async {
                        final uri = downloadStartRequest.url;
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                    if (progress < 1.0)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              color: Color(0xFFF7941D),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Loading GomlaTrade...',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                              ),
                            )
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildOfflineScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          const Text(
            'Whoops!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _isInitError ? 'Failed to load page. Please try again.' : 'No internet connection found.\nPlease check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                  _isInitError = false;
                  _isConnected = true; 
                  // Assume true while retrying, we'll check immediately below
              });
              await _checkConnectivity();
              if (_isConnected && webViewController != null) {
                webViewController!.reload();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF7941D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              )
            ),
            child: const Text('RETRY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}
