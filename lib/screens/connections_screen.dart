import 'package:flutter/material.dart';
import '../models/platform_def.dart';
import '../models/platform_registry.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/platform_card.dart';

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
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
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: AppColors.black,
      child: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 12),
                  // New vertical logo -- replaces text title + old BrandLogo
                  Image.asset(
                    'assets/images/logo_header.png',
                    width: screenWidth * 0.82,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 175,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.92,
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
