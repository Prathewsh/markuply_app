// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(const MarkuplyApp());

class MarkuplyApp extends StatelessWidget {
  const MarkuplyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Markuply',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MarkuplyWebView()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDF2F2),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [Image.asset('assets/logo.png', height: 300)],
        ),
      ),
    );
  }
}

class MarkuplyWebView extends StatefulWidget {
  const MarkuplyWebView({super.key});

  @override
  State<MarkuplyWebView> createState() => _MarkuplyWebViewState();
}

class _MarkuplyWebViewState extends State<MarkuplyWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasNetworkError = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() {
              _isLoading = true;
              _hasNetworkError = false;
            });
          },
          onPageFinished: (_) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            setState(() {
              if (error.errorCode == WebResourceErrorType.hostLookup.index ||
                  error.description.toLowerCase().contains(
                    'err_name_not_resolved',
                  ) ||
                  error.description.toLowerCase().contains('err_cache_miss')) {
                _hasNetworkError = true;
              }
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url == 'about:blank') {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse("https://markuply.vercel.app"),
        headers: {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
      );
  }

  Future<bool> _handleBackPress() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackPress,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              if (_hasNetworkError)
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, size: 60, color: Colors.white),
                      SizedBox(height: 20),
                      Text(
                        "Network not found",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Please check your internet connection",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                )
              else
                WebViewWidget(controller: _controller),
              if (_isLoading) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
