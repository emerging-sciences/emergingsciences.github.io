// Thin wrapper around the Google account picker (google_sign_in 7.x, Android Credential Manager).
// Everything else lives in auth_state.dart.
import 'package:google_sign_in/google_sign_in.dart';

import 'config.dart';

class GoogleTokens {
  final String? idToken;
  final String? accessToken;
  const GoogleTokens(this.idToken, this.accessToken);
}

/// Thrown when kGoogleWebClientId was not filled in config.dart yet.
class GoogleSetupMissing implements Exception {
  const GoogleSetupMissing();
  @override
  String toString() => 'GoogleSetupMissing: kGoogleWebClientId is empty';
}

bool _inited = false;

Future<void> _init() async {
  if (_inited) return;
  if (kGoogleWebClientId.trim().isEmpty) throw const GoogleSetupMissing();
  await GoogleSignIn.instance.initialize(serverClientId: kGoogleWebClientId.trim());
  _inited = true;
}

/// Opens the Android account picker. Returns null when the user closes it.
Future<GoogleTokens?> googleSignInTokens() async {
  await _init();
  try {
    final account = await GoogleSignIn.instance.authenticate();
    return GoogleTokens(account.authentication.idToken, null);
  } on GoogleSignInException catch (e) {
    if (e.code == GoogleSignInExceptionCode.canceled) return null;
    rethrow;
  }
}

Future<void> googleSignOut() async {
  try {
    if (_inited) await GoogleSignIn.instance.signOut();
  } catch (_) {}
}

/// True when the user just dismissed the account picker (not an error).
bool isGoogleCancel(Object e) => e is GoogleSignInException && e.code == GoogleSignInExceptionCode.canceled;

/// Short, human text for a failed Google sign-in.
String describeGoogleError(Object e) {
  if (e is GoogleSetupMissing) {
    return 'Google sign-in ka Web client ID app me abhi set nahi hai (lib/config.dart me kGoogleWebClientId bharna baaki hai).';
  }
  if (e is GoogleSignInException) {
    final d = e.description ?? '';
    switch (e.code) {
      case GoogleSignInExceptionCode.clientConfigurationError:
        return 'Google sign-in setup adhura hai (Web client ID / Firebase me Android app + SHA-1).';
      case GoogleSignInExceptionCode.interrupted:
        return 'Sign-in beech me ruk gaya, dobara try karo.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'Sign-in screen khul nahi payi, app ek baar band karke dobara kholo.';
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'Is phone me Google Play services / Google account ready nahi hai.';
      default:
        if (d.contains('No credential')) {
          return 'Koi Google account nahi mila. Phone me Google account jodo, ya Firebase me Android app + SHA-1 add karna baaki hai.';
        }
        return 'Google sign-in nahi hua (${e.code.name}).';
    }
  }
  return 'Google sign-in nahi hua.';
}
