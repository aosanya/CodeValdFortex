# MVP-FL-010: Login & Registration Screens

## Overview
**Priority**: P0  
**Effort**: Medium  
**Skills**: Flutter, Forms, Validation, Material Design  
**Dependencies**: MVP-FL-009 (Authentication State Management) ✅

Create complete login and registration UI screens with form validation, error handling, and integration with the authentication state management system (MVP-FL-009). Implements the design specifications from `/documents/2-SoftwareDesignAndArchitecture/flutter-designs/sign-in-design.md`.

## Requirements

### Functional Requirements

1. **Login Screen**
   - Email/password login form
   - Form validation (email format, password requirements)
   - "Remember me" checkbox (optional)
   - "Forgot password?" link
   - "Sign up" link to registration screen
   - Loading state during authentication
   - Error message display
   - Success navigation to home/dashboard

2. **Registration Screen**
   - User registration form (name, email, password, confirm password)
   - Form validation:
     - Valid email format
     - Password strength requirements (min 8 chars, uppercase, lowercase, number)
     - Password confirmation match
     - Required field validation
   - Terms & conditions checkbox
   - "Already have an account?" link to login
   - Loading state during registration
   - Error message display
   - Success navigation to login or home

3. **Form Validation**
   - Real-time field validation
   - Clear error messages
   - Disable submit button until form is valid
   - Validation feedback (checkmarks, error icons)

4. **Error Handling**
   - Display API errors from AuthProvider
   - Network error handling
   - User-friendly error messages
   - Clear error display (SnackBar or inline)

5. **Integration with AuthProvider (MVP-FL-009)**
   - Use `authProvider` from Riverpod
   - Call `loginWithEmail()` on form submit
   - Listen to auth state changes
   - Navigate to home on successful authentication
   - Display errors from auth state

### Non-Functional Requirements

1. **Responsive Design**
   - Mobile-first design (< 600px width)
   - Tablet support (600-900px)
   - Desktop support (> 900px)
   - Centered card layout on desktop

2. **Performance**
   - Fast form rendering (< 100ms)
   - Smooth animations
   - No UI jank during validation

3. **Accessibility**
   - Proper text field labels
   - Screen reader support
   - Keyboard navigation
   - Focus management

4. **Security**
   - Password field obscured
   - No credential logging
   - Secure form submission

## Technical Specifications

### Architecture

#### Component Structure
```
lib/views/auth/
├── sign_in/
│   ├── sign_in_view.dart              # Main login screen
│   └── widgets/
│       ├── email_sign_in_form.dart    # Email/password form widget
│       ├── sign_in_footer.dart        # Links (forgot password, sign up)
│       └── index.dart                 # Barrel export
└── sign_up/
    ├── sign_up_view.dart              # Main registration screen
    └── widgets/
        ├── sign_up_form.dart          # Registration form widget
        ├── password_strength_indicator.dart # Password strength meter
        └── index.dart                 # Barrel export
```

#### MVVM Pattern (Already established in MVP-FL-009)
```
SignInView (Widget)
    ↓ ref.watch(authProvider)
AuthProvider (StateNotifier)
    ↓ calls methods
AuthRepository
    ↓ uses
AuthService (API calls)
```

### Implementation Details

#### 1. Sign-In View

**File**: `lib/views/auth/sign_in/sign_in_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';
import 'widgets/email_sign_in_form.dart';
import 'widgets/sign_in_footer.dart';

class SignInView extends ConsumerWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    // Listen to auth state changes for navigation
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        // Navigate to home on successful login
        context.go('/home');
      }
      
      if (next.errorMessage != null) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth >= 900 ? 450 : double.infinity,
            ),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Icon(
                      Icons.lock_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    
                    // Welcome text
                    Text(
                      'Welcome Back!',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please sign in to continue',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    // Login form
                    const EmailSignInForm(),
                    const SizedBox(height: 24),
                    
                    // Footer with links
                    const SignInFooter(),
                    
                    // Loading indicator overlay
                    if (authState.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

#### 2. Email Sign-In Form Widget

**File**: `lib/views/auth/sign_in/widgets/email_sign_in_form.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/auth_provider.dart';

class EmailSignInForm extends ConsumerStatefulWidget {
  const EmailSignInForm({super.key});

  @override
  ConsumerState<EmailSignInForm> createState() => _EmailSignInFormState();
}

class _EmailSignInFormState extends ConsumerState<EmailSignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref.read(authProvider.notifier).loginWithEmail(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
      } catch (e) {
        // Error handled by auth state listener in SignInView
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: _validateEmail,
            enabled: !authState.isLoading,
          ),
          const SizedBox(height: 16),
          
          // Password field
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outlined),
              border: const OutlineInputBorder(),
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
            ),
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            validator: _validatePassword,
            enabled: !authState.isLoading,
            onFieldSubmitted: (_) => _handleSignIn(),
          ),
          const SizedBox(height: 8),
          
          // Remember me checkbox
          CheckboxListTile(
            value: _rememberMe,
            onChanged: authState.isLoading
                ? null
                : (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
            title: const Text('Remember me'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
          
          // Sign in button
          ElevatedButton(
            onPressed: authState.isLoading ? null : _handleSignIn,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: authState.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}
```

#### 3. Sign-In Footer Widget

**File**: `lib/views/auth/sign_in/widgets/sign_in_footer.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignInFooter extends StatelessWidget {
  const SignInFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Forgot password link
        TextButton(
          onPressed: () {
            // TODO: Navigate to forgot password (future task)
            context.push('/forgot-password');
          },
          child: const Text('Forgot password?'),
        ),
        const SizedBox(height: 8),
        
        // Divider with OR
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        
        // Sign up link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have an account?"),
            TextButton(
              onPressed: () {
                context.push('/sign-up');
              },
              child: const Text(
                'Sign Up',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
```

#### 4. Sign-Up View

**File**: `lib/views/auth/sign_up/sign_up_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'widgets/sign_up_form.dart';

class SignUpView extends ConsumerWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth >= 900 ? 450 : double.infinity,
            ),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon
                    Icon(
                      Icons.person_add_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    
                    // Title
                    Text(
                      'Join CodeVald',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your account to get started',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    // Registration form
                    const SignUpForm(),
                    const SizedBox(height: 24),
                    
                    // Sign in link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account?'),
                        TextButton(
                          onPressed: () {
                            context.go('/sign-in');
                          },
                          child: const Text(
                            'Sign In',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

#### 5. Sign-Up Form Widget

**File**: `lib/views/auth/sign_up/widgets/sign_up_form.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignUpForm extends ConsumerStatefulWidget {
  const SignUpForm({super.key});

  @override
  ConsumerState<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends ConsumerState<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions'),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        // TODO: Call registration API (future backend task)
        await Future.delayed(const Duration(seconds: 2)); // Simulate API call
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully! Please sign in.'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/sign-in');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration failed: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
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
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name field
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: Icon(Icons.person_outlined),
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            validator: _validateName,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 16),
          
          // Email field
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: _validateEmail,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 16),
          
          // Password field
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Create a strong password',
              prefixIcon: const Icon(Icons.lock_outlined),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            validator: _validatePassword,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 16),
          
          // Confirm password field
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Re-enter your password',
              prefixIcon: const Icon(Icons.lock_outlined),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() =>
                      _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),
            ),
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            validator: _validateConfirmPassword,
            enabled: !_isLoading,
            onFieldSubmitted: (_) => _handleSignUp(),
          ),
          const SizedBox(height: 16),
          
          // Terms & conditions checkbox
          CheckboxListTile(
            value: _acceptedTerms,
            onChanged: _isLoading
                ? null
                : (value) {
                    setState(() => _acceptedTerms = value ?? false);
                  },
            title: const Text.rich(
              TextSpan(
                text: 'I agree to the ',
                children: [
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
              style: TextStyle(fontSize: 13),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
          
          // Sign up button
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSignUp,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}
```

### File Structure
```
lib/views/auth/
├── sign_in/
│   ├── sign_in_view.dart              # Main login screen (Consumer Widget)
│   └── widgets/
│       ├── email_sign_in_form.dart    # Email/password form
│       ├── sign_in_footer.dart        # Footer with links
│       └── index.dart                 # Barrel export
└── sign_up/
    ├── sign_up_view.dart              # Main registration screen
    └── widgets/
        ├── sign_up_form.dart          # Registration form
        └── index.dart                 # Barrel export
```

### Routing Configuration

Update `lib/config/router.dart` to include auth routes:

```dart
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: authState.isAuthenticated ? '/home' : '/sign-in',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation.startsWith('/sign-in') ||
                          state.matchedLocation.startsWith('/sign-up');
      
      // Redirect to sign-in if not authenticated and trying to access protected route
      if (!isAuthenticated && !isAuthRoute) {
        return '/sign-in';
      }
      
      // Redirect to home if authenticated and trying to access auth pages
      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }
      
      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInView(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpView(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      // ... other routes
    ],
  );
});
```

## Acceptance Criteria

- [ ] **AC-1**: Login screen displays with email and password fields
- [ ] **AC-2**: Registration screen displays with all required fields
- [ ] **AC-3**: Email validation works (format check)
- [ ] **AC-4**: Password validation enforces strength requirements
- [ ] **AC-5**: Password confirmation matches password
- [ ] **AC-6**: Form submission disabled until all fields are valid
- [ ] **AC-7**: Login integrates with authProvider.loginWithEmail()
- [ ] **AC-8**: Loading state displays during authentication
- [ ] **AC-9**: Error messages display from auth state
- [ ] **AC-10**: Successful login navigates to home page
- [ ] **AC-11**: "Sign up" link navigates to registration screen
- [ ] **AC-12**: "Sign in" link navigates back to login screen
- [ ] **AC-13**: Responsive design works on mobile, tablet, desktop
- [ ] **AC-14**: Password visibility toggle works
- [ ] **AC-15**: Remember me checkbox functional (optional)
- [ ] **AC-16**: No errors from flutter analyze
- [ ] **AC-17**: Code follows project standards

## Testing Requirements

### Manual Testing

1. **Login Flow**
   - Enter valid credentials → should navigate to home
   - Enter invalid email → should show validation error
   - Enter short password → should show validation error
   - Submit with empty fields → should show required errors
   - Test loading state → spinner should appear

2. **Registration Flow**
   - Fill all fields correctly → should create account
   - Mismatch passwords → should show error
   - Weak password → should show strength requirements
   - Uncheck terms → should prevent submission

3. **Navigation**
   - Click "Sign up" → should navigate to registration
   - Click "Sign in" → should navigate to login
   - Click "Forgot password" → should navigate (or show placeholder)

4. **Responsive Design**
   - Test on mobile viewport (< 600px)
   - Test on tablet viewport (600-900px)
   - Test on desktop viewport (> 900px)
   - Verify card layout centers on desktop

### Future: Unit & Widget Tests

```dart
// test/views/auth/sign_in_test.dart
testWidgets('SignInView displays login form', (tester) async {
  await tester.pumpWidget(ProviderScope(child: MaterialApp(home: SignInView())));
  
  expect(find.text('Welcome Back!'), findsOneWidget);
  expect(find.byType(TextFormField), findsNWidgets(2)); // Email + Password
  expect(find.text('Sign In'), findsOneWidget);
});

testWidgets('Email validation works', (tester) async {
  // Test email validation logic
});

testWidgets('Password validation works', (tester) async {
  // Test password validation logic
});
```

## Usage Examples

### Navigate to Login Screen

```dart
// From any widget
context.go('/sign-in');
```

### Handle Login Success

```dart
// Already handled in SignInView via ref.listen
ref.listen<AuthState>(authProvider, (previous, next) {
  if (next.isAuthenticated) {
    context.go('/home');
  }
});
```

### Check if User is Logged In

```dart
final isAuthenticated = ref.watch(isAuthenticatedProvider);
if (isAuthenticated) {
  // Show protected content
}
```

## Backend Integration Notes

**Current State**: Registration endpoint (`POST /api/v1/auth/register`) does not exist in Cortex yet.

**For MVP-FL-010**:
- Login uses authProvider (MVP-FL-009) which expects `/auth/login` endpoint
- Registration will show success message and redirect to login (placeholder until backend ready)
- Future task: Implement registration API in Cortex

**Future Tasks**:
- Backend: Create registration endpoint
- Backend: Implement email verification
- Frontend: Connect registration form to real API

## Related Tasks

- **MVP-FL-009**: Authentication State Management ✅ (dependency)
- **MVP-FL-011**: Protected Routes & Permissions (depends on MVP-FL-010)
- **Backend (Future)**: Registration API endpoint in CodeValdCortex

## Design Reference

Complete design specification with visual layouts, Material Design components, and responsive breakpoints:
- `/documents/2-SoftwareDesignAndArchitecture/flutter-designs/sign-in-design.md` (1584 lines)

## Notes

- Uses existing AuthProvider from MVP-FL-009
- Registration is placeholder (success → redirect to login) until backend ready
- "Forgot password" is placeholder link (future task)
- Social login buttons deferred to future enhancement
- Mobile login (phone number) deferred to future enhancement
- Password strength indicator can be added as enhancement
