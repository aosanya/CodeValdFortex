import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'config/app_constants.dart';
import 'config/router.dart';
import 'core/api/dio_client.dart';
import 'core/auth/auth_event_notifier.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize app configuration
    await AppConfig.initialize(env: 'development');
  } catch (e) {
    // Fallback if env file fails to load
    // Environment config will use default values
    debugPrint('Warning: Failed to load environment config: $e');
  }

  // Create provider container for accessing providers outside widget tree
  final container = ProviderContainer();

  // Configure token refresh callback
  DioClient.setTokenRefreshCallback(() async {
    try {
      await container.read(authProvider.notifier).refreshToken();
      return true;
    } catch (e) {
      return false;
    }
  });

  // Run the app with Riverpod provider scope
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const CodeValdFortexApp(),
    ),
  );
}

class CodeValdFortexApp extends ConsumerStatefulWidget {
  const CodeValdFortexApp({super.key});

  @override
  ConsumerState<CodeValdFortexApp> createState() => _CodeValdFortexAppState();
}

class _CodeValdFortexAppState extends ConsumerState<CodeValdFortexApp> {
  GoRouter? _router;
  bool _isHandlingAuthEvent = false;

  @override
  void initState() {
    super.initState();
    
    // Listen to auth events and handle session expiry
    authEventNotifier.events.listen((event) async {
      // Prevent handling multiple events simultaneously
      if (_isHandlingAuthEvent) return;
      
      if (event == AuthEvent.tokenMissing || 
          event == AuthEvent.tokenRefreshFailed) {
        _isHandlingAuthEvent = true;
        authEventNotifier.setHandling(true);
        
        try {
          // Logout user and clear all tokens
          await ref.read(authProvider.notifier).logout();
          
          // Navigate to session expired screen
          if (_router != null && mounted) {
            _router!.go('/session-expired');
          }
        } finally {
          // Reset after a delay to allow navigation to complete
          Future.delayed(const Duration(seconds: 3), () {
            _isHandlingAuthEvent = false;
            authEventNotifier.setHandling(false);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);
    _router = router;

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
