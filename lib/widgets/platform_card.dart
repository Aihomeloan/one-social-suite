import 'package:flutter/material.dart';
import '../models/platform_def.dart';
import '../theme/app_theme.dart';

/// A single platform tile in the Connections grid.
/// Compact design -- icon + name + status, fits 3-col grid without wrapping.
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
        borderRadius: BorderRadius.circular(14),
        splashColor: AppColors.gold.withValues(alpha: 0.12),
        highlightColor: AppColors.gold.withValues(alpha: 0.06),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.4),
            boxShadow: connected
                ? <BoxShadow>[
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.18),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: <Widget>[
              // Top glow line
              Positioned(
                top: 0,
                left: 16,
                right: 16,
                child: Container(
                  height: 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        Colors.transparent,
                        AppColors.gold.withValues(
                            alpha: connected ? 0.9 : 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _IconRing(platform: platform, connected: connected),
                    const SizedBox(height: 8),
                    Text(
                      platform.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      connected ? 'Connected' : 'Tap to connect',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: connected
                            ? AppColors.gold
                            : AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: connected
                            ? FontWeight.w600
                            : FontWeight.w400,
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
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gold, width: 1.5),
        color: connected
            ? AppColors.gold.withValues(alpha: 0.08)
            : Colors.transparent,
      ),
      child: Center(
        child: platform.icon != null
            ? Icon(platform.icon, color: AppColors.gold, size: 22)
            : Text(
                platform.glyph ?? '?',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}
