import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../jobs/screens/jobs_screen.dart';
import 'package:provider/provider.dart';
import '../../matrimony/screens/matrimony_hub_screen.dart';
import '../../matrimony/screens/create_profile_screen.dart';
import '../../../providers/matrimony_provider.dart';

class HomeMenuGrid extends StatelessWidget {
  final Function(int) onNavigateTab;

  const HomeMenuGrid({super.key, required this.onNavigateTab});

  Future<void> _launchYouTube(BuildContext context) async {
    final Uri url = Uri.parse('https://www.youtube.com/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch YouTube')),
        );
      }
    }
  }

  void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$title is coming soon!')));
  }

  void _handleMatrimonyTap(BuildContext context) async {
    final provider = Provider.of<MatrimonyProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    await provider.fetchMyProfile();
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    final profile = provider.myProfile;
    if (profile == null) {
      _showMatrimonyAccessDialog(context);
    } else if (profile.status == 'PENDING') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your Matrimony profile is pending admin approval.'),
        ),
      );
    } else if (profile.status == 'APPROVED') {
      Navigator.of(
        context,
        rootNavigator: true,
      ).push(MaterialPageRoute(builder: (_) => const MatrimonyHubScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your Matrimony profile status is ${profile.status}.'),
        ),
      );
    }
  }

  void _showMatrimonyAccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Unlock Matrimony',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'You need to create a matrimonial profile and get admin approval to access this feature. Would you like to create one now?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx, rootNavigator: true).pop();
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) => const CreateMatrimonyProfileScreen(),
                ),
              );
            },
            child: const Text(
              'Create Profile',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Profile',
        'icon': 'assets/icons/icons8-user-100.png',
        'action': () => onNavigateTab(4),
      },
      {
        'title': 'Directory',
        'icon': 'assets/icons/icons8-contacts-94.png',
        'action': () => onNavigateTab(2),
      },
      {
        'title': 'Updates',
        'icon': 'assets/icons/icons8-news-94.png',
        'action': () => onNavigateTab(1),
      },
      {
        'title': 'Business',
        'icon': 'assets/icons/icons8-building-94.png',
        'action': () => onNavigateTab(3),
      },
      {
        'title': 'Job Board',
        'icon': 'assets/icons/icons8-graduation-cap-94.png',
        'action': () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const JobsScreen())),
      },
      {
        'title': 'Matrimony',
        'icon': 'assets/icons/icons8-couple-96.png',
        'action': () => _handleMatrimonyTap(context),
      },
      {
        'title': 'Anniversary',
        'icon': 'assets/icons/icons8-love-94.png',
        'action': () => _showComingSoon(context, 'Anniversaries'),
      },
      {
        'title': 'YouTube',
        'icon': 'assets/icons/icons8-youtube-94.png',
        'action': () => _launchYouTube(context),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return _MenuGridItem(
            title: item['title'] as String,
            iconPath: item['icon'] as String,
            onTap: item['action'] as VoidCallback,
          );
        },
      ),
    );
  }
}

class _MenuGridItem extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback onTap;

  const _MenuGridItem({
    required this.title,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.textLight.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(iconPath, width: 28, height: 28),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
