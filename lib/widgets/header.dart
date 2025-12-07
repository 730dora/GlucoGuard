import 'package:flutter/material.dart';
import '../theme.dart';

class HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String username;
  final VoidCallback? onProfileTap;

  const HeaderBar({
    super.key,
    required this.username,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Welcome, $username!',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: onProfileTap,
            child: CircleAvatar(
              backgroundColor: AppTheme.violet.withOpacity(0.2),
              child: const Icon(Icons.person, color: AppTheme.violet),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}