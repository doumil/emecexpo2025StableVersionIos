// lib/screens/details/DetailSessionScreen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../model/speakers_model.dart';
// Note: Keeping this import for the AppThemeData type hint in the helper function
import '../../model/app_theme_data.dart';
import '../../providers/theme_provider.dart'; // Correct relative import

class DetailSessionScreen extends StatelessWidget {
  final ProgramSession session;

  const DetailSessionScreen({Key? key, required this.session}) : super(key: key);

  // Helper to format the time range (remains the same)
  String _formatTimeRange(ProgramSession session) {
    final DateFormat sessionInputFormat = DateFormat('MM/dd/yyyy h:mm a');
    try {
      final DateTime start = sessionInputFormat.parse(session.dateDeb);
      final DateTime end = sessionInputFormat.parse(session.dateFin);

      final DateFormat fullDateFormat = DateFormat('EEE, dd MMM yyyy', 'fr_FR');
      final String datePart = fullDateFormat.format(start);

      final String timeRange = "${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}";

      return "$datePart | $timeRange";

    } catch (_) {
      return "Date et heure non disponibles";
    }
  }

  // New helper function for Time and Location Section
  Widget _buildTimeAndLocationSection(AppThemeData theme, Color primaryContentColor, Color accentContentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date and Time
        Text(
          'Date & Time',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryContentColor.withOpacity(0.9)),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200], // Standard lighter grey for neutral background
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 20, color: accentContentColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _formatTimeRange(session),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: primaryContentColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),

        // Location
        if (session.emplacement?.isNotEmpty == true) ...[
          Text(
            'Location',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryContentColor.withOpacity(0.9)),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200], // Standard lighter grey for neutral background
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 20, color: Colors.grey), // Standard grey for location icon
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    session.emplacement!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: primaryContentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    final Color primaryContentColor = theme.blackColor;
    final Color accentContentColor = theme.secondaryColor;
    final Color cardBackgroundColor = theme.whiteColor;

    // Fallback for session title
    final String sessionTitle = session.nom.isNotEmpty ? session.nom : "Session Title";
    final String sessionType = session.type.isNotEmpty ? session.type : "General Session";


    return Scaffold(
      backgroundColor: Colors.grey[100], // Standard light grey background
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        // 💡 THEMED: Use theme.whiteColor for icons/text in the app bar
        iconTheme: IconThemeData(color: theme.whiteColor),
        elevation: 0,
        title: Center(
          child: Text(
            'Session Details',
            style: TextStyle(color: theme.whiteColor, fontWeight: FontWeight.bold), // 💡 THEMED
          ),
        ),
        leading: IconButton(
          // 💡 THEMED: Use theme.whiteColor
          icon: Icon(Icons.arrow_back_ios, color: theme.whiteColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            // --- Session Header Card (Similar to Speaker Profile Section) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                color: cardBackgroundColor, // White background for the card area
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Placeholder Icon/Image for the Session (using a Stack similar to speaker image)
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: accentContentColor.withOpacity(0.1),
                        child: Icon(Icons.mic_external_on, size: 40, color: accentContentColor),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          // Display session type icon
                          child: Icon(Icons.label_important, size: theme.blackColor.computeLuminance() > 0.5 ? 20 : 18, color: theme.whiteColor), // 💡 THEMED
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Session Title
                  Text(
                    sessionTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryContentColor,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Session Type Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentContentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      sessionType.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: accentContentColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- Session Details/Bio Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Time and Location (Moved to its own dedicated section for clarity) ---
                  _buildTimeAndLocationSection(theme, primaryContentColor, accentContentColor),
                  const SizedBox(height: 25),

                  // --- Description Header ---
                  Text(
                    'Description',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryContentColor
                    ),
                  ),
                  const Divider(color: Colors.grey), // Standard grey divider

                  // --- Description Body ---
                  Text(
                    session.description.isNotEmpty ? session.description : 'Description non disponible pour cette session.',
                    style: TextStyle(
                        fontSize: 16,
                        color: primaryContentColor.withOpacity(0.7),
                        height: 1.5
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}