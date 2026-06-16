import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/platform_def.dart';
import '../models/platform_registry.dart';
import '../models/post_draft.dart';
import '../services/caption_formatter.dart';
import '../theme/app_theme.dart';

/// Inline preview: the one message, reshaped per selected platform.
/// Session 5 turns this into the polished swipeable Preview Screen.
class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key, required this.draft});

  final PostDraft draft;

  static const CaptionFormatter _formatter = RulesCaptionFormatter();

  @override
  Widget build(BuildContext context) {
    final List<PlatformDef> selected = PlatformRegistry.all
        .where((p) => draft.selectedPlatformIds.contains(p.id))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: const Text('Preview'),
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.gold,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: selected.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (BuildContext context, int i) {
          final PlatformDef p = selected[i];
          final String caption = _formatter.format(draft.text, p, draft.tone);
          return _PreviewCard(platform: p, caption: caption);
        },
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.platform, required this.caption});

  final PlatformDef platform;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _icon(platform),
              const SizedBox(width: 10),
              Text(
                platform.name,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${caption.length}/${platform.charLimit}',
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(
            caption.isEmpty ? '(empty)' : caption,
            style: const TextStyle(
                color: Colors.white, fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              if (platform.isOpenAndCopy)
                const Text('Open app + copy',
                    style:
                        TextStyle(color: AppColors.textMuted, fontSize: 12))
              else
                const Text('Share sheet ready',
                    style:
                        TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: caption));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${platform.name} caption copied')),
                  );
                },
                icon: const Icon(Icons.copy, color: AppColors.gold, size: 18),
                label: const Text('Copy',
                    style: TextStyle(color: AppColors.gold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _icon(PlatformDef p) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gold, width: 1.3),
      ),
      child: Center(
        child: p.icon != null
            ? Icon(p.icon, color: AppColors.gold, size: 16)
            : Text(p.glyph ?? '?',
                style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
      ),
    );
  }
}
