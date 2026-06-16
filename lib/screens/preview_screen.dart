import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/platform_def.dart';
import '../models/platform_registry.dart';
import '../models/post_draft.dart';
import '../services/caption_formatter.dart';
import '../theme/app_theme.dart';

/// Polished swipeable preview: one platform per page. Tap to edit each
/// caption; edits persist while you swipe (regenerate on re-entry).
class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key, required this.draft});

  final PostDraft draft;

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  static const CaptionFormatter _formatter = RulesCaptionFormatter();
  static const Color _warn = Color(0xFFFF8A3D);

  final PageController _page = PageController();
  late final List<PlatformDef> _platforms;
  late final List<String> _formatted;
  late final List<TextEditingController> _controllers;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _platforms = PlatformRegistry.all
        .where((p) => widget.draft.selectedPlatformIds.contains(p.id))
        .toList();
    _formatted = _platforms
        .map((p) => _formatter.format(widget.draft.text, p, widget.draft.tone))
        .toList();
    _controllers = _formatted
        .map((String c) => TextEditingController(text: c))
        .toList();
  }

  @override
  void dispose() {
    _page.dispose();
    for (final TextEditingController c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _dismissKeyboard() => FocusScope.of(context).unfocus();

  void _resetCurrent() {
    setState(() {
      _controllers[_index].text = _formatted[_index];
    });
  }

  void _copyCurrent() {
    Clipboard.setData(ClipboardData(text: _controllers[_index].text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_platforms[_index].name} caption copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_platforms.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.black,
        appBar: AppBar(
          title: const Text('Preview'),
          backgroundColor: AppColors.black,
          foregroundColor: AppColors.gold,
        ),
        body: const Center(
          child: Text('No platforms selected.',
              style: TextStyle(color: AppColors.textMuted)),
        ),
      );
    }

    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Scaffold(
        backgroundColor: AppColors.black,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text('Preview  ${_index + 1} of ${_platforms.length}'),
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
            _dots(),
            Expanded(
              child: PageView.builder(
                controller: _page,
                itemCount: _platforms.length,
                onPageChanged: (int i) => setState(() {
                  _dismissKeyboard();
                  _index = i;
                }),
                itemBuilder: (BuildContext context, int i) => _card(i),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dots() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List<Widget>.generate(_platforms.length, (int i) {
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

  Widget _card(int i) {
    final PlatformDef p = _platforms[i];
    final TextEditingController ctrl = _controllers[i];
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
                      : '$len / ${p.charLimit} — over limit',
                  style: TextStyle(
                    color: fits ? AppColors.textMuted : _warn,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                if (ctrl.text != _formatted[i])
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
                    onPressed: () =>
                        ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Share handoff arrives in Session 6.')),
                    ),
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
            const SizedBox(height: 6),
            Center(
              child: Text(
                i < _platforms.length - 1
                    ? 'Swipe for ${_platforms[i + 1].name}  →'
                    : 'Last platform',
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 12),
              ),
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
