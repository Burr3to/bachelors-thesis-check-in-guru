import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/features/auth/views/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';

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
      // Používame surface farbu z témy (v light biela, v dark tmavošedá/čierna)
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
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
              // Riverpod 3 Notifier syntax:
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

// --- LOGO ---
class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/app/tasks'),
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
                // onSurface sa automaticky zmení na bielu v dark móde
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

// --- NAVIGÁCIA (Tvoje modré ciary) ---
class _NavigationSection extends StatelessWidget {
  const _NavigationSection();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _verticalDivider(),
          _navButton(context, "Introduction", '/welcome'),
          _verticalDivider(),
          _navButton(context, "My Tasks", '/tasks'),
          _verticalDivider(),
          _navButton(context, "Shared with me", '/shared'),
          _verticalDivider(),
          //_navButton(context, "Create", '/tasks/create'),
          //_verticalDivider(),
        ],
      ),
    );
  }

  Widget _verticalDivider() =>
      Container(width: 1.5, color: Colors.blueAccent.withAlpha(123), height: 32);

  Widget _navButton(BuildContext context, String title, String path) {
    return TextButton(
      onPressed: () => context.go(path),
      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16)),
      child: Text(
        title,
        style: TextStyle(
          // Kľúčové: onSurface namiesto Colors.black
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}

// --- PROFIL PRIHLÁSENÉHO POUŽÍVATEĽA ---
class _UserAccountSection extends ConsumerWidget {
  final dynamic user;
  const _UserAccountSection({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        // Požiadavka: Modrý border
        border: Border.all(color: Colors.blueAccent.withAlpha(125), width: 2),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
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
                  color: colorScheme.onSurface, // Biely v dark, čierny v light
                ),
              ),
              Text(
                user.email ?? "",
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant, // Jemnejší text, viditeľný v oboch módoch
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => ref.read(authProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}

// --- TLAČIDLO PRIHLÁSIŤ ---
class _LoginButtonSection extends ConsumerWidget {
  const _LoginButtonSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () => ref.read(authProvider.notifier).signInWithGoogle(),
      icon: const Icon(Icons.login, size: 18),
      label: const Text("Login"),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blueAccent,
        side: const BorderSide(color: Colors.blueAccent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

// --- PREPÍNAČ JAZYKA ---
class _LanguageSwitch extends ConsumerWidget {
  const _LanguageSwitch();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language, color: Colors.blueAccent),
      onSelected: (locale) => ref.read(localeProvider.notifier).setLocale(locale),
      itemBuilder: (context) => [
        const PopupMenuItem(value: Locale('sk', 'SK'), child: Text("🇸🇰 Slovenčina")),
        const PopupMenuItem(value: Locale('en', 'US'), child: Text("🇺🇸 English")),
      ],
    );
  }
}