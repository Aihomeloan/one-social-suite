import 'package:flutter/material.dart';
import '../models/platform_def.dart';
import '../models/platform_registry.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import '../widgets/platform_card.dart';

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  // In-memory connection state for now. Session 5 persists this to Hive
  // so connections survive an app restart.
  final Set<String> _connected = <String>{};

  @override
  void initState() {
    super.initState();
    _connected.addAll(StorageService.instance.getConnected());
  }

  void _toggle(String id) {
    setState(() {
      if (_connected.contains(id)) {
        _connected.remove(id);
      } else {
        _connected.add(id);
      }
    });
    StorageService.instance.setConnected(_connected);
  }

  @override
  Widget build(BuildContext context) {
    final int connectedCount = _connected.length;
    final int total = PlatformRegistry.count;

    return Container(
      color: AppColors.black,
      child: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 16),
                  const Text(
                    '1SocialSuite',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$connectedCount of $total connected',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const BrandLogo(width: 440, height: 233),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.88,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final PlatformDef p = PlatformRegistry.all[index];
                    return PlatformCard(
                      platform: p,
                      connected: _connected.contains(p.id),
                      onTap: () => _toggle(p.id),
                    );
                  },
                  childCount: PlatformRegistry.all.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
