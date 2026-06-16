import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/platform_def.dart';

enum ShareOutcome {
  sharedViaSheet,
  copiedAndOpened,
  appNotFound,
  failed,
}

class ShareService {
  const ShareService();

  Future<ShareOutcome> shareToPlatform({
    required PlatformDef platform,
    required String caption,
    String? mediaPath,
  }) async {
    try {
      if (platform.isOpenAndCopy) {
        return _openAndCopy(platform, caption);
      }
      return _shareSheet(caption, mediaPath);
    } catch (_) {
      return ShareOutcome.failed;
    }
  }

  Future<ShareOutcome> _shareSheet(String caption, String? mediaPath) async {
    final ShareParams params = (mediaPath != null && mediaPath.isNotEmpty)
        ? ShareParams(text: caption, files: <XFile>[XFile(mediaPath)])
        : ShareParams(text: caption);
    await SharePlus.instance.share(params);
    return ShareOutcome.sharedViaSheet;
  }

  Future<ShareOutcome> _openAndCopy(
      PlatformDef platform, String caption) async {
    await Clipboard.setData(ClipboardData(text: caption));
    final String? scheme = platform.deepLinkScheme;
    if (scheme != null) {
      final Uri uri = Uri.parse(scheme);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return ShareOutcome.copiedAndOpened;
      }
    }
    return ShareOutcome.appNotFound;
  }
}
