import 'package:flutter/material.dart';
import 'package:gestura/core/themes/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final double? width;
  final double? height;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.width,
    this.height,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    // NOTE: responsiveSize diganti dengan responsiveHeight (untuk tinggi) 
    // dan responsiveFont (untuk padding/radius) karena responsiveSize tidak terdefinisi 
    // di file app_theme.dart. 0.065 adalah perkiraan rasio tinggi yang baik.
    const double defaultHeightRatio = 0.065; 

    return SizedBox(
      width: width ?? screenWidth(context) * 0.9,
      height: height ?? responsiveHeight(context, defaultHeightRatio),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 2,
          // Menggunakan konstanta warna dari app_theme.dart
          backgroundColor: isOutlined
              ? backgroundColor
              : (color ?? primaryColor),
          foregroundColor: isOutlined ? primaryColor : backgroundColor,
          shape: RoundedRectangleBorder(
            // Menggunakan responsiveFont untuk scaling radius
            borderRadius: BorderRadius.circular(responsiveFont(context, 10)),
            side: isOutlined
                ? BorderSide(color: primaryColor, width: 1.5)
                : BorderSide.none,
          ),
          padding: EdgeInsets.symmetric(
            // Menggunakan responsiveFont untuk scaling padding
            vertical: responsiveFont(context, 14),
            horizontal: responsiveFont(context, 16),
          ),
        ),
        child: Text(
          text,
          style: bodyTextWhite.copyWith(
            // Menggunakan bodyTextWhite dan bold dari app_theme.dart
            color: isOutlined ? primaryColor : backgroundColor,
            fontSize: responsiveFont(context, 14),
            fontWeight: bold,
          ),
        ),
      ),
    );
  }
}