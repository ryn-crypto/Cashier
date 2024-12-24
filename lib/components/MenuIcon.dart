import 'package:flutter/material.dart';
import '../assets/colors.dart';

class MenuIcon extends StatelessWidget {
  final bool active;
  final String title;
  final IconData? icon;
  final VoidCallback? onTap;

  const MenuIcon({
    Key? key,
    required this.active,
    required this.title,
    this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activeColor = active ? Colors.white : customColorScheme.onSurface;
    final backgroundColor = active ? customColorScheme.primary : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon != null
                ? Icon(
              icon,
              color: activeColor,
            )
                : const SizedBox.shrink(),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                color: activeColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}