/// Result of the PlatformSuggester: which platforms to post to, and why.
class PlatformSuggestion {
  const PlatformSuggestion({
    required this.recommendedIds,
    required this.reasons,
  });

  final List<String> recommendedIds;
  final List<String> reasons;

  bool get isEmpty => recommendedIds.isEmpty;
}
