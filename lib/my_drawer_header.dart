import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emecexpo/providers/theme_provider.dart';
import 'package:emecexpo/model/user_model.dart';

class MyHeaderDrawer extends StatelessWidget {
  final User? user;
  final VoidCallback onLogout;

  const MyHeaderDrawer({Key? key, this.user, required this.onLogout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Container(
      color: theme.primaryColor,
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.25, // صغرناه شوية باش يجي متناسق
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // لوغو واحد فقط (Logo)
          Container(
            height: 90,
            alignment: Alignment.center,
            child: Image(
              image: theme.logoImage, // الـ Getter الذكي اللي كيقلب بين Asset و Network
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) => const Icon(Icons.image, color: Colors.white54, size: 50),
            ),
          ),
          const SizedBox(height: 15),

          // اسم المستخدم
          Text(
            user != null
                ? (user!.name ?? '${user!.prenom ?? ''} ${user!.nom ?? ''}'.trim())
                : "Welcome, Guest!",
            style: TextStyle(
                color: theme.whiteColor,
                fontSize: 18,
                fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }
}