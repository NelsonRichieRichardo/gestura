import 'package:flutter/material.dart';
import 'package:gestura/core/themes/app_theme.dart'; 
import 'package:gestura/pages/edit_profile.dart'; 
import 'package:gestura/components/loading_overlay.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = 'Loading...';
  String email = 'Loading...';
  String phone = 'Loading...';
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserData();
    });
  }

  // ======================================================
  // LOGIKA PENGAMBILAN DATA DARI FIREBASE
  // ======================================================

  void _fetchUserData() async {
    // 1. Tampilkan loading overlay
    LoadingOverlay.show(context);
    
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists && mounted) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          
          setState(() {
            username = data['username'] ?? 'N/A';
            email = data['email'] ?? currentUser.email ?? 'N/A';
            phone = data['phoneNumber'] ?? 'N/A'; 
            _isDataLoaded = true;
          });
        }
      } else if (mounted) {
        setState(() {
          username = 'Guest';
          _isDataLoaded = true;
        });
      }

    } catch (e) {
      if (mounted) {
        print("Error fetching Firestore data: $e");
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Failed to load profile data.")),
        );
      }
    } finally {
      if (mounted) {
        LoadingOverlay.hide(context);
      }
    }
  }

  // ======================================================
  // WIDGET PEMBANTU
  // ======================================================

  Widget _buildDetailRow(String label, String value) {
    if (!_isDataLoaded) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: smallText.copyWith(color: greyColor)),
            const SizedBox(height: 4),
            Container(
              height: 16,
              width: 150,
              decoration: BoxDecoration(
                color: greyColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Divider(color: greyColor.withOpacity(0.5)),
          ],
        ),
      );
    }
    
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

  // ======================================================
  // BUILD METHOD
  // ======================================================

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
            // Foto Profil
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
            // Nama Pengguna
            Text(
              _isDataLoaded ? username : 'Loading...',
              style: heading1.copyWith(fontWeight: bold),
            ),
            const SizedBox(height: 40),

            // Detail Pengguna
            _buildDetailRow('E-mail', email),
            _buildDetailRow('Phone', phone),
            _buildDetailRow('Password', '********'), 
            const SizedBox(height: 40),

            // Tombol "Edit Profile" (navigasi ke halaman edit)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.edit, color: backgroundColor),
                label: const Text('Edit Profile'),
                onPressed: _isDataLoaded ? () {
                  // Meneruskan sinyal refresh kembali ke HomePage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfilePage(),
                    ),
                  ).then((result) { 
                    if (result == true) {
                      _fetchUserData(); // Refresh data ProfilePage
                      // Meneruskan sinyal refresh ke HomePage (pop result true)
                      Navigator.pop(context, true); 
                    }
                  });
                } : null, 
                style: primaryButton, 
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}