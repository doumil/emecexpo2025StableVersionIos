import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:emecexpo/providers/theme_provider.dart';

class InstagramScreen extends StatelessWidget {
  const InstagramScreen({Key? key}) : super(key: key);

  // وظيفة لفتح الإنستغرام
  Future<void> _launchInstagram() async {
    const String nativeUrl = "instagram://user?username=emecexpo";
    const String webUrl = "https://www.instagram.com/emecexpo/";

    try {
      // كايحاول يفتح التطبيق ديال إنستغرام مباشرة
      if (await canLaunchUrl(Uri.parse(nativeUrl))) {
        await launchUrl(Uri.parse(nativeUrl), mode: LaunchMode.externalApplication);
      } else {
        // إذا ماكانش التطبيق، كايفتحو في المتصفح الخارجي
        await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Could not launch Instagram: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Follow us on Instagram'),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.whiteColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // لوغو إنستغرام أو أيقونة جذابة
              const Icon(
                Icons.camera_alt_outlined,
                size: 100,
                color: Color(0xffe1306c), // لون إنستغرام الرسمي
              ),
              const SizedBox(height: 20),
              Text(
                "@emecexpo",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.blackColor,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Join our community to see the latest updates, highlights, and behind-the-scenes content from EMEC EXPO.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _launchInstagram,
                icon: const Icon(Icons.open_in_new, color: Colors.white),
                label: const Text(
                  "Open Instagram",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffe1306c),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}