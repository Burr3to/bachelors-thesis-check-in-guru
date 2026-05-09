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
    final isMobile = screenWidth < 800;

    return AppBar(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 3,
      automaticallyImplyLeading: isMobile,
      // Vynulujeme defaultný padding na mobile, aby sme získali viac miesta
      titleSpacing: isMobile ? 0 : NavigationToolbar.kMiddleSpacing,

      // 1. TITLE: Obsahuje len Logo na mobile, alebo Logo + Navigáciu na webe
      title: isMobile
          ? _LogoSection(isMobile: true)
          : Row(
        children:[
          const _LogoSection(isMobile: false),
          const Spacer(),
          const _NavigationSection(),
          const Spacer(),
        ],
      ),

      // 2. ACTIONS: Ikonky, ktoré sa automaticky pricapnú úplne napravo
      actions:[
        if (!isMobile) const _LanguageSwitch(),

        IconButton(
          icon: Icon(
            ref.watch(themeProvider) == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
            color: Colors.blueAccent,
            size: isMobile ? 22 : 24,
          ),
          padding: EdgeInsets.all(isMobile ? 8 : 12),
          constraints: const BoxConstraints(), // Zruší defaultné obrovské okraje
          onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
        ),

        SizedBox(width: isMobile ? 4 : 8),

        _UserAccountSection(isMobile: isMobile),

        SizedBox(width: isMobile ? 8 : 16),
      ],
    );
  }
}

// --- LOGO (S opraveným orezávaním) ---
class _LogoSection extends StatelessWidget {
  final bool isMobile;
  const _LogoSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/tasks'),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 4 : 8,
            vertical: 8
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children:[
            Icon(
                Icons.check_circle_outline_rounded,
                size: isMobile ? 24 : 32,
                color: Colors.blueAccent
            ),
            SizedBox(width: isMobile ? 6 : 10),
            // FLEXIBLE ZAISTÍ, ŽE SA TEXT ODREŽE IBA AK UŽ NAOZAJ NIE JE KAM UHnúŤ
            Flexible(
              child: Text(
                'CheckInGuru',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  // Vrátil som 18px pre mobil, pretože teraz tam máme vďaka správnemu layoutu miesto!
                  fontSize: isMobile ? 18 : 20,
                ),
                overflow: TextOverflow.ellipsis,
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
      children:[
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
            fontSize: 16,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// --- PROFIL PRIHLÁSENÉHO POUŽÍVATEĽA (Nezmenené z predošlej úpravy) ---
class _UserAccountSection extends ConsumerWidget {
  final bool isMobile;
  const _UserAccountSection({required this.isMobile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    if (user == null) {
      return _LoginButtonSection(isMobile: isMobile);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children:[
        if (!isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children:[
              Text(user.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              Text(user.email, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        if (!isMobile) const SizedBox(width: 10),

        InkWell(
          onTap: isMobile ? () => ref.read(authProvider.notifier).signOut() : null,
          borderRadius: BorderRadius.circular(16),
          child: CircleAvatar(
            radius: isMobile ? 14 : 16,
            backgroundColor: Colors.blueAccent.withAlpha(40),
            child: Text(
                (user.name)[0].toUpperCase(),
                style: TextStyle(fontSize: isMobile ? 10 : 12, color: Colors.blueAccent)
            ),
          ),
        ),

        if (!isMobile)
          IconButton(
            icon: const Icon(Icons.logout, size: 18),
            onPressed: () => ref.read(authProvider.notifier).signOut(),
          ),
      ],
    );
  }
}

// --- LOGIN (Nezmenené z predošlej úpravy) ---
class _LoginButtonSection extends ConsumerWidget {
  final bool isMobile;
  const _LoginButtonSection({required this.isMobile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isMobile) {
      return IconButton(
        onPressed: () => ref.read(authProvider.notifier).signInWithGoogle(),
        icon: const Icon(Icons.login, color: Colors.blueAccent, size: 22),
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
      );
    }

    return OutlinedButton.icon(
      onPressed: () => ref.read(authProvider.notifier).signInWithGoogle(),
      icon: const Icon(Icons.login, size: 18),
      label: Text(context.l10n.login),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blueAccent,
        side: const BorderSide(color: Colors.blueAccent),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      itemBuilder: (context) =>[
        const PopupMenuItem(value: Locale('sk', 'SK'), child: Text("Slovenčina")),
        const PopupMenuItem(value: Locale('en', 'US'), child: Text("English")),
      ],
    );
  }
}