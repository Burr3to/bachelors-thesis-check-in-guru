import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/features/auth/views/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class AppTopBar extends ConsumerWidget implements PreferredSizeWidget {
  const AppTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authProvider).user;

    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      automaticallyImplyLeading: false,

      title: Row(
        children: [
          InkWell(
            onTap: () {
              context.go('/app/tasks');
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 32,
                    color: Colors.blueAccent,
                  ),
                  SizedBox(width: 10),
                  Text('CheckInGuru', style: TextStyle(color: Colors.black)),
                ],
              ),
            ),
          ),

          const Spacer(),

          Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.transparent),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 1.5,
                  color: Colors.blueAccent.withAlpha(123),
                  height: 32,
                ),

                TextButton(
                  onPressed: () => context.go('/app/tasks'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                  ),
                  child: const Text(
                    "Tasks",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 21,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),

                Container(
                  width: 1.5,
                  color: Colors.blueAccent.withAlpha(123),
                  height: 32,
                ),
              ],
            ),
          ),

          const Spacer(),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Color.fromRGBO(204, 223, 255, 1),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),

            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(userState?.name ?? "New User", style: TextStyle(fontSize: 18)),
                    Text(
                      userState?.email ?? "New User Mail",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 10),

                if (userState != null)
                  IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: "Logout",
                    color: Colors.redAccent, // Červená pre logout je prehľadnejšia
                    onPressed: () => ref.read(authProvider.notifier).signOut(),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.login),
                    tooltip: "Login",
                    color: Colors.blueAccent,
                    onPressed: () => ref.read(authProvider.notifier).signInWithGoogle(),
                  ),
                ]
            ),
          ),
        ],
      ),
    );
  }
}
