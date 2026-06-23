import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/theme/app_theme.dart';

class BusinessesScreen extends StatelessWidget {
  final VoidCallback? onMenuTap;
  
  const BusinessesScreen({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(
          title: 'Businesses',
          leading: onMenuTap != null
              ? IconButton(
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedMenu01,
                    color: AppTheme.primaryPurple,
                    size: 24,
                  ),
                  onPressed: onMenuTap,
                )
              : null,
        ),
        body: const Center(
          child: Text('Businesses Screen Content'),
        ),
      ),
    );
  }
}
