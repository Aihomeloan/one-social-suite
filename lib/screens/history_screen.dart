import 'package:flutter/material.dart';
import '../widgets/coming_soon.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoon(
      icon: Icons.history,
      title: 'History',
      subtitle: 'A local log of what you prepared and shared. Honest status only.',
      session: 'BUILDING IN SESSION 7',
    );
  }
}
