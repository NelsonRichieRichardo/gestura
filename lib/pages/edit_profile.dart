import 'package:flutter/material.dart';
import 'package:gestura/core/themes/app_theme.dart';

// =================================================================
// CUSTOM TEXT FIELD WIDGET (Widget Input Kustom)
// =================================================================
class CustomTextField extends StatelessWidget {
  final String label;
  final IconData prefixIcon;
  final bool isPasswordField;
  final TextEditingController controller;

  const CustomTextField({
    super.key,
    required this.label,
    required this.prefixIcon,
    this.isPasswordField = false,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label di atas border (seperti pada desain)
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Text(
            label,
            style: smallText.copyWith(color: greyColor, height: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        // Input Field
        TextFormField(
          controller: controller,
          obscureText: isPasswordField,
          style: bodyText,
          decoration: InputDecoration(
            // Menghilangkan label karena sudah ada label di atas
            labelText: '', 
            prefixIcon: Icon(prefixIcon, color: accentColor),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            
            // Mengatur border (Border radius yang membulat)
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: greyColor, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: greyColor.withOpacity(0.6), width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: primaryColor, width: 2.0),
            ),
            fillColor: backgroundColor,
            filled: true,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// =================================================================
// EDIT PROFILE PAGE (Halaman Edit Profil)
// =================================================================
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Controller untuk setiap field input
  final TextEditingController _usernameController = TextEditingController(text: 'JohnDoe');
  final TextEditingController _emailController = TextEditingController(text: 'john.doe@example.com');
  final TextEditingController _phoneController = TextEditingController(text: '+628123456789');
  final TextEditingController _passwordController = TextEditingController(text: '********'); // Placeholder for password

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _editProfile() {
    // Logika untuk menyimpan perubahan profil (placeholder)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profil berhasil diperbarui!', style: bodyTextWhite),
        backgroundColor: successColor,
      ),
    );
    // Di sini Anda akan mengimplementasikan logika update ke Firebase/API
    print('Username: ${_usernameController.text}');
    print('Email: ${_emailController.text}');
    print('Phone: ${_phoneController.text}');
    print('New Password: ${_passwordController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryBackground, // Menggunakan warna background muda
      appBar: AppBar(
        backgroundColor: secondaryBackground, 
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: accentColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Edit Profile',
          style: heading2,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Area Foto Profil
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                // Lingkaran kuning besar untuk foto profil
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
                // Icon Edit Pensil
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor, width: 2),
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 18,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Field Input
            CustomTextField(
              label: 'Username',
              prefixIcon: Icons.person_outline,
              controller: _usernameController,
            ),
            CustomTextField(
              label: 'E-mail',
              prefixIcon: Icons.email_outlined,
              controller: _emailController,
            ),
            CustomTextField(
              label: 'Phone',
              prefixIcon: Icons.phone_outlined,
              controller: _phoneController,
            ),
            // Khusus untuk Password, menggunakan ikon sidik jari (fingerprint) dan isPasswordField=true
            CustomTextField(
              label: 'Password',
              prefixIcon: Icons.fingerprint, 
              isPasswordField: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 40),

            // Tombol Edit Profile
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _editProfile,
                style: primaryButton, // Menggunakan style tombol dari app_theme
                child: const Text('Edit Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
