import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../features/auth/views/providers/auth_provider.dart';
import '../providers/locale_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final user = ref.watch(authProvider).user;
    final String location = GoRouterState.of(context).uri.path;

    return Drawer(
      // Kľúčové: Nastavenie farby a nulový elevation pre čistý M3 vzhľad
      backgroundColor: cs.surface,
      surfaceTintColor: cs.surfaceTint,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // 1. VLASTNÝ HEADER (Nahrádza starý UserAccountsDrawerHeader)
          _buildCustomHeader(context, cs, user),

          const SizedBox(height: 12),

          // 2. NAVIGAČNÉ POLOŽKY
          _DrawerItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: context.l10n.nav_introduction,
            isActive: location == '/welcome',
            onTap: () => context.go('/welcome'),
          ),
          _DrawerItem(
            icon: Icons.task_outlined,
            activeIcon: Icons.task,
            label: context.l10n.nav_my_tasks,
            isActive: location.startsWith('/tasks') && !location.contains('create'),
            onTap: () => context.go('/tasks'),
          ),
          _DrawerItem(
            icon: Icons.add_circle_outline,
            activeIcon: Icons.add_circle,
            label: "Create Task",
            isActive: location == '/tasks/create',
            onTap: () => context.go('/tasks/create'),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Divider(),
          ),

          // 3. NASTAVENIA JAZYKA PRIAMO V MENU
          _buildLanguageSection(context, ref, cs),

          const Spacer(),

          // 4. LOGOUT SEKCIA
          if (user != null) _buildLogoutSection(context, ref, cs),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context, ColorScheme cs, dynamic user) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 24,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withAlpha(40), // Jemný modrý nádych
        border: Border(bottom: BorderSide(color: cs.outlineVariant.withAlpha(100))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: cs.primary,
            child: Text(
              (user?.name ?? "G").substring(0, 1).toUpperCase(),
              style: TextStyle(color: cs.onPrimary, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? "Guest User",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface),
          ),
          Text(
            user?.email ?? "Sign in to sync tasks",
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context, WidgetRef ref, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text("Language", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cs.primary)),
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          leading: const Icon(Icons.language, size: 20),
          title: const Text("Slovenčina"),
          onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('sk', 'SK')),
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          leading: const Icon(Icons.language, size: 20),
          title: const Text("English"),
          onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('en', 'US')),
        ),
      ],
    );
  }

  Widget _buildLogoutSection(BuildContext context, WidgetRef ref, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: cs.errorContainer.withAlpha(40),
        leading: Icon(Icons.logout, color: cs.error),
        title: Text("Logout", style: TextStyle(color: cs.error, fontWeight: FontWeight.bold)),
        onTap: () {
          Navigator.pop(context); // Zatvoriť drawer
          ref.read(authProvider.notifier).signOut();
        },
      ),
    );
  }
}

// --- POMOCNÝ WIDGET PRE POLOŽKU V MENU ---
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          isActive ? activeIcon : icon,
          color: isActive ? cs.primary : cs.onSurfaceVariant,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? cs.primary : cs.onSurface,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        // Aktívny podmaz
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isActive ? cs.primaryContainer.withAlpha(60) : Colors.transparent,
      ),
    );
  }
}