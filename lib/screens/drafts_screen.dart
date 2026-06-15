import 'package:flutter/material.dart';
import '../widgets/coming_soon.dart';

class DraftsScreen extends StatelessWidget {
  const DraftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoon(
      icon: Icons.drafts_outlined,
      title: 'Drafts',
      subtitle: 'Unfinished posts, saved locally on your device. Never cloud.',
      session: 'BUILDING IN SESSION 5',
    );
  }
}
