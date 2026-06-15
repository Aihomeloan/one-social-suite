import 'package:flutter/material.dart';
import '../widgets/coming_soon.dart';

class ComposeScreen extends StatelessWidget {
  const ComposeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoon(
      icon: Icons.edit_note,
      title: 'Compose',
      subtitle:
          'Write once. Shape your message for each platform, then share smarter.',
      session: 'BUILDING IN SESSION 3',
    );
  }
}
