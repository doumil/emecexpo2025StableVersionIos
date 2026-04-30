import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:emecexpo/providers/theme_provider.dart';

class LINKEDINScreen extends StatelessWidget {
  const LINKEDINScreen({Key? key}) : super(key: key);

  Future<void> _launchLinkedIn() async {
    // رابط الشركة على لينكد إن
    const String profileUrl = "https://www.linkedin.com/company/emecexpo/";

    try {
      // كنفتحوه في المتصفح الخارجي أو تطبيق لينكد إن تلقائياً
      if (!await launchUrl(
        Uri.parse(profileUrl),
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not launch LinkedIn');
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LinkedIn Profile'),
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
              // أيقونة لينكد إن بلونها الرسمي
              const Icon(
                Icons.business_center,
                size: 100,
                color: Color(0xff0059b1),
              ),
              const SizedBox(height: 20),
              Text(
                "EMEC EXPO on LinkedIn",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.blackColor,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Stay updated with our professional news, exhibition highlights, and networking opportunities.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _launchLinkedIn,
                icon: const Icon(Icons.open_in_new, color: Colors.white),
                label: const Text(
                  "View LinkedIn Profile",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0059b1),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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