import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'config/app_constants.dart';
import 'config/router.dart';
import 'providers/theme_provider.dart';

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

  // Run the app with Riverpod provider scope
  runApp(const ProviderScope(child: CodeValdFortexApp()));
}

class CodeValdFortexApp extends ConsumerWidget {
  const CodeValdFortexApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

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
