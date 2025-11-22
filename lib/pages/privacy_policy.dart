import 'package:flutter/material.dart';
import 'package:gestura/core/themes/app_theme.dart';

// Widget pembantu untuk membuat item daftar dengan bullet point
Widget _buildListItem(String text, {TextStyle? style, bool indent = false}) {
  return Padding(
    padding: EdgeInsets.only(bottom: 8.0, left: indent ? 16.0 : 0.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Menggunakan Text sebagai bullet point sederhana
        Text("• ", style: style ?? bodyText), 
        Expanded(
          child: Text(
            text,
            style: style ?? bodyText,
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    ),
  );
}

// Widget pembantu untuk membuat sub-judul dalam daftar (seperti Camera Data:)
Widget _buildSubSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
    child: Text(
      title,
      style: bodyText.copyWith(fontWeight: medium),
    ),
  );
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor, 
        elevation: 0, 
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: accentColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Privacy Policy',
          style: heading2,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Effective Date
            Text(
              "Effective Date: [Insert Date]",
              style: smallText.copyWith(fontWeight: medium),
            ),
            const SizedBox(height: 16),

            // Teks pengantar Kebijakan Privasi
            Text(
              "We respects your privacy and is committed to protecting your personal information. This Privacy Policy explains how we collect, use, and safeguard information when you use our application, which translates sign language into text using your device’s camera (\"the App\").",
              style: bodyText,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24),

            // ===================================================
            // 1. Information We Collect
            // ===================================================
            Text("1. Information We Collect", style: heading2),
            const SizedBox(height: 16),

            // Camera Data
            _buildSubSectionTitle("Camera Data:"),
            Text(
              "The App uses your device’s camera to recognize and translate sign language gestures.",
              style: bodyText,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 8),
            _buildListItem("All video input is processed in real time on your device.", style: smallText, indent: true),
            _buildListItem("We do not store, record, or transmit any images or videos captured by the camera.", style: smallText, indent: true),
            const SizedBox(height: 16),
            
            // Device Information
            _buildSubSectionTitle("Device Information:"),
            Text(
              "We may collect non-personal information such as device type, operating system version, and performance data to improve the App’s functionality.",
              style: bodyText,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),

            // Contact Information
            _buildSubSectionTitle("Contact Information (Optional):"),
            Text(
              "If you reach out for technical support, we may collect your name and email address to respond to your inquiry.",
              style: bodyText,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24),

            // ===================================================
            // 2. How We Use Your Information
            // ===================================================
            Text("2. How We Use Your Information", style: heading2),
            const SizedBox(height: 16),
            _buildListItem("Enable real-time sign language detection and translation.", style: bodyText),
            _buildListItem("Improve App accuracy, performance, and user experience.", style: bodyText),
            _buildListItem("Provide technical support or respond to user requests.", style: bodyText),
            const SizedBox(height: 8),
            Text(
              "We never sell, rent, or share your data with third parties.",
              style: bodyText.copyWith(fontWeight: bold),
            ),
            const SizedBox(height: 24),

            // ===================================================
            // 3. Data Processing and Security
            // ===================================================
            Text("3. Data Processing and Security", style: heading2),
            const SizedBox(height: 16),
            _buildListItem("All sign language recognition and translation occur locally on your device.", style: bodyText),
            _buildListItem("No image or video data is uploaded to external servers.", style: bodyText),
            _buildListItem("We apply appropriate technical and organizational measures to protect any information you share with us.", style: bodyText),
            const SizedBox(height: 24),
            
            // ===================================================
            // 4. Permissions
            // ===================================================
            Text("4. Permissions", style: heading2),
            const SizedBox(height: 16),
            _buildListItem("Camera Access: Required to capture sign language gestures for translation.", style: bodyText.copyWith(fontWeight: medium)),
            _buildListItem("Storage Access (Optional): If you choose to save translation results or settings.", style: bodyText.copyWith(fontWeight: medium)),
            const SizedBox(height: 8),
             Text(
              "You can manage or revoke these permissions at any time through your device settings.",
              style: smallText,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24),

            // ===================================================
            // 5. Third-Party Services
            // ===================================================
            Text("5. Third-Party Services", style: heading2),
            const SizedBox(height: 16),
            Text(
              "This App does not use third-party analytics, advertising, or tracking tools that collect personal data.",
              style: bodyText,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24),

            // ===================================================
            // 6. Updates to This Policy
            // ===================================================
            Text("6. Updates to This Policy", style: heading2),
            const SizedBox(height: 16),
            Text(
              "We may update this Privacy Policy from time to time. Any changes will be reflected in this section and indicated by an updated “Effective Date.”",
              style: bodyText,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24),

            // ===================================================
            // 7. Contact Us
            // ===================================================
            Text("7. Contact Us", style: heading2),
            const SizedBox(height: 16),
             Text(
              "If you have any questions or concerns about this Privacy Policy, please contact us at:",
              style: bodyText,
            ),
            const SizedBox(height: 8),
            Text(
              "📧 [your@email.com]",
              style: bodyText.copyWith(fontWeight: bold, color: primaryColor),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}