import 'package:app/providers/complete_profile_provider.dart';
import 'package:app/providers/directory_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/gradient_background.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/profile/screens/complete_profile_screen.dart';
import 'features/main/screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  const storage = FlutterSecureStorage();
  final String? hasSeenOnboarding = await storage.read(
    key: 'hasSeenOnboarding',
  );
  final String? accessToken = await storage.read(key: 'accessToken');
  final String? isProfileCompleteStr = await storage.read(
    key: 'isProfileComplete',
  );

  final bool showOnboarding = hasSeenOnboarding != 'true';
  final bool isAuthenticated = accessToken != null;
  final bool isProfileComplete = isProfileCompleteStr == 'true';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CompleteProfileProvider()),
        ChangeNotifierProvider(create: (_) => DirectoryProvider()),
      ],
      child: JaloreJainSanghApp(
        showOnboarding: showOnboarding,
        isAuthenticated: isAuthenticated,
        isProfileComplete: isProfileComplete,
      ),
    ),
  );
}

class JaloreJainSanghApp extends StatelessWidget {
  final bool showOnboarding;
  final bool isAuthenticated;
  final bool isProfileComplete;

  const JaloreJainSanghApp({
    super.key,
    required this.showOnboarding,
    required this.isAuthenticated,
    required this.isProfileComplete,
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
          : (isAuthenticated
                ? (isProfileComplete
                      ? const MainScreen()
                      : const CompleteProfileScreen())
                : const LoginScreen()),
    );
  }
}
