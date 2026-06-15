import 'package:flutter/widgets.dart';

/// How a platform receives a shared post.
enum ShareMode {
  /// Native share sheet + deep-link handoff.
  shareSheet,

  /// No public share API — open the app and copy caption to clipboard.
  openAndCopy,
}

/// Static definition of a social platform in the 8-platform gateway.
@immutable
class PlatformDef {
  const PlatformDef({
    required this.id,
    required this.name,
    required this.shareMode,
    this.icon,
    this.glyph,
    this.deepLinkScheme,
  });

  /// Stable lowercase id, e.g. 'instagram'. Used as a map/storage key.
  final String id;

  /// Display name shown on the card, e.g. 'Instagram'.
  final String name;

  /// How this platform receives a post.
  final ShareMode shareMode;

  /// Brand icon (FontAwesome). Null when [glyph] is used instead.
  final IconData? icon;

  /// Fallback single-letter glyph (e.g. Nextdoor 'n') when no icon exists.
  final String? glyph;

  /// Deep-link scheme to open the app, e.g. 'instagram://'.
  final String? deepLinkScheme;

  bool get isOpenAndCopy => shareMode == ShareMode.openAndCopy;
}
