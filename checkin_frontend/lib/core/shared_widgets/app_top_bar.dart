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
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check_circle_outline_rounded, size: 32, color: Colors.blueAccent),
                  SizedBox(width: 10),
                  Text('CheckInGuru', style: TextStyle(color: Colors.black)),
                ],
              ),),
          ),

          const Spacer(),

          if (userState != null) ...[
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

                  Text(userState.name, style: TextStyle(fontSize: 18),),

                  const SizedBox(width: 10),

                  IconButton(
                    //icon: Icon(Icons.density_medium),
                    icon: Icon(Icons.logout),
                    tooltip: "Logout",
                    color: Colors.blueAccent,
                    onPressed: () {
                      ref.read(authProvider.notifier).signOut();
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
