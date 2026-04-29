import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/features/auth/views/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';
import '../utils/l10n_extensions.dart';

class AppTopBar extends ConsumerWidget implements PreferredSizeWidget {
  const AppTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authProvider).user;
    final themeMode = ref.watch(themeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      // Tieň pri scrollovaní
      elevation: 0,
      scrolledUnderElevation: 3,
      shadowColor: colorScheme.shadow.withAlpha(200),
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const _LogoSection(),
          const Spacer(),
          const _NavigationSection(),
          const Spacer(),

          // JAZYK
          const _LanguageSwitch(),

          // THEME SWITCH
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
              color: Colors.blueAccent,
            ),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),

          const SizedBox(width: 10),

          // PROFIL / LOGIN
          userState != null
              ? _UserAccountSection(user: userState)
              : const _LoginButtonSection(),
        ],
      ),
    );
  }
}

// --- LOGO (Nezmenené) ---
class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/tasks'),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline_rounded, size: 32, color: Colors.blueAccent),
            const SizedBox(width: 10),
            Text(
              'CheckInGuru',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- NAVIGÁCIA (Nezmenené) ---
class _NavigationSection extends StatelessWidget {
  const _NavigationSection();

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _navButton(
            context,
            context.l10n.nav_introduction,
            '/welcome',
            isActive: location == '/welcome'
        ),
        const SizedBox(width: 8),
        _navButton(
            context,
            context.l10n.nav_my_tasks,
            '/tasks',
            isActive: location.startsWith('/tasks') && !location.startsWith('/tasks/create')
        ),
        _navButton(
            context,
            "Create Task",
            '/tasks/create',
            isActive: location.startsWith('/tasks/create')
        ),
      ],
    );
  }

  Widget _navButton(BuildContext context, String title, String path, {required bool isActive}) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      onTap: () => context.go(path),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? cs.primary.withAlpha(theme.brightness == Brightness.light ? 20 : 40)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? cs.primary.withAlpha(80) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? cs.primary : cs.onSurface.withAlpha(180),
            fontSize: 16, // Jemne zmenšené z 19 pre lepší balans
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// --- PROFIL PRIHLÁSENÉHO POUŽÍVATEĽA (UPRAVENÉ) ---
class _UserAccountSection extends ConsumerWidget {
  final dynamic user;
  const _UserAccountSection({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              user.name ?? "",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              user.email ?? "",
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        // Elegantný Avatar namiesto bordera
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.blueAccent.withAlpha(40),
          child: Text(
            (user.name ?? "U").substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: Icon(Icons.logout_rounded, color: colorScheme.onSurfaceVariant, size: 20),
          tooltip: 'Logout',
          onPressed: () => ref.read(authProvider.notifier).signOut(),
        ),
      ],
    );
  }
}

// --- LOGIN (Nezmenené) ---
class _LoginButtonSection extends ConsumerWidget {
  const _LoginButtonSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () => ref.read(authProvider.notifier).signInWithGoogle(),
      icon: const Icon(Icons.login, size: 18),
      label: Text(context.l10n.login),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blueAccent,
        side: const BorderSide(color: Colors.blueAccent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

// --- PREPÍNAČ JAZYKA (Nezmenené) ---
class _LanguageSwitch extends ConsumerWidget {
  const _LanguageSwitch();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language, color: Colors.blueAccent),
      onSelected: (locale) => ref.read(localeProvider.notifier).setLocale(locale),
      itemBuilder: (context) => [
        const PopupMenuItem(value: Locale('sk', 'SK'), child: Text("Slovenčina")),
        const PopupMenuItem(value: Locale('en', 'US'), child: Text("English")),
      ],
    );
  }
}