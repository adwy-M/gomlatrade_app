import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class PolicyScreen extends StatelessWidget {
  final String title;
  final String content;

  const PolicyScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: AppTheme.textPrimary)),
        backgroundColor: AppTheme.cardDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

const String genericPrivacyPolicy = '''
Privacy Policy for Gomlatrade

Last updated: Today

This Privacy Policy describes Our policies and procedures on the collection, use and disclosure of Your information when You use the Service and tells You about Your privacy rights and how the law protects You.

We use Your Personal data to provide and improve the Service. By using the Service, You agree to the collection and use of information in accordance with this Privacy Policy.
''';

const String genericTermsOfService = '''
Terms of Service for Gomlatrade

Last updated: Today

Please read these terms and conditions carefully before using Our Service.

By accessing or using the Service You agree to be bound by these Terms. If You disagree with any part of these Terms then You may not access the Service.
''';
