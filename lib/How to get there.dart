import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Local imports
import 'package:emecexpo/providers/theme_provider.dart';
import 'main.dart';

class GetThereScreen extends StatefulWidget {
  const GetThereScreen({Key? key}) : super(key: key);

  @override
  _GetThereScreenState createState() => _GetThereScreenState();
}

class _GetThereScreenState extends State<GetThereScreen> {
  SharedPreferences? prefs;
  late final WebViewController _controller;
  bool isLoading = true;
  bool isPrefsLoading = true;

  // Event venue info
  static const String fixedLat = "33.5783";
  static const String fixedLng = "-7.6273";
  static const String fixedLocationName = "Casablanca International Fair (OFEC)";

  // Official Google Maps Embed URL for OFEC Casablanca
  String get _mapsUrl {
    return 'https://www.google.com/maps/embed?pb=!1m12!1m8!1m3!1d106369.29218045658!2d-7.6272583!3d33.5783008!3m2!1i1024!2i768!4f13.1!2m1!1sCasablanca%20International%20Fair%20OFEC!5e0!3m2!1sen!2sma!4v1761148820478!5m2!1sen!2sma';
  }

  @override
  void initState() {
    super.initState();
    _initPreferences();
    _initWebViewController();
  }

  // Initialize SharedPreferences asynchronously
  Future<void> _initPreferences() async {
    prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        isPrefsLoading = false;
      });
    }
  }

  // Setup WebView controller
  void _initWebViewController() {
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
            debugPrint(
                'WebView error: ${error.errorCode} — ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(_mapsUrl));
  }

  // Handle back button behavior
  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false;
    }
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Êtes-vous sûr ?'),
        content: const Text('Voulez-vous quitter l\'application ?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Oui'),
          ),
        ],
      ),
    )) ??
        false;
  }

  // Handle app bar back action
  void _onAppBarBack() async {
    if (!mounted) return;

    if (prefs == null) {
      await _initPreferences();
    }

    prefs?.setString("Data", "99");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeProvider p) => p.currentTheme);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('How to Get There'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: theme.whiteColor),
            onPressed: _onAppBarBack,
          ),
          centerTitle: true,
          backgroundColor: theme.primaryColor,
          foregroundColor: theme.whiteColor,
        ),
        body: Stack(
          children: [
            // Full-screen map
            WebViewWidget(controller: _controller),

            // Loading overlay
            if (isLoading || isPrefsLoading)
              Container(
                color: theme.whiteColor,
                child: Center(
                  child: SpinKitThreeBounce(
                    color: theme.primaryColor,
                    size: 30.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}