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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Forgot password feature coming soon!'),
              ),
            );
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
              child: Text('OR', style: Theme.of(context).textTheme.bodySmall),
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
