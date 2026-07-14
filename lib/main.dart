// lib/main.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:emecexpo/program_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:emecexpo/providers/app_config_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:emecexpo/services/onwillpop_services.dart';
import 'package:emecexpo/model/user_model.dart';
import 'package:emecexpo/login_screen.dart';
import 'package:emecexpo/home_screen.dart';
import 'package:emecexpo/Busniess%20Safe.dart';
import 'package:emecexpo/Contact.dart';
import 'package:emecexpo/Exhibitors.dart';
import 'package:emecexpo/Food.dart';
import 'package:emecexpo/How%20to%20get%20there.dart';
import 'package:emecexpo/Information.dart';
import 'package:emecexpo/Media%20Partners.dart';
import 'package:emecexpo/News.dart';
import 'package:emecexpo/Notifications.dart';
import 'package:emecexpo/Official%20events.dart';
import 'package:emecexpo/Settings.dart';
import 'package:emecexpo/Social%20Media.dart';
import 'package:emecexpo/Speakers.dart';
import 'package:emecexpo/details/DetailCongress.dart';
import 'package:emecexpo/details/DetailNetworkin.dart';
import 'package:emecexpo/partners.dart';
import 'package:emecexpo/product.dart';
import 'package:emecexpo/services/local_notification_service.dart';
import 'package:emecexpo/activities.dart';
import 'package:emecexpo/My%20Agenda.dart';
import 'package:emecexpo/Suporting%20Partners.dart';
import 'package:emecexpo/details/CongressMenu.dart';
import 'package:emecexpo/model/notification_model.dart';
import 'package:emecexpo/my_drawer_header.dart';
import 'package:emecexpo/Schedule.dart';
import 'package:emecexpo/networking.dart';
import 'package:emecexpo/app_user_guide_screen.dart';
import 'package:emecexpo/my_profile_screen.dart';
import 'package:emecexpo/my_badge_screen.dart';
import 'package:emecexpo/favourites_screen.dart';
import 'package:emecexpo/scanned_badges_screen.dart';
import 'ExpoFloorPlan.dart';
import 'conversations_screen.dart';
import 'package:emecexpo/meeting_ratings_screen.dart';
import 'package:emecexpo/model/app_theme_data.dart';
import 'package:emecexpo/providers/theme_provider.dart';
import 'package:emecexpo/providers/home_provider.dart';
import 'package:emecexpo/providers/menu_provider.dart';
import 'package:emecexpo/constants.dart';
import 'global/app_config.dart';

// Global Variables
ValueNotifier<int> notificationCountNotifier = ValueNotifier(0);
List<NotifClass> globalLitems = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? authToken = prefs.getString('authToken');
  User? initialUser;

  if (authToken != null && authToken.isNotEmpty) {
    final String? userJson = prefs.getString('currentUserJson');
    if (userJson != null && userJson.isNotEmpty) {
      try {
        initialUser = User.fromJson(json.decode(userJson));
      } catch (e) {
        await prefs.remove('authToken');
        await prefs.remove('currentUserJson');
        initialUser = null;
      }
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppConfigProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
      ],
      child: MyApp(initialUser: initialUser),
    ),
  );
}

class MyApp extends StatefulWidget {
  final User? initialUser;
  const MyApp({Key? key, this.initialUser}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // استدعاء التهيئة بعد انتهاء بناء الواجهة لأول مرة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initApp();
    });
  }

  Future<void> _initApp() async {
    final config = Provider.of<AppConfigProvider>(context, listen: false);
    await config.initializeConfig();

    if (config.rawSettings != null) {
      Provider.of<ThemeProvider>(context, listen: false).updateThemeFromConfig(config);
      Provider.of<MenuProvider>(context, listen: false).updateMenuFromConfig(config);
      Provider.of<HomeProvider>(context, listen: false).updateCardsFromConfig(config);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xFF004B9F),
          body: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: widget.initialUser != null
              ? WelcomPage(user: widget.initialUser)
              : const LoginScreen(),
        );
      },
    );
  }
}
// أضف هذا الكلاس في أسفل ملف main.dart
class DullPage extends StatelessWidget {
  final String title;
  const DullPage({Key? key, this.title = 'Dull Page'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(
          child: Text(
              'This page is a work in progress.',
              style: TextStyle(fontSize: 18)
          )
      ),
    );
  }
}
// ... (بقية كلاساتك: WelcomPage, _WelcomPageState وكل الـ Widgets التي كانت في الأسفل) ...
// تأكد من لصق كود WelcomPage و _WelcomPageState الذي أرسلته لي هنا بالأسفل للحفاظ على عمل Drawer والـ BottomNav

class AppContent extends StatelessWidget {
  final Widget mainAppWidget;
  const AppContent({Key? key, required this.mainAppWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) { return mainAppWidget; }
}

class WelcomPage extends StatefulWidget {
  final User? user;
  const WelcomPage({Key? key, this.user}) : super(key: key);

  @override
  _WelcomPageState createState() => _WelcomPageState();
}

class _WelcomPageState extends State<WelcomPage> {
  var currentPage = DrawerSections.home;
  var _data = "";
  late SharedPreferences prefs;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  User? _loggedInUser;

  @override
  void initState() {
    super.initState();
    _initializeUserAndLoadData();
  }

  /// Clears persisted runtime context variables and drops authorization tokens
  Future<void> _performLogout() async {
    await prefs.remove('authToken');
    await prefs.remove('currentUserJson');
    _loggedInUser = null;
    notificationCountNotifier.value = 0;

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }

  /// Displays an asynchronous context confirmation layer before dropping scope sessions
  Future<void> _showLogoutConfirmationDialog(BuildContext context, AppThemeData theme) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const SingleChildScrollView(child: ListBody(children: <Widget>[Text('Are you sure you want to log out?')],)),
          actions: <Widget>[
            TextButton(child: Text('Cancel', style: TextStyle(color: theme.primaryColor)), onPressed: () => Navigator.of(context).pop()),
            TextButton(child: Text('Logout', style: TextStyle(color: theme.secondaryColor, fontWeight: FontWeight.bold)), onPressed: () { Navigator.of(context).pop(); _performLogout(); }),
          ],
        );
      },
    );
  }

  /// Reconstitutes profile sessions from offline disk storage layers
  Future<void> _initializeUserAndLoadData() async {
    prefs = await SharedPreferences.getInstance();
    _loggedInUser = widget.user;

    if (_loggedInUser == null) {
      final String? userJsonString = prefs.getString('currentUserJson');
      if (userJsonString != null) {
        try {
          final Map<String, dynamic> userMap = json.decode(userJsonString);
          _loggedInUser = User.fromJson(userMap);
        } catch (e) {
          debugPrint("Error parsing stored user JSON in WelcomPage: $e");
          await prefs.remove('authToken');
          await prefs.remove('currentUserJson');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
          });
          return;
        }
      }
    }

    _data = (prefs.getString("Data") ?? '');
    setState(() {
      if (_data == "1") currentPage = DrawerSections.exhibitors;
      else if (_data == "2") currentPage = DrawerSections.congressmenu;
      else if (_data == "3") currentPage = DrawerSections.business;
      else if (_data == "4") { currentPage = DrawerSections.notifications; notificationCountNotifier.value = 0; }
      else if (_data == "5") currentPage = DrawerSections.congressmenu;
      else if (_data == "6") currentPage = DrawerSections.detailexhib;
      else if (_data == "7") currentPage = DrawerSections.detailcongress;
      else if (_data == "8") currentPage = DrawerSections.DetailNetworkin;
      else if (_data == "9") currentPage = DrawerSections.networking;
      else if (_data == "10") currentPage = DrawerSections.myAgenda;
      else if (_data == "11") currentPage = DrawerSections.program;
      else currentPage = DrawerSections.home;
    });
  }

  void _onNavigateToSection(DrawerSections section) {
    setState(() { currentPage = section; });
    if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) { Navigator.pop(context); }
  }

  int _getBottomNavIndexForBottomNav() {
    if (currentPage == DrawerSections.home) return 0;
    if (currentPage == DrawerSections.notifications) return 1;
    return 0;
  }

  Future<bool> _onWillPop() async {
    if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) { Navigator.pop(context); return false; }
    if (currentPage != DrawerSections.home) { _onNavigateToSection(DrawerSections.home); return false; }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    if (_loggedInUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    User currentUser = _loggedInUser!;
    Widget container;

    if (currentPage == DrawerSections.home) container = HomeScreen(user: currentUser, onNavigate: _onNavigateToSection);
    else if (currentPage == DrawerSections.program) container = const ProgramScreen();
    else if (currentPage == DrawerSections.networking) container = NetworkinScreen(authToken: currentUser.token ?? "");
    else if (currentPage == DrawerSections.myAgenda) container = AgendaScreen();
    else if (currentPage == DrawerSections.speakers) container = SpeakersScreen();
    else if (currentPage == DrawerSections.officialEvents) container = OfficialEventsScreen();
    else if (currentPage == DrawerSections.partners) container = PartnersScreen();
    else if (currentPage == DrawerSections.exhibitors) container = ExhibitorsScreen();
    else if (currentPage == DrawerSections.eFP) container = ExpoFloorPlan();
    else if (currentPage == DrawerSections.supportingP) container = SupportingPScreen();
    else if (currentPage == DrawerSections.mediaP) container = MediaPScreen();
    else if (currentPage == DrawerSections.contact) container = ContactScreen();
    else if (currentPage == DrawerSections.information) container = InformationScreen();
    else if (currentPage == DrawerSections.schedule) container = SchelduleScreen();
    else if (currentPage == DrawerSections.getThere) container = GetThereScreen();
    else if (currentPage == DrawerSections.notifications) container = NotificationsScreen();
    else if (currentPage == DrawerSections.congressmenu) container = CongressMenu();
    else if (currentPage == DrawerSections.detailexhib) container = ExhibitorsScreen();
    else if (currentPage == DrawerSections.appUserGuide) container = const AppUserGuideScreen();
    else if (currentPage == DrawerSections.myProfile) container = MyProfileScreen(user: currentUser);
    else if (currentPage == DrawerSections.myBadge) container = MyBadgeScreen(user: currentUser);
    else if (currentPage == DrawerSections.favourites) container = const FavouritesScreen();
    else if (currentPage == DrawerSections.scannedBadges) container = ScannedBadgesScreen(user: currentUser);
    else if (currentPage == DrawerSections.meetingRatings) container = const MeetingRatingsScreen();
    else if (currentPage == DrawerSections.sponsors) container = SupportingPScreen();
    else container = Center(child: const DullPage(title: 'Page Not Found'));

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        body: container,
        endDrawer: Drawer(
          child: SafeArea(
            top: true, bottom: true, left: false, right: false,
            child: SingleChildScrollView(
              child: Container(
                color: theme.primaryColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyHeaderDrawer(user: currentUser, onLogout: _performLogout),
                    const SizedBox(height: 5.0),
                    Consumer<MenuProvider>(
                      builder: (context, menuProvider, child) {
                        final menuConfig = menuProvider.menuConfig;
                        return MyDrawerList(
                          theme: themeProvider,
                          menuConfig: menuConfig,
                          onNavigate: _onNavigateToSection,
                          currentSection: currentPage,
                          onLogout: _performLogout,
                          showLogoutDialog: _showLogoutConfirmationDialog,
                          appTheme: theme,
                        );
                      },
                    ),

                    // --- هنا زدنا الـ Version لتحت من الـ Logout ---
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          AppConfig.version,
                          style: TextStyle(
                            color: theme.whiteColor.withOpacity(0.5),
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ),
                    // ----------------------------------------------
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: ValueListenableBuilder<int>(
                valueListenable: notificationCountNotifier,
                builder: (context, count, child) {
                  return badges.Badge(
                    showBadge: count > 0,
                    badgeContent: Text(count.toString(), style: TextStyle(color: theme.whiteColor, fontSize: 10)),
                    badgeStyle: badges.BadgeStyle(badgeColor: theme.redColor, padding: const EdgeInsets.all(5)),
                    position: badges.BadgePosition.topEnd(top: -10, end: -12),
                    child: const Icon(Icons.notifications),
                  );
                },
              ),
              label: 'Notifications',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
          ],
          currentIndex: _getBottomNavIndexForBottomNav(),
          selectedItemColor: theme.secondaryColor,
          unselectedItemColor: theme.whiteColor,
          backgroundColor: theme.primaryColor,
          onTap: (index) async {
            if (index == 0) _onNavigateToSection(DrawerSections.home);
            else if (index == 1) { _onNavigateToSection(DrawerSections.notifications); notificationCountNotifier.value = 0; }
            else if (index == 2) _scaffoldKey.currentState?.openEndDrawer();
          },
        ),
      ),
    );
  }

  /// Layout list construction factory representing global application features navigation map
  Widget MyDrawerList({
    required ThemeProvider theme,
    required MenuConfig? menuConfig,
    required OnNavigateCallback onNavigate,
    required DrawerSections currentSection,
    required VoidCallback onLogout,
    required Function(BuildContext context, AppThemeData theme) showLogoutDialog,
    required AppThemeData appTheme,
  }) {
    final floorPlanActive = menuConfig?.floorPlan ?? true;
    final programActive = menuConfig?.program ?? true;
    final exhibitorsActive = menuConfig?.exhibitors ?? true;
    final speakersActive = menuConfig?.speakers ?? true;
    final sponsorsActive = menuConfig?.sponsors ?? true;
    final partnersActive = menuConfig?.partners ?? true;
    final badgeActive = menuConfig?.badge ?? true;
    final networkingActive = menuConfig?.networking ?? true;

    return Container(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          menuItem(DrawerSections.home, "Home", Icons.home, currentSection == DrawerSections.home, onNavigate, true),

          const Divider(color: Colors.white24, height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "EVENT INFORMATION",
              style: TextStyle(
                color: theme.currentTheme.whiteColor.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          menuItem(DrawerSections.eFP, "Floor Plan", Icons.location_on_outlined, currentSection == DrawerSections.eFP, onNavigate, floorPlanActive),
          menuItem(DrawerSections.program, "Program", Icons.calendar_today_outlined, currentSection == DrawerSections.program, onNavigate, programActive),
          menuItem(DrawerSections.exhibitors, "Exhibitors", Icons.store_mall_directory_outlined, currentSection == DrawerSections.exhibitors, onNavigate, exhibitorsActive),
          menuItem(DrawerSections.speakers, "Speakers", Icons.speaker_notes_outlined, currentSection == DrawerSections.speakers, onNavigate, speakersActive),
          menuItem(DrawerSections.sponsors, "Sponsors", Icons.favorite_outline, currentSection == DrawerSections.sponsors, onNavigate, sponsorsActive),
          menuItem(DrawerSections.partners, "Partners", Icons.handshake_outlined, currentSection == DrawerSections.partners, onNavigate, partnersActive),

          const Divider(color: Colors.white24, height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "ACCOUNT",
              style: TextStyle(
                color: theme.currentTheme.whiteColor.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          menuItem(DrawerSections.myProfile, "My Profile", Icons.person_outline, currentSection == DrawerSections.myProfile, onNavigate, true),
          menuItem(DrawerSections.myBadge, "My Badge", Icons.badge_outlined, currentSection == DrawerSections.myBadge, onNavigate, badgeActive),
          menuItem(DrawerSections.scannedBadges, "Scanned Badges", Icons.qr_code_scanner, currentSection == DrawerSections.scannedBadges, onNavigate, true),
          menuItem(DrawerSections.myAgenda, "My Agenda", Icons.calendar_today_outlined, currentSection == DrawerSections.myAgenda, onNavigate, programActive),
          menuItem(DrawerSections.networking, "Networking", Icons.people_outline, currentSection == DrawerSections.networking, onNavigate, networkingActive),

          const Divider(color: Colors.white24, height: 20),

          menuItem(DrawerSections.contact, "Contact", Icons.contact_mail_outlined, currentSection == DrawerSections.contact, onNavigate, true),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () { showLogoutDialog(context, appTheme); },
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 24, color: theme.currentTheme.secondaryColor),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Logout",
                        style: TextStyle(color: theme.currentTheme.whiteColor, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Structural item builder factory injecting single node configuration options into the layout drawer
  Widget menuItem(DrawerSections section, String title, IconData icon, bool selected, OnNavigateCallback onNavigate, bool isEnabled) {
    final theme = Provider.of<ThemeProvider>(context, listen: false);

    return Material(
      color: selected ? Colors.white12 : Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? () {
          onNavigate(section);
          if (section == DrawerSections.notifications) {
            notificationCountNotifier.value = 0;
          }
        } : null,
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isEnabled ? theme.currentTheme.secondaryColor : Colors.grey,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                        color: isEnabled ? theme.currentTheme.whiteColor : Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}