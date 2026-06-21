import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/theme/app_theme.dart';
import '../../home/screens/home_screen.dart';
import '../../news/screens/news_screen.dart';
import '../../directory/screens/directory_screen.dart';
import '../../businesses/screens/businesses_screen.dart';
import '../../profile/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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
      SafeArea(child: const HomeScreen()),
      SafeArea(child: const NewsScreen()),
      SafeArea(child: const DirectoryScreen()),
      SafeArea(child: const BusinessesScreen()),
      SafeArea(child: const ProfileScreen()),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedHome01,
          color: AppTheme.primaryPurple,
        ),
        inactiveIcon: const HugeIcon(
          icon: HugeIcons.strokeRoundedHome01,
          color: Colors.black45,
        ),
        title: "Home",
        activeColorPrimary: AppTheme.primaryPurple,
        inactiveColorPrimary: Colors.black45,
      ),
      PersistentBottomNavBarItem(
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedNews,
          color: AppTheme.primaryPurple,
        ),
        inactiveIcon: const HugeIcon(
          icon: HugeIcons.strokeRoundedNews,
          color: Colors.black45,
        ),
        title: "News",
        activeColorPrimary: AppTheme.primaryPurple,
        inactiveColorPrimary: Colors.black45,
      ),
      PersistentBottomNavBarItem(
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedContactBook,
          color: AppTheme.primaryPurple,
        ),
        inactiveIcon: const HugeIcon(
          icon: HugeIcons.strokeRoundedContactBook,
          color: Colors.black45,
        ),
        title: "Directory",
        activeColorPrimary: AppTheme.primaryPurple,
        inactiveColorPrimary: Colors.black45,
      ),
      PersistentBottomNavBarItem(
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedBuilding03,
          color: AppTheme.primaryPurple,
        ),
        inactiveIcon: const HugeIcon(
          icon: HugeIcons.strokeRoundedBuilding03,
          color: Colors.black45,
        ),
        title: "Businesses",
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
        title: "Profile",
        activeColorPrimary: AppTheme.primaryPurple,
        inactiveColorPrimary: Colors.black45,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        hideNavigationBarWhenKeyboardAppears: true,
        padding: const EdgeInsets.only(top: 8),
        margin: const EdgeInsets.only(bottom: 8),
        backgroundColor: Colors.white.withOpacity(0.95),
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
      ),
    );
  }
}
