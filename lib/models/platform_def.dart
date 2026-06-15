import 'package:flutter/widgets.dart';

/// How a platform receives a shared post.
enum ShareMode {
  shareSheet,   // native share sheet + deep-link handoff
  openAndCopy,  // no public share API: open app + copy caption to clipboard
}

/// Static definition of a social platform in the 8-platform gateway.
@immutable
class PlatformDef {
  const PlatformDef({
    required this.id,
    required this.name,
    required this.shareMode,
    required this.charLimit,
    this.icon,
    this.glyph,
    this.deepLinkScheme,
  });

  final String id;
  final String name;
  final ShareMode shareMode;
  final int charLimit;
  final IconData? icon;
  final String? glyph;
  final String? deepLinkScheme;

  bool get isOpenAndCopy => shareMode == ShareMode.openAndCopy;
}
