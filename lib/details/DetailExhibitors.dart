import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:emecexpo/model/exhibitors_model.dart';
import 'package:emecexpo/api_services/exhibitor_api_service.dart';
import 'package:emecexpo/providers/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailExhibitorsScreen extends StatefulWidget {
  final int exhibitorId;

  const DetailExhibitorsScreen({Key? key, required this.exhibitorId}) : super(key: key);

  @override
  _DetailExhibitorsScreenState createState() => _DetailExhibitorsScreenState();
}

class _DetailExhibitorsScreenState extends State<DetailExhibitorsScreen> {
  ExhibitorsClass? _currentExhibitor;
  bool isLoading = true;
  final ExhibitorApiService _apiService = ExhibitorApiService();

  @override
  void initState() {
    super.initState();
    _loadExhibitorDetails();
  }

  _loadExhibitorDetails() async {
    try {
      final List<ExhibitorsClass> allExhibitors = await _apiService.getExhibitors();
      setState(() {
        _currentExhibitor = allExhibitors.firstWhere(
              (exhibitor) => exhibitor.id == widget.exhibitorId,
          orElse: () => ExhibitorsClass(-1, '', '', '', '', '', '', '', false, false),
        );
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // الدالة اللي كتفلتر كلشي: يلا كانت N/A أو خاوية كترجع false
  bool _isDataValid(String? value) {
    if (value == null) return false;
    final trimmed = value.trim();
    return trimmed.isNotEmpty &&
        trimmed.toUpperCase() != 'N/A' &&
        trimmed.toUpperCase() != 'NOT SPECIFIED' &&
        trimmed != '-';
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString.startsWith('http') ? urlString : 'https://$urlString');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final primaryColor = theme.primaryColor;
    final secondaryColor = theme.secondaryColor;

    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator(color: secondaryColor)));
    }

    // يلا مالقيناش العارض، كنخرجوه من الصفحة بلا ما نبينو رسالة خطأ
    if (_currentExhibitor == null || _currentExhibitor!.id == -1) {
      return Scaffold(appBar: AppBar(backgroundColor: primaryColor), body: const Center(child: Text("No details available")));
    }

    final exhibitor = _currentExhibitor!;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: primaryColor, elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 30),
                color: primaryColor,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        imageUrl: exhibitor.image,
                        width: width * 0.3,
                        height: width * 0.3,
                        fit: BoxFit.contain,
                        errorWidget: (_, __, ___) => const Icon(Icons.business, size: 80, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(exhibitor.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الـ About كيتحيد تماماً يلا كانت الداتا غير صالحة
                    if (_isDataValid(exhibitor.discriptions)) ...[
                      Text('About', style: TextStyle(color: primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(exhibitor.discriptions!, style: const TextStyle(fontSize: 16, height: 1.5)),
                      const SizedBox(height: 20),
                    ],

                    // أي row خاوي ما كيترسمش كاع
                    _buildInfoRow('Website', exhibitor.siteweb, secondaryColor),
                    _buildInfoRow('Stand', exhibitor.stand, secondaryColor),
                    _buildInfoRow('Address', exhibitor.adress, secondaryColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value, Color accentColor) {
    if (!_isDataValid(value)) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: InkWell(
              onTap: () => _launchUrl(value!),
              child: Text(value!, style: TextStyle(color: accentColor, decoration: label == 'Website' ? TextDecoration.underline : TextDecoration.none)),
            ),
          ),
        ],
      ),
    );
  }
}