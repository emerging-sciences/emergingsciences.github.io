// App-wide constants. Change these only if the website address / GitHub repo changes.

/// Live website (GitHub Pages). data.js, sheet-config.js and the web pages come from here.
const String kSiteBase = 'https://emerging-sciences.github.io/emergingsciences.github.io/';

/// GitHub repository that builds the APK (owner/name). Used for the in-app "update available" check.
const String kRepo = 'emerging-sciences/emergingsciences.github.io';

const String kApkUrl = 'https://github.com/$kRepo/releases/latest/download/EmergingSciences.apk';
const String kVersionUrl = 'https://github.com/$kRepo/releases/latest/download/version.json';

/// Set by the build workflow (--dart-define=BUILD_NUMBER=...). 1 for local builds.
const int kBuildNumber = int.fromEnvironment('BUILD_NUMBER', defaultValue: 1);

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
