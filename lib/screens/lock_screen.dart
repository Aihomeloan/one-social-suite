import 'package:flutter/material.dart';
import '../services/app_lock_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';

/// Shown when the app is locked. Prompts Face ID; on success, calls onUnlock.
class LockScreen extends StatefulWidget {
  const LockScreen({super.key, required this.onUnlock});

  final VoidCallback onUnlock;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryUnlock());
  }

  Future<void> _tryUnlock() async {
    if (_authenticating) return;
    setState(() => _authenticating = true);
    final bool ok = await AppLockService.instance.authenticate();
    if (!mounted) return;
    setState(() => _authenticating = false);
    if (ok) {
      AppLockService.instance.recordActivity();
      widget.onUnlock();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const BrandLogo(width: 260, height: 140),
            const SizedBox(height: 28),
            const Icon(Icons.lock_outline, color: AppColors.gold, size: 40),
            const SizedBox(height: 16),
            const Text(
              '1Social is locked',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Unlock with Face ID to continue',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: _authenticating ? null : _tryUnlock,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  disabledBackgroundColor:
                      AppColors.gold.withValues(alpha: 0.4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.face, color: Colors.black, size: 20),
                label: Text(
                  _authenticating ? 'Unlocking...' : 'Unlock',
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
