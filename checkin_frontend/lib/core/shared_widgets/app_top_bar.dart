import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/features/auth/views/providers/auth_provider.dart';

class AppTopBar extends ConsumerWidget implements PreferredSizeWidget {
  const AppTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authProvider);

    return AppBar(
      backgroundColor: Colors.blueGrey,
      automaticallyImplyLeading: false,

      title: Row(
        children: [
          Icon(Icons.check_circle),
          SizedBox(width: 10),
          Text('Check-In'),

          const Spacer(),

          if (userState != null) ...[Text(userState.name), SizedBox(width: 10)],

          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
            },
          ),
        ],
      ),
    );
  }
}
