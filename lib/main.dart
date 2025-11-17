import 'package:flutter/material.dart';
import 'package:gestura/pages/register.dart';
import 'core/themes/app_theme.dart';
import 'pages/onboarding.dart';
import 'pages/login.dart';
import 'pages/register.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Sign Language Translator',

      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: backgroundColor,
      ),

      home: const OnboardingPage(),
    );
  }
}
