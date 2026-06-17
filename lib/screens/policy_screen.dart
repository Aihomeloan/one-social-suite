import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Displays the bundled privacy policy (assets/privacy_policy.md).
/// Renders the markdown-ish text with simple gold headings - no extra deps.
class PolicyScreen extends StatefulWidget {
  const PolicyScreen({super.key});

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  String? _text;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final String raw =
        await rootBundle.loadString('assets/privacy_policy.md');
    if (!mounted) return;
    setState(() => _text = raw);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.gold,
      ),
      body: _text == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _render(_text!),
              ),
            ),
    );
  }

  List<Widget> _render(String md) {
    final List<Widget> out = <Widget>[];
    for (final String lineRaw in md.split('\n')) {
      final String line = lineRaw.trimRight();
      if (line.isEmpty) {
        out.add(const SizedBox(height: 8));
      } else if (line.startsWith('# ')) {
        out.add(_heading(line.substring(2), 24));
      } else if (line.startsWith('## ')) {
        out.add(_heading(line.substring(3), 18));
      } else if (line.startsWith('- ')) {
        out.add(_bullet(line.substring(2)));
      } else if (line.startsWith('*') && line.endsWith('*') && line.length > 2) {
        out.add(Text(
          line.substring(1, line.length - 1),
          style: const TextStyle(
              color: AppColors.gold,
              fontStyle: FontStyle.italic,
              fontSize: 14),
        ));
      } else if (line.startsWith('**') && line.endsWith('**')) {
        out.add(Text(
          line.substring(2, line.length - 2),
          style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ));
      } else {
        out.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            line,
            style: const TextStyle(
                color: Color(0xFFD8D8D8), fontSize: 14, height: 1.5),
          ),
        ));
      }
    }
    return out;
  }

  Widget _heading(String text, double size) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Text(
          text,
          style: TextStyle(
              color: AppColors.gold,
              fontSize: size,
              fontWeight: FontWeight.bold),
        ),
      );

  Widget _bullet(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 6, right: 8),
              child: Icon(Icons.circle, color: AppColors.gold, size: 6),
            ),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                    color: Color(0xFFD8D8D8), fontSize: 14, height: 1.45),
              ),
            ),
          ],
        ),
      );
}
