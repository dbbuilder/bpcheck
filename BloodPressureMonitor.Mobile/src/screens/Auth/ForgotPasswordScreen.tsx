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

type ForgotPasswordScreenNavigationProp = NativeStackNavigationProp<AuthStackParamList, 'ForgotPassword'>;

export default function ForgotPasswordScreen() {
  const navigation = useNavigation<ForgotPasswordScreenNavigationProp>();
  const { signIn, isLoaded } = useSignIn();
  const [email, setEmail] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [emailSent, setEmailSent] = useState(false);
  const [error, setError] = useState('');

  const validateEmail = (email: string) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  };

  const handleResetPassword = async () => {
    if (!isLoaded) return;

    setError('');

    if (!email.trim()) {
      setError('Email is required');
      return;
    }

    if (!validateEmail(email)) {
      setError('Please enter a valid email');
      return;
    }

    setIsLoading(true);
    try {
      // Start the password reset flow with Clerk
      await signIn!.create({
        strategy: 'reset_password_email_code',
        identifier: email,
      });

      setEmailSent(true);
    } catch (err: any) {
      console.error('Password reset error:', err);
      const errorMessage = err.errors?.[0]?.message || 'Failed to send reset email';
      setError(errorMessage);
    } finally {
      setIsLoading(false);
    }
  };

  const handleResendEmail = () => {
    setEmailSent(false);
    handleResetPassword();
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
          <View className="flex-1 px-6 pt-4">
            {/* Header */}
            <TouchableOpacity
              onPress={() => navigation.goBack()}
              className="mb-8"
            >
              <Text className="text-2xl">←</Text>
            </TouchableOpacity>

            {!emailSent ? (
              /* Reset Password Form */
              <View>
                <View className="mb-8">
                  <View className="w-16 h-16 rounded-2xl bg-primary-100 items-center justify-center mb-6">
                    <Text className="text-4xl">🔑</Text>
                  </View>
                  <Text className="text-3xl font-bold text-neutral-900 mb-2">
                    Forgot Password?
                  </Text>
                  <Text className="text-base text-neutral-500">
                    No worries! Enter your email and we'll send you reset instructions.
                  </Text>
                </View>

                {/* Email Input */}
                <View className="mb-6">
                  <Text className="text-sm font-semibold text-neutral-700 mb-2">
                    Email Address
                  </Text>
                  <View
                    className={`flex-row items-center bg-neutral-50 rounded-xl px-4 border-2 ${
                      error ? 'border-red-500' : 'border-transparent'
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
                        if (error) setError('');
                      }}
                      keyboardType="email-address"
                      autoCapitalize="none"
                      autoCorrect={false}
                    />
                  </View>
                  {error ? (
                    <Text className="text-sm text-red-500 mt-1 ml-1">{error}</Text>
                  ) : null}
                </View>

                {/* Submit Button */}
                <TouchableOpacity
                  onPress={handleResetPassword}
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
                    <Text className="text-white text-base font-bold">Send Reset Link</Text>
                  )}
                </TouchableOpacity>

                {/* Back to Login */}
                <View className="flex-row items-center justify-center mt-8">
                  <Text className="text-neutral-600">Remember your password? </Text>
                  <TouchableOpacity onPress={() => navigation.navigate('Login')}>
                    <Text className="text-primary-600 font-bold">Sign In</Text>
                  </TouchableOpacity>
                </View>
              </View>
            ) : (
              /* Success State */
              <View>
                <View className="items-center mb-8">
                  <View className="w-24 h-24 rounded-full bg-green-100 items-center justify-center mb-6">
                    <Text className="text-6xl">✉️</Text>
                  </View>
                  <Text className="text-3xl font-bold text-neutral-900 mb-2 text-center">
                    Check Your Email
                  </Text>
                  <Text className="text-base text-neutral-500 text-center px-4">
                    We've sent password reset instructions to
                  </Text>
                  <Text className="text-base font-semibold text-primary-600 mt-2">
                    {email}
                  </Text>
                </View>

                {/* Instructions Card */}
                <View className="bg-blue-50 border border-blue-200 rounded-xl p-4 mb-6">
                  <Text className="text-sm font-semibold text-blue-900 mb-2">
                    Next Steps:
                  </Text>
                  <View className="space-y-2">
                    <View className="flex-row items-start">
                      <Text className="text-blue-600 mr-2">1.</Text>
                      <Text className="text-sm text-blue-900 flex-1">
                        Check your email inbox (and spam folder)
                      </Text>
                    </View>
                    <View className="flex-row items-start">
                      <Text className="text-blue-600 mr-2">2.</Text>
                      <Text className="text-sm text-blue-900 flex-1">
                        Click the reset link (expires in 1 hour)
                      </Text>
                    </View>
                    <View className="flex-row items-start">
                      <Text className="text-blue-600 mr-2">3.</Text>
                      <Text className="text-sm text-blue-900 flex-1">
                        Create a new secure password
                      </Text>
                    </View>
                  </View>
                </View>

                {/* Resend Button */}
                <TouchableOpacity
                  onPress={handleResendEmail}
                  className="bg-neutral-100 rounded-xl py-4 items-center justify-center mb-4"
                >
                  <Text className="text-neutral-700 font-semibold">Resend Email</Text>
                </TouchableOpacity>

                {/* Back to Login */}
                <TouchableOpacity
                  onPress={() => navigation.navigate('Login')}
                  className="bg-primary-600 rounded-xl py-4 items-center justify-center shadow-lg"
                  style={{
                    shadowColor: '#3b82f6',
                    shadowOffset: { width: 0, height: 4 },
                    shadowOpacity: 0.3,
                    shadowRadius: 8,
                    elevation: 8,
                  }}
                >
                  <Text className="text-white text-base font-bold">Back to Sign In</Text>
                </TouchableOpacity>
              </View>
            )}
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}
