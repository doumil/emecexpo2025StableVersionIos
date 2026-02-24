// lib/home_screen.dart

import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

// NOTE: Assuming these imports exist and are correct
import 'package:emecexpo/services/onwillpop_services.dart';
import 'package:emecexpo/constants.dart'; // Should contain DrawerSections enum
import 'package:emecexpo/model/user_model.dart';
import 'package:emecexpo/login_screen.dart';
import 'package:emecexpo/providers/menu_provider.dart';
import 'package:emecexpo/providers/theme_provider.dart';
import 'model/app_theme_data.dart'; // Assuming AppThemeData is defined here or accessible

// --- HELPER CLASS FOR MENU ITEMS ---
class MenuItem {
  final String title;
  final IconData icon;
  final DrawerSections section;
  final bool isCustomCard; // Flag for the special layout rule (first card is big)

  MenuItem({
    required this.title,
    required this.icon,
    required this.section,
    this.isCustomCard = false,
  });
}
// ----------------------------------------

class HomeScreen extends StatefulWidget {
  final User? user;
  final OnNavigateCallback onNavigate; // Assumed definition: typedef void OnNavigateCallback(DrawerSections section);

  const HomeScreen({Key? key, this.user, required this.onNavigate})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _loggedInUser;
  // Initialize prefs as late, it will be set in _initializeUserAndToken
  late SharedPreferences prefs;

  static const String _bannerImageUrl =
      'https://buzzevents.co/uploads/800x400-EMECEXPO-2025.jpg';

  @override
  void initState() {
    super.initState();
    _initializeUserAndToken();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false).fetchMenuConfig();
    });
  }

  // Helper to initialize SharedPreferences and user data
  _initializeUserAndToken() async {
    prefs = await SharedPreferences.getInstance();
    User? userFromWidget = widget.user;
    User? userFromPrefs;

    final String? userJsonString = prefs.getString('currentUserJson');
    if (userJsonString != null) {
      try {
        final Map<String, dynamic> userMap = json.decode(userJsonString);
        userFromPrefs = User.fromJson(userMap);
      } catch (e) {
        debugPrint("Error parsing stored user JSON: $e");
        await prefs.remove('currentUserJson');
      }
    }

    setState(() {
      _loggedInUser = userFromWidget ??
          userFromPrefs ??
          User(
            id: 0,
            name: "Guest",
            nom: "User",
            prenom: "",
            email: "guest@example.com",
          );
    });
  }

  // 💡 CORRECTED: Actual logout logic. We call getInstance() to ensure prefs is initialized.
  Future<void> _logoutConfirmed() async {
    // Re-initialize prefs to guarantee it's not null/uninitialized (Fixes the syntax issue)
    prefs = await SharedPreferences.getInstance();

    // Perform the logout actions
    await prefs.remove('authToken');
    await prefs.remove('currentUserJson');

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  // 💡 NEW: Function to show the confirmation dialog
  Future<void> _showLogoutConfirmationDialog(BuildContext context, AppThemeData theme) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to log out of your account?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: theme.primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: Text(
                'Logout',
                style: TextStyle(color: theme.secondaryColor, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog first
                _logoutConfirmed(); // Execute the actual logout logic
              },
            ),
          ],
        );
      },
    );
  }

  // Helper method to map MenuConfig booleans to a final, filtered List<MenuItem>
  List<MenuItem> _getVisibleMenuItems(MenuConfig menuConfig) {
    // Define all possible items. The order here determines the layout order.
    // 💡 CHANGE: 'My Agenda' moved to the 3rd spot to be one of the small cards.
    // 'Exhibitors' is moved down to the 4th spot.
    final List<Map<String, dynamic>> allItems = [
      // 1. BIG CARD: My Badge (Custom card flag set)
      {'title': 'My Badge', 'icon': Icons.qr_code_scanner, 'section': DrawerSections.myBadge, 'field': menuConfig.badge, 'custom': true},

      // 2. SMALL CARD 1: Floor Plan
      {'title': 'Floor Plan', 'icon': Icons.location_on_outlined, 'section': DrawerSections.eFP, 'field': menuConfig.floorPlan},

      // 3. SMALL CARD 2: My Agenda (NEWLY PRIORITIZED)
      {'title': 'My Agenda', 'icon': Icons.calendar_today_outlined, 'section': DrawerSections.myAgenda, 'field': menuConfig.program},

      // 4. REST OF ITEMS (Order doesn't matter for the first row anymore, but maintained for the rest)
      {'title': 'Exhibitors', 'icon': Icons.store_mall_directory_outlined, 'section': DrawerSections.exhibitors, 'field': menuConfig.exhibitors},
      {'title': 'Networking', 'icon': Icons.people_outline, 'section': DrawerSections.networking, 'field': menuConfig.networking},
      {'title': 'Products', 'icon': Icons.category_outlined, 'section': DrawerSections.products, 'field': menuConfig.products},
      {'title': 'Conferences', 'icon': Icons.account_balance, 'section': DrawerSections.congresses, 'field': menuConfig.congresses},
      {'title': 'Speakers', 'icon': Icons.person_outline, 'section': DrawerSections.speakers, 'field': menuConfig.speakers},
      {'title': 'Partners', 'icon': Icons.handshake_outlined, 'section': DrawerSections.partners, 'field': menuConfig.partners},
      {'title': 'Sponsors', 'icon': Icons.favorite_outline, 'section': DrawerSections.sponsors, 'field': menuConfig.sponsors},
    ];

    // Filter items where the API field is explicitly true
    return allItems
        .where((item) => item['field'] == true)
        .map((item) => MenuItem(
      title: item['title'] as String,
      icon: item['icon'] as IconData,
      section: item['section'] as DrawerSections,
      isCustomCard: item['custom'] == true,
    ))
        .toList();
  }

  // Single, flexible card builder
  Widget _buildFlexibleMenuCard({
    required BuildContext context,
    required MenuItem item,
    required double cardHeight,
    required double iconSize,
    required double fontSize,
    required double horizontalPadding,
    required ThemeProvider themeProvider,
    bool isWide = false,
  }) {
    final theme = themeProvider.currentTheme;

    // 💡 FIX: Force center alignment if this is the wide 'My Badge' card.
    // Otherwise, use center for standard cards, or start for other wide cards.
    CrossAxisAlignment alignment = CrossAxisAlignment.center;
    if (isWide && item.title != 'My Badge') {
      alignment = CrossAxisAlignment.start;
    }

    return GestureDetector(
      onTap: () {
        widget.onNavigate(item.section);
      },
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: theme.whiteColor.withOpacity(0.2)),
        ),
        padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding, vertical: isWide ? 15 : 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: alignment, // Use the determined alignment
          children: <Widget>[
            Icon(
              item.icon,
              size: iconSize,
              color: theme.secondaryColor,
            ),
            SizedBox(height: isWide ? 12.0 : 8.0),
            Text(
              item.title,
              textAlign: alignment == CrossAxisAlignment.start ? TextAlign.left : TextAlign.center,
              style: TextStyle(
                color: theme.whiteColor,
                fontSize: fontSize,
                fontWeight: isWide ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    return Consumer<MenuProvider>(
      builder: (context, menuProvider, child) {
        final menuConfig = menuProvider.menuConfig;

        if (menuConfig == null) {
          return Scaffold(
            backgroundColor: theme.blackColor,
            body: Center(
                child: CircularProgressIndicator(
                  color: theme.secondaryColor,
                )),
          );
        }

        // 1. Get the final, filtered list of items
        final List<MenuItem> allVisibleMenuItems = _getVisibleMenuItems(menuConfig);
        final int itemCount = allVisibleMenuItems.length;

        // --- Dynamic Layout Generation ---
        final List<Widget> menuWidgets = [];
        int index = 0;
        final double hSpacing = width * 0.03;
        final double vSpacing = height * 0.025;

        if (itemCount > 0) {
          // Original layout logic: Special layout if total items are odd OR the first item is marked 'custom' (My Badge) AND there are 3+ items.
          // This logic remains to trigger the desired 3-card layout (1 big, 2 small) if the top three are visible.
          bool isFirstRowSpecial = ((itemCount % 2 != 0) || allVisibleMenuItems[0].isCustomCard) && itemCount >= 3;

          if (isFirstRowSpecial) {
            // Layout 1: Big Card (index 0 - My Badge) + 2 Small Cards (Floor Plan, My Agenda)

            // Check if the required 3 items exist and are enabled
            if (itemCount >= 3 && allVisibleMenuItems[0].isCustomCard) {
              final bigCard = _buildFlexibleMenuCard(
                context: context,
                item: allVisibleMenuItems[index], // My Badge
                cardHeight: height * 0.28,
                iconSize: 60,
                fontSize: 22.0,
                horizontalPadding: width * 0.05,
                themeProvider: themeProvider,
                isWide: true,
              );

              final smallCard1 = _buildFlexibleMenuCard(
                context: context,
                item: allVisibleMenuItems[index + 1], // Floor Plan
                cardHeight: height * 0.13,
                iconSize: 40,
                fontSize: 15.0,
                horizontalPadding: width * 0.08,
                themeProvider: themeProvider,
              );

              final smallCard2 = _buildFlexibleMenuCard(
                context: context,
                item: allVisibleMenuItems[index + 2], // My Agenda
                cardHeight: height * 0.13,
                iconSize: 40,
                fontSize: 15.0,
                horizontalPadding: width * 0.08,
                themeProvider: themeProvider,
              );

              // Assemble the special row
              menuWidgets.add(
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: bigCard), // ~60% width
                    SizedBox(width: hSpacing),
                    Expanded(
                      flex: 2, // ~40% width
                      child: Column(
                        children: [
                          smallCard1,
                          SizedBox(height: height * 0.018),
                          smallCard2,
                        ],
                      ),
                    ),
                  ],
                ),
              );
              menuWidgets.add(SizedBox(height: vSpacing));
              index += 3; // Advance index by 3
            }
          } else if (itemCount >= 2 && index == 0) {
            // Layout 2: Two equal cards (For the first row if it's not the special 3-card layout)
            final card1 = _buildFlexibleMenuCard(
              context: context,
              item: allVisibleMenuItems[index],
              cardHeight: height * 0.2,
              iconSize: 40,
              fontSize: 15.0,
              horizontalPadding: width * 0.03,
              themeProvider: themeProvider,
            );
            final card2 = _buildFlexibleMenuCard(
              context: context,
              item: allVisibleMenuItems[index + 1],
              cardHeight: height * 0.2,
              iconSize: 40,
              fontSize: 15.0,
              horizontalPadding: width * 0.03,
              themeProvider: themeProvider,
            );

            menuWidgets.add(
              Row(
                children: [
                  Expanded(child: card1),
                  SizedBox(width: hSpacing),
                  Expanded(child: card2),
                ],
              ),
            );
            menuWidgets.add(SizedBox(height: vSpacing));
            index += 2;
          } else if (itemCount == 1 && index == 0) {
            // Layout 3: Single card (If only one item exists)
            final singleCard = _buildFlexibleMenuCard(
              context: context,
              item: allVisibleMenuItems[index],
              cardHeight: height * 0.2,
              iconSize: 40,
              fontSize: 15.0,
              horizontalPadding: width * 0.03,
              themeProvider: themeProvider,
            );

            menuWidgets.add(
              Row(
                children: [
                  Expanded(child: singleCard),
                  Expanded(child: SizedBox()), // Fill space
                ],
              ),
            );
            menuWidgets.add(SizedBox(height: vSpacing));
            index += 1;
          }

          // Loop for remaining items (Always two per row, handling any remainder from the first row)
          while (itemCount - index >= 2) {
            final card1 = _buildFlexibleMenuCard(
              context: context,
              item: allVisibleMenuItems[index],
              cardHeight: height * 0.2,
              iconSize: 40,
              fontSize: 15.0,
              horizontalPadding: width * 0.03,
              themeProvider: themeProvider,
            );
            final card2 = _buildFlexibleMenuCard(
              context: context,
              item: allVisibleMenuItems[index + 1],
              cardHeight: height * 0.2,
              iconSize: 40,
              fontSize: 15.0,
              horizontalPadding: width * 0.03,
              themeProvider: themeProvider,
            );

            menuWidgets.add(
              Row(
                children: [
                  Expanded(child: card1),
                  SizedBox(width: hSpacing),
                  Expanded(child: card2),
                ],
              ),
            );
            menuWidgets.add(SizedBox(height: vSpacing));
            index += 2;
          }

          // Handle the final single card
          if (itemCount - index == 1) {
            final singleCard = _buildFlexibleMenuCard(
              context: context,
              item: allVisibleMenuItems[index],
              cardHeight: height * 0.2,
              iconSize: 40,
              fontSize: 15.0,
              horizontalPadding: width * 0.03,
              themeProvider: themeProvider,
            );

            menuWidgets.add(
              Row(
                children: [
                  Expanded(child: singleCard),
                  Expanded(child: SizedBox()),
                ],
              ),
            );
            menuWidgets.add(SizedBox(height: vSpacing));
          }
        }
        // --- END Dynamic Layout Generation ---


        return WillPopScope(
          onWillPop: OnWillPop().onWillPop1,
          child: Scaffold(
            appBar: AppBar(
              title: Center(
                child: Text(
                  'Welcome, ${_loggedInUser?.prenom ?? _loggedInUser?.name ??'Guest'}!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.whiteColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              backgroundColor: theme.blackColor,
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.logout,
                    color: theme.whiteColor,
                  ),
                  onPressed: () {
                    // 💡 Call the confirmation dialog
                    _showLogoutConfirmationDialog(context, theme);
                  },
                  tooltip: 'Logout',
                ),
              ],
              elevation: 0,
            ),
            body: LayoutBuilder(
              builder: (BuildContext context,
                  BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.blackColor,
                            theme.primaryColor.withOpacity(0.9),
                          ],
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: width * 0.04, vertical: height * 0.02),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // DYNAMIC BANNER IMAGE
                          Container(
                            padding: EdgeInsets.fromLTRB(
                                width * 0.04, width * 0.04, width * 0.04,
                                width * 0.01),
                            child: Image.network(
                              _bannerImageUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: LinearProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                        null
                                        ? loadingProgress
                                        .cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: theme.secondaryColor,
                                    backgroundColor:
                                    theme.whiteColor.withOpacity(0.3),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                    "assets/banner.png", fit: BoxFit.contain);
                              },
                            ),
                          ),

                          SizedBox(height: height * 0.02),

                          // DYNAMIC MENU WIDGETS
                          ...menuWidgets,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}