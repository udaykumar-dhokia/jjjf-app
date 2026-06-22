import 'package:flutter/material.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/gradient_background.dart';
import '../widgets/hero_carousel.dart';
import '../widgets/home_greeting.dart';
import '../widgets/home_menu_grid.dart';
import '../widgets/home_latest_news.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const HomeScreen({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(title: 'Home'),
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
