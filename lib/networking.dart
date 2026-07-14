// lib/screens/networking_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/app_theme_data.dart';
import '../model/exposant_networking_model.dart';
import '../api_services/networking_api_service.dart';
import '../providers/theme_provider.dart';
import '../details/CommerciauxScreen.dart';
import '../main.dart'; // 💡 استيراد الـ main باش يقرا الـ WelcomPage

class NetworkinScreen extends StatefulWidget {
  final String? authToken;
  const NetworkinScreen({Key? key, this.authToken}) : super(key: key);

  @override
  _NetworkinScreenState createState() => _NetworkinScreenState();
}

class _NetworkinScreenState extends State<NetworkinScreen> {
  final NetworkingApiService _apiService = NetworkingApiService();
  final PageController _pageController = PageController();

  Future<List<ExposantNetworking>>? _fetchFuture;
  List<ExposantNetworking> _exhibitors = []; // 💡 حفظ الداتا هنا محلياً لمنع الـ Rebuild العشوائي
  String? _token;
  int _currentIndex = 0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchFuture = _initData();
  }

  Future<List<ExposantNetworking>> _initData() async {
    try {
      if (widget.authToken != null) {
        _token = widget.authToken;
      } else {
        final prefs = await SharedPreferences.getInstance();
        _token = prefs.getString('authToken');
      }

      final data = await _apiService.getNetworkingExhibitors(_token ?? "");

      setState(() {
        _exhibitors = data;
        _hasError = false;
      });
      return data;
    } catch (e) {
      debugPrint("❌ [NetworkinScreen] Error fetching data: $e");
      setState(() {
        _hasError = true;
      });
      rethrow;
    }
  }

  void _retryFetch() {
    setState(() {
      _exhibitors = [];
      _hasError = false;
      _currentIndex = 0;
      _fetchFuture = _initData();
    });
  }

  void _goToCommerciaux(ExposantNetworking exhibitor, AppThemeData theme) {
    if (_token == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommerciauxScreen(
          exposantId: exhibitor.compteId ?? 0,
          authToken: _token!,
          theme: theme,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text("Networking", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () async {
            // 💡 الـ الحل السحري لي كاين ف الـ Badge: كايصيفط "99" ويدير pushReplacement
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString("Data", "99");

            if (!mounted) return;
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const WelcomPage())
            );
          },
        ),
      ),
      body: FutureBuilder<List<ExposantNetworking>>(
        future: _fetchFuture,
        builder: (context, snapshot) {
          // 1. حالة الـ Loading: كاتبقى شاعرة غير يلا كانت القائمة خاوية وكيتسنى الداتا
          if (snapshot.connectionState == ConnectionState.waiting && _exhibitors.isEmpty) {
            return Center(child: SpinKitThreeBounce(color: theme.secondaryColor, size: 30));
          }

          // 2. حالة الخطأ أو الداتا خاوية من السيرفر
          if (_hasError || (snapshot.connectionState == ConnectionState.done && _exhibitors.isEmpty)) {
            return _buildEmptyState(theme);
          }

          // 3. عرض البيانات بأمان واستقرار
          return Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _exhibitors.length + 1,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    if (index == _exhibitors.length) {
                      return _buildEndOfListCard(theme);
                    }
                    return FadeInRight(
                      duration: const Duration(milliseconds: 400),
                      child: _buildExhibitorCard(_exhibitors[index], theme),
                    );
                  },
                ),
              ),
              if (_currentIndex < _exhibitors.length) _buildActions(theme),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExhibitorCard(ExposantNetworking item, AppThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _goToCommerciaux(item, theme),
            child: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey[50],
                    child: item.logo != null && item.logo!.isNotEmpty
                        ? Image.network(
                      item.logo!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stack) => Icon(Icons.business, size: 80, color: theme.primaryColor.withOpacity(0.2)),
                    )
                        : Icon(Icons.business_rounded, size: 80, color: theme.primaryColor.withOpacity(0.2)),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nom ?? "N/A",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.primaryColor),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: theme.secondaryColor),
                            const SizedBox(width: 4),
                            Text(item.ville ?? "Maroc", style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.activite ?? "Pas de description disponible",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(AppThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _roundButton(Icons.close, Colors.red, () {
          _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
        }),
        const SizedBox(width: 30),
        _roundButton(Icons.calendar_month, theme.secondaryColor, () {
          if (_currentIndex < _exhibitors.length) {
            _goToCommerciaux(_exhibitors[_currentIndex], theme);
          }
        }, isLarge: true),
        const SizedBox(width: 30),
        _roundButton(Icons.favorite, Colors.green, () {
          _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
        }),
      ],
    );
  }

  Widget _roundButton(IconData icon, Color color, VoidCallback onTap, {bool isLarge = false}) {
    double size = isLarge ? 75 : 60;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
          border: Border.all(color: color.withOpacity(0.1), width: 1),
        ),
        child: Icon(icon, color: color, size: isLarge ? 35 : 28),
      ),
    );
  }

  Widget _buildEndOfListCard(AppThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: theme.secondaryColor),
          const SizedBox(height: 10),
          const Text("That's all for now!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text("You've seen all exhibitors.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 60, color: Colors.grey),
          const SizedBox(height: 10),
          const Text("No exhibitors found"),
          const SizedBox(height: 10),
          TextButton(onPressed: _retryFetch, child: Text("Retry", style: TextStyle(color: theme.primaryColor))),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}