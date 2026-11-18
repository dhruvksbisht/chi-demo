import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

enum BiometricKind { none, face, fingerprint }

final _auth = LocalAuthentication();

/// What this device offers, so the UI can name the right method (Face ID vs fingerprint).
final biometricProvider = FutureProvider<BiometricKind>((ref) async {
  if (kIsWeb) return BiometricKind.none;
  try {
    if (!await _auth.isDeviceSupported() || !await _auth.canCheckBiometrics) {
      return BiometricKind.none;
    }
    final types = await _auth.getAvailableBiometrics();
    if (types.isEmpty) return BiometricKind.none;
    return types.contains(BiometricType.face)
        ? BiometricKind.face
        : BiometricKind.fingerprint;
  } catch (_) {
    return BiometricKind.none;
  }
});

Future<bool> authenticate(String reason) async {
  try {
    return await _auth.authenticate(
      localizedReason: reason,
      biometricOnly: true,
      persistAcrossBackgrounding: true,
    );
  } catch (_) {
    return false;
  }
}
