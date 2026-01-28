import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/auth/auth_state.dart';
import '../../../providers/auth_provider.dart';
import 'widgets/index.dart';

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
                        child: Center(child: CircularProgressIndicator()),
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
