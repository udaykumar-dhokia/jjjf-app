import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../providers/user_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/news_provider.dart';
import '../../../providers/job_provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../home/screens/home_screen.dart';
import '../../news/screens/news_screen.dart';
import '../../directory/screens/directory_screen.dart';
import '../../businesses/screens/businesses_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../auth/screens/login_screen.dart';
import '../../jobs/screens/jobs_screen.dart';
import '../../matrimony/screens/matrimony_hub_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PersistentTabController _controller;
  final _advancedDrawerController = AdvancedDrawerController();
  String _appVersion = 'Loading...';

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchMyProfile();
      context.read<NewsProvider>().fetchNews();
      context.read<JobProvider>().fetchJobs();
    });
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = 'Version ${info.version} (${info.buildNumber})';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _appVersion = 'Version unknown';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _advancedDrawerController.dispose();
    super.dispose();
  }

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

  void _handleMenuButtonPressed() {
    _advancedDrawerController.showDrawer();
  }

  List<Widget> _buildScreens() {
    return [
      SafeArea(
        child: HomeScreen(
          onNavigateTab: (index) {
            _controller.jumpToTab(index);
          },
          onMenuTap: _handleMenuButtonPressed,
        ),
      ),
      SafeArea(child: NewsScreen(onMenuTap: _handleMenuButtonPressed)),
      SafeArea(child: DirectoryScreen(onMenuTap: _handleMenuButtonPressed)),
      SafeArea(child: BusinessesScreen(onMenuTap: _handleMenuButtonPressed)),
      SafeArea(child: ProfileScreen(onMenuTap: _handleMenuButtonPressed)),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems(BuildContext context) {
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
        icon: _buildProfileIcon(context, true),
        inactiveIcon: _buildProfileIcon(context, false),
        title: "Profile",
        activeColorPrimary: AppTheme.primaryPurple,
        inactiveColorPrimary: Colors.black45,
      ),
    ];
  }

  Widget _buildProfileIcon(BuildContext context, bool isActive) {
    final userProvider = context.watch<UserProvider>();
    final userProfile = userProvider.userProfile;

    if (userProfile == null) {
      return HugeIcon(
        icon: HugeIcons.strokeRoundedUser,
        color: isActive ? AppTheme.primaryPurple : Colors.black45,
      );
    }

    final imageUrl =
        (userProfile.photoUrl != null && userProfile.photoUrl!.isNotEmpty)
        ? userProfile.photoUrl!
        : 'https://api.dicebear.com/10.x/glass/png?seed=${userProfile.firstName}';

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? AppTheme.primaryPurple : Colors.transparent,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: Image.network(
          imageUrl,
          width: 24,
          height: 24,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return HugeIcon(
              icon: HugeIcons.strokeRoundedUser,
              color: isActive ? AppTheme.primaryPurple : Colors.black45,
              size: 20,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      backdrop: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.primaryPurple.withOpacity(0.9),
        ),
      ),
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      drawer: _buildDrawer(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PersistentTabView(
          context,
          controller: _controller,
          screens: _buildScreens(),
          items: _navBarsItems(context),
          handleAndroidBackButtonPress: true,
          resizeToAvoidBottomInset: true,
          stateManagement: true,
          hideNavigationBarWhenKeyboardAppears: true,
          padding: const EdgeInsets.only(top: 10, bottom: 10),
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
      ),
    );
  }

  Widget _buildDrawer() {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.userProfile;
    final authProvider = context.read<AuthProvider>();

    final imageUrl = (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
        ? user.photoUrl!
        : 'https://api.dicebear.com/10.x/glass/png?seed=${user?.firstName ?? 'User'}';

    return SafeArea(
      child: ListTileTheme(
        textColor: Colors.white,
        iconColor: Colors.white,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: IntrinsicHeight(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100.0,
                    height: 100.0,
                    margin: const EdgeInsets.only(
                      top: 24.0,
                      bottom: 16.0,
                      left: 16.0,
                    ),
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: Image.network(imageUrl, fit: BoxFit.cover),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user?.firstName ?? 'Guest'} ${user?.gotra ?? ''}'
                              .trim(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (user?.memberId != null)
                          Text(
                            'Member ID: ${user!.memberId}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  ListTile(
                    onTap: () {
                      _advancedDrawerController.hideDrawer();
                      _controller.jumpToTab(0);
                    },
                    leading: Image.asset(
                      'assets/icons/icons8-dashboard-96.png',
                      width: 24,
                      height: 24,
                      // color: Colors.white,
                    ),
                    title: const Text('Home'),
                  ),
                  ListTile(
                    onTap: () {
                      _advancedDrawerController.hideDrawer();
                      _controller.jumpToTab(1);
                    },
                    leading: Image.asset(
                      'assets/icons/icons8-news-94.png',
                      width: 24,
                      height: 24,
                      // color: Colors.white,
                    ),
                    title: const Text('Updates'),
                  ),
                  ListTile(
                    onTap: () {
                      _advancedDrawerController.hideDrawer();
                      _controller.jumpToTab(2);
                    },
                    leading: Image.asset(
                      'assets/icons/icons8-contacts-94.png',
                      width: 24,
                      height: 24,
                      // color: Colors.white,
                    ),
                    title: const Text('Directory'),
                  ),
                  ListTile(
                    onTap: () {
                      _advancedDrawerController.hideDrawer();
                      _controller.jumpToTab(3);
                    },
                    leading: Image.asset(
                      'assets/icons/icons8-building-94.png',
                      width: 24,
                      height: 24,
                      // color: Colors.white,
                    ),
                    title: const Text('Business'),
                  ),
                  ListTile(
                    onTap: () {
                      _advancedDrawerController.hideDrawer();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const JobsScreen()),
                      );
                    },
                    leading: Image.asset(
                      'assets/icons/icons8-graduation-cap-94.png',
                      width: 24,
                      height: 24,
                      // color: Colors.white,
                    ),
                    title: const Text('Job Board'),
                  ),
                  ListTile(
                    onTap: () {
                      _advancedDrawerController.hideDrawer();
                      _controller.jumpToTab(4);
                    },
                    leading: Image.asset(
                      'assets/icons/icons8-user-100.png',
                      width: 24,
                      height: 24,
                      // color: Colors.white,
                    ),
                    title: const Text('Profile'),
                  ),
                  ListTile(
                    onTap: () {
                      _advancedDrawerController.hideDrawer();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MatrimonyHubScreen(),
                        ),
                      );
                    },
                    leading: Image.asset(
                      'assets/icons/icons8-couple-96.png',
                      width: 24,
                      height: 24,
                      // color: Colors.white,
                    ),
                    title: const Text('Matrimony'),
                  ),

                  const Spacer(),

                  ListTile(
                    onTap: () async {
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    leading: const HugeIcon(
                      icon: HugeIcons.strokeRoundedLogout01,
                      color: Colors.white,
                    ),
                    title: const Text('Logout'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _appVersion,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
