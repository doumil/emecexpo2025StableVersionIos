// lib/get_there_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:emecexpo/providers/theme_provider.dart';

class GetThereScreen extends StatelessWidget {
  const GetThereScreen({Key? key}) : super(key: key);

  // إحداثيات الموقع (كمثال لـ Casablanca Expo)
  final String lat = "33.5889";
  final String lng = "-7.6114";
  final String label = "EMEC EXPO";

  Future<void> _openMap() async {
    // رابط يشتغل على Android (Google Maps) و iOS (Apple Maps)
    final Uri googleMapsUrl = Uri.parse("google.navigation:q=$lat,$lng");
    final Uri appleMapsUrl = Uri.parse("https://maps.apple.com/?q=$label&ll=$lat,$lng");

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
      } else if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(appleMapsUrl);
      } else {
        // إذا لم يجد تطبيق خرائط، يفتح المتصفح
        final Uri browserUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
        await launchUrl(browserUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Error opening maps: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('How to get there'),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.whiteColor,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 100, color: theme.primaryColor),
            const SizedBox(height: 20),
            Text(
              "Visit us at EMEC EXPO",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.blackColor),
            ),
            const SizedBox(height: 10),
            const Text(
              "Click the button below to start navigation using your favorite maps app.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _openMap,
              icon: const Icon(Icons.directions, color: Colors.white),
              label: const Text("Start Navigation", style: TextStyle(color: Colors.white, fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}