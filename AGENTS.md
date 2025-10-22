# Blood Pressure Monitor - Agent Guide

## Build/Test Commands

### Backend (.NET API)
- **Build**: `dotnet build BloodPressureMonitor.API/BloodPressureMonitor.API.csproj`
- **Run**: `dotnet run --project BloodPressureMonitor.API`
- **Test**: `dotnet test` (create test project first)
- **Single Test**: `dotnet test --filter "FullyQualifiedName~TestClassName.TestMethodName"`

### Mobile (React Native + Expo)
- **Install**: `cd BloodPressureMonitor.Mobile && npm install`
- **Start Dev**: `npx expo start` (then press `i` for iOS, `a` for Android)
- **iOS Simulator**: `npx expo start --ios`
- **Android Emulator**: `npx expo start --android`
- **Build iOS**: `eas build --platform ios`
- **Build Android**: `eas build --platform android`
- **Test**: `npm test` (when tests created)

## Code Style

### Backend (.NET)
- **Framework**: .NET 8.0, C# 12, nullable reference types enabled
- **Database**: Stored procedures ONLY - no LINQ, no EF queries, no dynamic SQL
- **Types**: Explicit nullable annotations (`string?` vs `string`), use `Guid` for IDs, `DateTime` in UTC
- **Naming**: PascalCase classes/methods/properties, camelCase parameters/locals, suffix interfaces with `I`, suffix DTOs with `Dto`
- **Error Handling**: Never swallow exceptions, log with correlation IDs, return structured error responses
- **Security**: BCrypt passwords, JWT auth, parameterized stored procedures only, SAS tokens for blob access
- **Async**: All I/O operations async/await, use `ConfigureAwait(false)` in library code

### Mobile (React Native)
- **Language**: TypeScript with strict mode enabled
- **Components**: Functional components with hooks, no class components
- **Naming**: PascalCase for components/types, camelCase for functions/variables, UPPER_CASE for constants
- **State**: Use Context API for global state, local state for component-specific
- **Async**: async/await for all async operations, handle errors with try-catch
- **Styling**: StyleSheet.create for performance, avoid inline styles
- **Navigation**: React Navigation v6, typed navigation props
- **Permissions**: Always check permissions before using camera/photos, provide rationale
- **Offline-First**: All data operations through local SQLite first, sync to cloud in background
