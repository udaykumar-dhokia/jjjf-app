import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/gradient_background.dart';
import 'core/widgets/custom_app_bar.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/auth/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Synchronously check user local state
  const storage = FlutterSecureStorage();
  final String? hasSeenOnboarding = await storage.read(
    key: 'hasSeenOnboarding',
  );
  final String? accessToken = await storage.read(key: 'accessToken');

  final bool showOnboarding = hasSeenOnboarding != 'true';
  final bool isAuthenticated = accessToken != null;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: JaloreJainSanghApp(
        showOnboarding: showOnboarding,
        isAuthenticated: isAuthenticated,
      ),
    ),
  );
}

class JaloreJainSanghApp extends StatelessWidget {
  final bool showOnboarding;
  final bool isAuthenticated;

  const JaloreJainSanghApp({
    super.key,
    required this.showOnboarding,
    required this.isAuthenticated,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jalore Jain Sangh',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return GradientBackground(child: child!);
      },
      home: showOnboarding
          ? const OnboardingScreen()
          : (isAuthenticated ? const HomeScreen() : const LoginScreen()),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Jalore Jain Sangh'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to the Community!',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your highly modular architecture is ready.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (authProvider.isAuthenticated) {
                  authProvider.logout();
                } else {
                  // TODO: Navigate to Login Screen
                }
              },
              child: Text(
                authProvider.isAuthenticated ? 'Logout' : 'Go to Login',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
