import { SignIn } from '@clerk/clerk-react';

export default function Login() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-blue-100 flex items-center justify-center p-4">
      <div className="max-w-md w-full">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-blue-600 mb-2">Blood Pressure Monitor</h1>
          <p className="text-gray-600">Track your health with ease</p>
        </div>
        <div className="bg-white rounded-2xl shadow-2xl p-8">
          <SignIn
            routing="path"
            path="/login"
            signUpUrl="/signup"
            afterSignInUrl="/"
          />
        </div>
      </div>
    </div>
  );
}
