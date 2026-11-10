# Emerging Sciences – Android app (Flutter)

This folder is the source of the Emerging Sciences Android app. You do **not** need to install Flutter:
GitHub builds the APK for you (see `.github/workflows/build-apk.yml`).

## How content reaches the app
The app reads the same files as the website: `data.js`, `sheet-config.js` and the published Google Sheet tabs
(topics, lectures, material, pyqs, syllabus). It re-checks them when it opens, when it comes back to the
foreground, every 3 minutes while it is open, and on pull-to-refresh. So a new lecture or PDF added to the
website / Google Sheet appears in the app within a few minutes — no new APK is needed.

A new APK is only needed when the **app itself** changes (new screens, new buttons, design).

## Build a new APK
GitHub → **Actions** → **Build Android app (APK)** → **Run workflow**.
After ~8–12 minutes the signed `EmergingSciences.apk` appears under **Releases**.
Download link used by the website:
`https://github.com/emerging-sciences/emergingsciences.github.io/releases/latest/download/EmergingSciences.apk`

## One-time setup
1. Repository **Settings → Secrets and variables → Actions → New repository secret**
   Name: `SIGNING_PASSWORD` · Value: a long password (16+ characters). Keep a copy of it safe.
2. Run the workflow once. The first run creates the app signing key and saves it **encrypted** in
   `flutter_app/signing/release.keystore.enc`.

⚠ Never delete `flutter_app/signing/` and never change `SIGNING_PASSWORD` later — a different key means
students can no longer update the app in place (they would have to uninstall first).
Also keep a copy of `release.keystore.enc` and the password somewhere safe (for example your own Google Drive).

## Dark / light theme
Same as the website: sun/moon button in the Home header (and Theme in More → Settings). Dark is the default; the
choice is saved on the phone. Colours live in `lib/theme.dart` (the light palette is copied from `theme.css`).
Website pages shown inside the app (Focus, Doubts, Support...) get the same choice automatically.

## Comments, likes and replies (Google sign-in)
Lecture pages in the app have the same extra comments, like / dislike and replies as the website (same Firebase
project, so a comment written in the app shows on the website and the other way round). Sign-in uses the phone's
own Google account picker. One-time setup, in this order:
1. Run the build once (or press **Run workflow**). Open the finished run → **Summary**: it shows the app's
   package name and the **SHA-1 / SHA-256** fingerprints.
2. Firebase console → **Project settings → Your apps → Add app → Android**. Package name
   `com.emergingsciences.emerging_sciences`, paste the SHA-1 (and the SHA-256), register, skip the other steps.
3. Firebase console → **Authentication → Sign-in method → Google → Web SDK configuration** → copy the
   **Web client ID** and paste it in `flutter_app/lib/config.dart` as `kGoogleWebClientId`, then commit.
   That builds a new APK automatically.
If you later publish on Google Play with "Play App Signing", add the SHA-1 shown in Play Console
(Setup → App signing) to the same Firebase Android app too.

## Folder map
- `lib/core/` – data.js reader, Google Sheet merge, lookups, Firebase REST client (pure Dart, same rules as the website)
- `lib/screens/` – Home, Lectures, Watch (YouTube player), Material, PYQs, Mock tests, Search, More; Comments, Notifications
- `tools/` – `make_snapshot.js` (bundles current content into the APK), `patch_android.py`
- `android_overlay/` – app icon and launch screen
