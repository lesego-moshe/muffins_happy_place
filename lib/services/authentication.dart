import 'package:local_auth/local_auth.dart';

class Authentication {
  static final auth = LocalAuthentication();

  static Future<bool> canAuthenticate() async =>
      await auth.canCheckBiometrics || await auth.isDeviceSupported();

  static Future<bool> authentication() async {
    try {
      if (!await canAuthenticate()) return false;
      return auth.authenticate(localizedReason: "Gain access to the nasty 😚");
    } catch (e) {
      print('Hell $e');
      return false;
    }
  }
}
