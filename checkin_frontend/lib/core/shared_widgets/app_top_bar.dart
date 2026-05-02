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
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800; // Breakpoint pre mobil/tablet

    return AppBar(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 3,
      // Na mobile ukážeme leading (hamburger), na webe ho vypneme
      automaticallyImplyLeading: isMobile,
      title: Row(
        children: [
          const _LogoSection(),
          if (!isMobile) ...[
            const Spacer(),
            const _NavigationSection(),
            const Spacer(),
          ] else
            const Spacer(), // Na mobile len odtlačíme ikony doprava

          // JAZYK (na mobile ho môžeme nechať alebo schovať do Draweru)
          if (!isMobile) const _LanguageSwitch(),

          // THEME SWITCH
          IconButton(
            icon: Icon(
              ref.watch(themeProvider) == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
              color: Colors.blueAccent,
            ),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),

          const SizedBox(width: 8),

          // PROFIL (na mobile zjednodušený)
          _UserAccountSection(isMobile: isMobile),
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
  final bool isMobile;
  const _UserAccountSection({required this.isMobile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    if (user == null) return const _LoginButtonSection();

    return Row(
      children: [
        if (!isMobile) // Meno a email ukážeme len na desktope
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(user.name ?? "", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              Text(user.email ?? "", style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        const SizedBox(width: 10),
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.blueAccent.withAlpha(40),
          child: Text((user.name ?? "U")[0].toUpperCase(), style: const TextStyle(fontSize: 12, color: Colors.blueAccent)),
        ),
        if (!isMobile) // Logout tlačidlo priamo v bare len na desktope
          IconButton(
            icon: const Icon(Icons.logout, size: 18),
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