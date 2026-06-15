import 'package:flutter/material.dart';
import 'platform_def.dart';

/// The canonical v1 set of 8 platforms, in mockup display order.
/// Uses built-in Material icons (zero external deps). Brand glyphs for
/// platforms Material lacks (X, TikTok, Nextdoor, Snapchat).
class PlatformRegistry {
  PlatformRegistry._();

  static const List<PlatformDef> all = <PlatformDef>[
    PlatformDef(
      id: 'instagram',
      name: 'Instagram',
      shareMode: ShareMode.shareSheet,
      icon: Icons.camera_alt_outlined,
      deepLinkScheme: 'instagram://',
    ),
    PlatformDef(
      id: 'x',
      name: 'X',
      shareMode: ShareMode.shareSheet,
      glyph: 'X',
      deepLinkScheme: 'twitter://',
    ),
    PlatformDef(
      id: 'pinterest',
      name: 'Pinterest',
      shareMode: ShareMode.shareSheet,
      icon: Icons.push_pin_outlined,
      deepLinkScheme: 'pinterest://',
    ),
    PlatformDef(
      id: 'nextdoor',
      name: 'Nextdoor',
      shareMode: ShareMode.openAndCopy,
      glyph: 'n',
      deepLinkScheme: 'nextdoor://',
    ),
    PlatformDef(
      id: 'snapchat',
      name: 'Snapchat',
      shareMode: ShareMode.openAndCopy,
      glyph: '👻',
      deepLinkScheme: 'snapchat://',
    ),
    PlatformDef(
      id: 'tiktok',
      name: 'TikTok',
      shareMode: ShareMode.shareSheet,
      icon: Icons.music_note,
      deepLinkScheme: 'tiktok://',
    ),
    PlatformDef(
      id: 'linkedin',
      name: 'LinkedIn',
      shareMode: ShareMode.shareSheet,
      glyph: 'in',
      deepLinkScheme: 'linkedin://',
    ),
    PlatformDef(
      id: 'facebook',
      name: 'Facebook',
      shareMode: ShareMode.shareSheet,
      icon: Icons.facebook,
      deepLinkScheme: 'fb://',
    ),
  ];

  static int get count => all.length;
}
