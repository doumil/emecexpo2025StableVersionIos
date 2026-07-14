// lib/supporting_p_screen.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:cached_network_image/cached_network_image.dart'; // We will use Image.network instead for unified fallback

// --- Updated Imports to use Exhibitors API ---
import 'package:emecexpo/providers/theme_provider.dart';
import 'package:emecexpo/api_services/exhibitor_api_service.dart';
import 'package:emecexpo/model/exhibitors_model.dart';
import 'package:emecexpo/model/app_theme_data.dart';

import 'details/DetailExhibitors.dart';
import 'main.dart';

// Define a simple data structure for sponsor categories
class SponsorCategory {
  final String title;
  final Color titleColor;
  final List<ExhibitorsClass> sponsors;

  SponsorCategory({required this.title, required this.titleColor, required this.sponsors});
}

class SupportingPScreen extends StatefulWidget {
  const SupportingPScreen({Key? key}) : super(key: key);

  @override
  _SupportingPScreenState createState() => _SupportingPScreenState();
}

class _SupportingPScreenState extends State<SupportingPScreen> {
  late SharedPreferences prefs;
  List<SponsorCategory> _sponsorCategories = [];
  final ExhibitorApiService _exhibitorApiService = ExhibitorApiService();
  bool _isLoading = true;
  bool _hasError = false;

  // --- Category Definitions with correct Colors ---
  final Map<String, Color> _categoryDefinitions = {
    "Diamond Sponsors": const Color(0xff00c1c1),  // Aqua/Cyan
    "Platinum Sponsors": Colors.grey.shade600,    // Grey
    "Gold Sponsors": const Color(0xffCE8946),     // Gold Color
    "Bronze Sponsors": const Color(0xffceb346),   // Bronze Color
    "Strategic Partner": const Color(0xFFA91DBE),
  };

  // Helper to determine sort rank for sponsors
  int _getSponsorRank(String? type) {
    switch (type?.toLowerCase()?.trim()) {
      case 'diamond':
        return 1;
      case 'platinum':
        return 2;
      case 'gold':
        return 3;
      case 'bronze':
        return 4;
      default:
        return 99;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSponsorData();
  }

  Future<void> _loadSponsorData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _sponsorCategories = [];
    });

    try {
      // 1. Fetch all exhibitors
      final List<ExhibitorsClass> allExhibitors = await _exhibitorApiService.getExhibitors();

      // 2. FILTER: Exclude any exhibitor with expositionType == 'partenaire'
      final List<ExhibitorsClass> nonPartnerExhibitors = allExhibitors
          .where((e) => e.expositionType?.toLowerCase() != 'partenaire')
          .toList();

      // 3. FILTER: Get only sponsors from the non-partner list
      final List<ExhibitorsClass> allSponsors = nonPartnerExhibitors
          .where((e) => e.expositionType?.toLowerCase() == 'sponsor')
          .toList();

      _groupSponsorsIntoCategories(allSponsors);

    } catch (e) {
      print("Error loading sponsor data: $e");
      setState(() {
        _hasError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _groupSponsorsIntoCategories(List<ExhibitorsClass> sponsors) {
    Map<String, List<ExhibitorsClass>> groupedSponsors = {};

    // Sort sponsors by rank for consistent display order within groups
    sponsors.sort((a, b) {
      int aRank = _getSponsorRank(a.sponsorType);
      int bRank = _getSponsorRank(b.sponsorType);
      if (aRank != bRank) {
        return aRank.compareTo(bRank);
      }
      return a.title.compareTo(b.title); // Secondary sort by title
    });

    // Group sponsors by their type
    for (var sponsor in sponsors) {
      String? rawType = sponsor.sponsorType?.trim().toLowerCase();
      String categoryTitle = "Other Sponsors";

      // Determine the correct category title based on sponsorType
      if (rawType == 'diamond') {
        categoryTitle = "Diamond Sponsors";
      } else if (rawType == 'platinum') {
        categoryTitle = "Platinum Sponsors";
      } else if (rawType == 'gold') {
        categoryTitle = "Gold Sponsors";
      } else if (rawType == 'bronze') {
        categoryTitle = "Bronze Sponsors";
      } else if (rawType != null && rawType.isNotEmpty) {
        // Fallback for other non-standard types
        categoryTitle = rawType.split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ') + " Sponsors";
      }

      groupedSponsors.putIfAbsent(categoryTitle, () => []).add(sponsor);
    }

    // Build the final list of categories
    List<SponsorCategory> categories = groupedSponsors.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) {
      // Get the color, falling back to a default if the title isn't in the map
      Color color = _categoryDefinitions[entry.key] ?? Colors.black;
      return SponsorCategory(
        title: entry.key,
        titleColor: color,
        sponsors: entry.value,
      );
    })
        .toList();

    // Sort the final categories list by rank (Diamond, Platinum, Gold, Bronze...)
    categories.sort((a, b) {
      int aRank = _getSponsorRank(a.title.split(' ')[0]);
      int bRank = _getSponsorRank(b.title.split(' ')[0]);
      return aRank.compareTo(bRank);
    });


    setState(() {
      _sponsorCategories = categories;
    });
  }


  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Êtes-vous sûr'),
        content: const Text('Voulez-vous quitter cette application'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Oui '),
          ),
        ],
      ),
    )) ?? false;
  }

  // 🚀 NEW HELPER: Adapted from _buildSpeakerImage for sponsors/exhibitors
  Widget _buildSponsorImage(String? imageUrl, AppThemeData theme) {
    // 🎯 Use the specific API fallback image URL
    final String defaultApiImage = 'https://buzzevents.co/uploads/ICON-EMEC.png';

    // Check if the exhibitor image is valid; if not, use the API default.
    final String finalUrl = imageUrl?.isNotEmpty == true &&
        (imageUrl!.startsWith('http') || imageUrl.startsWith('https'))
        ? imageUrl
        : defaultApiImage;

    // Use a fixed size for consistent appearance in the grid
    const double iconSize = 50.0;

    return Image.network(
      finalUrl,
      fit: BoxFit.contain,
      // Error: Show a broken image icon if loading the final URL fails (even the default)
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.broken_image,
          color: Colors.grey,
          size: iconSize,
        );
      },
      // Loading: Show a progress indicator while the image is loading
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.secondaryColor,
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    return
      Scaffold(
        backgroundColor: theme.whiteColor,
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          elevation: 0,
          title: Text(
            'Sponsors',
            style: TextStyle(
                color: theme.whiteColor,
                fontWeight: FontWeight.bold
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: theme.whiteColor),
            onPressed: () async{
              prefs = await SharedPreferences.getInstance();
              prefs.setString("Data", "99");
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => WelcomPage()));
            },
          ),
          centerTitle: true,
        ),
        body: FadeInDown(
          duration: const Duration(milliseconds: 500),
          child: _buildBody(theme),
        ),
      );
  }

  Widget _buildBody(AppThemeData theme) {
    if (_isLoading) {
      return Center(
        child: SpinKitThreeBounce(
          color: theme.secondaryColor,
          size: 30.0,
        ),
      );
    }

    if (_hasError || _sponsorCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_outline, color: Colors.grey, size: 50),
            const SizedBox(height: 10),
            const Text(
              "Failed to load sponsors or none available.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _sponsorCategories.map((category) {
          final int itemCount = category.sponsors.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 5.0),
                child: Center(
                  child: Text(
                    category.title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: category.titleColor), // Color based on sponsor level
                  ),
                ),
              ),

              // 💡 DYNAMIC LAYOUT LOGIC: Centered single item or 2-column grid
              if (itemCount == 1)
              // Case 1: Only one item -> Show centered
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    // Constrain the width for centering effect (e.g., half the screen width)
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: _buildSponsorGridItem(category.sponsors.first, theme, category.titleColor), // Pass category color
                  ),
                )
              else
              // Case 2: Two or more items -> Use the GridView (2 columns)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15.0, // Increased spacing
                    mainAxisSpacing: 15.0, // Increased spacing
                    childAspectRatio: 1.2,
                  ),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    return _buildSponsorGridItem(category.sponsors[index], theme, category.titleColor); // Pass category color
                  },
                ),

              const SizedBox(height: 30.0), // Increased separation between categories
            ],
          );
        }).toList(),
      ),
    );
  }

  // Updated widget: uses the new _buildSponsorImage helper
  Widget _buildSponsorGridItem(ExhibitorsClass exhibitor, AppThemeData theme, Color categoryColor) {

    return GestureDetector( // 🎯 WRAP with GestureDetector
      onTap: () {
        // FIX APPLIED: Passing the required 'exhibitorId' using the assumed correct field 'id'
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailExhibitorsScreen(exhibitorId: exhibitor.id) // ⬅️ Corrected to use .id
            )
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.whiteColor,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: categoryColor.withOpacity(0.5),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            // 🚀 INTEGRATED THE NEW IMAGE LOGIC
            child: _buildSponsorImage(exhibitor.image, theme),
          ),
        ),
      ),
    );
  }
}