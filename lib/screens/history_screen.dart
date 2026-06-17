import 'package:flutter/material.dart';
import '../models/history_entry.dart';
import '../models/platform_registry.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryEntry> _entries = <HistoryEntry>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() =>
      setState(() => _entries = StorageService.instance.getHistory());

  Future<void> _clearAll() async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear history?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'This removes your local share log from this device. It cannot be undone.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear',
                style: TextStyle(color: Color(0xFFFF8A3D))),
          ),
        ],
      ),
    );
    if (ok == true) {
      await StorageService.instance.clearHistory();
      _load();
    }
  }

  String _timeAgo(DateTime t) {
    final Duration d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    return '${t.month}/${t.day}/${t.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.black,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'History',
                  style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
                if (_entries.isNotEmpty)
                  Positioned(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: IconButton(
                        icon: const Icon(Icons.delete_sweep_outlined,
                            color: AppColors.textMuted, size: 20),
                        onPressed: _clearAll,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'A local log of what you prepared and shared',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Expanded(child: _entries.isEmpty ? _empty() : _list()),
          ],
        ),
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold, width: 2),
              ),
              child:
                  const Icon(Icons.history, color: AppColors.gold, size: 40),
            ),
            const SizedBox(height: 20),
            const Text('No history yet',
                style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'When you share a post, it is logged here on your device so you can see what you sent and where.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textMuted, fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: _entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int i) {
        final HistoryEntry e = _entries[i];
        final dynamic def = PlatformRegistry.byId(e.platformId);
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 1.3),
                    ),
                    child: Center(
                      child: def?.icon != null
                          ? Icon(def.icon, color: AppColors.gold, size: 15)
                          : Text(def?.glyph ?? '?',
                              style: const TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    e.platformName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(_timeAgo(e.sharedAt),
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                e.preview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 13, height: 1.35),
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      e.status,
                      style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (e.hadMedia) ...<Widget>[
                    const SizedBox(width: 8),
                    const Icon(Icons.image_outlined,
                        color: AppColors.textMuted, size: 14),
                    const SizedBox(width: 3),
                    const Text('media',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 11)),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
