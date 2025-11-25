import 'package:flutter/material.dart';
import 'package:gestura/core/themes/app_theme.dart';
import 'package:gestura/components/loading_overlay.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestura/pages/login.dart'; 
// import 'package:gestura/pages/onboarding.dart'; // Tidak diperlukan jika navigasi root adalah LoginPage

// =================================================================
// CUSTOM TEXT FIELD WIDGET (Tetap sama)
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
                Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                        label,
                        style: smallText.copyWith(color: greyColor, height: 0.5),
                    ),
                ),
                const SizedBox(height: 4),
                TextFormField(
                    controller: controller,
                    obscureText: isPasswordField,
                    style: bodyText,
                    decoration: InputDecoration(
                        labelText: '', 
                        prefixIcon: Icon(prefixIcon, color: accentColor),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        
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
// 2. EDIT PROFILE PAGE STATE
// =================================================================
class EditProfilePage extends StatefulWidget {
    const EditProfilePage({super.key});

    @override
    State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _phoneController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController(text: '********');
    
    String _initialUsername = '';
    String _initialPhone = '';
    
    bool _isInitializing = true;
    User? _currentUser;
    
    bool get _hasUnsavedChanges {
      return _usernameController.text.trim() != _initialUsername.trim() ||
             _phoneController.text.trim() != _initialPhone.trim() ||
             (_passwordController.text.isNotEmpty && _passwordController.text != '********');
    }
    
    @override
    void initState() {
        super.initState();
        _currentUser = FirebaseAuth.instance.currentUser;
        if (_currentUser != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
                _fetchUserData();
            });
        } else {
            setState(() => _isInitializing = false);
        }
    }

    @override
    void dispose() {
        _usernameController.dispose();
        _emailController.dispose();
        _phoneController.dispose();
        _passwordController.dispose();
        super.dispose();
    }

    // --- A. Fetch Data Awal ---
    void _fetchUserData() async {
        if (_currentUser == null) return;
        
        LoadingOverlay.show(context);

        try {
            DocumentSnapshot userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(_currentUser!.uid)
                .get();

            if (userDoc.exists && mounted) {
                Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
                
                _initialUsername = data['username'] ?? '';
                _initialPhone = data['phoneNumber']?.replaceAll('+', '') ?? '';
                
                setState(() {
                    _usernameController.text = _initialUsername;
                    _emailController.text = _currentUser!.email ?? data['email'] ?? '';
                    _phoneController.text = _initialPhone; 
                    _isInitializing = false;
                });
            }
        } catch (e) {
            print("Error fetching profile data: $e");
        } finally {
            if (mounted) {
                LoadingOverlay.hide(context);
            }
        }
    }

    // --- B. Logika Update dan Navigasi ---
    void _performUpdate(bool passwordChanged) async {
        if (_currentUser == null) return;
        
        LoadingOverlay.show(context);
        
        final newUsername = _usernameController.text.trim();
        final newPhone = _phoneController.text.trim();
        final newPassword = _passwordController.text; 

        try {
            // 1. Update Firestore (Username & Phone)
            await FirebaseFirestore.instance
                .collection('users')
                .doc(_currentUser!.uid)
                .update({
                    'username': newUsername,
                    'phoneNumber': newPhone,
                });

            // 2. Update Auth (Password)
            if (passwordChanged) {
                if (newPassword.length < 6) {
                    throw FirebaseAuthException(code: 'weak-password', message: "Password minimal 6 karakter.");
                }
                
                await _currentUser!.updatePassword(newPassword);
            }

            // 3. SUKSES & NAVIGASI
            if (mounted) {
                _passwordController.text = '********';
                LoadingOverlay.hide(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            passwordChanged 
                            ? 'Profil & Password berhasil diperbarui! Mohon login kembali.' 
                            : 'Profil berhasil diperbarui.', 
                            style: bodyTextWhite
                        ),
                        backgroundColor: successColor,
                    ),
                );
                
                if (passwordChanged) {
                    // KASUS 1: PASSWORD BERUBAH (HARUS LOGOUT TOTAL)
                    await FirebaseAuth.instance.signOut(); 
                    
                    // NAVIGASI KE LOGIN.DART (target root)
                    Navigator.pushAndRemoveUntil(
                        context, 
                        MaterialPageRoute(builder: (context) => const LoginPage()), 
                        (route) => false,
                    );
                } else {
                    // KASUS 2: DATA NON-PASSWORD BERUBAH (KEMBALI DENGAN REFRESH SINYAL)
                    // Mengirim sinyal 'true' ke ProfilePage untuk memicu refresh
                    Navigator.pop(context, true); 
                }
            }

        } on FirebaseAuthException catch (e) {
            String errorMessage = (e.code == 'requires-recent-login') 
                                  ? "Mohon login ulang untuk mengubah password." 
                                  : "Gagal: ${e.message}";
            if (mounted) {
                LoadingOverlay.hide(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(errorMessage), backgroundColor: dangerColor),
                );
            }
        } catch (e) {
            if (mounted) {
                LoadingOverlay.hide(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal memperbarui profil. Error: $e'), backgroundColor: dangerColor),
                );
            }
        } 
    }
    
    // --- C. Fungsi Utama (Dispatch) ---
    Future<bool> _onWillPop() async {
      if (!_hasUnsavedChanges) {
        return true; 
      }

      return await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: secondaryBackground,
            title: Text('Perhatian!', style: heading2.copyWith(fontSize: 18, color: dangerColor)),
            content: Text(
              'Anda memiliki perubahan yang belum disimpan. Yakin ingin meninggalkan halaman ini? Perubahan tidak akan tersimpan.',
              style: bodyText,
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Tinggalkan', style: bodyText.copyWith(color: dangerColor)),
                onPressed: () => Navigator.of(context).pop(true),
              ),
              ElevatedButton(
                style: primaryButton,
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Lanjutkan Edit'),
              ),
            ],
          );
        },
      ) ?? false;
    }

    void _editProfile() async {
        if (_currentUser == null) return;
        
        if (_usernameController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Username tidak boleh kosong.')),
            );
            return;
        }
        
        final newPassword = _passwordController.text; 
        final passwordWillChange = newPassword.isNotEmpty && newPassword != '********';
        
        if (passwordWillChange) {
            _showConfirmDialog(
                title: "Konfirmasi Perubahan Password",
                content: "Anda mengubah password. Untuk alasan keamanan, Anda akan di-logout dan harus login kembali. Lanjutkan?",
                onConfirm: () => _performUpdate(true),
            );
        } else {
            _performUpdate(false);
        }
    }
    
    // --- D. Dialog Konfirmasi Simpan Password ---
    void _showConfirmDialog({
        required String title,
        required String content,
        required VoidCallback onConfirm,
    }) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
                return AlertDialog(
                    backgroundColor: secondaryBackground,
                    title: Text(title, style: heading2.copyWith(fontSize: 18)),
                    content: Text(content, style: bodyText),
                    actions: <Widget>[
                        TextButton(
                            child: Text("Batal", style: bodyText.copyWith(color: greyColor)),
                            onPressed: () => Navigator.of(context).pop(),
                        ),
                        ElevatedButton(
                            style: primaryButton,
                            onPressed: () {
                                Navigator.of(context).pop();
                                onConfirm(); 
                            },
                            child: const Text("Ya, Simpan"),
                        ),
                    ],
                );
            },
        );
    }

    // --- E. Build Widget ---
    @override
    Widget build(BuildContext context) {
        if (_currentUser == null) {
            return const Scaffold(
                body: Center(child: Text("Pengguna tidak terautentikasi.")),
            );
        }

        if (_isInitializing) {
            return Scaffold(
                backgroundColor: secondaryBackground,
                appBar: AppBar(
                    backgroundColor: secondaryBackground,
                    title: Text('Edit Profile', style: heading2),
                    centerTitle: true,
                ),
                body: const Center(child: CircularProgressIndicator(color: primaryColor)),
            );
        }
        
        return WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
                backgroundColor: secondaryBackground, 
                appBar: AppBar(
                    backgroundColor: secondaryBackground, 
                    elevation: 0,
                    centerTitle: true,
                    leading: IconButton(
                        icon: Icon(Icons.arrow_back, color: accentColor),
                        onPressed: () async {
                            if (await _onWillPop()) {
                                Navigator.pop(context);
                            }
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
                                label: 'E-mail (Tidak Dapat Diubah)',
                                prefixIcon: Icons.email_outlined,
                                controller: _emailController,
                            ),
                            CustomTextField(
                                label: 'Phone',
                                prefixIcon: Icons.phone_outlined,
                                controller: _phoneController,
                            ),
                            CustomTextField(
                                label: 'New Password (Kosongkan jika tidak ingin diubah)',
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
                                    style: primaryButton, 
                                    child: const Text('Simpan Perubahan'),
                                ),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
}