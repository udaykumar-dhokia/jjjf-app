import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final double elevation;
  final Color backgroundColor;
  final Color foregroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.elevation = 0,
    this.backgroundColor = Colors.transparent,
    this.foregroundColor = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(color: foregroundColor, fontWeight: FontWeight.w600),
      ),
      leading: leading,
      actions: actions,
      surfaceTintColor: Colors.transparent,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      elevation: elevation,
      iconTheme: IconThemeData(color: foregroundColor),
      actionsIconTheme: IconThemeData(color: foregroundColor),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
