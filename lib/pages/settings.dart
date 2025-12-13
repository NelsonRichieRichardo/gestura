import 'package:flutter/material.dart';
import 'package:gestura/components/loading_overlay.dart';
import 'package:gestura/pages/privacy_policy.dart';
import 'package:gestura/pages/profile.dart';
import 'package:gestura/pages/terms_conditions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gestura/core/themes/app_theme.dart';
import 'package:gestura/pages/login.dart'; // Untuk Logout

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = screenWidth(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: responsiveHeight(context, 0.02)),

              // Title
              Text(
                "Setting",
                style: GoogleFonts.poppins(
                  fontSize: responsiveFont(context, 28),
                  fontWeight: bold,
                  color: accentColor,
                ),
              ),
              SizedBox(height: responsiveHeight(context, 0.04)),

              // Group 1: Policies & Profile
              _buildSettingGroup(
                context,
                items: [
                  _buildSettingItem(
                    context,
                    title: "Profile",
                    icon: Icons.person,
                    iconColor: infoColor,
                    onTap: () async {
                      // Tampilkan Loading
                      LoadingOverlay.show(context);
                      await Future.delayed(
                        const Duration(milliseconds: 700),
                      ); // Delay simulasi

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );

                      // Sembunyikan Loading setelah navigasi selesai
                      LoadingOverlay.hide(context);
                    },
                  ),
                  _buildSettingItem(
                    context,
                    title: "Privacy Policy",
                    icon: Icons.description,
                    iconColor: dangerColor,
                    onTap: () async {
                      // Tampilkan Loading
                      LoadingOverlay.show(context);
                      await Future.delayed(
                        const Duration(milliseconds: 700),
                      ); // Delay simulasi

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyPage(),
                        ),
                      );

                      // Sembunyikan Loading setelah navigasi selesai
                      LoadingOverlay.hide(context);
                    },
                  ),
                  _buildSettingItem(
                    context,
                    title: "Terms and Condition",
                    icon: Icons.gavel,
                    iconColor: successColor,
                    onTap: () async {
                      // Tampilkan Loading
                      LoadingOverlay.show(context);
                      await Future.delayed(
                        const Duration(milliseconds: 700),
                      ); // Delay simulasi

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsAndConditionsPage(),
                        ),
                      );

                      // Sembunyikan Loading setelah navigasi selesai
                      LoadingOverlay.hide(context);
                    },
                  ),
                ],
              ),

              SizedBox(height: responsiveHeight(context, 0.04)),

              // Group 2: Stay in touch
              Text(
                "Stay in touch",
                style: bodyText.copyWith(
                  color: accentColor.withOpacity(0.6),
                  fontWeight: bold,
                ),
              ),
              SizedBox(height: responsiveHeight(context, 0.015)),
              _buildSettingGroup(
                context,
                items: [
                  _buildSettingItem(
                    context,
                    title: "Send Feedback",
                    icon: Icons.star_rate,
                    iconColor: Colors.deepPurple,
                    onTap: () {},
                  ),
                ],
              ),

              SizedBox(height: responsiveHeight(context, 0.04)),

              // Logout Button (dapat diletakkan di sini atau di Profile)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  "Logout",
                  style: bodyText.copyWith(
                    color: dangerColor,
                    fontWeight: bold,
                  ),
                ),
                trailing: Icon(Icons.logout, color: dangerColor),
                onTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
              ),

              SizedBox(
                height: responsiveHeight(context, 0.15),
              ), // Ruang untuk FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingGroup(
    BuildContext context, {
    required List<Widget> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: items.map((item) => item).toList()),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    // Tambahkan Divider kecuali untuk item terakhir
    final isLast = title == "Send Feedback";

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: responsiveWidth(context, 0.04),
          vertical: responsiveHeight(context, 0.01),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Icon (Diatur ke warna background untuk efek 'pop')
                Container(
                  padding: EdgeInsets.all(responsiveFont(context, 8)),
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: backgroundColor,
                    size: responsiveFont(context, 20),
                  ),
                ),
                SizedBox(width: responsiveWidth(context, 0.04)),
                // Title
                Expanded(
                  child: Text(
                    title,
                    style: bodyText.copyWith(fontWeight: medium),
                  ),
                ),
                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  color: greyColor,
                  size: responsiveFont(context, 16),
                ),
              ],
            ),
            if (!isLast)
              Padding(
                padding: EdgeInsets.only(
                  left: responsiveWidth(context, 0.15),
                  top: responsiveHeight(context, 0.01),
                ),
                child: Divider(color: greyColor.withOpacity(0.3), height: 1),
              ),
          ],
        ),
      ),
    );
  }
}
