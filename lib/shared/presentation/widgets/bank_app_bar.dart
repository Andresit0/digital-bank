import 'package:flutter/material.dart';

class BankAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BankAppBar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.person_outline),
          tooltip: 'Profile',
        ),
      ],
    );
  }
}
