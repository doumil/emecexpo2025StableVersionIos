import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../api_services/speaker_api_service.dart';
import '../../model/speakers_model.dart';
import 'DetailSpeakeres.dart';
import '../model/program_model.dart';
import '../providers/theme_provider.dart';
import '../model/app_theme_data.dart';

class DetailProgramScreen extends StatelessWidget {
  final ProgramItemModel programItem;

  const DetailProgramScreen({Key? key, required this.programItem}) : super(key: key);

  String _formatDateTimeRange(String dateDeb, String dateFin) {
    if (dateDeb.isEmpty || dateFin.isEmpty) return 'Date et heure non disponibles';
    try {
      final inputFormat = DateFormat('MM/dd/yyyy h:mm a');
      final start = inputFormat.parse(dateDeb);
      final end = inputFormat.parse(dateFin);
      final datePart = DateFormat('EEE, dd MMM yyyy', 'fr_FR').format(start);
      final timeRange = "${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}";
      return "$datePart | $timeRange";
    } catch (e) {
      return "Date et heure non disponibles";
    }
  }

  Widget _buildTimeAndLocationSection(AppThemeData theme, Color primaryContentColor, Color accentContentColor) {
    final String formattedTime = _formatDateTimeRange(programItem.dateDeb, programItem.dateFin);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date & Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryContentColor.withOpacity(0.9))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 20, color: accentContentColor),
              const SizedBox(width: 10),
              Expanded(child: Text(formattedTime, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: primaryContentColor))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpeakerListSection(BuildContext context, AppThemeData theme, Color primaryContentColor, Color accentContentColor) {
    if (programItem.speakers.isEmpty) return const SizedBox.shrink();
    final String imageBaseUrl = SpeakerApiService.imageBaseUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(programItem.speakers.length > 1 ? 'Speakers' : 'Speaker', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryContentColor.withOpacity(0.9))),
        const SizedBox(height: 8),
        ...programItem.speakers.map((speaker) {
          final String finalImageUrl = imageBaseUrl + (speaker.pic?.isNotEmpty == true ? speaker.pic! : 'ICON-EMEC.png');

          return Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Card(
              margin: EdgeInsets.zero,
              color: Colors.grey[200],
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  final List<String> nameParts = speaker.fullName.trim().split(' ');
                  // 🚀 الانتقال مع تمرير الـ Speaker و قائمة periods فارغة لتفادي الـ Crash
                  Navigator.push(context, MaterialPageRoute(builder: (context) => DetailSpeakersScreen(
                    speaker: Speakers(
                      id: speaker.id,
                      nom: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : speaker.fullName,
                      prenom: nameParts.isNotEmpty ? nameParts.first : '',
                      poste: speaker.poste,
                      compagnie: '',
                      pic: speaker.pic,
                      biographie: '',
                      isFavorite: false,
                      isRecommended: false,
                    ),
                    periods: const [],
                  )));
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 25, backgroundColor: accentContentColor.withOpacity(0.2), child: ClipOval(child: Image.network(finalImageUrl, fit: BoxFit.cover, width: 50, height: 50, errorBuilder: (_, __, ___) => Icon(Icons.person, color: theme.primaryColor)))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(speaker.fullName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primaryContentColor)),
                            Text(speaker.poste, style: TextStyle(fontSize: 14, color: primaryContentColor.withOpacity(0.7))),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 14, color: theme.blackColor.withOpacity(0.3)),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: theme.whiteColor), onPressed: () => Navigator.pop(context)), backgroundColor: theme.primaryColor, title: const Text('Session Details', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(color: theme.whiteColor, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 7)]),
              child: Column(children: [
                CircleAvatar(radius: 50, backgroundColor: theme.secondaryColor.withOpacity(0.1), child: Icon(Icons.mic_external_on, size: 40, color: theme.secondaryColor)),
                const SizedBox(height: 15),
                Text(programItem.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: theme.secondaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(5)), child: Text(programItem.type.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: theme.secondaryColor))),
              ]),
            ),
            const SizedBox(height: 20),
            _buildTimeAndLocationSection(theme, theme.blackColor, theme.secondaryColor),
            const SizedBox(height: 25),
            _buildSpeakerListSection(context, theme, theme.blackColor, theme.secondaryColor),
            const SizedBox(height: 25),
            const Text('Description', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            Text(programItem.description.isNotEmpty ? programItem.description : 'Description non disponible.', style: TextStyle(fontSize: 16, color: theme.blackColor.withOpacity(0.7), height: 1.5), textAlign: TextAlign.justify),
          ],
        ),
      ),
    );
  }
}