# memory.md — 1SocialSuite decisions & context

## What this app is
Pivot from the earlier Swift/Supabase build. New approach: local-first utility +
native share handoff. APIs/OAuth deferred to v2/Pro. This kills the OAuth
quicksand that stalled the Swift version.

## Locked decisions
- 8 platforms, two handoff modes (share-sheet six; open+copy two).
- Caption formatter is an interface (rules now, AI later) — no refactor to add AI.
- Lock: Face ID, 1/5/15 min (default 5), idle-only, never while keyboard open.
- PlatformSuggester deferred to v1.1.
- Tabs: 5 (Compose | Connections | Drafts | History | Privacy).
- Naming: pkg one_social_suite, id com.stevenfischer.onesocialsuite, shows "1SocialSuite".
- Android applicationId cannot start with a digit -> "onesocialsuite".

## Privacy stance (App Store label target)
No account. No social passwords stored. No ad/tracking SDKs. Drafts + history
on-device. Never claim "Posted" — use Prepared / Opened in app /
Shared via system sheet / Saved as draft.

## Brand
Gold #F5CC1F on black. Logo = gold orbiting "1" + blue globe. Logo + icons LOCKED.

## Environment
Mac M1 primary (iOS+Android), project on external APFS DevDrive at
/Volumes/DevDrive/one_social_suite. Windows secondary (Android) via GitHub.
iPhone 17 Pro Max (wireless) + Z Fold 3. M1 builds use --no-enable-impeller.
