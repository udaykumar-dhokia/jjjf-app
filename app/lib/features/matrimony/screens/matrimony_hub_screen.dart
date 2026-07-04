import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_theme.dart';
import 'browse_matrimony_screen.dart';
import 'matrimony_requests_screen.dart';
import 'my_matrimony_profile_screen.dart';

class MatrimonyHubScreen extends StatefulWidget {
  const MatrimonyHubScreen({super.key});

  @override
  State<MatrimonyHubScreen> createState() => _MatrimonyHubScreenState();
}

class _MatrimonyHubScreenState extends State<MatrimonyHubScreen> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Widget> _buildScreens() {
    return [
      const BrowseMatrimonyScreen(),
      const MatrimonyRequestsScreen(),
      const MyMatrimonyProfileScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedUserMultiple,
          color: AppTheme.primaryPurple,
        ),
        inactiveIcon: const HugeIcon(
          icon: HugeIcons.strokeRoundedUserMultiple,
          color: Colors.black45,
        ),
        title: "Browse",
        activeColorPrimary: AppTheme.primaryPurple,
        inactiveColorPrimary: Colors.black45,
      ),
      PersistentBottomNavBarItem(
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedNotification01,
          color: AppTheme.primaryPurple,
        ),
        inactiveIcon: const HugeIcon(
          icon: HugeIcons.strokeRoundedNotification01,
          color: Colors.black45,
        ),
        title: "Requests",
        activeColorPrimary: AppTheme.primaryPurple,
        inactiveColorPrimary: Colors.black45,
      ),
      PersistentBottomNavBarItem(
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedUser,
          color: AppTheme.primaryPurple,
        ),
        inactiveIcon: const HugeIcon(
          icon: HugeIcons.strokeRoundedUser,
          color: Colors.black45,
        ),
        title: "My Profile",
        activeColorPrimary: AppTheme.primaryPurple,
        inactiveColorPrimary: Colors.black45,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      backgroundColor: Colors.white,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(0.0),
        colorBehindNavBar: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      navBarStyle: NavBarStyle.style12,
    );
  }
}
