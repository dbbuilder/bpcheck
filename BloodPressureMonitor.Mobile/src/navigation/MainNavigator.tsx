import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { MainTabParamList } from '../types';
import { View, Text, TouchableOpacity } from 'react-native';
import { useAuth, useUser } from '@clerk/clerk-expo';

// Placeholder screens (will be created)
const DashboardScreen = () => (
  <View className="flex-1 items-center justify-center bg-white">
    <Text className="text-2xl font-bold text-primary-600">Dashboard</Text>
  </View>
);

const CameraScreen = () => (
  <View className="flex-1 items-center justify-center bg-white">
    <Text className="text-2xl font-bold text-primary-600">Camera</Text>
  </View>
);

const ReadingsScreen = () => (
  <View className="flex-1 items-center justify-center bg-white">
    <Text className="text-2xl font-bold text-primary-600">Readings</Text>
  </View>
);

const SettingsScreen = () => {
  const { signOut } = useAuth();
  const { user } = useUser();

  return (
    <View className="flex-1 bg-white p-6">
      <Text className="text-3xl font-bold text-neutral-900 mb-6">Settings</Text>

      {user && (
        <View className="mb-8">
          <Text className="text-lg text-neutral-700 mb-2">Signed in as:</Text>
          <Text className="text-xl font-semibold text-primary-600">
            {user.emailAddresses[0]?.emailAddress}
          </Text>
          {user.firstName && (
            <Text className="text-base text-neutral-600 mt-1">
              {user.firstName} {user.lastName}
            </Text>
          )}
        </View>
      )}

      <TouchableOpacity
        onPress={() => signOut()}
        className="bg-red-500 rounded-xl py-4 items-center justify-center shadow-lg"
        style={{
          shadowColor: '#ef4444',
          shadowOffset: { width: 0, height: 4 },
          shadowOpacity: 0.3,
          shadowRadius: 8,
          elevation: 8,
        }}
      >
        <Text className="text-white text-base font-bold">Sign Out</Text>
      </TouchableOpacity>
    </View>
  );
};

const Tab = createBottomTabNavigator<MainTabParamList>();

export default function MainNavigator() {
  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: '#3b82f6',
        tabBarInactiveTintColor: '#9ca3af',
        tabBarStyle: {
          borderTopWidth: 1,
          borderTopColor: '#e5e7eb',
          elevation: 8,
          shadowColor: '#000',
          shadowOffset: { width: 0, height: -2 },
          shadowOpacity: 0.1,
          shadowRadius: 4,
        },
      }}
    >
      <Tab.Screen
        name="Dashboard"
        component={DashboardScreen}
        options={{
          tabBarLabel: 'Dashboard',
        }}
      />
      <Tab.Screen
        name="Camera"
        component={CameraScreen}
        options={{
          tabBarLabel: 'Capture',
        }}
      />
      <Tab.Screen
        name="Readings"
        component={ReadingsScreen}
        options={{
          tabBarLabel: 'Readings',
        }}
      />
      <Tab.Screen
        name="Settings"
        component={SettingsScreen}
        options={{
          tabBarLabel: 'Settings',
        }}
      />
    </Tab.Navigator>
  );
}
