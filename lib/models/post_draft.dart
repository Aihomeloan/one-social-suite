import 'tone.dart';

/// The single object that flows Composer -> Formatter -> Share.
class PostDraft {
  const PostDraft({
    required this.text,
    required this.selectedPlatformIds,
    required this.tone,
    this.mediaPath,
    this.isVideo = false,
    this.useAi = false,
  });

  final String text;
  final Set<String> selectedPlatformIds;
  final Tone tone;
  final String? mediaPath;
  final bool isVideo;
  final bool useAi;

  bool get hasMedia => mediaPath != null;
}
