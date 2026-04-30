import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:emecexpo/providers/theme_provider.dart';

class FacebookScreen extends StatelessWidget {
  const FacebookScreen({super.key});

  // الروابط الخاصة بفيسبوك
  static const String _facebookWebUrl = 'https://www.facebook.com/EMECEXPO';
  static const String _facebookAppUrl = 'fb://facewebmodal/f?href=$_facebookWebUrl';

  Future<void> _launchFacebookPage(BuildContext context) async {
    final Uri appUri = Uri.parse(_facebookAppUrl);
    final Uri webUri = Uri.parse(_facebookWebUrl);

    try {
      // كيحاول يحل التطبيق أولاً
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
      } else {
        // إلى ماكانش التطبيق كايحل المتصفح
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch Facebook.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    const Color facebookBlue = Color(0xFF1877F2);

    return GestureDetector(
      onTap: () => _launchFacebookPage(context),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          // استعملنا الشفافية مع الألوان ديال الـ Theme باش يجي متناسق
          color: theme.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: theme.primaryColor.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            // اللوغو
            ClipRRect(
              borderRadius: BorderRadius.circular(10), // شكل عصري شوية
              child: Image.asset(
                'assets/emec.jpg',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => CircleAvatar(
                  radius: 30,
                  backgroundColor: facebookBlue.withOpacity(0.1),
                  child: const Icon(Icons.facebook, color: facebookBlue, size: 35),
                ),
              ),
            ),
            const SizedBox(width: 15.0),

            // المعلومات
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'EMEC EXPO',
                        style: TextStyle(
                          color: theme.blackColor, // استعملنا لون الـ Theme
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // علامة التوثيق (اختيارية كتعطي منظر زوين)
                      const Icon(Icons.verified, color: facebookBlue, size: 16),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Internet Marketing Service',
                    style: TextStyle(
                      color: theme.blackColor.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '2K followers',
                    style: TextStyle(
                      color: theme.blackColor.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // زر Follow الصغير
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: facebookBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Follow',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}