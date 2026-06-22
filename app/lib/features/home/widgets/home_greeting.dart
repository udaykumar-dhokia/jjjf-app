import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';
import '../../../core/theme/app_theme.dart';

class HomeGreeting extends StatelessWidget {
  const HomeGreeting({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final firstName =
            "${userProvider.userProfile?.firstName ?? 'Guest'} ${userProvider.userProfile?.gotra}";
        final greeting = _getGreeting();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text.rich(
            TextSpan(
              text: '$greeting, 👋',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                  text: firstName,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryPurple,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
