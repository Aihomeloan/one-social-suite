/// A local record of a share action. Honest status only - never "Posted".
class HistoryEntry {
  HistoryEntry({
    required this.id,
    required this.platformId,
    required this.platformName,
    required this.caption,
    required this.status,
    required this.hadMedia,
    required this.sharedAt,
  });

  final String id;
  final String platformId;
  final String platformName;
  final String caption;
  final String status; // 'Shared via sheet' | 'Copied + opened' | 'Prepared'
  final bool hadMedia;
  final DateTime sharedAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'platformId': platformId,
        'platformName': platformName,
        'caption': caption,
        'status': status,
        'hadMedia': hadMedia,
        'sharedAt': sharedAt.toIso8601String(),
      };

  static HistoryEntry fromMap(Map<dynamic, dynamic> m) => HistoryEntry(
        id: m['id'] as String,
        platformId: m['platformId'] as String? ?? '',
        platformName: m['platformName'] as String? ?? '',
        caption: m['caption'] as String? ?? '',
        status: m['status'] as String? ?? 'Prepared',
        hadMedia: m['hadMedia'] as bool? ?? false,
        sharedAt: DateTime.tryParse(m['sharedAt'] as String? ?? '') ??
            DateTime.now(),
      );

  String get preview {
    final String t = caption.trim();
    if (t.isEmpty) return '(no caption)';
    return t.length <= 70 ? t : '${t.substring(0, 70)}...';
  }
}
