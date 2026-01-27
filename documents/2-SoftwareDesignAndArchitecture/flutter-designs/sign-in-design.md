# Sign-In Authentication - Flutter Design Specification

**Document Version:** 1.0  
**Last Updated:** January 27, 2026  
**Target Platforms:** Web (Primary), iOS, Android, Desktop  
**Reference:** Nowa Sign-In Template

## 1. Overview

This document specifies the Flutter architecture for a comprehensive authentication sign-in interface supporting both email/password and mobile number login methods, with social authentication options.

### 1.1 Purpose and Key Features

- **Dual Login Methods**: Email/password or mobile number authentication
- **Tab-Based UI**: Switch between email and mobile login
- **Social Authentication**: Facebook, Twitter, LinkedIn, Instagram
- **Password Recovery**: Link to forgot password flow
- **User Registration**: Link to sign-up flow
- **Responsive Design**: Centered card layout adapting to all screen sizes
- **Brand Integration**: Logo display and themed components

### 1.2 Design Principles

- **Security First**: Secure credential handling and validation
- **User-Friendly**: Clear error messages and intuitive flows
- **Component Modularity**: All widgets ≤ 500 lines per file
- **Accessibility**: Screen reader support, keyboard navigation
- **Performance**: Minimal dependencies, optimized rendering

### 1.3 Component Splitting Strategy

Given the complexity of authentication flows, components are split as follows:

```
lib/views/auth/sign_in/
├── sign_in_view.dart              (< 200 lines) - Main view scaffold
├── widgets/
│   ├── sign_in_card.dart          (< 150 lines) - Card container
│   ├── email_sign_in_form.dart    (< 250 lines) - Email/password form
│   ├── mobile_sign_in_form.dart   (< 200 lines) - Mobile number form
│   ├── social_login_buttons.dart  (< 150 lines) - Social auth buttons
│   ├── sign_in_footer.dart        (< 100 lines) - Footer links
│   └── index.dart                 (< 50 lines)  - Barrel export
```

## 2. Architecture Pattern: MVVM

### 2.1 Structure

```
SignInView (Widget)
    ↓
SignInViewModel (State Management)
    ↓
AuthRepository (Data Operations)
    ↓
[AuthApiClient, SecureStorage]
```

### 2.2 Data Flow

1. User enters credentials → View captures input
2. View calls ViewModel method → ViewModel validates input
3. ViewModel calls Repository → Repository makes API call
4. API response → Repository maps to model → ViewModel updates state
5. State change → View rebuilds with result/error

## 3. Data Models

### 3.1 EmailLoginCredentials Model

**File:** `lib/models/auth/email_login_credentials.dart`

```dart
class EmailLoginCredentials {
  final String email;
  final String password;

  const EmailLoginCredentials({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  EmailLoginCredentials copyWith({
    String? email,
    String? password,
  }) {
    return EmailLoginCredentials(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
```

### 3.2 MobileLoginCredentials Model

**File:** `lib/models/auth/mobile_login_credentials.dart`

```dart
class MobileLoginCredentials {
  final String countryCode;
  final String phoneNumber;

  const MobileLoginCredentials({
    required this.countryCode,
    required this.phoneNumber,
  });

  String get fullNumber => '$countryCode$phoneNumber';

  Map<String, dynamic> toJson() {
    return {
      'country_code': countryCode,
      'phone_number': phoneNumber,
    };
  }

  MobileLoginCredentials copyWith({
    String? countryCode,
    String? phoneNumber,
  }) {
    return MobileLoginCredentials(
      countryCode: countryCode ?? this.countryCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
```

### 3.3 AuthResponse Model

**File:** `lib/models/auth/auth_response.dart`

```dart
class AuthResponse {
  final String token;
  final String refreshToken;
  final UserModel user;
  final DateTime expiresAt;

  const AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.user,
    required this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refresh_token': refreshToken,
      'user': user.toJson(),
      'expires_at': expiresAt.toIso8601String(),
    };
  }
}
```

### 3.4 SocialProvider Enum

**File:** `lib/models/auth/social_provider.dart`

```dart
enum SocialProvider {
  facebook('facebook', 'Facebook', 'ri-facebook-fill'),
  twitter('twitter', 'Twitter', 'ri-twitter-x-line'),
  linkedin('linkedin', 'LinkedIn', 'ri-linkedin-fill'),
  instagram('instagram', 'Instagram', 'ri-instagram-fill');

  final String id;
  final String displayName;
  final String iconName;

  const SocialProvider(this.id, this.displayName, this.iconName);
}
```

### 3.5 LoginMethod Enum

**File:** `lib/models/auth/login_method.dart`

```dart
enum LoginMethod {
  email('Email'),
  mobile('Mobile no');

  final String label;
  const LoginMethod(this.label);
}
```

## 4. Widget Component Hierarchy

### 4.1 Main Layout Structure

```
SignInView (StatelessWidget)
└─ Scaffold
   └─ Stack
      ├─ AnimatedBackground (optional decorative squares)
      └─ Center
         └─ ResponsiveContainer (max width based on screen)
            └─ SignInCard
               ├─ BrandLogo
               ├─ WelcomeHeader
               │  ├─ Title: "Welcome back!"
               │  └─ Subtitle: "Please sign in to continue."
               ├─ LoginMethodTabs
               │  ├─ TabBar (Email/Mobile)
               │  └─ TabBarView
               │     ├─ EmailSignInForm
               │     │  ├─ EmailTextField
               │     │  ├─ PasswordTextField
               │     │  └─ SignInButton
               │     └─ MobileSignInForm
               │        ├─ CountryCodePicker
               │        ├─ PhoneNumberTextField
               │        └─ ProceedButton
               ├─ SocialLoginButtons (4 icon buttons)
               └─ SignInFooter
                  ├─ ForgotPasswordLink
                  └─ CreateAccountLink
```

## 5. Detailed Widget Specifications

### 5.1 SignInView Widget

**File:** `lib/views/auth/sign_in/sign_in_view.dart`  
**File Size:** ~180 lines

```dart
class SignInView extends ConsumerWidget {
  const SignInView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(signInViewModelProvider);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Optional: Animated background
          if (screenSize.width >= AuthBreakpoints.desktop)
            const AnimatedBackground(),
          
          // Main content
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 32,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: _getMaxWidth(screenSize.width),
                ),
                child: const SignInCard(),
              ),
            ),
          ),

          // Loading overlay
          if (viewModel.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  double _getMaxWidth(double screenWidth) {
    if (screenWidth >= AuthBreakpoints.desktop) return 500;
    if (screenWidth >= AuthBreakpoints.tablet) return 450;
    return double.infinity;
  }
}
```

### 5.2 SignInCard Widget

**File:** `lib/views/auth/sign_in/widgets/sign_in_card.dart`  
**File Size:** ~140 lines

```dart
class SignInCard extends ConsumerWidget {
  const SignInCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(signInViewModelProvider);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo
            BrandLogo(),
            SizedBox(height: 32),

            // Welcome header
            WelcomeHeader(),
            SizedBox(height: 24),

            // Tab-based login forms
            LoginMethodTabs(),
            SizedBox(height: 24),

            // Social login buttons
            SocialLoginButtons(
              onProviderTap: (provider) {
                ref.read(signInViewModelProvider.notifier)
                    .signInWithSocial(provider);
              },
            ),
            SizedBox(height: 24),

            // Footer links
            SignInFooter(),

            // Error message display
            if (viewModel.errorMessage != null) ...[
              SizedBox(height: 16),
              Text(
                viewModel.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### 5.3 EmailSignInForm Widget

**File:** `lib/views/auth/sign_in/widgets/email_sign_in_form.dart`  
**File Size:** ~240 lines

```dart
class EmailSignInForm extends ConsumerStatefulWidget {
  const EmailSignInForm({Key? key}) : super(key: key);

  @override
  ConsumerState<EmailSignInForm> createState() => _EmailSignInFormState();
}

class _EmailSignInFormState extends ConsumerState<EmailSignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: _validateEmail,
            autofillHints: const [AutofillHints.email],
          ),
          SizedBox(height: 16),

          // Password field
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(),
            ),
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            validator: _validatePassword,
            autofillHints: const [AutofillHints.password],
            onFieldSubmitted: (_) => _handleSignIn(),
          ),
          SizedBox(height: 24),

          // Sign In button
          ElevatedButton(
            onPressed: _handleSignIn,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Sign In',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _handleSignIn() {
    if (_formKey.currentState?.validate() ?? false) {
      final credentials = EmailLoginCredentials(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      ref.read(signInViewModelProvider.notifier)
          .signInWithEmail(credentials);
    }
  }
}
```

### 5.4 MobileSignInForm Widget

**File:** `lib/views/auth/sign_in/widgets/mobile_sign_in_form.dart`  
**File Size:** ~190 lines

```dart
class MobileSignInForm extends ConsumerStatefulWidget {
  const MobileSignInForm({Key? key}) : super(key: key);

  @override
  ConsumerState<MobileSignInForm> createState() => _MobileSignInFormState();
}

class _MobileSignInFormState extends ConsumerState<MobileSignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _countryCode = '+91';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Phone number input with country code
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Country code selector
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: _showCountryCodePicker,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _countryCode,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),

              // Phone number field
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    hintText: 'Phone number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  validator: _validatePhoneNumber,
                  onFieldSubmitted: (_) => _handleProceed(),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Note text
          Text(
            'Note: Login with registered mobile number to generate OTP.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 24),

          // Proceed button
          ElevatedButton(
            onPressed: _handleProceed,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Proceed',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length < 10) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  void _showCountryCodePicker() {
    // Show country code picker dialog
    // Implementation depends on country_code_picker package
  }

  void _handleProceed() {
    if (_formKey.currentState?.validate() ?? false) {
      final credentials = MobileLoginCredentials(
        countryCode: _countryCode,
        phoneNumber: _phoneController.text.trim(),
      );
      
      ref.read(signInViewModelProvider.notifier)
          .signInWithMobile(credentials);
    }
  }
}
```

### 5.5 SocialLoginButtons Widget

**File:** `lib/views/auth/sign_in/widgets/social_login_buttons.dart`  
**File Size:** ~120 lines

```dart
class SocialLoginButtons extends StatelessWidget {
  final void Function(SocialProvider) onProviderTap;

  const SocialLoginButtons({
    Key? key,
    required this.onProviderTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Or sign in with',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: SocialProvider.values.map((provider) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: _SocialButton(
                provider: provider,
                onTap: () => onProviderTap(provider),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback onTap;

  const _SocialButton({
    required this.provider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            _getIconData(provider),
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
      ),
    );
  }

  IconData _getIconData(SocialProvider provider) {
    // Map icon names to IconData
    // This assumes using a custom icon font or Flutter icons
    switch (provider) {
      case SocialProvider.facebook:
        return Icons.facebook;
      case SocialProvider.twitter:
        return Icons.close; // Twitter X icon
      case SocialProvider.linkedin:
        return Icons.business;
      case SocialProvider.instagram:
        return Icons.camera_alt;
    }
  }
}
```

### 5.6 SignInFooter Widget

**File:** `lib/views/auth/sign_in/widgets/sign_in_footer.dart`  
**File Size:** ~80 lines

```dart
class SignInFooter extends StatelessWidget {
  const SignInFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Forgot password link
        TextButton(
          onPressed: () {
            context.go('/auth/forgot-password');
          },
          child: Text('Forgot password?'),
        ),
        SizedBox(height: 8),

        // Create account link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            TextButton(
              onPressed: () {
                context.go('/auth/sign-up');
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('Create an Account'),
            ),
          ],
        ),
      ],
    );
  }
}
```

### 5.7 Helper Widgets

**BrandLogo Widget**  
**File:** `lib/views/auth/sign_in/widgets/brand_logo.dart` (~50 lines)

```dart
class BrandLogo extends StatelessWidget {
  const BrandLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/'),
      child: Image.asset(
        'assets/images/brand-logos/toggle-logo.png',
        height: 40,
        fit: BoxFit.contain,
      ),
    );
  }
}
```

**WelcomeHeader Widget**  
**File:** `lib/views/auth/sign_in/widgets/welcome_header.dart` (~60 lines)

```dart
class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 8),
        Text(
          'Please sign in to continue.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
```

**LoginMethodTabs Widget**  
**File:** `lib/views/auth/sign_in/widgets/login_method_tabs.dart` (~120 lines)

```dart
class LoginMethodTabs extends ConsumerWidget {
  const LoginMethodTabs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMethod = ref.watch(
      signInViewModelProvider.select((vm) => vm.selectedLoginMethod),
    );

    return DefaultTabController(
      length: LoginMethod.values.length,
      child: Column(
        children: [
          TabBar(
            tabs: LoginMethod.values.map((method) {
              return Tab(text: method.label);
            }).toList(),
            onTap: (index) {
              ref.read(signInViewModelProvider.notifier)
                  .setLoginMethod(LoginMethod.values[index]);
            },
          ),
          SizedBox(height: 24),
          SizedBox(
            height: 280, // Fixed height for tab content
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: const [
                EmailSignInForm(),
                MobileSignInForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

## 6. ViewModel Architecture

### 6.1 SignInViewModel

**File:** `lib/viewmodels/auth/sign_in_viewmodel.dart`  
**File Size:** ~280 lines

```dart
class SignInViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final SecureStorageService _secureStorage;

  // State
  LoginMethod _selectedLoginMethod = LoginMethod.email;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  LoginMethod get selectedLoginMethod => _selectedLoginMethod;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SignInViewModel({
    required AuthRepository authRepository,
    required SecureStorageService secureStorage,
  })  : _authRepository = authRepository,
        _secureStorage = secureStorage;

  void setLoginMethod(LoginMethod method) {
    _selectedLoginMethod = method;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> signInWithEmail(EmailLoginCredentials credentials) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _authRepository.signInWithEmail(
        email: credentials.email,
        password: credentials.password,
      );

      await _saveAuthData(response);
      
      // Navigation handled by auth state listener
      _setLoading(false);
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _setLoading(false);
    }
  }

  Future<void> signInWithMobile(MobileLoginCredentials credentials) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // First step: Request OTP
      await _authRepository.requestOTP(
        countryCode: credentials.countryCode,
        phoneNumber: credentials.phoneNumber,
      );

      _setLoading(false);
      
      // Navigate to OTP verification screen
      // Navigation logic here or handled by router
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
    } catch (e) {
      _errorMessage = 'Failed to send OTP. Please try again.';
      _setLoading(false);
    }
  }

  Future<void> signInWithSocial(SocialProvider provider) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _authRepository.signInWithSocial(provider);
      
      await _saveAuthData(response);
      
      _setLoading(false);
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
    } catch (e) {
      _errorMessage = 'Social login failed. Please try again.';
      _setLoading(false);
    }
  }

  Future<void> _saveAuthData(AuthResponse response) async {
    await _secureStorage.write(key: 'auth_token', value: response.token);
    await _secureStorage.write(
      key: 'refresh_token',
      value: response.refreshToken,
    );
    await _secureStorage.write(
      key: 'user_data',
      value: jsonEncode(response.user.toJson()),
    );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
```

## 7. Riverpod Provider Setup

**File:** `lib/providers/auth_providers.dart`

```dart
// Repository providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ref.read(apiClientProvider),
  );
});

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

// ViewModel provider
final signInViewModelProvider = ChangeNotifierProvider<SignInViewModel>((ref) {
  return SignInViewModel(
    authRepository: ref.read(authRepositoryProvider),
    secureStorage: ref.read(secureStorageProvider),
  );
});

// Selector providers for optimized rebuilds
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(signInViewModelProvider.select((vm) => vm.isLoading));
});

final errorMessageProvider = Provider<String?>((ref) {
  return ref.watch(signInViewModelProvider.select((vm) => vm.errorMessage));
});
```

## 8. View Implementation

### 8.1 Main View with Error Handling

```dart
class SignInView extends ConsumerWidget {
  const SignInView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to auth state changes
    ref.listen<String?>(errorMessageProvider, (previous, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      body: _buildBody(context, ref),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    // Implementation from 5.1
  }
}
```

## 9. Responsive Design

### 9.1 Breakpoints

```dart
class AuthBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}
```

### 9.2 Layout Adaptations

| Screen Size | Card Width | Padding | Logo Size | Font Scale |
|-------------|------------|---------|-----------|------------|
| < 600px | 100% | 16px | 36px | 1.0 |
| 600-899px | 450px | 24px | 40px | 1.0 |
| 900-1199px | 500px | 32px | 40px | 1.0 |
| ≥ 1200px | 500px | 32px | 40px | 1.0 |

### 9.3 Responsive Card Sizing

```dart
double _getCardWidth(double screenWidth) {
  if (screenWidth >= AuthBreakpoints.desktop) return 500;
  if (screenWidth >= AuthBreakpoints.tablet) return 450;
  return screenWidth - 32; // Full width with margins
}
```

## 10. File Structure

```
lib/
├── models/
│   └── auth/
│       ├── email_login_credentials.dart       (< 50 lines)
│       ├── mobile_login_credentials.dart      (< 60 lines)
│       ├── auth_response.dart                 (< 100 lines)
│       ├── social_provider.dart               (< 40 lines)
│       └── login_method.dart                  (< 30 lines)
├── viewmodels/
│   └── auth/
│       └── sign_in_viewmodel.dart             (< 280 lines)
├── views/
│   └── auth/
│       └── sign_in/
│           ├── sign_in_view.dart              (< 200 lines)
│           └── widgets/
│               ├── sign_in_card.dart          (< 150 lines)
│               ├── brand_logo.dart            (< 50 lines)
│               ├── welcome_header.dart        (< 60 lines)
│               ├── login_method_tabs.dart     (< 120 lines)
│               ├── email_sign_in_form.dart    (< 250 lines)
│               ├── mobile_sign_in_form.dart   (< 200 lines)
│               ├── social_login_buttons.dart  (< 130 lines)
│               ├── sign_in_footer.dart        (< 80 lines)
│               └── index.dart                 (< 50 lines)
├── repositories/
│   └── auth_repository.dart                   (< 400 lines)
├── services/
│   ├── api/
│   │   └── auth_api_client.dart              (< 300 lines)
│   └── secure_storage_service.dart           (< 150 lines)
└── providers/
    └── auth_providers.dart                    (< 100 lines)
```

**Total Lines per Component:**
- All widget files: < 500 lines ✓
- ViewModel: < 300 lines ✓
- Models: < 100 lines each ✓

## 11. Required Packages

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.0
  
  # Routing
  go_router: ^13.0.0
  
  # Secure Storage
  flutter_secure_storage: ^9.0.0
  
  # HTTP & API
  dio: ^5.4.0
  
  # Form Validation
  # (using built-in validators)
  
  # Optional: Country Code Picker
  country_code_picker: ^3.0.0
  
  # Optional: Social Auth
  google_sign_in: ^6.1.0
  flutter_facebook_auth: ^6.0.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  mockito: ^5.4.0
```

## 12. Theme Configuration

### 12.1 Authentication Theme

```dart
class AuthTheme {
  static ThemeData lightTheme(ColorScheme colorScheme) {
    return ThemeData(
      colorScheme: colorScheme,
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
        ),
      ),
      
      // Card theme
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Tab theme
      tabBarTheme: TabBarTheme(
        labelColor: colorScheme.primary,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.tab,
      ),
    );
  }
}
```

### 12.2 Color Palette

```dart
class AuthColors {
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color successGreen = Color(0xFF388E3C);
  
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color dividerColor = Color(0xFFBDBDBD);
  
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
}
```

## 13. API Integration

### 13.1 AuthRepository

**File:** `lib/repositories/auth_repository.dart`  
**File Size:** ~350 lines

```dart
class AuthRepository {
  final AuthApiClient _apiClient;

  AuthRepository({required AuthApiClient apiClient}) : _apiClient = apiClient;

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleApiError(e);
    }
  }

  Future<void> requestOTP({
    required String countryCode,
    required String phoneNumber,
  }) async {
    try {
      await _apiClient.post(
        '/auth/otp/request',
        data: {
          'country_code': countryCode,
          'phone_number': phoneNumber,
        },
      );
    } on DioException catch (e) {
      throw _handleApiError(e);
    }
  }

  Future<AuthResponse> verifyOTP({
    required String countryCode,
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/otp/verify',
        data: {
          'country_code': countryCode,
          'phone_number': phoneNumber,
          'otp': otp,
        },
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleApiError(e);
    }
  }

  Future<AuthResponse> signInWithSocial(SocialProvider provider) async {
    try {
      // Get token from social provider SDK
      final socialToken = await _getSocialToken(provider);

      final response = await _apiClient.post(
        '/auth/social',
        data: {
          'provider': provider.id,
          'token': socialToken,
        },
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleApiError(e);
    }
  }

  Future<String> _getSocialToken(SocialProvider provider) async {
    // Implement social auth token retrieval
    // This would use packages like google_sign_in, flutter_facebook_auth, etc.
    throw UnimplementedError('Social auth not yet implemented');
  }

  ApiException _handleApiError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      return ApiException(
        message: data['message'] ?? 'Authentication failed',
        statusCode: error.response!.statusCode,
      );
    }
    
    return ApiException(
      message: 'Network error. Please check your connection.',
    );
  }
}
```

### 13.2 API Endpoints

```dart
class AuthEndpoints {
  static const String login = '/auth/login';
  static const String otpRequest = '/auth/otp/request';
  static const String otpVerify = '/auth/otp/verify';
  static const String socialAuth = '/auth/social';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
}
```

## 14. Implementation Notes

### 14.1 Security Considerations

**Password Handling:**
- Never log passwords
- Clear password fields on error
- Use secure text input (obscureText: true)
- Support password visibility toggle

**Token Storage:**
- Use flutter_secure_storage for tokens
- Store tokens encrypted on device
- Implement token refresh logic
- Clear tokens on logout

**Input Validation:**
- Client-side validation for UX
- Server-side validation for security
- Sanitize inputs before API calls
- Rate limiting on login attempts

### 14.2 Error Handling Strategy

**User-Friendly Messages:**
```dart
String _getFriendlyErrorMessage(ApiException error) {
  switch (error.statusCode) {
    case 401:
      return 'Invalid email or password';
    case 403:
      return 'Account is locked. Please contact support.';
    case 429:
      return 'Too many attempts. Please try again later.';
    case 500:
      return 'Server error. Please try again.';
    default:
      return 'An error occurred. Please try again.';
  }
}
```

**Error Display:**
- Show errors in SnackBar for non-blocking feedback
- Display inline errors for form validation
- Provide actionable error messages
- Log errors for debugging

### 14.3 Accessibility Features

**Screen Reader Support:**
- Semantic labels for all form fields
- Announce error messages
- Describe button actions
- Label tab navigation

**Keyboard Navigation:**
- Proper TextInputAction for form flow
- Support Tab key navigation
- Enter key submits form
- Focus management on errors

**Visual Accessibility:**
- Minimum contrast ratios (WCAG AA)
- Scalable fonts
- Touch target size ≥ 48dp
- Color not sole indicator

### 14.4 Performance Optimization

**Form Performance:**
- Debounce validation (avoid validation on every keystroke)
- Lazy load country codes
- Cache user input temporarily
- Optimize rebuild scopes

**Network:**
- Implement request timeout (30s)
- Retry logic for failed requests
- Cancel pending requests on dispose
- Connection status checking

**State Management:**
- Use select() for granular rebuilds
- Dispose controllers properly
- Clear error state on success
- Minimize notifyListeners() calls

### 14.5 Testing Strategy

**Unit Tests:**
- Validator functions
- ViewModel state changes
- Repository methods
- Model serialization

**Widget Tests:**
- Form submission
- Tab switching
- Error display
- Loading states

**Integration Tests:**
- Complete sign-in flow
- Social auth flow
- Mobile OTP flow
- Navigation after auth

## 15. Usage Example

### 15.1 Basic Implementation

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CodeVald Fortex',
      theme: AuthTheme.lightTheme(
        ColorScheme.fromSeed(seedColor: AuthColors.primaryBlue),
      ),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/auth/sign-in',
      builder: (context, state) => SignInView(),
    ),
    // ... other routes
  ],
  redirect: (context, state) {
    // Auth guard logic
    return null;
  },
);
```

### 15.2 Navigation Integration

```dart
// After successful sign-in
context.go('/dashboard');

// Navigate to forgot password
context.push('/auth/forgot-password');

// Navigate to sign up
context.push('/auth/sign-up');
```

## 16. Related Documents

- [Dashboard Design](dashboard-design.md) - Main application layout
- [Task Management Design](task-management-design.md) - Task interface patterns
- [Design Patterns](../design-patterns.md) - Reusable widget components
- [MVP Tasks](../../3-SofwareDevelopment/mvp.md) - Implementation roadmap (MVP-FL-015: Authentication)

---

## Appendix: Component Size Verification

| Component | File | Lines | Status |
|-----------|------|-------|--------|
| SignInView | sign_in_view.dart | ~180 | ✓ |
| SignInCard | sign_in_card.dart | ~140 | ✓ |
| EmailSignInForm | email_sign_in_form.dart | ~240 | ✓ |
| MobileSignInForm | mobile_sign_in_form.dart | ~190 | ✓ |
| SocialLoginButtons | social_login_buttons.dart | ~120 | ✓ |
| SignInFooter | sign_in_footer.dart | ~80 | ✓ |
| BrandLogo | brand_logo.dart | ~50 | ✓ |
| WelcomeHeader | welcome_header.dart | ~60 | ✓ |
| LoginMethodTabs | login_method_tabs.dart | ~120 | ✓ |
| SignInViewModel | sign_in_viewmodel.dart | ~280 | ✓ |
| AuthRepository | auth_repository.dart | ~350 | ✓ |

**All components comply with 500-line maximum.**
