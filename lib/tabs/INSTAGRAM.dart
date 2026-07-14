import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class InstagramScreen extends StatefulWidget {
  const InstagramScreen({Key? key}) : super(key: key);

  @override
  _InstagramScreenState createState() => _InstagramScreenState();
}

class _InstagramScreenState extends State<InstagramScreen> {
  // 1. Declare a WebViewController.
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // 2. Initialize the WebViewController in initState.
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress < 100) {
              setState(() {
                isLoading = true;
              });
            }
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              isLoading = false;
            });
            print('Web view error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.instagram.com/emecexpo/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          // 3. Use the WebViewWidget and pass the controller.
          WebViewWidget(controller: _controller),
          if (isLoading)
            Center(
              child: SpinKitThreeBounce(
                color: const Color(0xffe1306c),
                size: 30.0,
              ),
            ),
        ],
      ),
    );
  }
}