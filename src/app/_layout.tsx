import { Amiri_400Regular } from '@expo-google-fonts/amiri';
import { Fraunces_400Regular_Italic, Fraunces_600SemiBold } from '@expo-google-fonts/fraunces';
import { Inter_400Regular, Inter_500Medium, Inter_600SemiBold } from '@expo-google-fonts/inter';
import { useFonts } from 'expo-font';
import { Stack } from 'expo-router';
import * as SplashScreen from 'expo-splash-screen';
import { StatusBar } from 'expo-status-bar';
import { useEffect } from 'react';

import { AppProvider } from '@/lib/store';
import { color } from '@/theme';

SplashScreen.preventAutoHideAsync();

export default function RootLayout() {
  const [loaded, error] = useFonts({
    Fraunces_600SemiBold,
    Fraunces_400Regular_Italic,
    Inter_400Regular,
    Inter_500Medium,
    Inter_600SemiBold,
    Amiri_400Regular,
  });

  useEffect(() => {
    // Never strand the user on the splash screen: fall back to system fonts on error.
    if (loaded || error) SplashScreen.hideAsync();
  }, [loaded, error]);

  if (!loaded && !error) return null;

  return (
    <AppProvider>
      <StatusBar style="dark" />
      <Stack screenOptions={{ headerShown: false, contentStyle: { backgroundColor: color.bg } }}>
        <Stack.Screen name="(tabs)" />
        <Stack.Screen name="checkout" options={{ presentation: 'modal' }} />
        <Stack.Screen name="request-access" options={{ presentation: 'modal' }} />
      </Stack>
    </AppProvider>
  );
}
