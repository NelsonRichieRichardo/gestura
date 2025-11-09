import 'package:flutter/material.dart';
import 'package:gestura/core/themes/app_theme.dart';
import 'package:gestura/core/utils/responsive.dart';

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
    return SizedBox(
      width: width ?? screenWidth(context) * 0.9,
      height: height ?? responsiveSize(context, 52),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: isOutlined
              ? backgroundColor
              : (color ?? primaryColor),
          foregroundColor: isOutlined ? primaryColor : backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsiveSize(context, 10)),
            side: isOutlined
                ? BorderSide(color: primaryColor, width: 1.5)
                : BorderSide.none,
          ),
          padding: EdgeInsets.symmetric(
            vertical: responsiveSize(context, 14),
            horizontal: responsiveSize(context, 16),
          ),
        ),
        child: Text(
          text,
          style: bodyTextWhite.copyWith(
            color: isOutlined ? primaryColor : backgroundColor,
            fontSize: responsiveFont(context, 14),
            fontWeight: bold,
          ),
        ),
      ),
    );
  }
}
