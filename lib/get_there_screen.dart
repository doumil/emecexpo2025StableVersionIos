// lib/get_there_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart'; // 💡 Import Provider
import 'package:emecexpo/providers/theme_provider.dart'; // 💡 Import your ThemeProvider

class GetThereScreen extends StatefulWidget {
  const GetThereScreen({Key? key}) : super(key: key);

  @override
  _GetThereScreenState createState() => _GetThereScreenState();
}

class _GetThereScreenState extends State<GetThereScreen> {
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
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
      ..loadRequest(Uri.parse('https://maps.google.com/maps?q=location&t=k&z=13&ie=UTF8&iwloc=&output=embed'));
  }

  /*Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Êtes-vous sûr'),
        content: const Text('Voulez-vous quitter une application'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Oui '),
          ),
        ],
      ),
    )) ?? false;
  }*/

  @override
  Widget build(BuildContext context) {
    // 💡 Access the theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    return
      //WillPopScope(
      //onWillPop: _onWillPop,
       Scaffold(
        appBar: AppBar(
          title: const Text('How to get there'),
          centerTitle: true,
          // ✅ Use primary color from the theme
          backgroundColor: theme.primaryColor,
          // ✅ Use white color from the theme
          foregroundColor: theme.whiteColor,
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (isLoading)
              Center(
                child: SpinKitThreeBounce(
                  // ✅ Use primary color from the theme
                  color: theme.primaryColor,
                  size: 30.0,
                ),
              ),
          ],
        ),
     // ),
    );
  }
}