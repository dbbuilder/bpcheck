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
import { useSignUp } from '@clerk/clerk-expo';

type RegisterScreenNavigationProp = NativeStackNavigationProp<AuthStackParamList, 'Register'>;

export default function RegisterScreen() {
  const navigation = useNavigation<RegisterScreenNavigationProp>();
  const { signUp, setActive, isLoaded } = useSignUp();
  const [step, setStep] = useState(1);
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    confirmPassword: '',
    firstName: '',
    lastName: '',
  });
  const [isLoading, setIsLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [errors, setErrors] = useState({
    email: '',
    password: '',
    confirmPassword: '',
    firstName: '',
    general: '',
  });

  const validateEmail = (email: string) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  };

  const getPasswordStrength = (password: string): { strength: number; label: string; color: string } => {
    let strength = 0;
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (/[a-z]/.test(password)) strength++;
    if (/[A-Z]/.test(password)) strength++;
    if (/[0-9]/.test(password)) strength++;
    if (/[^a-zA-Z0-9]/.test(password)) strength++;

    if (strength <= 2) return { strength: 1, label: 'Weak', color: 'bg-red-500' };
    if (strength <= 4) return { strength: 2, label: 'Medium', color: 'bg-yellow-500' };
    return { strength: 3, label: 'Strong', color: 'bg-green-500' };
  };

  const validateStep1 = () => {
    const newErrors = { ...errors, email: '', password: '', confirmPassword: '' };
    let hasErrors = false;

    if (!formData.email.trim()) {
      newErrors.email = 'Email is required';
      hasErrors = true;
    } else if (!validateEmail(formData.email)) {
      newErrors.email = 'Please enter a valid email';
      hasErrors = true;
    }

    if (!formData.password) {
      newErrors.password = 'Password is required';
      hasErrors = true;
    } else if (formData.password.length < 8) {
      newErrors.password = 'Password must be at least 8 characters';
      hasErrors = true;
    } else if (!/[A-Z]/.test(formData.password)) {
      newErrors.password = 'Password must contain an uppercase letter';
      hasErrors = true;
    } else if (!/[0-9]/.test(formData.password)) {
      newErrors.password = 'Password must contain a number';
      hasErrors = true;
    } else if (!/[^a-zA-Z0-9]/.test(formData.password)) {
      newErrors.password = 'Password must contain a special character';
      hasErrors = true;
    }

    if (formData.password !== formData.confirmPassword) {
      newErrors.confirmPassword = 'Passwords do not match';
      hasErrors = true;
    }

    setErrors(newErrors);
    return !hasErrors;
  };

  const handleNext = () => {
    if (validateStep1()) {
      setStep(2);
    }
  };

  const handleRegister = async () => {
    if (!isLoaded) return;

    setIsLoading(true);
    try {
      // Create the user with Clerk
      const result = await signUp!.create({
        emailAddress: formData.email,
        password: formData.password,
        firstName: formData.firstName || undefined,
        lastName: formData.lastName || undefined,
      });

      // If email verification is required, Clerk will handle it
      // For now, we'll assume auto-verification or handle it later
      if (result.status === 'complete') {
        await setActive!({ session: result.createdSessionId });
        // Navigation will happen automatically via Clerk auth state
      } else if (result.status === 'missing_requirements') {
        // Handle email verification if needed
        setErrors({ ...errors, general: 'Please verify your email to continue.' });
      } else {
        setErrors({ ...errors, general: 'Registration failed. Please try again.' });
      }
    } catch (err: any) {
      console.error('Registration error:', err);
      const errorMessage = err.errors?.[0]?.message || 'Registration failed. Please try again.';
      setErrors({ ...errors, general: errorMessage });
    } finally {
      setIsLoading(false);
    }
  };

  const passwordStrength = getPasswordStrength(formData.password);

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
              onPress={() => (step === 1 ? navigation.goBack() : setStep(1))}
              className="mb-8"
            >
              <Text className="text-2xl">←</Text>
            </TouchableOpacity>

            {/* Progress Indicator */}
            <View className="flex-row mb-8">
              <View className={`h-1 flex-1 rounded-full ${step >= 1 ? 'bg-primary-600' : 'bg-neutral-200'}`} />
              <View className="w-2" />
              <View className={`h-1 flex-1 rounded-full ${step >= 2 ? 'bg-primary-600' : 'bg-neutral-200'}`} />
            </View>

            {step === 1 ? (
              /* Step 1: Account Details */
              <View>
                <View className="mb-8">
                  <Text className="text-3xl font-bold text-neutral-900 mb-2">
                    Create Account
                  </Text>
                  <Text className="text-base text-neutral-500">
                    Step 1 of 2 - Account credentials
                  </Text>
                </View>

                <View className="space-y-6">
                  {/* Email */}
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
                        value={formData.email}
                        onChangeText={(text) => {
                          setFormData({ ...formData, email: text });
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

                  {/* Password */}
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
                        placeholder="Create a strong password"
                        placeholderTextColor="#9ca3af"
                        value={formData.password}
                        onChangeText={(text) => {
                          setFormData({ ...formData, password: text });
                          if (errors.password) setErrors({ ...errors, password: '' });
                        }}
                        secureTextEntry={!showPassword}
                        autoCapitalize="none"
                      />
                      <TouchableOpacity onPress={() => setShowPassword(!showPassword)}>
                        <Text className="text-xl">{showPassword ? '👁️' : '👁️‍🗨️'}</Text>
                      </TouchableOpacity>
                    </View>
                    {formData.password.length > 0 && (
                      <View className="mt-2">
                        <View className="flex-row items-center justify-between mb-1">
                          <Text className="text-xs text-neutral-600">Password strength:</Text>
                          <Text className={`text-xs font-semibold ${
                            passwordStrength.strength === 1 ? 'text-red-500' :
                            passwordStrength.strength === 2 ? 'text-yellow-500' : 'text-green-500'
                          }`}>
                            {passwordStrength.label}
                          </Text>
                        </View>
                        <View className="flex-row space-x-1">
                          {[1, 2, 3].map((level) => (
                            <View
                              key={level}
                              className={`h-2 flex-1 rounded-full ${
                                level <= passwordStrength.strength
                                  ? passwordStrength.color
                                  : 'bg-neutral-200'
                              }`}
                            />
                          ))}
                        </View>
                      </View>
                    )}
                    {errors.password ? (
                      <Text className="text-sm text-red-500 mt-1 ml-1">{errors.password}</Text>
                    ) : null}
                  </View>

                  {/* Confirm Password */}
                  <View>
                    <Text className="text-sm font-semibold text-neutral-700 mb-2">
                      Confirm Password
                    </Text>
                    <View
                      className={`flex-row items-center bg-neutral-50 rounded-xl px-4 border-2 ${
                        errors.confirmPassword ? 'border-red-500' : 'border-transparent'
                      }`}
                    >
                      <Text className="text-xl mr-2">🔒</Text>
                      <TextInput
                        className="flex-1 py-4 text-base text-neutral-900"
                        placeholder="Confirm your password"
                        placeholderTextColor="#9ca3af"
                        value={formData.confirmPassword}
                        onChangeText={(text) => {
                          setFormData({ ...formData, confirmPassword: text });
                          if (errors.confirmPassword) setErrors({ ...errors, confirmPassword: '' });
                        }}
                        secureTextEntry={!showPassword}
                        autoCapitalize="none"
                      />
                    </View>
                    {errors.confirmPassword ? (
                      <Text className="text-sm text-red-500 mt-1 ml-1">{errors.confirmPassword}</Text>
                    ) : null}
                  </View>
                </View>

                <TouchableOpacity
                  onPress={handleNext}
                  className="bg-primary-600 rounded-xl py-4 items-center justify-center mt-8 shadow-lg"
                  style={{
                    shadowColor: '#3b82f6',
                    shadowOffset: { width: 0, height: 4 },
                    shadowOpacity: 0.3,
                    shadowRadius: 8,
                    elevation: 8,
                  }}
                >
                  <Text className="text-white text-base font-bold">Continue</Text>
                </TouchableOpacity>
              </View>
            ) : (
              /* Step 2: Personal Information */
              <View>
                <View className="mb-8">
                  <Text className="text-3xl font-bold text-neutral-900 mb-2">
                    Personal Info
                  </Text>
                  <Text className="text-base text-neutral-500">
                    Step 2 of 2 - Tell us about yourself (optional)
                  </Text>
                </View>

                <View className="space-y-6">
                  {/* First Name */}
                  <View>
                    <Text className="text-sm font-semibold text-neutral-700 mb-2">
                      First Name
                    </Text>
                    <View className="flex-row items-center bg-neutral-50 rounded-xl px-4 border-2 border-transparent">
                      <Text className="text-xl mr-2">👤</Text>
                      <TextInput
                        className="flex-1 py-4 text-base text-neutral-900"
                        placeholder="John"
                        placeholderTextColor="#9ca3af"
                        value={formData.firstName}
                        onChangeText={(text) => setFormData({ ...formData, firstName: text })}
                        autoCapitalize="words"
                      />
                    </View>
                  </View>

                  {/* Last Name */}
                  <View>
                    <Text className="text-sm font-semibold text-neutral-700 mb-2">
                      Last Name
                    </Text>
                    <View className="flex-row items-center bg-neutral-50 rounded-xl px-4 border-2 border-transparent">
                      <Text className="text-xl mr-2">👤</Text>
                      <TextInput
                        className="flex-1 py-4 text-base text-neutral-900"
                        placeholder="Doe"
                        placeholderTextColor="#9ca3af"
                        value={formData.lastName}
                        onChangeText={(text) => setFormData({ ...formData, lastName: text })}
                        autoCapitalize="words"
                      />
                    </View>
                  </View>
                </View>

                <TouchableOpacity
                  onPress={handleRegister}
                  disabled={isLoading}
                  className={`bg-primary-600 rounded-xl py-4 items-center justify-center mt-8 shadow-lg ${
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
                    <Text className="text-white text-base font-bold">Create Account</Text>
                  )}
                </TouchableOpacity>

                <TouchableOpacity
                  onPress={() => navigation.navigate('Login')}
                  className="mt-4"
                >
                  <Text className="text-center text-neutral-600">
                    Skip for now
                  </Text>
                </TouchableOpacity>
              </View>
            )}

            {/* Already have account */}
            <View className="flex-row items-center justify-center mt-8 pb-6">
              <Text className="text-neutral-600">Already have an account? </Text>
              <TouchableOpacity onPress={() => navigation.navigate('Login')}>
                <Text className="text-primary-600 font-bold">Sign In</Text>
              </TouchableOpacity>
            </View>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}
