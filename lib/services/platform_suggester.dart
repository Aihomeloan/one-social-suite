import '../models/post_draft.dart';
import '../models/platform_registry.dart';
import '../models/platform_suggestion.dart';
import '../models/tone.dart';

/// Suggests which platforms to post to. Swap the implementation later
/// (OpenAIPlatformSuggester, LocalAIPlatformSuggester) without touching the UI.
abstract class PlatformSuggester {
  PlatformSuggestion suggest(PostDraft draft);
}

/// v1: deterministic, fully offline rules engine. No network, privacy-first.
class RuleBasedPlatformSuggester implements PlatformSuggester {
  const RuleBasedPlatformSuggester();

  @override
  PlatformSuggestion suggest(PostDraft draft) {
    final Map<String, double> scores = <String, double>{
      for (final p in PlatformRegistry.all) p.id: 0,
    };
    final List<String> reasons = <String>[];

    // --- Tone (strong signal) ---
    switch (draft.tone) {
      case Tone.professional:
        _boost(scores, <String>['linkedin', 'facebook', 'x'], 3);
        reasons.add('Professional tone selected');
      case Tone.casual:
        _boost(scores, <String>['facebook', 'instagram', 'snapchat'], 3);
        reasons.add('Casual tone selected');
      case Tone.hype:
        _boost(scores, <String>['tiktok', 'instagram', 'x'], 3);
        reasons.add('Hype tone selected');
      case Tone.clean:
        _boost(scores, <String>['linkedin', 'facebook', 'nextdoor'], 3);
        reasons.add('Clean tone selected');
    }

    // --- Media ---
    if (draft.hasMedia) {
      if (draft.isVideo) {
        _boost(scores, <String>['tiktok', 'instagram', 'facebook'], 2);
        reasons.add('Contains a video');
      } else {
        _boost(scores, <String>['instagram', 'pinterest', 'facebook', 'tiktok'], 2);
        reasons.add('Contains an image');
      }
    }

    // --- Hashtags ---
    final int tags = _hashtagCount(draft.text);
    if (tags > 5) {
      _boost(scores, <String>['instagram', 'x', 'tiktok'], 2);
      reasons.add('Contains $tags hashtags');
    }

    // --- Length ---
    final int len = draft.text.trim().length;
    if (len > 500) {
      _boost(scores, <String>['linkedin', 'facebook', 'nextdoor'], 2);
      _boost(scores, <String>['x'], -2);
      reasons.add('Long post suits LinkedIn & Facebook');
    } else if (len > 0 && len < 200) {
      _boost(scores, <String>['x', 'instagram', 'tiktok'], 2);
      reasons.add('Short post is ideal for X & Instagram');
    }

    // Rank: score desc, then registry order for stable ties.
    final List<String> order =
        PlatformRegistry.all.map((p) => p.id).toList();
    final List<MapEntry<String, double>> ranked = scores.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) {
        final int byScore = b.value.compareTo(a.value);
        if (byScore != 0) return byScore;
        return order.indexOf(a.key).compareTo(order.indexOf(b.key));
      });

    final List<String> top =
        ranked.take(3).map((e) => e.key).toList();

    return PlatformSuggestion(recommendedIds: top, reasons: reasons);
  }

  void _boost(Map<String, double> scores, List<String> ids, double amount) {
    for (final String id in ids) {
      scores[id] = (scores[id] ?? 0) + amount;
    }
  }

  int _hashtagCount(String text) {
    return RegExp(r'#\w+').allMatches(text).length;
  }
}
