import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/errors/app_exception.dart';
import '../domain/device_biometric_auth.dart';

class DeviceBiometricAuthImpl implements DeviceBiometricAuth {
  DeviceBiometricAuthImpl({LocalAuthentication? localAuthentication})
      : _localAuthentication = localAuthentication ?? LocalAuthentication();

  final LocalAuthentication _localAuthentication;

  @override
  Future<bool> isSupported() async {
    if (kIsWeb) {
      return false;
    }
    try {
      return await _localAuthentication.canCheckBiometrics ||
          await _localAuthentication.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate({
    required String localizedReason,
  }) async {
    if (kIsWeb) {
      return false;
    }
    try {
      return await _localAuthentication.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (error) {
      throw AppException(
        'auth_biometric_failed',
        'No se pudo completar la autenticacion local del dispositivo.',
        logContext: <String, Object?>{
          'runtimeType': error.runtimeType.toString(),
          'details': error.toString(),
        },
      );
    }
  }
}
