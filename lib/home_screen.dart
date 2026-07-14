// lib/home_screen.dart

import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:emecexpo/services/onwillpop_services.dart';
import 'package:emecexpo/constants.dart';
import 'package:emecexpo/model/user_model.dart';
import 'package:emecexpo/login_screen.dart';
import 'package:emecexpo/providers/menu_provider.dart';
import 'package:emecexpo/providers/theme_provider.dart';
import 'package:emecexpo/global/app_config.dart';
import 'model/app_theme_data.dart';
import 'main.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final DrawerSections section;
  final bool isCustomCard;
  final bool isEnabled;

  MenuItem({
    required this.title,
    required this.icon,
    required this.section,
    this.isCustomCard = false,
    required this.isEnabled,
  });
}

class HomeScreen extends StatefulWidget {
  final User? user;
  final OnNavigateCallback onNavigate;

  const HomeScreen({Key? key, this.user, required this.onNavigate}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _loggedInUser;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initializeUserAndToken();
  }

  Future<void> _initializeUserAndToken() async {
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

  Future<void> _logoutConfirmed() async {
    prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('currentUserJson');

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context, AppThemeData theme) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
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
              child: Text('Cancel', style: TextStyle(color: theme.primaryColor)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Logout', style: TextStyle(color: theme.secondaryColor, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
                _logoutConfirmed();
              },
            ),
          ],
        );
      },
    );
  }

  // 🟩 الترتيب السحري الجديد باش تجي My Agenda صغيورة ف الجنب د الـ Badge
  List<MenuItem> _getAllMenuItems(MenuConfig? menuConfig) {
    return [
      MenuItem(title: 'My Badge', icon: Icons.qr_code_scanner, section: DrawerSections.myBadge, isCustomCard: true, isEnabled: menuConfig?.badge ?? true), // Index 0 -> الكبيرة
      MenuItem(title: 'Floor Plan', icon: Icons.location_on_outlined, section: DrawerSections.eFP, isEnabled: menuConfig?.floorPlan ?? true), // Index 1 -> الصغيرة الأولى فوق ف الجنب
      MenuItem(title: 'My Agenda', icon: Icons.calendar_today_outlined, section: DrawerSections.myAgenda, isEnabled: menuConfig?.badge ?? true), // Index 2 -> الصغيرة الثانية تحتها ف الجنب 🎯
      MenuItem(title: 'Program', icon: Icons.event_note, section: DrawerSections.program, isEnabled: menuConfig?.program ?? true), // باقي الكروت كيجيو ف الـ Grid العادي متناسقين جوج بجوج
      MenuItem(title: 'Exhibitors', icon: Icons.store_mall_directory_outlined, section: DrawerSections.exhibitors, isEnabled: menuConfig?.exhibitors ?? true),
      MenuItem(title: 'Networking', icon: Icons.people_outline, section: DrawerSections.networking, isEnabled: menuConfig?.networking ?? true),
      MenuItem(title: 'Speakers', icon: Icons.person_outline, section: DrawerSections.speakers, isEnabled: menuConfig?.speakers ?? true),
      MenuItem(title: 'Partners', icon: Icons.handshake_outlined, section: DrawerSections.partners, isEnabled: menuConfig?.partners ?? true),
      MenuItem(title: 'Sponsors', icon: Icons.favorite_outline, section: DrawerSections.sponsors, isEnabled: menuConfig?.sponsors ?? true),
    ];
  }

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

    CrossAxisAlignment alignment = CrossAxisAlignment.center;
    if (isWide && item.title != 'My Badge') {
      alignment = CrossAxisAlignment.start;
    }

    return GestureDetector(
      onTap: item.isEnabled ? () => widget.onNavigate(item.section) : null,
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          color: item.isEnabled
              ? theme.primaryColor.withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
              color: item.isEnabled
                  ? theme.whiteColor.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05)
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: isWide ? 15 : 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: alignment,
          children: <Widget>[
            Icon(
              item.icon,
              size: iconSize,
              color: item.isEnabled ? theme.secondaryColor : Colors.white30,
            ),
            SizedBox(height: isWide ? 12.0 : 8.0),
            Text(
              item.title,
              textAlign: alignment == CrossAxisAlignment.start ? TextAlign.left : TextAlign.center,
              style: TextStyle(
                color: item.isEnabled ? theme.whiteColor : Colors.white30,
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
        final List<MenuItem> allMenuItems = _getAllMenuItems(menuConfig);
        final int itemCount = allMenuItems.length;

        final List<Widget> menuWidgets = [];
        int index = 0;
        final double hSpacing = width * 0.03;
        final double vSpacing = height * 0.025;

        if (itemCount > 0) {
          bool isFirstRowSpecial = ((itemCount % 2 != 0) || allMenuItems[0].isCustomCard) && itemCount >= 3;

          if (isFirstRowSpecial) {
            if (itemCount >= 3 && allMenuItems[0].isCustomCard) {
              final bigCard = _buildFlexibleMenuCard(
                context: context,
                item: allMenuItems[index],
                cardHeight: height * 0.28,
                iconSize: 60,
                fontSize: 22.0,
                horizontalPadding: width * 0.05,
                themeProvider: themeProvider,
                isWide: true,
              );

              final smallCard1 = _buildFlexibleMenuCard(
                context: context,
                item: allMenuItems[index + 1],
                cardHeight: height * 0.13,
                iconSize: 40,
                fontSize: 15.0,
                horizontalPadding: width * 0.08,
                themeProvider: themeProvider,
              );

              final smallCard2 = _buildFlexibleMenuCard(
                context: context,
                item: allMenuItems[index + 2],
                cardHeight: height * 0.13,
                iconSize: 40,
                fontSize: 15.0,
                horizontalPadding: width * 0.08,
                themeProvider: themeProvider,
              );

              menuWidgets.add(
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: bigCard),
                    SizedBox(width: hSpacing),
                    Expanded(
                      flex: 2,
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
              index += 3;
            }
          }

          while (itemCount - index >= 2) {
            final card1 = _buildFlexibleMenuCard(
              context: context,
              item: allMenuItems[index],
              cardHeight: height * 0.2,
              iconSize: 40,
              fontSize: 15.0,
              horizontalPadding: width * 0.03,
              themeProvider: themeProvider,
            );
            final card2 = _buildFlexibleMenuCard(
              context: context,
              item: allMenuItems[index + 1],
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

          if (itemCount - index == 1) {
            final singleCard = _buildFlexibleMenuCard(
              context: context,
              item: allMenuItems[index],
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
                  Expanded(child: const SizedBox()),
                ],
              ),
            );
            menuWidgets.add(SizedBox(height: vSpacing));
          }
        }

        return WillPopScope(
          onWillPop: OnWillPop().onWillPop1,
          child: Scaffold(
            appBar: AppBar(
              title: Center(
                child: Text(
                  'Welcome, ${_loggedInUser?.prenom ?? _loggedInUser?.name ?? 'Guest'}!',
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
                  icon: Icon(Icons.logout, color: theme.whiteColor),
                  onPressed: () => _showLogoutConfirmationDialog(context, theme),
                  tooltip: 'Logout',
                ),
              ],
              elevation: 0,
            ),
            body: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: viewportConstraints.maxHeight,
                      ),
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
                      padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.02),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(width * 0.04, width * 0.0, width * 0.04, width * 0.01),
                            child: Image(
                              image: theme.bannerImage,
                              height: height * 0.24,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox();
                              },
                            ),
                          ),
                          SizedBox(height: height * 0.01),
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