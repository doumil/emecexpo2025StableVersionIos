import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
  bool isPrefsLoading = true;

  // إحداثيات المعرض الدولي بالدار البيضاء (OFEC)
  static const String fixedLat = "33.5783";
  static const String fixedLng = "-7.6273";
  static const String fixedLocationName = "Casablanca International Fair (OFEC)";

  @override
  void initState() {
    super.initState();
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        isPrefsLoading = false;
      });
    }
  }

  // وظيفة فتح الخريطة الخارجية (الخيار الأفضل للقبول في المتجر)
  Future<void> _openMapNavigation() async {
    final Uri googleUrl = Uri.parse("google.navigation:q=$fixedLat,$fixedLng");
    final Uri appleUrl = Uri.parse("https://maps.apple.com/?q=$fixedLocationName&ll=$fixedLat,$fixedLng");

    try {
      if (await canLaunchUrl(googleUrl)) {
        await launchUrl(googleUrl);
      } else if (await canLaunchUrl(appleUrl)) {
        await launchUrl(appleUrl);
      } else {
        // إذا لم يتوفر تطبيق خرائط، نفتح المتصفح
        final Uri browserUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$fixedLat,$fixedLng");
        await launchUrl(browserUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching maps: $e');
    }
  }

  void _onAppBarBack() async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }
    await prefs?.setString("Data", "99");

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeProvider p) => p.currentTheme);

    // استخدام PopScope بدلاً من WillPopScope الملغى في النسخ الجديدة
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _onAppBarBack(); // نرجعه للصفحة الرئيسية عند محاولة الرجوع
      },
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
        body: isPrefsLoading
            ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
            : Container(
          padding: const EdgeInsets.all(24.0),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 80, color: theme.primaryColor),
              const SizedBox(height: 20),
              Text(
                fixedLocationName,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.blackColor),
              ),
              const SizedBox(height: 10),
              const Text(
                "Click the button below to start navigation to the Casablanca International Fair (OFEC).",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _openMapNavigation,
                icon: const Icon(Icons.directions, color: Colors.white),
                label: const Text("Start Navigation", style: TextStyle(color: Colors.white, fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}