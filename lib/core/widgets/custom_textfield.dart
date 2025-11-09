import 'package:flutter/material.dart';
import 'package:gestura/core/themes/app_theme.dart';
import 'package:gestura/core/utils/responsive.dart';

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
    return Container(
      margin: EdgeInsets.only(bottom: responsiveSize(context, 14)),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(responsiveSize(context, 12)),
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
                  padding: EdgeInsets.all(responsiveSize(context, 10)),
                  child: Icon(prefixIcon, color: primaryColor),
                )
              : null,
          suffixIcon: suffixIcon != null
              ? GestureDetector(
                  onTap: onSuffixTap,
                  child: Padding(
                    padding: EdgeInsets.all(responsiveSize(context, 10)),
                    child: Icon(suffixIcon, color: primaryColor),
                  ),
                )
              : null,
          contentPadding: EdgeInsets.symmetric(
            horizontal: responsiveSize(context, 16),
            vertical: responsiveSize(context, 14),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(responsiveSize(context, 12)),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
