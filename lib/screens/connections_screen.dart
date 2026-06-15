import 'package:flutter/material.dart';
import '../widgets/coming_soon.dart';

class ConnectionsScreen extends StatelessWidget {
  const ConnectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoon(
      icon: Icons.hub_outlined,
      title: 'Connections',
      subtitle: 'Your 8-platform gateway. The gold grid lands next.',
      session: 'BUILDING IN SESSION 2',
    );
  }
}
