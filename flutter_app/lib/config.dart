// App-wide constants. Change these only if the website address / GitHub repo changes.

/// Live website (GitHub Pages). data.js, sheet-config.js and the web pages come from here.
const String kSiteBase = 'https://emerging-sciences.github.io/emergingsciences.github.io/';

/// GitHub repository that builds the APK (owner/name). Used for the in-app "update available" check.
const String kRepo = 'emerging-sciences/emergingsciences.github.io';

const String kApkUrl = 'https://github.com/$kRepo/releases/latest/download/EmergingSciences.apk';
const String kVersionUrl = 'https://github.com/$kRepo/releases/latest/download/version.json';

/// Set by the build workflow (--dart-define=BUILD_NUMBER=...). 1 for local builds.
const int kBuildNumber = int.fromEnvironment('BUILD_NUMBER', defaultValue: 1);

/// Firebase project of the website (comments, likes, replies). Same public values as in the website's comments.js.
const String kFirebaseApiKey = 'AIzaSyD_YYVetPkf6jOO4VfBetw0q-NaWUptYtk';
const String kFirebaseProject = 'emerging-sciences-ece22';

/// REQUIRED for Google sign-in (comments, likes, replies): the "Web client ID" of the Firebase project
/// (Firebase console -> Authentication -> Sign-in method -> Google -> Web SDK configuration -> Web client ID).
/// Looks like 1234567890-abc123def456.apps.googleusercontent.com . It is a public value, safe to keep in the repo.
const String kGoogleWebClientId = '';

/// While the app is open, content is re-checked this often (so new lectures appear within minutes).
const Duration kRefreshEvery = Duration(minutes: 3);

/// Web pages on these domains (and their sub-domains) stay inside the app; everything else opens in the browser.
const List<String> kInAppDomains = [
  'emerging-sciences.github.io',
  'google.com',
  'googleusercontent.com',
  'gstatic.com',
];

bool isInAppHost(String host) {
  for (final d in kInAppDomains) {
    if (host == d || host.endsWith('.$d')) return true;
  }
  return false;
}
