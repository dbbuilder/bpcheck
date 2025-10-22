import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { View, ActivityIndicator, Text } from 'react-native';
import { useAuth } from '@clerk/clerk-expo';
import { RootStackParamList } from '../types';

import AuthNavigator from './AuthNavigator';
import MainNavigator from './MainNavigator';

const Stack = createStackNavigator<RootStackParamList>();

export default function AppNavigator() {
  const { isSignedIn, isLoaded } = useAuth();

  // Show loading screen while Clerk is initializing
  if (!isLoaded) {
    return (
      <View className="flex-1 items-center justify-center bg-white">
        <View className="w-16 h-16 rounded-2xl bg-primary-100 items-center justify-center mb-4">
          <Text className="text-4xl">❤️</Text>
        </View>
        <ActivityIndicator size="large" color="#3b82f6" />
        <Text className="text-neutral-600 mt-4">Loading...</Text>
      </View>
    );
  }

  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        {!isSignedIn ? (
          <Stack.Screen name="Auth" component={AuthNavigator} />
        ) : (
          <Stack.Screen name="Main" component={MainNavigator} />
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
}
