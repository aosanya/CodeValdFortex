import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/auth/auth_event_notifier.dart';

/// Brief notification screen shown when session expires
/// 
/// Displays a message for 2 seconds before redirecting to login
class SessionExpiredScreen extends StatefulWidget {
  const SessionExpiredScreen({
    super.key,
    this.message = 'Session expired. Please log in again.',
  });

  final String message;

  @override
  State<SessionExpiredScreen> createState() => _SessionExpiredScreenState();
}

class _SessionExpiredScreenState extends State<SessionExpiredScreen> {
  @override
  void initState() {
    super.initState();
    
    // Redirect to login after brief delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        // Reset auth event handler before navigating
        authEventNotifier.reset();
        context.go('/sign-in');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Session Expired',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                widget.message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
