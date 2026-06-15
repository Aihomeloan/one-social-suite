import 'package:flutter/material.dart';
import '../widgets/coming_soon.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoon(
      icon: Icons.shield_outlined,
      title: 'Privacy',
      subtitle:
          'No passwords stored. No data sold. No cross-app tracking. Face ID optional.',
      session: 'BUILDING IN SESSION 8',
    );
  }
}
