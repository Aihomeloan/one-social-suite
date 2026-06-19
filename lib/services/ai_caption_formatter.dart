import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/platform_def.dart';
import '../models/tone.dart';

/// BETA: AI-powered caption formatter using OpenAI.
///
/// WARNING: For TestFlight beta only. The API key is provided at build time
/// and can be extracted from the binary. Never ship to the public App Store
/// with a baked-in key - replace with a backend proxy first.
///
/// Implements the same contract as RulesCaptionFormatter so it drops in with
/// zero UI changes. On any error, returns an empty string so the caller can
/// fall back to the rules engine.
class AICaptionFormatter {
  const AICaptionFormatter();

  static const String _apiKey = String.fromEnvironment(
    'OPENAI_KEY',
    defaultValue: '',
  );

  static const String _endpoint = 'https://api.openai.com/v1/chat/completions';

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<String> formatAsync(
      String text, PlatformDef platform, Tone tone) async {
    if (_apiKey.isEmpty || text.trim().isEmpty) return '';

    final String prompt = _buildPrompt(text, platform, tone);
    const String systemMessage =
        'You are a social media copywriter. Rewrite the message for a specific '
        'platform. Return ONLY the rewritten caption: no quotes, no preamble, '
        'no notes.';

    try {
      final http.Response res = await http
          .post(
            Uri.parse(_endpoint),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode(<String, dynamic>{
              'model': 'gpt-4o-mini',
              'messages': <Map<String, String>>[
                <String, String>{'role': 'system', 'content': systemMessage},
                <String, String>{'role': 'user', 'content': prompt},
              ],
              'max_tokens': 400,
              'temperature': 0.7,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (res.statusCode != 200) return '';
      final Map<String, dynamic> data =
          jsonDecode(res.body) as Map<String, dynamic>;
      final List<dynamic> choices =
          data['choices'] as List<dynamic>? ?? <dynamic>[];
      if (choices.isEmpty) return '';
      final Map<String, dynamic> msg =
          (choices.first as Map<String, dynamic>)['message']
              as Map<String, dynamic>;
      final String out = (msg['content'] as String? ?? '').trim();
      if (out.length > platform.charLimit) {
        return out.substring(0, platform.charLimit);
      }
      return out;
    } catch (_) {
      return '';
    }
  }

  String _buildPrompt(String text, PlatformDef p, Tone tone) {
    final String style = switch (p.id) {
      'x' => 'short, sharp, max 280 characters, at most 2 hashtags',
      'linkedin' =>
        'professional and polished, no emoji spam, expand contractions',
      'instagram' => 'visual and emotional, with a hashtag block at the end',
      'pinterest' => 'keyword-rich and descriptive, search-friendly',
      'nextdoor' => 'local, friendly, community-focused, no hashtags',
      'tiktok' => 'short, catchy, trend-aware energy',
      'facebook' => 'personal and conversational',
      'snapchat' => 'very short and casual',
      _ => 'clear and engaging',
    };
    return 'Platform: ${p.name}\n'
        'Tone: ${tone.label}\n'
        'Style guidance: $style\n'
        'Keep it under ${p.charLimit} characters.\n\n'
        'Message to rewrite:\n$text';
  }
}
