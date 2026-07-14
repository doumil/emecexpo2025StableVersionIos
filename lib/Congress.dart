// lib/screens/congress_screen.dart
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import 'package:emecexpo/providers/theme_provider.dart';
import 'details/CongressMenu.dart';
import 'model/app_theme_data.dart';
import 'model/congress_model.dart';

class CongressScreen extends StatefulWidget {
  const CongressScreen({Key? key}) : super(key: key);

  @override
  _CongressScreenState createState() => _CongressScreenState();
}

class _CongressScreenState extends State<CongressScreen> {
  List<CongressClass> _allSessions = [];
  List<CongressClass> litems = [];
  bool isLoading = true;
  int _selectedDateIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _getDateStringFromIndex(int index) {
    switch (index) {
      case 0: return "lun., 14 avr. 2025";
      case 1: return "mar., 15 avr. 2025";
      case 2: return "mer., 16 avr. 2025";
      default: return "";
    }
  }

  void _updateFilteredSessions() {
    String selectedDate = _getDateStringFromIndex(_selectedDateIndex);
    litems = _allSessions.where((session) => session.date == selectedDate).toList();
  }

  _loadData() async {
    _allSessions.clear();

    _allSessions.add(
      CongressClass(
        id: 101,
        title: "Opening Ceremony",
        isSessionOver: false,
        date: "lun., 14 avr. 2025",
        time: "09:00 - 09:30 | Main Hall",
        location: "Main Hall",
        stage: "Main Stage",
        tags: ["Conference"],
        speakers: [Speaker(name: "John Doe", imageUrl: "assets/speakers/speaker1.png")],
      ),
    );
    _allSessions.add(
      CongressClass(
        id: 102,
        title: "AI in Healthcare",
        isSessionOver: false,
        date: "lun., 14 avr. 2025",
        time: "09:45 - 10:30 | Room A",
        location: "Room A",
        stage: "AI Stage",
        tags: ["AI", "Healthcare"],
        speakers: [Speaker(name: "Jane Smith", imageUrl: "assets/speakers/speaker2.png")],
      ),
    );
    _allSessions.add(
      CongressClass(
        id: 103,
        title: "Morning Keynote: Innovation",
        isSessionOver: false,
        date: "lun., 14 avr. 2025",
        time: "10:45 - 11:30 | Auditorium",
        location: "Auditorium",
        stage: "Main Stage",
        tags: ["Innovation", "Keynote"],
        speakers: [Speaker(name: "Dr. Alex Lee", imageUrl: "assets/speakers/speaker5.png")],
      ),
    );
    _allSessions.add(
      CongressClass(
        id: 201,
        title: "Future of Blockchain",
        isSessionOver: false,
        date: "mar., 15 avr. 2025",
        time: "10:00 - 10:45 | Room B",
        location: "Room B",
        stage: "Blockchain Stage",
        tags: ["Blockchain", "Fintech"],
        speakers: [Speaker(name: "Alice Brown", imageUrl: "assets/speakers/speaker3.png")],
      ),
    );
    _allSessions.add(
      CongressClass(
        id: 1,
        title: "Opening | Welcome Address",
        isSessionOver: true,
        date: "mer., 16 avr. 2025",
        time: "10:15 - 10:20 | Africa(Casablanca time)",
        location: "GITEX Africa/Ai Stage",
        stage: "Ai Stage",
        tags: ["GITEX Africa"],
        speakers: [
          Speaker(name: "Speaker One", imageUrl: "assets/speakers/speaker1.png"),
        ],
      ),
    );
    _allSessions.add(
      CongressClass(
        id: 2,
        title: "Keynote Session",
        isSessionOver: false,
        date: "mer., 16 avr. 2025",
        time: "10:30 - 11:00 | Africa(Casablanca time)",
        location: "Main Stage",
        stage: "Main Stage",
        tags: ["AI Innovation"],
        speakers: [
          Speaker(name: "Speaker Two", imageUrl: "assets/speakers/speaker2.png"),
          Speaker(name: "Speaker Three", imageUrl: "assets/speakers/speaker3.png"),
        ],
      ),
    );

    _updateFilteredSessions();

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 💡 جلب الـ Provider والـ currentTheme بطريقة صحيحة وآمنة
    final themeProvider = Provider.of<ThemeProvider>(context);
    final AppThemeData theme = themeProvider.currentTheme;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Conferences",
          style: TextStyle(
              color: theme.whiteColor,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
                Icons.filter_list,
                color: theme.whiteColor
            ),
            onPressed: () {
              print("Filter button pressed");
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: SpinKitThreeBounce(
          color: theme.secondaryColor,
          size: 30.0,
        ),
      )
          : Column(
        children: [
          // --- Search Bar ---
          Container(
            color: theme.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Recherche',
                hintStyle: TextStyle(color: theme.whiteColor.withOpacity(0.6)),
                prefixIcon: Icon(Icons.search, color: theme.whiteColor.withOpacity(0.6)),
                filled: true,
                fillColor: theme.whiteColor.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              ),
              style: TextStyle(color: theme.whiteColor),
            ),
          ),
          // --- Date Selection ---
          Container(
            color: theme.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 💡 تم إصلاح المشكلة هنا: صيفطنا الـ theme مباشرة بلا كاستينغ عشوائي
                _buildDateSelector(0, "14", "AVR.", theme),
                _buildDateSelector(1, "15", "AVR.", theme),
                _buildDateSelector(2, "16", "AVR.", theme),
              ],
            ),
          ),
          // --- Main Content (Sessions and Speakers) ---
          Expanded(
            child: ListView.builder(
              itemCount: litems.length,
              itemBuilder: (context, index) {
                final session = litems[index];
                return _buildSessionCard(session, theme);
              },
            ),
          ),
        ],
      ),
    );
  }

  // 💡 تم تعديل الـ Signature باش تاخد AppThemeData نيشان وتفادي الـ Crash
  Widget _buildDateSelector(int index, String day, String month, AppThemeData theme) {
    bool isSelected = _selectedDateIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDateIndex = index;
          _updateFilteredSessions();
        });
      },
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? theme.whiteColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: isSelected ? Colors.transparent : theme.whiteColor.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              day,
              style: TextStyle(
                color: isSelected ? theme.primaryColor : theme.whiteColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              month,
              style: TextStyle(
                color: isSelected ? theme.primaryColor : theme.whiteColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(CongressClass session, AppThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: theme.whiteColor,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (session.location != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        session.location!,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              session.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.blackColor,
              ),
            ),
            const SizedBox(height: 5),
            if (session.isSessionOver)
              Text(
                'Session is over',
                style: TextStyle(color: theme.redColor, fontSize: 14, fontWeight: FontWeight.bold),
              )
            else ...[
              if (session.date != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 18, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        session.date!,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              if (session.time != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, size: 18, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          session.time!,
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              if (session.stage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Row(
                    children: [
                      const Icon(Icons.place, size: 18, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          session.stage!,
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 10),
            if (session.tags != null && session.tags!.isNotEmpty)
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: session.tags!.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: theme.blackColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                          fontSize: 12,
                          color: theme.blackColor),
                    ),
                  );
                }).toList(),
              ),
            if (session.speakers != null && session.speakers!.isNotEmpty) ...[
              const SizedBox(height: 15),
              Text(
                'Speakers',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.blackColor.withOpacity(0.87),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: session.speakers!.map((speaker) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Column(
                        children: [
                          ClipOval(
                            child: Image.asset(
                              speaker.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person_outline, size: 50, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            speaker.name,
                            style: TextStyle(
                                fontSize: 12,
                                color: theme.blackColor.withOpacity(0.54)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}