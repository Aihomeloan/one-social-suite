import 'package:flutter/material.dart';
import 'platform_def.dart';

/// The canonical v1 set of 8 platforms, in mockup display order.
class PlatformRegistry {
  PlatformRegistry._();

  static const List<PlatformDef> all = <PlatformDef>[
    PlatformDef(
      id: 'instagram',
      name: 'Instagram',
      shareMode: ShareMode.shareSheet,
      charLimit: 2200,
      icon: Icons.camera_alt_outlined,
      deepLinkScheme: 'instagram://',
    ),
    PlatformDef(
      id: 'x',
      name: 'X',
      shareMode: ShareMode.shareSheet,
      charLimit: 280,
      glyph: 'X',
      deepLinkScheme: 'twitter://',
    ),
    PlatformDef(
      id: 'pinterest',
      name: 'Pinterest',
      shareMode: ShareMode.shareSheet,
      charLimit: 500,
      icon: Icons.push_pin_outlined,
      deepLinkScheme: 'pinterest://',
    ),
    PlatformDef(
      id: 'nextdoor',
      name: 'Nextdoor',
      shareMode: ShareMode.openAndCopy,
      charLimit: 1000,
      glyph: 'n',
      deepLinkScheme: 'nextdoor://',
    ),
    PlatformDef(
      id: 'snapchat',
      name: 'Snapchat',
      shareMode: ShareMode.openAndCopy,
      charLimit: 250,
      glyph: '👻',
      deepLinkScheme: 'snapchat://',
    ),
    PlatformDef(
      id: 'tiktok',
      name: 'TikTok',
      shareMode: ShareMode.shareSheet,
      charLimit: 2200,
      icon: Icons.music_note,
      deepLinkScheme: 'tiktok://',
    ),
    PlatformDef(
      id: 'linkedin',
      name: 'LinkedIn',
      shareMode: ShareMode.shareSheet,
      charLimit: 3000,
      glyph: 'in',
      deepLinkScheme: 'linkedin://',
    ),
    PlatformDef(
      id: 'facebook',
      name: 'Facebook',
      shareMode: ShareMode.shareSheet,
      charLimit: 63206,
      icon: Icons.facebook,
      deepLinkScheme: 'fb://',
    ),
  ];

  static int get count => all.length;

  static PlatformDef? byId(String id) {
    for (final PlatformDef p in all) {
      if (p.id == id) return p;
    }
    return null;
  }
}
