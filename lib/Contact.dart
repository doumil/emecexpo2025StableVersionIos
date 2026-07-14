import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:emecexpo/api_services/event_contact_api_service.dart';
import 'package:emecexpo/model/event_contact_model.dart';
import '../providers/theme_provider.dart';
import '../main.dart';
import '../model/app_theme_data.dart';
import 'global/app_config.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final EventContactApiService _apiService = EventContactApiService();
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchAllData();
  }

  Future<Map<String, dynamic>> _fetchAllData() async {
    final eventDetails = await _apiService.fetchEventDetails();

    final response = await http.get(Uri.parse(AppConfig.appSettingsUrl));
    String email = "N/A";
    String phone = "N/A";

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      email = json['data']['contact_email']['value'] ?? "N/A";
      phone = json['data']['support_phone']['value'] ?? "N/A";
    }

    return {'event': eventDetails, 'email': email, 'phone': phone};
  }

  Future<void> _launchMapUrl(String address) async {
    // الرابط اللي طلبتي
    final Uri url = Uri.parse('https://www.google.com/maps/place/DoubleTree+by+Hilton+Casablanca+City+Centre/@33.5957982,-7.6026141,17z/data=!4m9!3m8!1s0xda7cd8eb45d3459:0x52164eacaf45beb2!5m2!4m1!1i2!8m2!3d33.5957938!4d-7.6000392!16s%2Fg%2F11mstmwb5b?entry=ttu&g_ep=EgoyMDI2MDYxNi4wIKXMDSoASAFQAw%3D%3D?q=${Uri.encodeComponent(address)}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString("Data", "99");
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomPage()));
          },
        ),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.whiteColor,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: theme.primaryColor));
          }
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));

          final data = snapshot.data!;
          return _buildContent(context, theme, data['event'], data['email'], data['phone']);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppThemeData theme, EventContactModel eventData, String email, String phone) {
    String formatDate(String dateString) {
      final dateTime = DateTime.tryParse(dateString);
      if (dateTime == null) return dateString;
      final monthMap = {1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr', 5: 'May', 6: 'Jun', 7: 'Jul', 8: 'Aug', 9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec'};
      return '${dateTime.day} ${monthMap[dateTime.month]}, ${dateTime.year}';
    }

    String modifiedEndDate = eventData.scheduledEndDate;
    final endDateTime = DateTime.tryParse(eventData.scheduledEndDate);
    if (endDateTime != null && endDateTime.day == 22) {
      modifiedEndDate = DateTime(endDateTime.year, endDateTime.month, 21).toIso8601String();
    }

    const String locationAddress = 'DoubleTree by Hilton Casablanca City Centre';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Card(
              margin: const EdgeInsets.only(bottom: 20.0),
              color: theme.whiteColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.network(
                  '${AppConfig.logoBaseUrl}${eventData.logoName}',
                  height: 150,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 75),
                ),
              ),
            ),
          ),

          Text('Opening time', style: TextStyle(fontSize: 18, color: theme.primaryColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Card(
            margin: const EdgeInsets.only(bottom: 20.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildContactInfoRow(icon: Icons.access_time, text: 'Start Day: ${formatDate(eventData.scheduledStartDate)} (9h to 19h)', theme: theme),
                  const Divider(),
                  _buildContactInfoRow(icon: Icons.access_time, text: 'Last Day: ${formatDate(modifiedEndDate)} (9h to 19h)', theme: theme),
                ],
              ),
            ),
          ),

          Text('The Exhibition\'s location', style: TextStyle(fontSize: 18, color: theme.primaryColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Card(
            margin: const EdgeInsets.only(bottom: 20.0),
            child: InkWell(
              onTap: () => _launchMapUrl(locationAddress),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildContactInfoRow(icon: Icons.map, text: locationAddress, theme: theme, isClickable: true),
              ),
            ),
          ),

          Text('CONTACT', style: TextStyle(fontSize: 18, color: theme.primaryColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  _buildContactInfoRow(icon: Icons.phone, text: phone, theme: theme),
                  const Divider(),
                  _buildContactInfoRow(icon: Icons.email_outlined, text: email, theme: theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoRow({required IconData icon, required String text, required AppThemeData theme, bool isClickable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 24, color: theme.secondaryColor),
          const SizedBox(width: 15),
          Expanded(child: Text(text, style: TextStyle(fontSize: 16))),
          if (isClickable) const Icon(Icons.open_in_new, size: 20, color: Colors.grey),
        ],
      ),
    );
  }
}