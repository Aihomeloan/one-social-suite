import '../models/platform_def.dart';
import '../models/tone.dart';

/// Reshapes one message into a platform-perfect caption.
/// Swap the implementation later (AICaptionFormatter) without UI changes.
abstract class CaptionFormatter {
  String format(String text, PlatformDef platform, Tone tone);
}

/// v1: deterministic, fully offline rules engine. Privacy-first, no network.
class RulesCaptionFormatter implements CaptionFormatter {
  const RulesCaptionFormatter();

  @override
  String format(String text, PlatformDef platform, Tone tone) {
    final String base = _normalizeWhitespace(text);
    if (base.isEmpty) return '';

    switch (platform.id) {
      case 'x':
        return _forX(base, tone);
      case 'linkedin':
        return _forLinkedIn(base, tone);
      case 'instagram':
        return _forInstagram(base, tone);
      case 'pinterest':
        return _forPinterest(base, tone);
      case 'nextdoor':
        return _forNextdoor(base, tone);
      case 'tiktok':
        return _forTikTok(base, tone);
      case 'facebook':
        return _forFacebook(base, tone);
      case 'snapchat':
        return _forSnapchat(base, tone);
      default:
        return base;
    }
  }

  // ---------- Per-platform shapers ----------

  /// X: short, sharp. Keep <=2 hashtags. Hard trim toward 280.
  String _forX(String text, Tone tone) {
    String body = _stripExtraHashtags(text, keep: 2);
    body = _applyTone(body, tone);
    return _trimToLimit(body, 280);
  }

  /// LinkedIn: professional, expanded contractions, no emoji spam.
  String _forLinkedIn(String text, Tone tone) {
    String body = _expandContractions(text);
    body = _stripEmojis(body);
    body = _stripExtraHashtags(body, keep: 3);
    final String opener = switch (tone) {
      Tone.professional => 'Excited to share: ',
      Tone.clean => '',
      Tone.casual => '',
      Tone.hype => 'Big news — ',
    };
    return _trimToLimit('$opener$body'.trim(), 3000);
  }

  /// Instagram: emotional hook + hashtag block pulled to the end.
  String _forInstagram(String text, Tone tone) {
    final List<String> tags = _extractHashtags(text);
    String body = _removeHashtags(text);
    body = _applyTone(body, tone);
    final String block = tags.isEmpty ? '' : '\n\n${tags.join(' ')}';
    return _trimToLimit('$body$block', 2200);
  }

  /// Pinterest: keyword-forward, descriptive, clean.
  String _forPinterest(String text, Tone tone) {
    String body = _stripEmojis(text);
    body = _stripExtraHashtags(body, keep: 3);
    return _trimToLimit(body, 500);
  }

  /// Nextdoor: local/community framing, no hashtags.
  String _forNextdoor(String text, Tone tone) {
    String body = _removeHashtags(text);
    body = _stripEmojis(body);
    return _trimToLimit(body, 1000);
  }

  /// TikTok: short, catchy, trend energy.
  String _forTikTok(String text, Tone tone) {
    String body = _stripExtraHashtags(text, keep: 4);
    body = _applyTone(body, Tone.hype == tone ? tone : Tone.casual);
    return _trimToLimit(body, 2200);
  }

  /// Facebook: personal, conversational. Light touch.
  String _forFacebook(String text, Tone tone) {
    final String body = _applyTone(text, tone);
    return _trimToLimit(body, 63206);
  }

  /// Snapchat: ultra-short, casual.
  String _forSnapchat(String text, Tone tone) {
    String body = _removeHashtags(text);
    body = _stripEmojis(body);
    return _trimToLimit(body, 250);
  }

  // ---------- Tone ----------

  String _applyTone(String text, Tone tone) {
    switch (tone) {
      case Tone.professional:
        return _expandContractions(text);
      case Tone.clean:
        return _stripEmojis(text);
      case Tone.hype:
        String t = text;
        if (!t.endsWith('!')) {
          t = t.replaceFirst(RegExp(r'[.\s]*$'), '');
          t = '$t!';
        }
        return t;
      case Tone.casual:
        return text;
    }
  }

  // ---------- Helpers ----------

  String _normalizeWhitespace(String text) {
    return text
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  List<String> _extractHashtags(String text) {
    return RegExp(r'#\w+').allMatches(text).map((m) => m.group(0)!).toList();
  }

  String _removeHashtags(String text) {
    return _normalizeWhitespace(text.replaceAll(RegExp(r'#\w+'), ''));
  }

  String _stripExtraHashtags(String text, {required int keep}) {
    final List<String> tags = _extractHashtags(text);
    if (tags.length <= keep) return text;
    final Set<String> drop = tags.skip(keep).toSet();
    String out = text;
    for (final String t in drop) {
      out = out.replaceFirst(t, '');
    }
    return _normalizeWhitespace(out);
  }

  String _stripEmojis(String text) {
    final RegExp emoji = RegExp(
      r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{1F1E6}-\u{1F1FF}\u{2190}-\u{21FF}\u{2B00}-\u{2BFF}]',
      unicode: true,
    );
    return _normalizeWhitespace(text.replaceAll(emoji, ''));
  }

  String _expandContractions(String text) {
    const Map<String, String> map = <String, String>{
      "I'm": 'I am', "you're": 'you are', "we're": 'we are',
      "they're": 'they are', "it's": 'it is', "that's": 'that is',
      "don't": 'do not', "doesn't": 'does not', "didn't": 'did not',
      "can't": 'cannot', "won't": 'will not', "isn't": 'is not',
      "aren't": 'are not', "wasn't": 'was not', "I've": 'I have',
      "we've": 'we have', "you've": 'you have', "I'll": 'I will',
      "we'll": 'we will', "let's": 'let us',
    };
    String out = text;
    map.forEach((String k, String v) {
      out = out.replaceAll(k, v);
      out = out.replaceAll(_capitalize(k), _capitalize(v));
    });
    return out;
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _trimToLimit(String text, int limit) {
    final String t = text.trim();
    if (t.length <= limit) return t;
    final String cut = t.substring(0, limit - 1).trimRight();
    final int lastSpace = cut.lastIndexOf(' ');
    final String safe = lastSpace > limit * 0.6 ? cut.substring(0, lastSpace) : cut;
    return '$safe…';
  }
}
