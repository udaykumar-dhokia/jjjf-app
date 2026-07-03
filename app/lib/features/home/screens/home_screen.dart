import 'package:flutter/material.dart';
import '../../../core/widgets/update_checker_icon.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/gradient_background.dart';
import '../widgets/hero_carousel.dart';
import '../widgets/home_greeting.dart';
import '../widgets/home_menu_grid.dart';
import '../widgets/home_latest_news.dart';
import '../widgets/home_latest_jobs.dart';

import 'package:hugeicons/hugeicons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigateTab;
  final VoidCallback onMenuTap;

  const HomeScreen({
    super.key,
    required this.onNavigateTab,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(
          title: 'Home',
          leading: IconButton(
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedMenu01,
              color: AppTheme.primaryPurple,
              size: 24,
            ),
            onPressed: onMenuTap,
          ),
          actions: const [UpdateCheckerIcon()],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const HomeGreeting(),
                const SizedBox(height: 24),
                const HeroCarousel(),
                const SizedBox(height: 32),
                HomeMenuGrid(onNavigateTab: onNavigateTab),
                const SizedBox(height: 32),
                HomeLatestNews(onNavigateTab: onNavigateTab),
                const SizedBox(height: 32),
                const HomeLatestJobs(
                  title: 'Latest Vacancies',
                  isVacancy: true,
                ),
                const SizedBox(height: 32),
                const HomeLatestJobs(
                  title: 'Latest Job Requests',
                  isVacancy: false,
                ),
                const SizedBox(height: 32),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      AppTheme.primaryPurple.withOpacity(0.6),
                      AppTheme.primaryPurple.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: Text(
                    'JALORE JILLA\nJAIN FEDERATION',
                    style: GoogleFonts.poppins(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.0,
                      letterSpacing: -1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
