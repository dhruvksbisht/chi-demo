import * as LocalAuthentication from 'expo-local-authentication';
import { Platform } from 'react-native';

export type BiometricSupport = { available: boolean; label: string };

/** Detects Face ID / fingerprint so the UI can name the right method. */
export async function biometricSupport(): Promise<BiometricSupport> {
  if (Platform.OS === 'web') return { available: false, label: 'Biometrics' };
  try {
    const [hardware, enrolled, types] = await Promise.all([
      LocalAuthentication.hasHardwareAsync(),
      LocalAuthentication.isEnrolledAsync(),
      LocalAuthentication.supportedAuthenticationTypesAsync(),
    ]);
    const face = types.includes(LocalAuthentication.AuthenticationType.FACIAL_RECOGNITION);
    return { available: hardware && enrolled, label: face ? 'Face ID' : 'Fingerprint' };
  } catch {
    return { available: false, label: 'Biometrics' };
  }
}

export async function authenticate(prompt: string): Promise<boolean> {
  try {
    const result = await LocalAuthentication.authenticateAsync({ promptMessage: prompt });
    return result.success;
  } catch {
    return false;
  }
}
