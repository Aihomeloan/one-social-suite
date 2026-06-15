import 'package:flutter/material.dart';
import '../models/platform_def.dart';
import '../theme/app_theme.dart';

/// A single platform tile in the Connections grid.
/// Matches the mockup: dark card, gold border, top glow line, circular
/// icon, name, and status. The whole card is one reliable tap target.
class PlatformCard extends StatelessWidget {
  const PlatformCard({
    super.key,
    required this.platform,
    required this.connected,
    required this.onTap,
  });

  final PlatformDef platform;
  final bool connected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = connected ? AppColors.gold : AppColors.border;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.gold.withValues(alpha: 0.12),
        highlightColor: AppColors.gold.withValues(alpha: 0.06),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.4),
            boxShadow: connected
                ? <BoxShadow>[
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.18),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: <Widget>[
              // Top glow line.
              Positioned(
                top: 0,
                left: 24,
                right: 24,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        Colors.transparent,
                        AppColors.gold
                            .withValues(alpha: connected ? 0.9 : 0.5),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppColors.gold
                            .withValues(alpha: connected ? 0.6 : 0.3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _IconRing(platform: platform, connected: connected),
                    const SizedBox(height: 14),
                    Text(
                      platform.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      connected ? 'Connected' : 'Tap to connect',
                      style: TextStyle(
                        color:
                            connected ? AppColors.gold : AppColors.textMuted,
                        fontSize: 13,
                        fontWeight:
                            connected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconRing extends StatelessWidget {
  const _IconRing({required this.platform, required this.connected});

  final PlatformDef platform;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gold, width: 1.6),
        color: connected
            ? AppColors.gold.withValues(alpha: 0.08)
            : Colors.transparent,
      ),
      child: Center(
        child: platform.icon != null
            ? Icon(platform.icon, color: AppColors.gold, size: 28)
            : Text(
                platform.glyph ?? '?',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}
