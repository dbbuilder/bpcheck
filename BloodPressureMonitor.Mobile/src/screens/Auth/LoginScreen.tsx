import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  ActivityIndicator,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { AuthStackParamList } from '../../types';
import { useSignIn } from '@clerk/clerk-expo';

type LoginScreenNavigationProp = NativeStackNavigationProp<AuthStackParamList, 'Login'>;

export default function LoginScreen() {
  const navigation = useNavigation<LoginScreenNavigationProp>();
  const { signIn, setActive, isLoaded } = useSignIn();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [errors, setErrors] = useState({ email: '', password: '', general: '' });

  const validateEmail = (email: string) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  };

  const handleLogin = async () => {
    if (!isLoaded) return;

    // Clear previous errors
    setErrors({ email: '', password: '', general: '' });

    // Validation
    let hasErrors = false;
    const newErrors = { email: '', password: '', general: '' };

    if (!email.trim()) {
      newErrors.email = 'Email is required';
      hasErrors = true;
    } else if (!validateEmail(email)) {
      newErrors.email = 'Please enter a valid email';
      hasErrors = true;
    }

    if (!password) {
      newErrors.password = 'Password is required';
      hasErrors = true;
    } else if (password.length < 8) {
      newErrors.password = 'Password must be at least 8 characters';
      hasErrors = true;
    }

    if (hasErrors) {
      setErrors(newErrors);
      return;
    }

    // Attempt login with Clerk
    setIsLoading(true);
    try {
      const result = await signIn!.create({
        identifier: email,
        password,
      });

      if (result.status === 'complete') {
        await setActive!({ session: result.createdSessionId });
        // Navigation will happen automatically via Clerk auth state
      } else {
        setErrors({ email: '', password: '', general: 'Login failed. Please try again.' });
      }
    } catch (err: any) {
      console.error('Login error:', err);
      const errorMessage = err.errors?.[0]?.message || 'Invalid email or password';
      setErrors({ email: '', password: '', general: errorMessage });
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <SafeAreaView className="flex-1 bg-white">
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        className="flex-1"
      >
        <ScrollView
          contentContainerClassName="flex-grow"
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}
        >
          <View className="flex-1 px-6 pt-12">
            {/* Header */}
            <View className="mb-12">
              <View className="w-16 h-16 rounded-2xl bg-primary-100 items-center justify-center mb-6">
                <Text className="text-4xl">❤️</Text>
              </View>
              <Text className="text-4xl font-bold text-neutral-900 mb-2">
                Welcome Back
              </Text>
              <Text className="text-lg text-neutral-500">
                Monitor your blood pressure with ease
              </Text>
            </View>

            {/* Form */}
            <View className="space-y-6 mb-8">
              {/* Email Input */}
              <View>
                <Text className="text-sm font-semibold text-neutral-700 mb-2">
                  Email Address
                </Text>
                <View
                  className={`flex-row items-center bg-neutral-50 rounded-xl px-4 border-2 ${
                    errors.email ? 'border-red-500' : 'border-transparent'
                  }`}
                >
                  <Text className="text-xl mr-2">📧</Text>
                  <TextInput
                    className="flex-1 py-4 text-base text-neutral-900"
                    placeholder="your@email.com"
                    placeholderTextColor="#9ca3af"
                    value={email}
                    onChangeText={(text) => {
                      setEmail(text);
                      if (errors.email) setErrors({ ...errors, email: '' });
                    }}
                    keyboardType="email-address"
                    autoCapitalize="none"
                    autoCorrect={false}
                  />
                </View>
                {errors.email ? (
                  <Text className="text-sm text-red-500 mt-1 ml-1">{errors.email}</Text>
                ) : null}
              </View>

              {/* Password Input */}
              <View>
                <Text className="text-sm font-semibold text-neutral-700 mb-2">
                  Password
                </Text>
                <View
                  className={`flex-row items-center bg-neutral-50 rounded-xl px-4 border-2 ${
                    errors.password ? 'border-red-500' : 'border-transparent'
                  }`}
                >
                  <Text className="text-xl mr-2">🔒</Text>
                  <TextInput
                    className="flex-1 py-4 text-base text-neutral-900"
                    placeholder="Enter your password"
                    placeholderTextColor="#9ca3af"
                    value={password}
                    onChangeText={(text) => {
                      setPassword(text);
                      if (errors.password) setErrors({ ...errors, password: '' });
                    }}
                    secureTextEntry={!showPassword}
                    autoCapitalize="none"
                  />
                  <TouchableOpacity onPress={() => setShowPassword(!showPassword)}>
                    <Text className="text-xl">{showPassword ? '👁️' : '👁️‍🗨️'}</Text>
                  </TouchableOpacity>
                </View>
                {errors.password ? (
                  <Text className="text-sm text-red-500 mt-1 ml-1">{errors.password}</Text>
                ) : null}
              </View>

              {/* Forgot Password */}
              <TouchableOpacity
                onPress={() => navigation.navigate('ForgotPassword')}
                className="self-end"
              >
                <Text className="text-sm font-semibold text-primary-600">
                  Forgot Password?
                </Text>
              </TouchableOpacity>
            </View>

            {/* General Error */}
            {errors.general ? (
              <View className="bg-red-50 border border-red-200 rounded-xl p-4 mb-6">
                <Text className="text-sm text-red-600">{errors.general}</Text>
              </View>
            ) : null}

            {/* Login Button */}
            <TouchableOpacity
              onPress={handleLogin}
              disabled={isLoading}
              className={`bg-primary-600 rounded-xl py-4 items-center justify-center shadow-lg ${
                isLoading ? 'opacity-70' : ''
              }`}
              style={{
                shadowColor: '#3b82f6',
                shadowOffset: { width: 0, height: 4 },
                shadowOpacity: 0.3,
                shadowRadius: 8,
                elevation: 8,
              }}
            >
              {isLoading ? (
                <ActivityIndicator color="#ffffff" />
              ) : (
                <Text className="text-white text-base font-bold">Sign In</Text>
              )}
            </TouchableOpacity>

            {/* Biometric Login Option (Placeholder) */}
            <View className="my-8 flex-row items-center">
              <View className="flex-1 h-px bg-neutral-200" />
              <Text className="mx-4 text-sm text-neutral-500">or continue with</Text>
              <View className="flex-1 h-px bg-neutral-200" />
            </View>

            <TouchableOpacity
              className="bg-neutral-100 rounded-xl py-4 items-center justify-center flex-row"
              onPress={() => {
                // TODO: Implement biometric authentication
                console.log('Biometric login');
              }}
            >
              <Text className="text-2xl mr-2">👆</Text>
              <Text className="text-neutral-700 font-semibold">Biometric Login</Text>
            </TouchableOpacity>

            {/* Sign Up Link */}
            <View className="flex-row items-center justify-center mt-8 pb-6">
              <Text className="text-neutral-600">Don't have an account? </Text>
              <TouchableOpacity onPress={() => navigation.navigate('Register')}>
                <Text className="text-primary-600 font-bold">Sign Up</Text>
              </TouchableOpacity>
            </View>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}
