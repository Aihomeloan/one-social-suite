import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/history_entry.dart';
import '../models/platform_def.dart';
import '../models/platform_registry.dart';
import '../models/post_draft.dart';
import '../services/caption_formatter.dart';
import '../services/storage_service.dart';
import '../services/share_service.dart';
import '../theme/app_theme.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key, required this.draft});

  final PostDraft draft;

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  static const CaptionFormatter _formatter = RulesCaptionFormatter();
  static const ShareService _share = ShareService();
  static const Color _warn = Color(0xFFFF8A3D);

  final PageController _page = PageController();

  // Live, editable selection (starts from the incoming draft).
  late Set<String> _selectedIds;
  // Per-platform edited captions, keyed by platform id so edits survive
  // toggling platforms on/off.
  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};

  int _index = 0;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.draft.selectedPlatformIds.toSet();
    _syncControllers();
  }

  List<PlatformDef> get _platforms => PlatformRegistry.all
      .where((p) => _selectedIds.contains(p.id))
      .toList();

  String _formattedFor(PlatformDef p) =>
      _formatter.format(widget.draft.text, p, widget.draft.tone);

  void _syncControllers() {
    for (final PlatformDef p in PlatformRegistry.all) {
      if (_selectedIds.contains(p.id)) {
        _controllers.putIfAbsent(
            p.id, () => TextEditingController(text: _formattedFor(p)));
      }
    }
  }

  @override
  void dispose() {
    _page.dispose();
    for (final TextEditingController c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _dismissKeyboard() => FocusScope.of(context).unfocus();

  void _toggle(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      _syncControllers();
      if (_index >= _platforms.length) {
        _index = _platforms.isEmpty ? 0 : _platforms.length - 1;
      }
    });
  }

  void _resetCurrent() {
    final PlatformDef p = _platforms[_index];
    setState(() => _controllers[p.id]!.text = _formattedFor(p));
  }

  void _copyCurrent() {
    final PlatformDef p = _platforms[_index];
    Clipboard.setData(ClipboardData(text: _controllers[p.id]!.text));
    _snack('${p.name} caption copied');
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _logShare(PlatformDef p, ShareOutcome o) async {
    if (o == ShareOutcome.failed) return;
    final String status = switch (o) {
      ShareOutcome.sharedViaSheet => 'Shared via sheet',
      ShareOutcome.copiedAndOpened => 'Copied + opened',
      ShareOutcome.appNotFound => 'Copied (app not found)',
      ShareOutcome.failed => 'Prepared',
    };
    await StorageService.instance.addHistory(HistoryEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString() + p.id,
      platformId: p.id,
      platformName: p.name,
      caption: _controllers[p.id]?.text ?? '',
      status: status,
      hadMedia: widget.draft.mediaPath != null,
      sharedAt: DateTime.now(),
    ));
  }

  String _outcomeMessage(PlatformDef p, ShareOutcome o) {
    switch (o) {
      case ShareOutcome.sharedViaSheet:
        return '${p.name}: share sheet opened';
      case ShareOutcome.copiedAndOpened:
        return '${p.name}: caption copied, paste to post';
      case ShareOutcome.appNotFound:
        return '${p.name} not installed, caption copied';
      case ShareOutcome.failed:
        return '${p.name}: could not share';
    }
  }

  Future<void> _shareOne(PlatformDef p) async {
    _dismissKeyboard();
    final ShareOutcome o = await _share.shareToPlatform(
      platform: p,
      caption: _controllers[p.id]!.text,
      mediaPath: widget.draft.mediaPath,
    );
    await _logShare(p, o);
    if (!mounted) return;
    _snack(_outcomeMessage(p, o));
  }

  Future<void> _shareAll() async {
    _dismissKeyboard();
    setState(() => _busy = true);
    for (final PlatformDef p in _platforms) {
      final ShareOutcome o = await _share.shareToPlatform(
        platform: p,
        caption: _controllers[p.id]!.text,
        mediaPath: widget.draft.mediaPath,
      );
      await _logShare(p, o);
      if (!mounted) return;
      _snack(_outcomeMessage(p, o));
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final List<PlatformDef> platforms = _platforms;

    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Scaffold(
        backgroundColor: AppColors.black,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(platforms.isEmpty
              ? 'Preview'
              : 'Preview  ${_index + 1} of ${platforms.length}'),
          backgroundColor: AppColors.black,
          foregroundColor: AppColors.gold,
          actions: <Widget>[
            TextButton(
              onPressed: _dismissKeyboard,
              child: const Text('Done',
                  style: TextStyle(
                      color: AppColors.gold, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            _platformChips(),
            if (platforms.isEmpty)
              Expanded(child: _emptyState())
            else ...<Widget>[
              _dots(platforms),
              Expanded(
                child: PageView.builder(
                  controller: _page,
                  itemCount: platforms.length,
                  onPageChanged: (int i) => setState(() {
                    _dismissKeyboard();
                    _index = i;
                  }),
                  itemBuilder: (BuildContext context, int i) =>
                      _card(platforms[i]),
                ),
              ),
              _shareAllBar(platforms.length),
            ],
          ],
        ),
      ),
    );
  }

  Widget _platformChips() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text('Share to',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PlatformRegistry.all.map((p) {
              final bool on = _selectedIds.contains(p.id);
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _toggle(p.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: on
                          ? AppColors.gold.withValues(alpha: 0.16)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: on ? AppColors.gold : AppColors.border,
                          width: on ? 1.5 : 1),
                    ),
                    child: Text(p.name,
                        style: TextStyle(
                            color: on ? AppColors.gold : Colors.white,
                            fontSize: 13,
                            fontWeight:
                                on ? FontWeight.w700 : FontWeight.w400)),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            Icon(Icons.hub_outlined, color: AppColors.gold, size: 48),
            SizedBox(height: 16),
            Text('Pick at least one platform',
                style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              'Tap a platform above to see your message shaped for it and share.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textMuted, fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shareAllBar(int count) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _busy ? null : _shareAll,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              disabledBackgroundColor: AppColors.gold.withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black),
                  )
                : const Icon(Icons.rocket_launch,
                    color: Colors.black, size: 20),
            label: Text(
              _busy ? 'Sharing...' : 'Share All ($count)',
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dots(List<PlatformDef> platforms) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List<Widget>.generate(platforms.length, (int i) {
          final bool active = i == _index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: active ? AppColors.gold : AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _card(PlatformDef p) {
    final TextEditingController ctrl = _controllers[p.id]!;
    final int len = ctrl.text.length;
    final bool fits = len <= p.charLimit;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.08),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                _icon(p),
                const SizedBox(width: 12),
                Text(
                  p.name,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: p.isOpenAndCopy
                            ? AppColors.border
                            : AppColors.gold.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    p.isOpenAndCopy ? 'Open + copy' : 'Share sheet',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(14),
              child: TextField(
                controller: ctrl,
                maxLines: null,
                minLines: 4,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                    color: Colors.white, fontSize: 15, height: 1.4),
                cursorColor: AppColors.gold,
                decoration: const InputDecoration.collapsed(hintText: ''),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Icon(
                  fits ? Icons.check_circle_outline : Icons.warning_amber,
                  color: fits ? AppColors.gold : _warn,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  fits
                      ? '$len / ${p.charLimit}'
                      : '$len / ${p.charLimit} over limit',
                  style: TextStyle(
                    color: fits ? AppColors.textMuted : _warn,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                if (ctrl.text != _formattedFor(p))
                  TextButton(
                    onPressed: _resetCurrent,
                    child: const Text('Reset',
                        style: TextStyle(color: AppColors.textMuted)),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _copyCurrent,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.gold),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.copy,
                        color: AppColors.gold, size: 18),
                    label: const Text('Copy',
                        style: TextStyle(color: AppColors.gold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _busy ? null : () => _shareOne(p),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.ios_share,
                        color: Colors.black, size: 18),
                    label: const Text('Share',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _icon(PlatformDef p) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gold, width: 1.5),
      ),
      child: Center(
        child: p.icon != null
            ? Icon(p.icon, color: AppColors.gold, size: 20)
            : Text(p.glyph ?? '?',
                style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
      ),
    );
  }
}
