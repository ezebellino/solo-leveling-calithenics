abstract class DeviceBiometricAuth {
  Future<bool> isSupported();

  Future<bool> authenticate({
    required String localizedReason,
  });
}
