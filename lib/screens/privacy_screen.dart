import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Privacy Dashboard - 1SocialSuite's privacy promise made visible.
/// Wording is honest and matches what we can actually claim.
class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  // Local-only toggles for v1. Wired to real services in later sessions:
  //   Face ID -> Session 8 (AppLockService)
  //   Analytics -> always off in v1 (privacy-first)
  bool _faceIdEnabled = false;
  int _lockTimeoutMinutes = 5;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.black,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header
              const Center(
                child: Icon(Icons.shield_outlined,
                    color: AppColors.gold, size: 56),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Privacy',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  'Write once. Share smarter. Stay private.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
              const SizedBox(height: 24),

              // The Promise
              _sectionLabel('The 1SocialSuite Promise'),
              const SizedBox(height: 8),
              _promiseCard(),
              const SizedBox(height: 24),

              // What stays on your device
              _sectionLabel('What stays on your device'),
              const SizedBox(height: 8),
              _statusRow(
                icon: Icons.lock_outline,
                title: 'Social media passwords',
                status: 'Never stored',
                ok: true,
              ),
              _statusRow(
                icon: Icons.do_not_disturb_on_outlined,
                title: 'Selling your data',
                status: 'Never',
                ok: true,
              ),
              _statusRow(
                icon: Icons.visibility_off_outlined,
                title: 'Cross-app tracking',
                status: 'None',
                ok: true,
              ),
              _statusRow(
                icon: Icons.edit_note,
                title: 'Drafts',
                status: 'On this device only',
                ok: true,
              ),
              _statusRow(
                icon: Icons.history,
                title: 'Share history',
                status: 'On this device only',
                ok: true,
              ),
              _statusRow(
                icon: Icons.analytics_outlined,
                title: 'Analytics',
                status: 'Off',
                ok: true,
              ),
              const SizedBox(height: 24),

              // Security settings (Face ID + timeout)
              _sectionLabel('Security'),
              const SizedBox(height: 8),
              _toggleCard(
                icon: Icons.face_outlined,
                title: 'Face ID lock',
                subtitle: _faceIdEnabled
                    ? 'Required to open 1SocialSuite'
                    : 'Tap to require Face ID on app open',
                value: _faceIdEnabled,
                onChanged: (bool v) {
                  setState(() => _faceIdEnabled = v);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Face ID will wire up in Session 8 (the lock).')),
                  );
                },
              ),
              if (_faceIdEnabled) ...<Widget>[
                const SizedBox(height: 10),
                _timeoutCard(),
              ],
              const SizedBox(height: 24),

              // Honest footnote
              _sectionLabel('What this means'),
              const SizedBox(height: 8),
              _footnoteCard(),
              const SizedBox(height: 20),

              // Privacy policy link
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Full Privacy Policy bundles in Session 10 (store prep).')),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.gold),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.description_outlined,
                      color: AppColors.gold, size: 18),
                  label: const Text('Read Full Privacy Policy',
                      style: TextStyle(color: AppColors.gold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- pieces ----

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      );

  Widget _promiseCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.verified_outlined,
                  color: AppColors.gold, size: 22),
              SizedBox(width: 8),
              Text(
                'Privacy-first by design',
                style: TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'No social media passwords stored. No selling user data. '
            'No cross-app tracking. Drafts and share history stay on '
            'your device unless you choose otherwise.',
            style: TextStyle(
                color: Colors.white, fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _statusRow({
    required IconData icon,
    required String title,
    required String status,
    required bool ok,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: AppColors.gold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.5)),
            ),
            child: Text(
              status,
              style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: value
                ? AppColors.gold.withValues(alpha: 0.6)
                : AppColors.border),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: AppColors.gold, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.gold,
          ),
        ],
      ),
    );
  }

  Widget _timeoutCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.timer_outlined, color: AppColors.gold, size: 20),
              SizedBox(width: 10),
              Text(
                'Auto-lock after',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: <int>[1, 5, 15].map((int m) {
              final bool selected = _lockTimeoutMinutes == m;
              return ChoiceChip(
                label: Text('$m min',
                    style: TextStyle(
                        color: selected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w600)),
                selected: selected,
                onSelected: (_) =>
                    setState(() => _lockTimeoutMinutes = m),
                backgroundColor: AppColors.black,
                selectedColor: AppColors.gold,
                side: BorderSide(
                    color: selected ? AppColors.gold : AppColors.border),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          const Text(
            'Idle time only. Never locks while you are typing.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _footnoteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Sharing uses your phone\'s built-in share sheet. '
            'Each app handles your post on its own end. 1SocialSuite '
            'cannot see or confirm what is published after handoff.',
            style: TextStyle(
                color: AppColors.textMuted, fontSize: 12.5, height: 1.45),
          ),
          SizedBox(height: 10),
          Text(
            'For Snapchat and Nextdoor, the caption is copied to your '
            'clipboard and the app is opened so you can paste it in.',
            style: TextStyle(
                color: AppColors.textMuted, fontSize: 12.5, height: 1.45),
          ),
        ],
      ),
    );
  }
}
