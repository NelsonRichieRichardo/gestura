import 'package:flutter/material.dart';
import 'package:gestura/core/themes/app_theme.dart';

class CustomTextfield extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool readOnly;

  const CustomTextfield({
    super.key,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    // NOTE: Semua responsiveSize diganti dengan responsiveFont untuk penskalaan yang tepat.
    return Container(
      margin: EdgeInsets.only(bottom: responsiveFont(context, 14)),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(responsiveFont(context, 12)),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        readOnly: readOnly,
        style: bodyText.copyWith(fontSize: responsiveFont(context, 14)),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: smallText.copyWith(color: greyColor),
          prefixIcon: prefixIcon != null
              ? Padding(
                  padding: EdgeInsets.all(responsiveFont(context, 10)),
                  child: Icon(prefixIcon, color: primaryColor),
                )
              : null,
          suffixIcon: suffixIcon != null
              ? GestureDetector(
                  onTap: onSuffixTap,
                  child: Padding(
                    padding: EdgeInsets.all(responsiveFont(context, 10)),
                    child: Icon(suffixIcon, color: primaryColor),
                  ),
                )
              : null,
          contentPadding: EdgeInsets.symmetric(
            horizontal: responsiveFont(context, 16),
            vertical: responsiveFont(context, 14),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(responsiveFont(context, 12)),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}