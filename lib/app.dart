import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_shell.dart';

class OneSocialSuiteApp extends StatelessWidget {
  const OneSocialSuiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '1SocialSuite',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeShell(),
    );
  }
}
