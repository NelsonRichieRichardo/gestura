import 'package:flutter/material.dart';
import 'package:gestura/core/themes/app_theme.dart'; // Import tema
import 'package:gestura/pages/edit_profile.dart'; // Import halaman edit profil

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Data pengguna sebagai contoh
  final String username = 'JohnDoe';
  final String email = 'john.doe@example.com';
  final String phone = '+62 812 3456 789';

  // Widget pembantu untuk menampilkan detail
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: smallText.copyWith(color: greyColor),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: bodyText.copyWith(fontWeight: medium),
          ),
          Divider(color: greyColor.withOpacity(0.5)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryBackground,
      appBar: AppBar(
        backgroundColor: secondaryBackground,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profile',
          style: heading2,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Foto Profil (Sama dengan desain Edit Profile)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                size: 72,
                color: backgroundColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              username,
              style: heading1.copyWith(fontWeight: bold),
            ),
            const SizedBox(height: 40),

            // Detail Pengguna
            _buildDetailRow('E-mail', email),
            _buildDetailRow('Phone', phone),
            _buildDetailRow('Password', '********'), // Tidak menampilkan password asli
            const SizedBox(height: 40),

            // Tombol "Edit Profile" (navigasi ke halaman edit)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.edit, color: backgroundColor),
                label: const Text('Edit Profile'),
                onPressed: () {
                  // LOGIKA NAVIGASI: Pindah ke halaman EditProfilePage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfilePage(),
                    ),
                  );
                },
                style: primaryButton, 
              ),
            ),
            const SizedBox(height: 16),
            
            // Contoh tombol logout
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                icon: Icon(Icons.logout, color: dangerColor),
                label: Text('Logout', style: bodyText.copyWith(color: dangerColor)),
                onPressed: () {
                  // Logika Logout di sini
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}