import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/shared_widgets/autoplay_video.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Tieto farby teraz ťaháme z témy
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final primaryBlue = colorScheme.primary;
    // Použijeme surfaceContainer pre jemne sivé/tmavé sekcie
    final secondaryBg = colorScheme.surfaceContainer;
    const double maxContentWidth = 1150;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HERO SEKCIA ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primaryBlue.withAlpha(theme.brightness == Brightness.light ? 12 : 30),
                    colorScheme.surface,
                  ],
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxContentWidth),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 110, horizontal: 40),
                    child: Column(
                      children: [
                        // Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: primaryBlue.withAlpha(25),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            "Independent • Collaborative • Public • Private",
                            style: TextStyle(
                              color: primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          "Smart Checklists.\nFrictionless Responses.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 62,
                            fontWeight: FontWeight.bold,
                            height: 1.05,
                            letterSpacing: -1.5,
                            color: colorScheme.onSurface, // Automaticky biela/čierna
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          "The professional way to collect data. You build the task,\nthey complete it in seconds—no registration required for respondents.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            color: colorScheme.onSurfaceVariant, // Jemnejšia farba textu
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 48),
                        ElevatedButton(
                          onPressed: () => context.go('/login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 26),
                            elevation: 8,
                            shadowColor: primaryBlue.withAlpha(100),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text("Create Your First Task", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // SEKCIA 1
            _buildFeatureSection(
              context: context,
              maxWidth: maxContentWidth,
              title: "Two Modes. Infinite Control.",
              description: _styledDescription(
                context,
                "Choose **Collaborative** for shared team goals where everyone works together, or **Independent** to give every respondent their own private copy of the checklist.",
                primaryBlue,
              ),
              videoAsset: 'assets/videos/AutorCreate.webm',
              isReversed: false,
            ),

            // SEKCIA 2 (so šedým/tmavým pozadím)
            _buildFeatureSection(
              context: context,
              maxWidth: maxContentWidth,
              backgroundColor: secondaryBg,
              title: "Participation Made Simple.",
              description: _styledDescription(
                context,
                "Respondents join via a simple URL. For public tasks, **no login is required**—they just type their name and start. Fast, direct, and effective.",
                primaryBlue,
              ),
              videoAsset: 'assets/videos/Respondent.webm',
              isReversed: true,
            ),

            // SEKCIA 3
            _buildFeatureSection(
              context: context,
              maxWidth: maxContentWidth,
              title: "Your Data, Your Rules.",
              description: _styledDescription(
                context,
                "Need verified responses? Switch to **Private Mode** to require authentication. Want maximum reach? Use **Public Mode** for instant access without barriers.",
                primaryBlue,
              ),
              videoAsset: 'assets/videos/AutorOverview.webm',
              isReversed: false,
            ),

            // --- FOOTER ---
            // Footer býva často tmavý aj v light móde, ale v dark ho zladíme
            Container(
              padding: const EdgeInsets.symmetric(vertical: 80),
              width: double.infinity,
              color: theme.brightness == Brightness.light
                  ? const Color(0xFF1A1F36)
                  : Colors.black, // V dark móde úplne čierny
              child: Center(
                child: Column(
                  children: [
                    const Text(
                      "CheckIn",
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1),
                    ),
                    const SizedBox(height: 20),
                    Container(height: 2, width: 40, color: primaryBlue),
                    const SizedBox(height: 20),
                    const Text(
                      "The efficient way to manage Tasks.",
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      "© 2026 CheckIn • Powered by Flutter Web",
                      style: TextStyle(color: Colors.white24, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSection({
    required BuildContext context,
    required double maxWidth,
    required String title,
    required Widget description,
    required String videoAsset,
    required bool isReversed,
    Color? backgroundColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryBlue = colorScheme.primary;

    final textColumn = Expanded(
      flex: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectionArea(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                letterSpacing: -1.5,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SelectionArea(child: description),
          const SizedBox(height: 32),
          Row(
            children: [
              Icon(Icons.check_circle, color: primaryBlue, size: 20),
              const SizedBox(width: 10),
              Text(
                "Ready in seconds",
                style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
              ),
            ],
          ),
        ],
      ),
    );

    final videoColumn = Expanded(
      flex: 6,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: primaryBlue.withAlpha(25), width: 1),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withAlpha(themeBrightness(context) == Brightness.light ? 32 : 10),
              blurRadius: 50,
              offset: const Offset(0, 25),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Transform.scale(
          scale: 1.03,
          child: AutoplayVideo(assetPath: videoAsset),
        ),
      ),
    );

    return Container(
      color: backgroundColor ?? colorScheme.surface,
      width: double.infinity,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
            child: Row(
              children: [
                if (isReversed) videoColumn else textColumn,
                const SizedBox(width: 80),
                if (isReversed) textColumn else videoColumn,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _styledDescription(BuildContext context, String text, Color accentColor) {
    final parts = text.split('**');
    final colorScheme = Theme.of(context).colorScheme;

    return Text.rich(
      TextSpan(
        style: TextStyle(fontSize: 20, color: colorScheme.onSurfaceVariant, height: 1.6),
        children: parts.asMap().entries.map((entry) {
          final isBold = entry.key % 2 != 0;
          return TextSpan(
            text: entry.value,
            style: isBold ? TextStyle(color: accentColor, fontWeight: FontWeight.bold) : null,
          );
        }).toList(),
      ),
    );
  }

  Brightness themeBrightness(BuildContext context) => Theme.of(context).brightness;
}