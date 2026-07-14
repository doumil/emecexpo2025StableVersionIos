// lib/widgets/facebook_follow_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:emecexpo/providers/theme_provider.dart'; // Make sure this path is correct
import 'package:emecexpo/model/app_theme_data.dart'; // Assuming your AppThemeData is here

class FacebookScreen extends StatelessWidget {
  const FacebookScreen({super.key});

  static const String _facebookUrl = 'https://www.facebook.com/EMECEXPO';

  Future<void> _launchFacebookPage(BuildContext context) async {
    final Uri url = Uri.parse(_facebookUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch Facebook page.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    // Define Facebook blue color
    const Color facebookBlue = Color(0xFF1877F2);

    return GestureDetector(
      onTap: () => _launchFacebookPage(context),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          // Use a dark color for the card background, similar to the image
          color: Colors.grey.withOpacity(0.4), // Assuming darkColor is a dark grey/black
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.grey.withOpacity(0.2)), // Subtle border
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Circular Logo (EMECEXPO.png)
            ClipOval(
              child: Image.asset(
                'assets/emec.jpg', // Your EMEC EXPO logo
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.primaryColor.withOpacity(0.3),
                  child: Icon(Icons.public, color: theme.whiteColor, size: 30),
                ),
              ),
            ),
            const SizedBox(width: 12.0),

            // Middle: Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Take minimum space vertically
                children: [
                  Row(
                    children: [
                      Text(
                        'EMEC EXPO',
                        style: TextStyle(
                          color: theme.primaryColor, // Use primary text color
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // "Follow" button
                      TextButton(
                        onPressed: () => _launchFacebookPage(context),
                        style: TextButton.styleFrom(
                          foregroundColor: facebookBlue, // Facebook Blue for text color
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero, // Remove default padding
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrink tap area
                        ),
                        child: Text(
                          'Follow',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: facebookBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Internet Marketing Service',
                    style: TextStyle(
                      color: Colors.black45, // Use secondary text color
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '2K followers', // Or dynamically load this if possible
                    style: TextStyle(
                      color: Colors.black45, // Use secondary text color
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}