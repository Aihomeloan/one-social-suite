# CLAUDE.md — 1SocialSuite (Flutter)

> Code Buddy operating manual. Read first every session.

## Identity
- Display name: 1SocialSuite
- Package: one_social_suite
- Bundle / applicationId: com.stevenfischer.onesocialsuite
- Tagline: Write once. Share smarter.
- Brand: black + gold (#FFB800). Logo = gold orbiting "1" + blue globe. LOCKED.

## Product in one sentence
A private social command center: write once, shape the message per platform,
save drafts, share via native handoff — without storing passwords, selling
data, or tracking across apps.

## Stack (v1, lean)
- Flutter 3.44.x / Dart 3.12.x
- Storage: Hive, NO codegen (store JSON maps)
- Sharing: share_plus + url_launcher
- Lock: local_auth (Face ID)
- Media: image_picker
- NO accounts. NO cloud. NO Supabase. NO ad/tracking SDKs.

## Dev rules (non-negotiable)
1. Complete files only. No partial edits, no "...", no codegen/build_runner.
2. One task per session. `flutter analyze` clean before "done".
3. Add a dep only when its feature is built (just-in-time), so iOS perms
   are configured alongside it.
4. Privacy non-negotiable. NEVER say "Posted" — use honest status labels.
5. Terminal-first. Commands under ~900 bytes or moved to a script.
6. Brand assets (logo, icons, gold/black) are LOCKED.

## Architecture
screens -> services -> Hive. One-way, boring, bulletproof. Plain setState.
Services: StorageService (Hive) | ShareService (share_plus+url_launcher) |
CaptionFormatter (abstract -> RulesCaptionFormatter v1, AICaptionFormatter v2) |
AppLockService (local_auth)
Deferred to v1.1: PlatformSuggester (+ AI)
Models: Draft | HistoryEntry | PlatformDef | ShareStatus (enum)

## Platforms (8) — behavior locked
- Share sheet + deep link: Instagram, TikTok, X, Facebook, LinkedIn, Pinterest
- Open app + copy caption: Snapchat, Nextdoor (no public share API — honest UX)

## Caption formatter
Abstract CaptionFormatter. v1 = RulesCaptionFormatter (deterministic, offline):
per-platform length, hashtag placement, emoji density, line-break normalization.
Tones: Casual / Clean / Professional / Hype.

## Lock
Face ID. Timeout 1/5/15 min, default 5. Idle-only (recordActivity resets timer).
NEVER locks while keyboard is open (active composition).

## Tabs (5)
Compose | Connections | Drafts | History | Privacy

## Build order
1 scaffold+theme [DONE] | 2 Connections | 3 Composer | 4 Caption formatter |
5 Drafts (Hive) | 6 Share handoff | 7 History | 8 Privacy | 9 Face ID lock |
10 polish + store prep

## Rigs & repo
- Mac M1 (/Volumes/DevDrive/one_social_suite) — iOS + Android, primary
- Windows (C:\Project) — Android, via git
- Repo: Aihomeloan/one-social-suite (private)
- Run iPhone:  flutter run --no-enable-impeller -d 00008150-001E20891188401C
- Run Z Fold 3: flutter run --no-enable-impeller -d RFCT40JD22H
- NOTE: project lives on external APFS DevDrive. Drive must be mounted before any build.
